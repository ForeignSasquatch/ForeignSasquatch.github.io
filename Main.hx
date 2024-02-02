/*
    NOTE: I do not remember how this works :p (feb 2024)
*/
import haxe.Template;
import sys.FileSystem;
import sys.io.File;

using StringTools;

typedef Card = {
	heading:String,
	time:String,
	quote:String,
	desc:String,
	link:String
}

typedef Post = {
	stuff:String
}

var template = "
<div class='card'>
  <h2>::heading::</h2>
  <hr>
  <h5>::time:: || ::quote::</h5>
  <p> ::desc:: </p>
  <a href='::link::'> [Read] </a>
</div>
";
var hml = "
<meta name='viewport' content='width=device-width, initial-scale=1.0'> 
<head>
  <link rel='stylesheet' href='index.css'>
</head>

<div class='header'>
  <h1> Grotte étrangère </h1>
  <a href='https://www.github.com/foreignsasquatch'> [github] </a>
  <a href='https://www.twitter.com/ratkrisp'> [twitter] </a>
  </div>
<div class='content'>
  <h1> Posts </h1>
  {{post}}
</div>
";
var po = "
<meta name='viewport' content='width=device-width, initial-scale=1.0'> 
<head>
  <link rel='stylesheet' href='../index.css'>
</head>

<div class='posts'>
<a href='../index.html'> [Back] </a>
::stuff::
</div>
";
var filenams:Array<String> = [];
var filemap:Map<String, String> = [];
var html:Array<String> = [];

function main() {
	var files:Array<String> = [];
	for (file in FileSystem.readDirectory("page")) {
		if (!FileSystem.isDirectory("page/" + file)) {
			filenams.push(file);
			files.push(File.getContent("page/" + file));
			filemap.set(File.getContent("page/" + file), file);
		}
	}

	for (f in filenams) {
		var fe = "static/" + f.replace("md", "html");
		File.saveContent(fe, "");
		html.push(fe);
	}

	save(files);
	gen(html);
}

function gen(f:Array<String>) {
	var filenames:Map<String, String> = [];

	for (file in FileSystem.readDirectory("page")) {
		if (!FileSystem.isDirectory("page/" + file)) {
			filenames.set(file, File.getContent("page/" + file));
		}
	}

	for (fe in f) {
		var htmlfile = File.getContent(fe);
		htmlfile = po;
		var mds = filenames.get(fe.split("/")[1].replace("html", "md"));
		var md = mds.split("^")[1];

		var ht = Markdown.markdownToHtml(md);
		var s:Post = {
			stuff: ht
		};
		var te = new Template(po);
		var o = te.execute(s);

		File.saveContent(fe, o);
	}
}

function save(files:Array<String>) {
	var out = "";
	var arr:Array<String> = [];

	for (f in files) {
		var stuff = f.split("\n");
		var t:Map<String, String> = [];
		for (s in stuff)
			t.set(s.split(":")[0], s.split(":")[1]);

		var fil = filemap.get(f).replace("md", "html");
		var c:Card = {
			heading: t.get("heading"),
			time: t.get("time"),
			quote: t.get("quote"),
			desc: t.get("desc"),
			link: "static/" + fil
		};

		var te = new Template(template);
		var o = te.execute(c);

		arr.push(o);
	}

	var ss = "";
	for (a in arr) {
		ss += a;
	}
	out = hml;
	out = out.replace("{{post}}", ss);
	File.saveContent("index.html", out);
}
