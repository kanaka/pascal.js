function Library (st) {
  function __init__() {
    var ir = [];
    ir.push(['declare i32 @printf(i8*, ...)']);
    ir.push(['declare double @drand48()']);
    ir.push(['declare i32 @lrand48()']);
    ir.push(['declare void @exit(i32) noreturn nounwind']);
    ir.push(['']);
    ir.push(['%struct._IO_FILE = type { i32, i8* }']);
    ir.push(['@stdout = external global %struct._IO_FILE*']);
    ir.push(['declare i32 @fflush(%struct._IO_FILE*)']);
    ir.push(['']);
    //ir.push(['@.newline = private constant [3 x i8] c"\\0D\\0A\\00"']);
    ir.push(['@.newline = private constant [2 x i8] c"\\0A\\00"']);
    ir.push(['@.true_str = private constant [5 x i8] c"TRUE\\00"']);
    ir.push(['@.false_str = private constant [6 x i8] c"FALSE\\00"']);
    ir.push(['@.str_format = private constant [3 x i8] c"%s\\00"']);
    ir.push(['@.chr_format = private constant [3 x i8] c"%c\\00"']);
    ir.push(['@.int_format = private constant [3 x i8] c"%d\\00"']);
    ir.push(['@.float_format = private constant [4 x i8] c"% E\\00"']);
    return ir;
  }

  function __stop__() {
      return [];
  }

  function CHR (ast, cparams) {
    var ir = [], clen = cparams.length,
        cparam = cparams[0],
        lname = st.new_name('%char');
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

  function HALT(ast, cparams) {
    var ir = [], clen = cparams.length,
        cparam = cparams[0],
        lname = st.new_name('%char');
    if (clen !== 1) {
      throw new Error("HALT only accepts one argument (" + clen + " given)");
    }
    ir.push('  ; HALT start');
    ir.push('  call void @exit(' + cparam.itype + ' ' + cparam.ilocal + ') noreturn nounwind');
    ir.push('  unreachable');
    ir.push('  ; HALT finish');
    return ir;
  }

  function RANDOM (ast, cparams) {
    var ir = [],
        clen = cparams.length, cparam,
        pre = st.new_name('RANDOM'),
        call = '%' + pre + 'call',
        conv = '%' + pre + 'conv';

    ir.push('  ; RANDOM start');
    if (clen === 0) {
        // Return a random Real 0 <= x < 1
        ir.push('  ' + call + ' = call double @drand48()');
        ir.push('  ' + conv + ' = fptrunc double ' + call + ' to float');
        ast.type = {node:'type',name:'REAL'};
        ast.itype = 'float';
        ast.ilocal = conv;
    } else if (clen === 1) {
        // Return a random Integer 0 <= x < Num
        cparam = cparams[0];
        ir.push('  ' + call + ' = call i32 @lrand48()');
        ir.push('  ' + conv + ' = urem i32 ' + call + ', ' + cparam.ilocal);
        ast.type = {node:'type',name:'INTEGER'};
        ast.itype = 'i32';
        ast.ilocal = conv;
    } else {
      throw new Error("Random only accepts one or zero arguments (" + clen + " given)");
    }
    ir.push('  ; RANDOM finish');
    return ir;
  }

  function WRITE (ast, cparams) {
    var ir = [];
    ir.push('  ; WRITE start');
    for(var i=0; i < cparams.length; i++) {
      var param = cparams[i],
          pre = st.new_name('WRITE'),
          str = '%' + pre + 'str',
          sout = '%' + pre + 'sout',
          call1 = '%' + pre + 'call1',
          call2 = '%' + pre + 'call2',
          format = null,
          flen = 3;
      switch (param.type.name) {
        case 'INTEGER':   format = "@.int_format"; break;
        case 'STRING':    format = "@.str_format"; break;
        case 'CHARACTER': format = "@.chr_format"; break;
        case 'REAL':
          var conv = '%' + pre + 'conv';
          ir.push('  ' + conv +
                  ' = fpext float ' + param.ilocal + ' to double');
          format = "@.float_format";
          flen = 4;
          param.itype = "double";
          param.ilocal = conv;
          break;
        case 'BOOLEAN':
          var br_name = pre + 'br',
              br_true = br_name + '_true',
              br_false = br_name + '_false',
              br_done = br_name + '_done',
              bool_local1 = '%' + pre + 'bool_local_1',
              bool_local2 = '%' + pre + 'bool_local_2',
              bool_local_out = '%' + pre + 'bool_local_out';
          ir.push('  br ' + param.itype + ' ' + param.ilocal +
                  ', label %' + br_true + ', label %' + br_false);
          ir.push('  ' + br_true + ':');
          ir.push('    ' + bool_local1 +
                  ' = getelementptr [5 x i8]* @.true_str, i32 0, i32 0');
          ir.push('  br label %' + br_done);
          ir.push('  ' + br_false + ':');
          ir.push('    ' + bool_local2 +
                  ' = getelementptr [6 x i8]* @.false_str, i32 0, i32 0');
          ir.push('  br label %' + br_done);
          ir.push('  ' + br_done + ':');
          ir.push('  ' + bool_local_out + ' = phi i8* [ ' + bool_local1 +
                  ', %' + br_true + '], [ ' + bool_local2 +
                  ', %' + br_false + ']');
          format = "@.str_format";
          param.itype = 'i8*';
          param.ilocal = bool_local_out;
          break;
        default:
          throw new Error("Unknown WRITE type: " + param.type.name);
      }
      ir.push('  ' + str + ' = getelementptr inbounds [' + flen + ' x i8]* ' +
              format + ', i32 0, i32 0');
      ir.push('  ' + call1 + ' = call i32 (i8*, ...)* @printf(i8* ' + str +
              ', ' + param.itype + ' ' + param.ilocal + ')');
    }
    ir.push('  ' + sout + ' = load %struct._IO_FILE** @stdout');
    ir.push('  ' + call2 + ' = call i32 @fflush(%struct._IO_FILE* ' + sout + ')');
    ir.push('  ; WRITE finish');
    return ir;
  }

  function WRITELN (ast, cparams) {
    var ir = [],
        pre = st.new_name('WRITELN'),
        str = '%' + pre + 'str',
        call = '%' + pre + 'call';
    ir.push('  ; WRITELN start');
    ir.push.apply(ir, WRITE(ast, cparams));
    ir.push.apply(ir, WRITE(ast, [{type:{name: 'STRING'},itype:'[2 x i8]*',ilocal:'@.newline'}]));
    ir.push('  ; WRITELN finish');
    return ir;
  }

  return {__init__: __init__,
          __stop__: __stop__,
          CHR: CHR,
          HALT: HALT,
          RANDOM:RANDOM,
          WRITE:WRITE,
          WRITELN:WRITELN
          };
};

exports.Library = Library;
