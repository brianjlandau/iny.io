doFile("extensions.io")
doFile("url_regex.io")

portNumber := System getOptions(System args)["port"]

doFile("UrlModel.io")

shortened_template := File @read("shortened.html")
error_html := File @read("error.html")

doFile("InyIoServer.io")

if (System args contains("-d")) then (
   File with("inyio.pid") remove
   pidFile := File with("inyio.pid") open
   pidFile write(System thisProcessPid asString)
   pidFile close
   # System daemon(true, false) # This causes an exception right now
)

InyIoServer start
