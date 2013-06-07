/* Turbo Pascal 1.0 parser */

/* lexical grammar */
%lex
%options case-insensitive
%s comment

STRING                  "'"[^']*"'"
REAL                    [0-9]+"."[0-9]*     
INTEGER                 [0-9]+
ID                      [A-Za-z][A-Za-z0-9]*
WHITESPACE              \s+

%%

"(*"                    this.begin('comment');
<comment>[^*][^*]*      /* ignore comment contents up to "*" */
<comment>"*"+[^)]       /* ignore '*" in comment that is not before ")" */
<comment>"*)"           this.begin('INITIAL');

"{".*"}"                /* skip whitespace */

":="                    return "ASSIGN";  /* Needs to be before COLON and EQ */

":"                     return "COLON";
";"                     return "SEMI";
","                     return "COMMA";
"."                     return "DOT";
"("                     return "LPAREN";
")"                     return "RPAREN";
"["                     return "LBRACKET";
"]"                     return "RBRACKET";
"{"                     return "LCURLY";
"}"                     return "RCURLY";

"<="                    return "LEQ";
">="                    return "GEQ";
"<>"                    return "NEQ";
"+"                     return "PLUS";
"-"                     return "MINUS";
"*"                     return "STAR";
"/"                     return "SLASH";
"<"                     return "LT";
">"                     return "GT";
"="                     return "EQ";

"AND"                   return "AND";
"DIV"                   return "DIV";
"IN"                    return "IN";
"MOD"                   return "MOD";
"NOT"                   return "NOT";
"OR"                    return "OR";
"SHL"                   return "SHL";
"SHR"                   return "SHR";
"XOR"                   return "XOR";

/* Reserved words */
"ABSOLUTE"              return "ABSOLUTE";
"ARRAY"                 return "ARRAY";
"BEGIN"                 return "BEGIN";
"CASE"                  return "CASE";
"CONST"                 return "CONST";
"DO"                    return "DO";
"DOWNTO"                return "DOWNTO";
"ELSE"                  return "ELSE";
"END"                   return "END";
"EXTERNAL"              return "EXTERNAL";
"FILE"                  return "FILE";
"FOR"                   return "FOR";
"FUNCTION"              return "FUNCTION";
"GOTO"                  return "GOTO";
"IF"                    return "IF";
"INLINE"                return "INLINE";
"LABEL"                 return "LABEL";
/*"NIL"                   return "NIL"; */
"OF"                    return "OF";
"PACKED"                return "PACKED";
"PROCEDURE"             return "PROCEDURE";
"PROGRAM"               return "PROGRAM";
"RECORD"                return "RECORD";
"REPEAT"                return "REPEAT";
"SET"                   return "SET";
"THEN"                  return "THEN";
"TO"                    return "TO";
"TYPE"                  return "TYPE";
"UNTIL"                 return "UNTIL";
"VAR"                   return "VAR";
"WHILE"                 return "WHILE";
"WITH"                  return "WITH";


{STRING}                return "STRING_LITERAL";
{REAL}                  return "REAL_LITERAL";
{INTEGER}               return "INTEGER_LITERAL";

{ID}                    return "ID";

{WHITESPACE}            /* skip whitespace */

<<EOF>>                 return 'EOF'
.                       return 'INVALID'

/lex

%{
    var util = require("util");
    function inspect(obj) {
        console.warn(util.inspect(obj,false,20));
    }

    function appendChild(node, child){
      node.splice(node.length,0,child);
      return node;
    }
%}


/* operator associations and precedence */

%right          "THEN" "ELSE"
%nonassoc       "EQ" "NEQ" "GT" "LT" "GEQ" "LEQ" "IN"
%left           "PLUS" "MINUS" "OR" "XOR"
%left           "STAR" "SLASH" "MOD" "DIV" "AND" "SHL" "SHR"
%nonassoc       "NOT"
%left           "UMINUS"          

%start program

%% /* language grammar */

program         : program_header SEMI block DOT         {{ $$ = {node:'program',id:$1.id,fparams:$1.fparams,block:$3};
                                                           //inspect($$);
                                                           return $$; }}
                ;
program_header  : PROGRAM id                            {{ $$ = {node:'program_heading',id:$2,fparams:[]}; }}
                | PROGRAM id LPAREN ids RPAREN          {{ $$ = {node:'program_heading',id:$2,fparams:$4}; }}
                ;
block           : decls cstmt                           {{ $$ = {node:'block',decls:$1,stmts:$2}; }}
                |       cstmt                           {{ $$ = {node:'block',decls:[],stmts:$1}; }}
                ;

/* decl is a plural (an array) already */
decls           : decls decl                            {{ $$ = $1.concat($2); }}
                |       decl                            {{ $$ = $1; }}
                ;
decl            : VAR var_decls SEMI                    {{ $$ = $2; }}
                | PROCEDURE proc_decl SEMI              {{ $$ = [$2]; }}
                | FUNCTION func_decl SEMI               {{ $$ = [$2]; }}
                ;
var_decls       : var_decls SEMI var_decl               {{ $$ = $1.concat($3); }}
                |                var_decl               {{ $$ = $1; }}
                ;
var_decl        : ids COLON id                          {{ $$ = [];
                                                           for(var i=0; i < $1.length; i++) {
                                                             $$ = $$.concat([{node:'var_decl',id:$1[i],type:$3.toUpperCase()}]); } }}
                ;

proc_decl       : id formal_params SEMI block           {{ $$ = {node:'proc_decl',id:$1,fparams:$2,block:$4}; }}
                | id               SEMI block           {{ $$ = {node:'proc_decl',id:$1,fparams:[],block:$4}; }}
                |
                ;
func_decl       : id formal_params COLON id SEMI block  {{ $$ = {node:'func_decl',id:$2,fparams:$2,type:$4.toUpperCase(),block:$6}; }}
                | id               COLON id SEMI block  {{ $$ = {node:'func_decl',id:$2,fparams:[],type:$4.toUpperCase(),block:$6}; }}
                |
                ;
formal_params   : LPAREN fp_sections RPAREN             {{ $$ = $2; }}
                | LPAREN             RPAREN             {{ $$ = []; }}
                ;
fp_sections     : fp_sections SEMI fp_section           {{ $$ = $1.concat($3); }}
                |                  fp_section           {{ $$ = $1; }}
                ;
/* fp_section is plural (array) */
fp_section      : ids COLON id                          {{ $$ = [];
                                                           for(var i=0; i < $1.length; i++) {
                                                             $$ = $$.concat([{node:'param',id:$1[i],type:$3.toUpperCase(),var:false}]); } }}
                | VAR ids COLON id                      {{ $$ = [];
                                                           for(var i=0; i < $2.length; i++) {
                                                             $$ = $$.concat([{node:'param',id:$2[i],type:$4.toUpperCase(),var:true}]); } }}
                ;

cstmt           : BEGIN stmts END                       {{ $$ = $2; }}
                ;
stmts           : stmts SEMI stmt                       {{ $$ = $1.concat($3); }}
                |            stmt                       {{ $$ = [$1]; }}
                ;
stmt            : open_stmt                             {{ $$ = $1; }}
                | closed_stmt                           {{ $$ = $1; }}
                ;
closed_stmt     : lvalue ASSIGN expr                    {{ $$ = {node:'stmt_assign',lvalue:$1,expr:$3}; }}
                | id call_params                        {{ $$ = {node:'stmt_call',id:$1,call_params:$2}; }}
                | lvalue                                {{ $$ = {node:'stmt_call',id:$1.id,call_params:[]}; }}
                | cstmt                                 {{ $$ = {node:'stmt_compound',stmts:$1}; }}
                | closed_if_stmt                        {{ $$ = $1; }}
                | closed_for_stmt                       {{ $$ = $1; }}
                ;
open_stmt       : open_if_stmt                          {{ $$ = $1; }}
                | open_for_stmt                         {{ $$ = $1; }}
                ;
closed_if_stmt  : IF expr THEN closed_stmt ELSE closed_stmt {{ $$ = {node:'stmt_if',expr:$2,tstmt:$4,fstmt:$6}; }}
                ;
open_if_stmt    : IF expr THEN stmt                         {{ $$ = {node:'stmt_if',expr:$2,tstmt:$4,fstmt:null}; }}
                | IF expr THEN closed_stmt ELSE open_stmt   {{ $$ = {node:'stmt_if',expr:$2,tstmt:$4,fstmt:$6}; }}
                ;
closed_for_stmt : FOR lvalue ASSIGN expr TO     expr DO closed_stmt {{ $$ = {node:'stmt_for',index:$2,start:$4,by:1, end:$6,stmt:$8}; }}
                | FOR lvalue ASSIGN expr DOWNTO expr DO closed_stmt {{ $$ = {node:'stmt_for',index:$2,start:$4,by:-1,end:$6,stmt:$8}; }}
                ;
open_for_stmt   : FOR lvalue ASSIGN expr TO     expr DO open_stmt   {{ $$ = {node:'stmt_for',index:$2,start:$4,by:1, end:$6,stmt:$8}; }}
                | FOR lvalue ASSIGN expr DOWNTO expr DO open_stmt   {{ $$ = {node:'stmt_for',index:$2,start:$4,by:-1,end:$6,stmt:$8}; }}
                ;

exprs           : exprs COMMA expr                      {{ $$= $1.concat([$3]); }}
                |             expr                      {{ $$ = [$1]; }}
                ;
expr            : INTEGER_LITERAL                       {{ $$ = {node:'integer',type:'INTEGER',val:parseInt($1)}; }}
                | REAL_LITERAL                          {{ $$ = {node:'real',type:'REAL',val:parseFloat($1)}; }}
                | STRING_LITERAL                        {{ $$ = {node:'string',type:'STRING',val:$1.substr(1,$1.length-2)}; }}
                | lvalue                                {{ $$ = $1; }}
                | LPAREN expr RPAREN                    {{ $$ = $2; }}
                | MINUS expr                            {{ $$ = {node:'expr_unop',op:'minus',expr:$2}; }}
                | expr PLUS expr                        {{ $$ = {node:'expr_binop',op:'plus',left:$1,right:$3}; }}
                | expr MINUS expr                       {{ $$ = {node:'expr_binop',op:'minus',left:$1,right:$3}; }}
                | expr STAR expr                        {{ $$ = {node:'expr_binop',op:'star',left:$1,right:$3}; }}
                | expr SLASH expr                       {{ $$ = {node:'expr_binop',op:'slash',left:$1,right:$3}; }}
                | expr DIV expr                         {{ $$ = {node:'expr_binop',op:'div',left:$1,right:$3}; }}
                | expr MOD expr                         {{ $$ = {node:'expr_binop',op:'mod',left:$1,right:$3}; }}
                | expr OR expr                          {{ $$ = {node:'expr_binop',op:'or',left:$1,right:$3}; }}
                | expr AND expr                         {{ $$ = {node:'expr_binop',op:'and',left:$1,right:$3}; }}
                | expr GT expr                          {{ $$ = {node:'expr_binop',op:'gt',left:$1,right:$3}; }}
                | expr LT expr                          {{ $$ = {node:'expr_binop',op:'lt',left:$1,right:$3}; }}
                | expr EQ expr                          {{ $$ = {node:'expr_binop',op:'eq',left:$1,right:$3}; }}
                | expr GEQ expr                         {{ $$ = {node:'expr_binop',op:'geq',left:$1,right:$3}; }}
                | expr LEQ expr                         {{ $$ = {node:'expr_binop',op:'leq',left:$1,right:$3}; }}
                | expr NEQ expr                         {{ $$ = {node:'expr_binop',op:'neq',left:$1,right:$3}; }}
                ;

call_params     : LPAREN exprs RPAREN                   {{ $$ = $2; }}
                | LPAREN RPAREN                         {{ $$ = []; }}
                ;

lvalue          : id                                    {{ $$ = {node:'variable',id:$1}; }}
                ;
ids             : ids COMMA id                          {{ $$ = $1.concat([$3]); }}
                | id                                    {{ $$ = [$1]; }}
                ;
id              : ID                                    {{ $$ = yytext; }}
                ;
