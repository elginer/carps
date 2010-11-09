require "rdoc/markup/to_html"

task :readme_site do
   h = RDoc::Markup::ToHtml.new
   body = h.convert(File.read("README.rdoc"))
   # Just hack out the beginning and end...
   doc = <<-END
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<title>CARPS #{CARPS::VERSION}</title>
<style type="text/css">
body
{
font-family:"DejaVu Sans", "Arial";
}
</style>
</head>
<body>
#{body}
</body>
</html>
END
   web = File.open "website/index.html", "w"
   web.write doc
   web.close
end
