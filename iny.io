doFile("extensions.io")
doFile("url_regex.io")

portNumber := System getOptions(System args)["port"]

doFile("UrlModel.io")
doFile("InyTemplates.io")

base_template := InyTemplates clone with("views/layout.html")

shortened_template := File @read("views/shortened.html")
index_html := File @read("public/index.html")
invalid_error_html := File @read("views/invalid.html")

doFile("InyIoServer.io")

if (System args contains("-d")) then (
   File with("inyio.pid") remove
   pidFile := File with("inyio.pid") open
   pidFile write(System thisProcessPid asString)
   pidFile close
   # System daemon(true, false) # This causes an exception right now
)

InyIoServer start
