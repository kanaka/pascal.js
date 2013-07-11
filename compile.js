var fs = require('fs'),
    path = require('path');

function Compiler() {
  var vm = require('vm'),
      Parse = require('./parse'),
      IR = require('./ir.js'),
      llcode = null,
      llvm_path = path.resolve('./llvm.js');
 
  // Hacks to load the llvm.js compiler directly
  llcode = fs.readFileSync('./llvm.js/compiler.js', "utf8");
  var init_ctx = {process: {cwd: process.cwd,
                            argv: [],
                            stdout: {write: function(x) {}},
                            stderr: {write: function(x) {}}},
                  require: require,
                  __dirname: llvm_path},
      llcompiler = vm.createContext(init_ctx);

  vm.runInContext(llcode, llcompiler);


  function compileJS(source) {
    var ast = Parse.parser.parse(source),
        ir = IR.toIR(ast),
        out = "";
    llcompiler.process.stdout.write = function(x) { out += x; };
    llcompiler.compile(ir);
    return out;
  }

  return {compileJS: compileJS};
}

if (typeof module !== 'undefined') {
  exports.Compiler = Compiler;

  exports.main = function commonjsMain(args) {
    if (!args[1]) {
        console.log('Usage: '+args[0]+' SOURCE_FILE [OUTFILE]');
        process.exit(1);
    }
    var infile = path.resolve(args[1]),
        outfile = args[2] || 'a.out.js',
        source = fs.readFileSync(infile, "utf8"),
        compiler = new Compiler(),
        js = compiler.compileJS(source);
    fs.writeFileSync(outfile, js);
  }
  if (require.main === module) {
    exports.main(process.argv.slice(1));
  }
}

// vim: expandtab:ts=2:sw=2:syntax=javascript
