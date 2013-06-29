function Compiler() {

  function compile(source, callback) {
    var ast = Parse.parser.parse(source),
        ir = IR.toIR(ast),
        child;
    child = exec('llc -', function(error, stdout, stderr) {
      if (error !== null) {
        throw new Error("Errors during compilation:\n" + stderr);
      } 
      callback(stdout);
    });
    child.stdin.write(ir);
    child.stdin.end();
  }

  function assemble(source, outfile) {
    var child;
    child = exec('gcc -x assembler -o ' + outfile + ' -', function(error, stdout, stderr) {
      if (error !== null) {
        throw new Error("Errors during assembly:\n" + stderr);
      }
    });
    child.stdin.write(source);
    child.stdin.end();
  }

  return {compile:compile,
          assemble:assemble};
}

if (typeof module !== 'undefined') {
  var fs = require('fs'),
      path = require('path'),
      Parse = require('./parse'),
      IR = require('./ir.js'),
      exec = require('child_process').exec;

  exports.Compiler = Compiler;

  exports.main = function commonjsMain(args) {
    if (!args[1]) {
        console.log('Usage: '+args[0]+' SOURCE_FILE [OUTFILE]');
        process.exit(1);
    }
    var infile = args[1],
        outfile = args[2] || 'a.out',
        source = fs.readFileSync(path.normalize(infile), "utf8"),
        compiler = new Compiler();
    compiler.compile(source, function (assembly) {
      compiler.assemble(assembly, outfile);
    });
  }
  if (require.main === module) {
    exports.main(process.argv.slice(1));
  }
}

// vim: expandtab:ts=2:sw=2:syntax=javascript
