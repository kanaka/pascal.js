
function StdLib (st) {
  var vcnt = 0;

  function __init__() {
    var ir = [];
    ir.push("declare i32 @printf(i8*, ...)");
    ir.push("");
    ir.push('@.newline = private constant [2 x i8] c"\\0A\\00"');
    ir.push('@.true_str = private constant [5 x i8] c"TRUE\\00"');
    ir.push('@.false_str = private constant [6 x i8] c"FALSE\\00"');
    ir.push('@.str_format = private constant [3 x i8] c"%s\\00"');
    ir.push('@.chr_format = private constant [3 x i8] c"%c\\00"');
    ir.push('@.int_format = private constant [3 x i8] c"%d\\00"');
    ir.push('@.float_format = private constant [4 x i8] c"% E\\00"');
    return ir;
  }

  function WRITE (ast, cparams) {
    var ir = [];
    ir.push('  ; WRITE start');
    for(var i=0; i < cparams.length; i++) {
      var param = cparams[i],
          v = vcnt++,
          format = null,
          flen = 3;
      switch (param.type.name) {
        case 'INTEGER':   format = "@.int_format"; break;
        case 'STRING':    format = "@.str_format"; break;
        case 'CHARACTER': format = "@.chr_format"; break;
        case 'REAL':
          var conv = '%conv_' + v;
          ir.push('  ' + conv + ' = fpext float ' + param.ilocal + ' to double');
          format = "@.float_format";
          flen = 4;
          param.itype = "double";
          param.ilocal = conv;
          break;
        case 'BOOLEAN':
          var br_name = 'br' + v,
              br_true = br_name + '_true',
              br_false = br_name + '_false',
              br_done = br_name + '_done',
              bool_local1 = '%bool_local' + v + '_1',
              bool_local2 = '%bool_local' + v + '_2',
              bool_local_out = '%bool_local' + v + '_out';
          ir.push('  br ' + param.itype + ' ' + param.ilocal + ', label %' + br_true + ', label %' + br_false);
          ir.push('  ' + br_true + ':');
          ir.push('    ' + bool_local1 + ' = getelementptr [5 x i8]* @.true_str, i32 0, i32 0');
          ir.push('  br label %' + br_done);
          ir.push('  ' + br_false + ':');
          ir.push('    ' + bool_local2 + ' = getelementptr [6 x i8]* @.false_str, i32 0, i32 0');
          ir.push('  br label %' + br_done);
          ir.push('  ' + br_done + ':');
          ir.push('  ' + bool_local_out + ' = phi i8* [ ' + bool_local1 + ', %' + br_true + '], [ ' + bool_local2 + ', %' + br_false + ']');
          format = "@.str_format";
          param.itype = 'i8*';
          param.ilocal = bool_local_out;
          break;
        default:
          throw new Error("Unknown WRITE type: " + param.type.name);
      }
      ir.push('  %str' + v + ' = getelementptr inbounds [' + flen + ' x i8]* ' + format + ', i32 0, i32 0');
      ir.push('  %call' + v + ' = call i32 (i8*, ...)* @printf(i8* %str' + v + ', ' +
                param.itype + ' ' + param.ilocal + ')');
    }
    ir.push('  ; WRITE finish');
    return ir;
  }

  function WRITELN (ast, cparams) {
    var ir = [];
    ir.push.apply(ir, WRITE(ast, cparams));
    v = vcnt++;
    ir.push('  ; WRITELN start');
    ir.push('  %str' + v + ' = getelementptr inbounds [2 x i8]* @.newline, i32 0, i32 0');
    ir.push('  %call' + v + ' = call i32 (i8*, ...)* @printf(i8* %str' + v + ')');
    ir.push('  ; WRITELN finish');
    return ir;
  }

  function CHR (ast, cparams) {
    var ir = [], clen = cparams.length,
        cparam = cparams[0],
        lname = "%char" + vcnt++;
    if (clen !== 1) {
      throw new Error("Chr only accepts one argument (" + clen + " given)");
    }
    ir.push('  ; CHR start');
    ir.push('  ' + lname + ' = trunc ' + cparam.itype + ' ' + cparam.ilocal + ' to i8');
    ir.push('  ; CHR finish');
    ast.type = {node:'type',name:'CHARACTER'};
    ast.itype = 'i8';
    ast.ilocal = lname;
    return ir;
  }

  return {__init__: __init__,
          WRITE:WRITE,
          WRITELN:WRITELN,
          CHR: CHR};
};

exports.StdLib = StdLib;
