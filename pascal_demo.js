function loadSourceFile(path) {
  var req = new XMLHttpRequest();
  req.onload = function() {
      var src = document.getElementById('the_source');
      console.warn(req.responseText);
      src.innerHTML = req.responseText;
  }
  req.open("get", path);
  req.send();
}

var exampleFiles = {"Hello World":       "examples/hello.pas",
                    "Fibonacci":         "tests/ffib.pas",
                    "Quick Sort":        "tests/qsort.pas",
                    "Nested Scope":      "tests/nested4.pas",
                    "Hailstone Numbers": "examples/hailstone.pas",
                    "JS Alert":          "examples/js_alert.pas",
                    "JS Callback":       "examples/js_callback.pas"};
var sel = document.getElementById('source_file');

for (var k in exampleFiles) {
  var opt = document.createElement('option');
  opt.value = exampleFiles[k];
  opt.innerHTML = k;
  sel.appendChild(opt);
}

sel.onchange = function() { loadSourceFile(sel.value); };
loadSourceFile("examples/hello.pas");

// emscripten workarounds
arguments = [];

var Module = {};

// Keep LLVM.js from triggering browser print dialog
print = function () { };

// Monkey patch XMLHttpRequest open to be relative to XHR_PREFIX
(function(xhr) {
  var orig_open = xhr.open;
  xhr.open = function(method, url) {
      var rest = Array.prototype.slice.apply(arguments).slice(2);
      if (window.XHR_PREFIX && url.substr(0,4).toLowerCase() !== "http") {
        url = XHR_PREFIX + url;
      }
      return orig_open.apply(this, [method, url].concat(rest));
  };
})(XMLHttpRequest.prototype);

var XHR_PREFIX = ""

function doParse(src, dst) {
  var source = document.getElementById(src).value,
      outElem = document.getElementById(dst),
      parser = new parse.Parser(),
      ast = null;
  try {
    ast = parser.parse(source);
    outElem.style.backgroundColor = '#eeffee';
    outElem.value = JSON.stringify(ast,null,4);
  } catch (e) {
    outElem.style.backgroundColor = '#ffe0e0';
    outElem.value = 'Error in parsing: ' + e; // error message
    throw e;
  }
}

function doIR(src, dst) {
  var json_ast = document.getElementById(src).value,
      ast = JSON.parse(json_ast),
      outElem = document.getElementById(dst),
      IR_API = new IR(),
      ir = null;
  XHR_PREFIX = "";
  try {
    ir = IR_API.normalizeIR(IR_API.toIR(ast));
    outElem.style.backgroundColor = '#eeffee';
    outElem.value = ir;
  } catch(e) {
    outElem.style.backgroundColor = '#ffe0e0';
    outElem.value = 'Error compiling to IR: ' + e; // error message
    throw e;
  }
}

function doOptimize(src, dst) {
  XHR_PREFIX = "llvm.js/";
  var ir = document.getElementById(src).value,
      outElem = document.getElementById(dst),
      new_ir = '', js = '';

  try {
    new_ir = llvmDis(llvmAs(ir));
    outElem.style.backgroundColor = '#eeffee';
    outElem.value = new_ir;
  } catch (e) {
    outElem.style.backgroundColor = '#ffe0e0';
    outElem.value = 'Error in compilation: ' + e; // error message
    throw e;
  }
}

function doCompile(src, dst) {
  XHR_PREFIX = "llvm.js/";
  var ir = document.getElementById(src).value,
      outElem = document.getElementById(dst),
      js = '';

  print = function(x) { js += x; };
  try {
    compile(ir);
//    if (js && js[0] === 'E') {
//        throw new Error(js);
//    }
    outElem.style.backgroundColor = '#eeffee';
    outElem.value = js;
  } catch (e) {
    outElem.style.backgroundColor = '#ffe0e0';
    outElem.value = 'Error compiling to JS: ' + e; // error message
    throw e;
  }
}

function doExecute(src, dst) {
  XHR_PREFIX = "";
  var js = document.getElementById(src).value,
      outElem = document.getElementById(dst);
  outElem.value = '';
  Module.print = print = function(x) { outElem.value += x + '\n'; };
  try {
    eval(js);
    outElem.style.backgroundColor = '#eeffee';
  } catch(e) {
    outElem.style.backgroundColor = '#ffe0e0';
    outElem.value = 'Error in execution: ' + e; // error message
    throw e;
  }
}
