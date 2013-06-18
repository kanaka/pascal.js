
function Library (st) {
  var vcnt = 0;

  function __init__() {
    var ir = [];
    ir.push("declare i32 @usleep(i32)");
    return ir;
  }

  function CLRSCR (ast, cparams) {
    var ir = [];
    return ir;
  }

  function DELAY (ast, cparams) {
    var ir = [], clen = cparams.length,
        param = cparams[0],
        ms = '%DELAYms' + (++vcnt),
        call = '%DELAYcall' + vcnt;
    if (clen !== 1) {
      throw new Error("Delay only accepts one argument (" + clen + " given)");
    }
    ir.push('  ; DELAY start');
    ir.push('  ' + ms + ' = mul ' + param.itype + ' 1000, ' + param.ilocal);
    ir.push('  ' + call + ' = call i32 (i32)* @usleep(i32 ' + ms + ')');
    ir.push('  ; DELAY finish');
    return ir;
  }

  function GOTOXY (ast, cparams) {
    var ir = [];
    return ir;
  }

  return {__init__: __init__,
          //CLRSCR:CLRSCR,
          DELAY:DELAY,
          //GOTOXY:GOTOXY
          };
};

exports.Library = Library;
