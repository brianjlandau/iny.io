doFile("extensions.io")
doFile("url_regex.io")

portNumber := System getOptions(System args)["port"]

doFile("UrlModel.io")

shortened_template := readFile("shortened.html")
error_html := readFile("error.html")

doFile("InyIoServer.io")

InyIoServer start
