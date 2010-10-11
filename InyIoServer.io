InyIoServer := HttpServer clone do (
   setPort((portNumber || 8080) asNumber)
   
   shortenUrl := method(request,
      token := UrlModel create(request parameters["url"])
		shortened_url := "http://" .. request headers["HOST"] .. "/" .. token
		redisConnection @@incr("shortened")
		return shortened_url
   )
   
   isValidUrl := method(url,
      regexError != nil or url matchesOfRegex(url_regex) all size > 0
   )
   
   isShorenRequest := method(request,
      request parameters["url"] and (request path split("/")[1] == "shorten" or request path split("/")[1] == "shorten-api")
   )
   
   shortenAction := method(request, response,
      if (isValidUrl(request parameters["url"])) then (
		   shortened_url := shortenUrl(request)
		   response addHeader("Content-type", "text/html")
		   response body appendSeq(shortened_template interpolate)
		) else (
		   errorResponse(response)
		)
   )
   
   shortenApiAction := method(request, response,
      if (isValidUrl(request parameters["url"])) then (
		   shortened_url := shortenUrl(request)
		   response addHeader("Content-type", "text/plain")
		   response addHeader("Location", shortened_url)
		   response body appendSeq(shortened_url)
		) else (
		   errorResponse(response)
		)
   )
   
   redirectAction := method(request, response,
      token := request path split("/")[1]
		redirectUrl := UrlModel find(token)
		redisConnection @@incr(redirectUrl .. "-redirect-counter")
		if (redirectUrl,
			response addHeader("Location", redirectUrl)
			response setStatusCode(301)
		)
   )
   
   errorResponse := method(response,
      response addHeader("Content-type", "text/html")
      response setStatusCode(500)
	   response body appendSeq(error_html)
   )
   
   renderResponse := method(request, response,
      if (request path split("/")[1] and request path split("/")[1] != "") then (
         if (isShorenRequest(request)) then (
            if (request path split("/")[1] == "shorten") then (
   			   shortenAction(request, response)
   			) elseif (request path split("/")[1] == "shorten-api") then (
   			   shortenApiAction(request, response)
   			)
         ) else (
            redirectAction(request, response)
         )
      )
	)
)
