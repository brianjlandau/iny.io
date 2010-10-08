doFile("Iodis.io")

redisConnection := Iodis clone connect

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
	renderResponse := method(request, response,
		if (request parameters at("url")) then (
			url := request  parameters at("url")
			token := UrlModel create(url)
			response body appendSeq("http://iny.io/" .. token)
		) elseif (request path split("/") at (1) != "") then (
			token := request path split("/") at (1)
			redirectUrl := UrlModel find(token)
			if (redirectUrl,
				response addHeader("Location", redirectUrl)
				response setStatusCode(301)
			)
		)
	)
)

InyIoServer start
