InyIoServer := HttpServer clone do (
   setPort((portNumber || 8080) asNumber)
   
   shortenUrl := method(request,
      token := UrlModel create(request parameters["url"])
      shortened_url := "http://" .. request headers["HOST"] .. "/" .. token
      InyioRedisConnection getConnection @incr("shortened")
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
       response body appendSeq(base_template render("Shortened URL", shortened_template interpolate))
     ) else (
       invalidResponse(response)
     )
   )
   
   shortenApiAction := method(request, response,
     if (isValidUrl(request parameters["url"])) then (
       shortened_url := shortenUrl(request)
       response addHeader("Content-type", "text/plain")
       response addHeader("Location", shortened_url)
       response body appendSeq(shortened_url)
     ) else (
       invalidResponse(response)
     )
   )
   
   redirectAction := method(request, response,
      token := request path split("/")[1]
      redirectUrl := UrlModel find(token)
      if (redirectUrl) then (
        InyioRedisConnection getConnection @incr(redirectUrl .. "-redirect-counter")
        response addHeader("Location", redirectUrl)
        response setStatusCode(301)
      ) else (
        notFoundResponse(response)
      )
   )
   
   invalidResponse := method(response,
      response addHeader("Content-type", "text/html")
      response setStatusCode(422)
      response body appendSeq(base_template render("Inavlid URL", invalid_error_html))
   )
   
   errorResponse := method(response,
      response addHeader("Content-type", "text/html")
      response setStatusCode(500)
      response body appendSeq(base_template render("ERROR", "<p>Something has gone wrong and we are looking into it.</p>"))
   )
   
   notFoundResponse := method(response,
      response addHeader("Content-type", "text/html")
      response setStatusCode(404)
      response body appendSeq(base_template render("Not Found 404", "<p>The page you are looking for can not be found.</p>"))
   )
   
   indexAction := method(response,
      response addHeader("Content-type", "text/html")
      response body appendSeq(index_html)
   )
   
   renderResponse := method(request, response,
      exception := try (
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
        ) else (
          indexAction(response)
        )
      )
      if (exception) then (
        errorResponse(response)
      )
  )
)
