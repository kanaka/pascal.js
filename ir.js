/*
 * Based on https://raw.github.com/zaach/floop.js/master/lib/lljsgen.js @ 4a981a2799
 */

var util = require('util');

function id(identifier) {
  return identifier.split('-').join('_').replace('?', '$');
}

function SymbolTable() {
  var data = [{}];

  function begin_scope() {
    data.push({});
  }
  function end_scope() {
    if (data.length === 1) {
      throw new Error("end_scope without begin_scope");
    }
    data.pop();
  }

  function indexOf(name) {
    for(var idx = data.length-1; idx >= 0; idx--) {
      if (data[idx][name]) {
        return idx;
      }
    }
    return undefined;
  }

  function lookup(name) {
    var name = name.toUpperCase(),
        idx = indexOf(name);
    if (typeof(idx) !== "undefined") {
      return data[idx][name];
    }
    throw new Error("Name '" + name + "' not found in symbol table");
  }

  function insert(name, value, level) {
    if (typeof level === 'undefined') { level = data.length-1; }
    data[level][name.toUpperCase()] = value;
  }

  function replace(name, value) {
    var name = name.toUpperCase(),
        idx = indexOf(name);
    if (typeof(idx) !== "undefined") {
      data[idx][name] = value;
    } else {
      throw new Error("Name '" + name + "' not found to replace");
    }
  }

  function display() {
    console.warn("-------------");
    for(var idx = 0; idx < data.length; idx++) {
      console.warn("--- " + idx + " ---");
      for(var name in data[idx]) {
        console.warn(name + ": ", data[idx][name]);
      }
    }
    console.warn("-------------");
  }

  return {lookup: lookup,
          insert: insert,
          replace: replace,
          begin_scope: begin_scope,
          end_scope: end_scope,
          display: display};
};

function IR(theAST) {

  var st = new SymbolTable();
  var vcnt = 0; // variable counter
  var str_cnt = 0;
  var name_cnt = 0;
  var expected_returned_type = 'NoTyp';

  function new_name(name) {
    return name + "_" + (name_cnt++) + "_";
  }

  function type_to_lltype(type) {
    switch (type.name) {
      case 'INTEGER': return "i32"; break;
      case 'REAL':    return "float"; break;
      case 'BOOLEAN': return "i1"; break;
      case 'ARRAY':
        var res = "",
            indexes = type.indexes;
        for (var i=0; i<indexes.length; i++) {
          var start = indexes[i].start,
              end = indexes[i].end;
          res = res + '[' + (end-start+1) + ' x ';
        }
        res = res + type_to_lltype(type.type);
        for (var i=0; i<indexes.length; i++) {
          res = res + ']';
        }
        return res;
        break;
      default: throw new Error("TODO: handle " + type.name + " type");
    }
  }

  // normalizeIR takes a JSON IR
  function normalizeIR(ir) {
    var prefix = [], body = [];
    body.push("");
    for (var i=0; i < ir.length; i++) {
      if (typeof(ir[i]) === "object") {
        prefix.push.apply(prefix, ir[i]);
      } else {
        body.push(ir[i]);
      }
    }
    return (prefix.concat(body)).join("\n");
  }

  function toIR(astTree, level, fnames) {
    var ast = astTree || theAST,
        indent = "",
        node = ast.node,
        fname,
        ir = [];
    level = level ? level : 0;
    fnames = fnames ? fnames : ['main'];
    fname = fnames[fnames.length-1];
    for (var i=0; i < level; i++) {
      indent = indent + "  ";
    }

    //console.warn("toIR",node,"level:", level, "fnames:", fnames, "ast:", JSON.stringify(ast));

    switch (node) {
      case 'program':
        var name = ast.id,  // TODO: do anything with program name?
            fparams = ast.fparams,
            block = ast.block;
        st.insert('main',{name:'main',level:level,fparams:fparams,lparams:[]});

        ir.push("declare i32 @printf(i8*, ...)");
        ir.push("");
        ir.push('@.newline = private constant [2 x i8] c"\\0A\\00"');
        ir.push('@.true_str = private constant [5 x i8] c"TRUE\\00"');
        ir.push('@.false_str = private constant [6 x i8] c"FALSE\\00"');
        ir.push('@.str_format = private constant [3 x i8] c"%s\\00"');
        ir.push('@.int_format = private constant [3 x i8] c"%d\\00"');
        ir.push('@.float_format = private constant [3 x i8] c"%f\\00"');
        ir.push('');
        block.param_list = [];
        ir.push.apply(ir, toIR(block,level,fnames));
        break;

      case 'block':
        var decls = ast.decls,
            stmts = ast.stmts,
            pdecl = st.lookup(fname),
            lparams = pdecl.lparams,
            fparams = pdecl.fparams,
            param_list = [],
            lparam_list = [],
            pdecl_ir = [],
            vdecl_ir = [],
            stmts_ir = [];

        // Regular formal parameters
        for (var i=0; i < fparams.length; i++) {
          var fparam = fparams[i],
              pname = "%" + new_name(fparam.id + "_fparam"),
              lltype = type_to_lltype(fparam.type);
          st.insert(fparam.id,{node:'var_decl',type:fparam.type,pname:pname,var:fparam.var,level:level});
          if (fparam.var) {
            param_list.push(lltype + '* ' + pname);
          } else {
            param_list.push(lltype + ' ' + pname);
          }
        }
        // Evaluate the children. We might need to modify the
        // param-list based on internal variables that refer to higher
        // level lexical scope
        for (var i=0; i < decls.length; i++) {
          var decl = decls[i];
          if (decl.node === 'proc_decl' || decl.node === 'func_decl') {
            pdecl_ir.push.apply(pdecl_ir, toIR(decl,level,fnames));
          } else {
            vdecl_ir.push.apply(vdecl_ir, toIR(decl,level,fnames));
          }
        }
        for (var i=0; i < stmts.length; i++) {
          stmts_ir.push.apply(stmts_ir, toIR(stmts[i],level,fnames));
        }

        // Variables that refer to higher lexical scope
        for (var i=0; i < lparams.length; i++) {
          var lparam = lparams[i],
              ldecl = st.lookup(lparam.id),
              pname = ldecl.pname,
              lltype = type_to_lltype(ldecl.type);
            lparam_list.push(lltype + '* ' + pname);
        }
        param_list = lparam_list.concat(param_list);

        // Now output the IR
        // Add sub-program declarations at the top level
        var pitype = pdecl.itype || "i32";
        ir.push.apply(ir, pdecl_ir);
        ir.push('');
        ir.push('define ' + pitype + ' @' + pdecl.name + '(' + param_list.join(", ") +') {');
        ir.push('entry:');
        if (pdecl.ireturn) {
          ir.push('  %retval = alloca ' + pitype);
        }
        // Add variable declarations inside the body definition
        ir.push.apply(ir, vdecl_ir);
        // Postpone variable declarations until inside the body
        ir.push.apply(ir, stmts_ir);
        if (pdecl.ireturn) {
          ir.push('  %retreg = load ' + pitype + '* %retval');
          ir.push('  ret ' + pitype + ' %retreg');
        } else {
          ir.push('  ret ' + pitype + ' 0');
        }
        ir.push('}');
        break;

      case 'var_decl':
        var id = ast.id,
            type = ast.type,
            pdecl = st.lookup(fname),
            sname = "%" + new_name(id + "_stack");

        lltype = type_to_lltype(type),
        st.insert(id,{node:'var_decl',type:type,sname:sname,level:pdecl.level});
        ir.push('  ' + sname + ' = alloca ' + lltype);
        break;

      case 'proc_decl':
      case 'func_decl':
        var id = ast.id,
            type = ast.type,
            fparams = ast.fparams,
            block = ast.block,
            new_fname = new_name(id),
            new_level = level+1;

        st.insert(id, {name: new_fname, type:type, level: new_level,fparams:fparams,lparams:[]});
        st.begin_scope();
        ir.push.apply(ir, toIR(block,new_level,fnames.concat([id])));
        st.end_scope();
        break;

      case 'stmt_assign':
        var lvalue = ast.lvalue,
            expr = ast.expr
            lltype = null;
        ir.push.apply(ir,toIR(expr,level,fnames));
        if (lvalue.id === fname) {
          // This is actually a function name being used to set the
          // return value for the function so we don't evaluate the
          // lvalue
          var pdecl = st.lookup(fname);
          lvalue.type = pdecl.type;
          lvalue.itype = type_to_lltype(pdecl.type);
          pdecl.ireturn = true;
          pdecl.itype = lvalue.itype;
          ir.push('  store ' + expr.itype + ' ' + expr.ilocal + ', ' + pdecl.itype + '* %retval');
          st.replace(fname,pdecl);
        } else {
          ir.push.apply(ir,toIR(lvalue,level,fnames));
          ir.push('  store ' + expr.itype + ' ' + expr.ilocal + ', ' + lvalue.itype + '* ' + lvalue.istack);
        }
        ast.itype = lvalue.itype;
        ast.istack = lvalue.istack;
        ast.ilocal = lvalue.ilocal;
        break;

      case 'stmt_call':
      case 'expr_call':
        var id = ast.id,
            cparams = (ast.call_params || []);
        // evaluate the parameters
        for(var i=0; i < cparams.length; i++) {
          var cparam = cparams[i];
          // TODO: make sure call params and formal params match
          // length and types
          ir.push.apply(ir, toIR(cparam,level,fnames));
        }
        // TODO: perhaps move to a separate library.js
        switch (id) {
          case 'WRITE':
          case 'WRITELN':
            ir.push('  ; WRITELN start');
            for(var i=0; i < cparams.length; i++) {
              var param = cparams[i],
                  v = vcnt++,
                  format = null;
              switch (param.type.name) {
                case 'INTEGER': format = "@.int_format"; break;
                case 'REAL':    format = "@.float_format"; break;
                case 'STRING':  format = "@.str_format"; break;
                case 'BOOLEAN':
                  var br_name = new_name('br'),
                      br_true = br_name + '_true',
                      br_false = br_name + '_false',
                      br_done = br_name + '_done',
                      bool_local1 = '%' + new_name('bool_local'),
                      bool_local2 = '%' + new_name('bool_local'),
                      bool_local_out = '%' + new_name('bool_local');
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
              ir.push('  %str' + v + ' = getelementptr inbounds [3 x i8]* ' + format + ', i32 0, i32 0');
              ir.push('  %call' + v + ' = call i32 (i8*, ...)* @printf(i8* %str' + v + ', ' +
                      param.itype + ' ' + param.ilocal + ')');
            }
            
            if (id === 'WRITELN') {
              v = vcnt++;
              ir.push('  %str' + v + ' = getelementptr inbounds [2 x i8]* @.newline, i32 0, i32 0');
              ir.push('  %call' + v + ' = call i32 (i8*, ...)* @printf(i8* %str' + v + ')');
            }
            ir.push('  ; WRITELN finish');
            break;
          default:
            var pdecl = st.lookup(id);
            if (!pdecl) {
              throw new Error("Unknown function '" + id + "'");
            }
            var lparams = pdecl.lparams,
                fparams = pdecl.fparams,
                param_list = [];
            for(var i=0; i < lparams.length; i++) {
              var lparam = lparams[i],
                  litype = null;
              ir.push.apply(ir, toIR(lparam,level,fnames));
              litype = type_to_lltype(lparam.type);
              param_list.push(litype + "* " + lparam.istack);
            }
            for(var i=0; i < cparams.length; i++) {
              var cparam = cparams[i];
              if (cparams[i].lparam) {
                throw new Error("TODO handle lparam in call");
              } else if (fparams[i].var) {
                param_list.push(cparam.itype + "* " + cparam.istack);
              } else {
                param_list.push(cparam.itype + " " + cparam.ilocal);
              }
            }
            if (node === 'expr_call') {
              var ret = '%' + new_name(pdecl.name + "_ret"),
                pitype = type_to_lltype(pdecl.type);
              ir.push('  ' + ret + ' = call ' + pitype + ' @' + pdecl.name + "(" + param_list.join(", ") + ")");
              ast.type = pdecl.type;
              ast.itype = pitype;
              ast.ilocal = ret;
            } else {
              ir.push('  call i32 @' + pdecl.name + "(" + param_list.join(", ") + ")");
            }
        }
        break;

      case 'stmt_compound':
        for (var i=0; i < ast.stmts.length; i++) {
          ir.push.apply(ir,toIR(ast.stmts[i],level,fnames));
        }
        break;

      case 'stmt_if':
        var expr = ast.expr,
            tstmt = ast.tstmt,
            fstmt = ast.fstmt;
        ir.push('');
        ir.push('  ; if statement start');
        ir.push.apply(ir, toIR(expr,level,fnames));
        var br_name = new_name('br'),
            br_true = br_name + '_true',
            br_false = br_name + '_false',
            br_done = br_name + '_done';
        ir.push('  br ' + expr.itype + ' ' + expr.ilocal + ', label %' + br_true + ', label %' + br_false);
        ir.push('  ' + br_true + ':');
        ir.push.apply(ir, toIR(tstmt,level,fnames));
        ir.push('  br label %' + br_done); 
        ir.push('  ' + br_false + ':');
        ir.push.apply(ir, toIR(fstmt,level,fnames));
        ir.push('  br label %' + br_done); 
        ir.push('  ' + br_done + ':');
        ir.push('  ; if statement finish');
        ir.push('');
        break;

      case 'stmt_for':
        var index = ast.index,
            start = ast.start,
            by = ast.by,
            end = ast.end,
            stmt = ast.stmt,
            for_label = new_name('for'),
            for_start = for_label + 'start',
            for_cond = for_label + 'cond',
            for_body = for_label + 'body',
            for_inc = for_label + 'inc',
            for_end = for_label + 'end',
            for_index = '%' + for_label + 'index',
            for_cmp = '%' + for_label + 'cmp',
            for_cmp1 = '%' + for_label + 'cmp1',
            for_cmp2 = '%' + for_label + 'cmp2',
            for_inc1 = '%' + for_label + 'inc1',
            for0 = '%' + for_label + '0',
            for1 = '%' + for_label + '1',
            for2 = '%' + for_label + '2',
            for3 = '%' + for_label + '3';

        ir.push('');
        ir.push('  ; for statement start');

        ir.push.apply(ir, toIR(index,level,fnames));
        ir.push.apply(ir, toIR(start,level,fnames));
        ir.push.apply(ir, toIR(end,level,fnames));

        if (by === 1) {
          ir.push('  ' + for_cmp + ' = icmp sgt i32 ' + start.ilocal + ', ' + end.ilocal);
        } else {
          ir.push('  ' + for_cmp + ' = icmp slt i32 ' + start.ilocal + ', ' + end.ilocal);
        }
        ir.push('  br i1 ' + for_cmp + ', label %' + for_end + ', label %' + for_start);

        ir.push('  br label %' + for_start); 

        ir.push('');
        ir.push('  ' + for_start + ':');
        ir.push('  store ' + start.itype + ' ' + start.ilocal + ', ' + index.itype + '* ' + index.istack);
        ir.push('  br label %' + for_cond); 

        ir.push('');
        ir.push('  ' + for_cond + ':');
        ir.push('  ' + for1 + ' = load i32* ' + index.istack);
        if (by === 1) {
          ir.push('  ' + for_cmp1 + ' = icmp sle i32 ' + for1 + ', ' + end.ilocal);
        } else {
          ir.push('  ' + for_cmp1 + ' = icmp sge i32 ' + for1 + ', ' + end.ilocal);
        }
        ir.push('  br i1 ' + for_cmp1 + ', label %' + for_body + ', label %' + for_end);

        ir.push('');
        ir.push('  ' + for_body + ':');
        ir.push.apply(ir, toIR(stmt,level,fnames));
        ir.push('  ' + for2 + ' = load i32* ' + index.istack);
        ir.push('  ' + for_cmp2 + ' = icmp eq i32 ' + for2 + ', ' + end.ilocal);
        ir.push('  br i1 ' + for_cmp2 + ', label %' + for_end + ', label %' + for_inc);

        ir.push('');
        ir.push('  ' + for_inc + ':');
        ir.push('  ' + for3 + ' = load i32* ' + index.istack);
        ir.push('  ' + for_inc1 + ' = add nsw i32 ' + for3 + ', ' + by);
        ir.push('  store i32 ' + for_inc1 + ', i32* ' + index.istack);
        ir.push('  br label %' + for_cond);

        ir.push('');
        ir.push('  ' + for_end + ':');

        ir.push('  ; for statement finish');
        ir.push('');
        break;

      case 'expr_binop':
        var left = ast.left,
            right = ast.right,
            dest_name = '%' + new_name("binop"),
            lltype, rtype, ritype, op;
        ir.push.apply(ir, toIR(left,level,fnames));
        ir.push.apply(ir, toIR(right,level,fnames));
        // TODO: real typechecking comparison
        lltype = type_to_lltype(left.type);
        rtype = left.type;
        ritype = lltype;
        switch (ast.op) {
          case 'plus':  op = 'add'; break;
          case 'minus': op = 'sub'; break;
          case 'star':  op = 'mul'; break;
          case 'slash': op = 'sdiv'; break;  // float
          case 'div':   op = 'sdiv'; break;
          case 'mod':   op = 'urem'; break;

          case 'and':   op = 'and'; break;
          case 'or':    op = 'or'; break;

          case 'gt':    op = 'icmp sgt'; ritype = 'i1'; break;
          case 'lt':    op = 'icmp slt'; ritype = 'i1'; break;
          case 'eq':    op = 'icmp eq'; ritype = 'i1'; break;
          case 'geq':   op = 'icmp sge'; ritype = 'i1'; break;
          case 'leq':   op = 'icmp sle'; ritype = 'i1'; break;
          case 'neq':   op = 'icmp ne'; ritype = 'i1'; break;

          default: throw new Error("Unexpected expr_binop operand " + ast.op);
        }
        ir.push('  ' + dest_name + ' = ' + op + ' ' + lltype + ' ' + left.ilocal + ', ' + right.ilocal);
        ast.type = rtype;
        ast.itype = ritype;
        ast.ilocal = dest_name;
        break;

      case 'expr_unop':
        var expr = ast.expr,
            dest_name = '%' + new_name("unop"),
            op;
        ir.push.apply(ir, toIR(expr,level,fnames));
        // TODO: real typechecking comparison
        switch (ast.op) {
          case 'minus':
            ir.push('  ' + dest_name + ' = sub i32 0, ' + expr.ilocal);
            break;
          case 'not':
            ir.push('  ' + dest_name + ' = xor i1 1, ' + expr.ilocal);
            break;
          default: throw new Error("Unexpected expr_unop operand " + ast.op);
        }
        ast.type = expr.type;
        ast.itype = expr.itype;
        ast.ilocal = dest_name;
        break;

      case 'expr_array_deref':
        // TODO: support multi-level arrays
        var lvalue = ast.lvalue,
            adecl = st.lookup(lvalue.id),
            expr = ast.exprs[0];
        ir.push.apply(ir, toIR(expr,level,fnames));
        ir.push.apply(ir, toIR(lvalue,level,fnames));
        var start = lvalue.type.indexes[0].start,
            end = lvalue.type.indexes[0].end,
            aidx = '%' + new_name(lvalue.id + '_arrayidx'),
            aoff = '%' + new_name(lvalue.id + '_arrayoff'),
            aval = '%' + new_name(lvalue.id + '_arrayval'),
            lltype = type_to_lltype(adecl.type.type);
        // TODO: generate index checks and assertion errors
        ir.push('  ' + aidx + ' = sub ' + expr.itype + ' ' + expr.ilocal + ', ' + start);
        ir.push('  ' + aoff + ' = getelementptr inbounds ' + lvalue.itype + '* ' + lvalue.istack + ', i32 0, ' + expr.itype + ' ' + aidx);
        ir.push('  ' + aval + ' = load ' + lltype + '* ' + aoff);
        ast.type = adecl.type.type;
        ast.itype = lltype;
        ast.istack = aoff;
        ast.ilocal = aval;
        break;

      case 'integer':
        ast.itype = "i32";
        ast.ilocal = ast.val;
        break;
      case 'real':
        throw new Error("TODO: support reals");
        break;
      case 'string':
        var sval = ast.val,
            slen = sval.length+1,
            sname = '@.string' + (str_cnt++),
            lname;
        ir.push([sname + ' = private constant [' + slen + ' x i8] c"' + sval + '\\00"']);
        ast.itype = '[' + slen + ' x i8]*';
        ast.ilocal = sname;
        ast.iref = sname;
        break;
      case 'boolean':
        ast.itype = "i1";
        ast.ilocal = ast.val.toString();
        break;

      case 'variable':
        var id = ast.id,
            vdecl = st.lookup(ast.id),
            type = vdecl.type,
            lltype = type_to_lltype(type);
            sname = vdecl.sname,
            vlevel = vdecl.level;

        if (vdecl.fparams) {
          // This is actually a function call expression so
          // replace the AST with a function and evalutate it
          ast.node = 'expr_call';
          ast.call_params = [];
          ir.push.apply(ir, toIR(ast,level,fnames));
          break;
        }

        // Add on any variables from a higher lexical scope first
        if (level !== vdecl.level) {
          // Variable is in higher lexical scope, simulate static
          // link by passing the variable through intervening
          // sub-programs
          for(var l = vlevel+1; l <= level; l++) {
            var fname = fnames[l],
                pname = "%" + new_name(id + "_lparam"),
                pdecl = st.lookup(fname);
            // replace vdecl and insert it at this level
            vdecl = {node:'var_decl',type:type,pname:pname,sname:sname,var:true,lparam:true,level:l};
            st.insert(id,vdecl,l);
            // add the variable to the lparams (lexical variables) 
            pdecl.lparams.push({node:'variable',id:id,type:type});
            ast.ilocal = pname;
            ast.istack = vdecl.sname;
            st.replace(fname,pdecl);
          }
        }

        ast.type = vdecl.type;
        ast.itype = lltype;
        // Variable in current lexical scope
        if (vdecl.pname && !vdecl.var) {
          var sname = "%" + new_name(id + "_stack");
          ast.ilocal = vdecl.pname;
          ast.istack = sname;
          ir.push('  ' + sname + ' = alloca ' + lltype);
          ir.push('  store ' + lltype + ' ' + vdecl.pname + ', ' + lltype + '* ' + sname);
        } else {
          // stack variable or var parameter
          var lname = "%" + new_name(id + "_local");
          ast.ilocal = lname;
          if (vdecl.pname && vdecl.var) {
            ast.istack = vdecl.pname;
          } else {
            ast.istack = vdecl.sname;
          }
          ir.push('  ' + lname + ' = load ' + lltype + '* ' + ast.istack);
        }
        break;

      default:
        throw new Error("Unknown AST: " + JSON.stringify(ast));
    }

    return ir;
  }

  return {toIR: toIR, normalizeIR: normalizeIR,
          displayST: function() { st.display(); },
          getAST: function() { return theAST; }};
}

exports.IR = IR;
exports.toIR = function (ast) {
  var ir = new IR(ast);
  return ir.normalizeIR(ir.toIR());
};
if (typeof module !== 'undefined' && require.main === module) {
  var ast = require('./parse').main(process.argv.slice(1));
  console.log(exports.toIR(ast));
}

// vim: expandtab:ts=2:sw=2:syntax=javascript
