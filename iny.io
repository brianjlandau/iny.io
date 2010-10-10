doFile("Iodis.io")
doFile("extensions.io")

portNumber := System getOptions(System args)["port"]

redisConnection := Iodis clone connect

shortened_template_file := File clone openForReading("shortened.html")
shortened_template := shortened_template_file readToEnd
shortened_template_file close
shortened_template_file = nil

UrlModel := Object clone do (
	characters := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
	tokenLength := 5
	
	find := method(token,
		return redisConnection get(token)
	)
	
	create := method(url,
		if (redisConnection exists(url)) then (
			return redisConnection get(url)
		) else (
			token := generateToken
			while (redisConnection exists(token),
				token = generateToken
			)
			redisConnection @set(token, url)
			redisConnection @set(url, token)
			return token
		)
	)
	
	generateToken := method(
		token := Sequence clone
		tokenLength repeat(
			token = token appendSeq(characters at(Random value(characters size) round) asCharacter)
		)
		return token
	)
)

InyIoServer := HttpServer clone do (
   setPort((portNumber || 8080) asNumber)
   
   renderResponse := method(request, response,
		if (request path split("/")[1] != "") then (
		   if (request parameters["url"]) then (
   			url := request  parameters["url"]
   			token := UrlModel create(url)
   			shortened_url := "http://" .. request headers["HOST"] .. "/" .. token
   			redisConnection @incr("shortened")
   			if (request path split("/")[1] == "shorten") then (
   			   response addHeader("Content-type", "text/html")
   			   response body appendSeq(shortened_template interpolate)
   			) elseif (request path split("/")[1] == "shorten-api") then (
   			   response addHeader("Content-type", "text/plain")
   			   response addHeader("Location", shortened_url)
   			   response body appendSeq(shortened_url)
   			)
   		) else (
   		   token := request path split("/")[1]
   			redirectUrl := UrlModel find(token)
   			redisConnection @incr(redirectUrl .. "-redirect-counter")
   			if (redirectUrl,
   				response addHeader("Location", redirectUrl)
   				response setStatusCode(301)
   			)
   		)
		)
	)
)

InyIoServer start
