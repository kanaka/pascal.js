var LLC = "llc",
    fs = require('fs'),
    path = require('path'),
    exec = require('child_process').exec;

function Compiler() {

  function compile(infile, callback) {
    var Parse = require('./parse'),
        IR = require('./ir.js'),
        source = fs.readFileSync(infile, "utf8"),
        ast = Parse.parser.parse(source),
        ir = IR.toIR(ast),
        child;
    child = exec(LLC + ' -', function(error, stdout, stderr) {
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
    child = exec('gcc -g -x assembler -o ' + outfile + ' -', function(error, stdout, stderr) {
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
  exports.Compiler = Compiler;

  exports.main = function commonjsMain(args) {
    if (!args[1]) {
        console.log('Usage: '+args[0]+' SOURCE_FILE [OUTFILE]');
        process.exit(1);
    }
    var infile = path.normalize(args[1]),
        outfile = args[2] || 'a.out',
        compiler = new Compiler();
    compiler.compile(infile, function (assembly) {
      compiler.assemble(assembly, outfile);
    });
  }
  if (require.main === module) {
    exports.main(process.argv.slice(1));
  }
}

// vim: expandtab:ts=2:sw=2:syntax=javascript
