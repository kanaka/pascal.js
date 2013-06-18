/* Turbo Pascal 1.0 parser */

/* lexical grammar */
%lex
%options case-insensitive
%s comment

STRING                  "'"[^']*"'"
REAL                    [0-9]+"."[0-9]+
INTEGER                 [0-9]+
BOOLEAN                 "TRUE"|"FALSE"
CHARACTER               "#"[0-9]+|"^".
ID                      [A-Za-z_][A-Za-z0-9_]*
WHITESPACE              \s+

%%

"(*"                    this.begin('comment');
<comment>[^*][^*]*      /* ignore comment contents up to "*" */
<comment>"*"+[^)]       /* ignore '*" in comment that is not before ")" */
<comment>"*)"           this.begin('INITIAL');

"{".*"}"                /* skip whitespace */

/* Literals */
{REAL}                  return "REAL_LITERAL";
{INTEGER}               return "INTEGER_LITERAL";
{STRING}                return "STRING_LITERAL";
{CHARACTER}             return "CHARACTER_LITERAL";
"TRUE"                  return "TRUE_LITERAL";
"FALSE"                 return "FALSE_LITERAL";


":="                    return "ASSIGN";  /* Needs to be before COLON and EQ */

":"                     return "COLON";
";"                     return "SEMI";
","                     return "COMMA";
"."                     return "DOT";
"("                     return "LPAREN";
")"                     return "RPAREN";
"["                     return "LBRACK";
"]"                     return "RBRACK";
"{"                     return "LCURLY";
"}"                     return "RCURLY";
"^"                     return "CARET";

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
"USES"                  return "USES";
"VAR"                   return "VAR";
"WHILE"                 return "WHILE";
"WITH"                  return "WITH";

/* built-in types */
"INTEGER"               return "INTEGER";
"REAL"                  return "REAL";
"STRING"                return "STRING";
"BOOLEAN"               return "BOOLEAN";
"CHAR"                  return "CHAR";
"BYTE"                  return "BYTE";


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
%left           "EQ" "NEQ" "GT" "LT" "GEQ" "LEQ" "IN"
%left           "PLUS" "MINUS" "OR" "XOR"
%left           "STAR" "SLASH" "MOD" "DIV" "AND" "SHL" "SHR"
%left           "NOT"
%left           "UMINUS"          

%start program

%% /* language grammar */

program         : program_header SEMI pblock DOT        {{ $$ = {node:'program',id:$1.id,fparams:$1.fparams,block:$3};
                                                           if (typeof module !== 'undefined' && require.main === module) {
                                                             console.warn(inspect($$));
                                                           }
                                                           return $$; }}
                ;
program_header  : PROGRAM id                            {{ $$ = {node:'program_heading',id:$2,fparams:[]}; }}
                | PROGRAM id LPAREN ids RPAREN          {{ $$ = {node:'program_heading',id:$2,fparams:$4}; }}
                ;
pblock          : use_decls block                       {{ $$ = $2; }}
                |           block                       {{ $$ = $1; }}
                ;
block           : decls cstmt                           {{ $$ = {node:'block',decls:$1,stmts:$2}; }}
                |       cstmt                           {{ $$ = {node:'block',decls:[],stmts:$1}; }}
                ;

use_decls       : use_decls use_decl                    {{ $$ = $1.concat($2); }}
                |           use_decl                    {{ $$ = [$1]; }}
                ;
use_decl        : USES ids SEMI                         {{ $$ = {node:'use_decl',ids:$2}; }}
                ;
/* decl is a plural (an array) already */
decls           : decls decl                            {{ $$ = $1.concat($2); }}
                |       decl                            {{ $$ = $1; }}
                ;
decl            : CONST const_decls SEMI                {{ $$ = $2; }}
                | TYPE type_decls SEMI                  {{ $$ = $2; }}
                | VAR var_decls SEMI                    {{ $$ = $2; }}
                | PROCEDURE proc_decl SEMI              {{ $$ = [$2]; }}
                | FUNCTION func_decl SEMI               {{ $$ = [$2]; }}
                ;

const_decls     : const_decls SEMI const_decl           {{ $$ = $1.concat($3); }}
                |                  const_decl           {{ $$ = [$1]; }}
                ;
const_decl      : id EQ expr                            {{ $$ = {node:'const_decl',id:$1,expr:$3}; }}
                ;
type_decls      : type_decls SEMI type_decl             {{ $$ = $1.concat($3); }}
                |                 type_decl             {{ $$ = [$1]; }}
                ;
type_decl       : id EQ type                            {{ $$ = {node:'type_decl',id:$1,type:$3}; }}
                ;
type            : id                                    {{ $$ = {node:'type',name:'NAMED',id:$1}; }}
                | INTEGER                               {{ $$ = {node:'type',name:'INTEGER'}; }}
                | REAL                                  {{ $$ = {node:'type',name:'REAL'}; }}
                | STRING                                {{ $$ = {node:'type',name:'STRING'}; }}
                | BOOLEAN                               {{ $$ = {node:'type',name:'BOOLEAN'}; }}
                | CHAR                                  {{ $$ = {node:'type',name:'CHARACTER'}; }}
//                | BYTE                                  {{ $$ = {node:'type',name:'BYTE'}; }}
                /* ordinal types */
//                | enumerated_type                       {{ }}
//                | subrange_type                         {{ }}
                | structured_type                         {{ $$ = $1; }}
                /* pointer type */
//                | CARET id                              {{ }}
                ;
structured_type : ARRAY LBRACK indexes RBRACK OF type   {{ $$ = $6;
                                                           for(var i=$3.length-1; i >= 0; i--) {
                                                             $$ = {node:'type',name:'ARRAY',type:$$,index:$3[i]}; } }}
                | RECORD rec_sections END               {{ $$ = {node:'type',name:'RECORD',sections:$2}; }}
                | RECORD rec_sections SEMI END          {{ $$ = {node:'type',name:'RECORD',sections:$2}; }}
//                | SET OF ordinal_type                   {{ }}
//                | FILE OF type                          {{ }}
                ;
indexes         : indexes COMMA ordinal_type            {{ $$ = $1.concat($3); }}
                | ordinal_type                          {{ $$ = [$1]; }}
                ;
ordinal_type    : subrange_type                         {{ $$ = $1; }}
//                | enumerated_type                       {{ }}
                | id
                ;
subrange_type   : INTEGER_LITERAL DOT DOT INTEGER_LITERAL {{ $$ = {node:'subrange',start:parseInt($1),end:parseInt($4)}; }}
                ;
rec_sections    : rec_sections SEMI rec_section         {{ $$ = $1.concat($3); }}
                |                   rec_section         {{ $$ = $1; }}
                ;
/* rec_section is plural */
rec_section     : ids COLON type                        {{ $$ = [];
                                                           for(var i=0; i < $1.length; i++) {
                                                             $$ = $$.concat([{node:'component',id:$1[i],type:$3}]); } }}
                ;

var_decls       : var_decls SEMI var_decl               {{ $$ = $1.concat($3); }}
                |                var_decl               {{ $$ = $1; }}
                ;
/* var_decl is plural */
var_decl        : ids COLON type                        {{ $$ = [];
                                                           for(var i=0; i < $1.length; i++) {
                                                             $$ = $$.concat([{node:'var_decl',id:$1[i],type:$3}]); } }}
                ;

proc_decl       : id formal_params SEMI block           {{ $$ = {node:'proc_decl',id:$1,fparams:$2,block:$4}; }}
                | id               SEMI block           {{ $$ = {node:'proc_decl',id:$1,fparams:[],block:$3}; }}
                |
                ;
func_decl       : id formal_params COLON type SEMI block  {{ $$ = {node:'func_decl',id:$1,fparams:$2,type:$4,block:$6}; }}
                | id               COLON type SEMI block  {{ $$ = {node:'func_decl',id:$1,fparams:[],type:$3,block:$5}; }}
                |
                ;
formal_params   : LPAREN fp_sections RPAREN             {{ $$ = $2; }}
                | LPAREN             RPAREN             {{ $$ = []; }}
                ;
fp_sections     : fp_sections SEMI fp_section           {{ $$ = $1.concat($3); }}
                |                  fp_section           {{ $$ = $1; }}
                ;
/* fp_section is plural (array) */
fp_section      : ids COLON type                        {{ $$ = [];
                                                           for(var i=0; i < $1.length; i++) {
                                                             $$ = $$.concat([{node:'param',id:$1[i],type:$3,var:false}]); } }}
                | VAR ids COLON type                    {{ $$ = [];
                                                           for(var i=0; i < $2.length; i++) {
                                                             $$ = $$.concat([{node:'param',id:$2[i],type:$4,var:true}]); } }}
                ;


cstmt           : BEGIN stmts END                       {{ $$ = $2; }}
                | BEGIN stmts SEMI END                  {{ $$ = $2; }}
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
                | repeat_stmt                           {{ $$ = $1; }}
                | closed_if_stmt                        {{ $$ = $1; }}
                | closed_while_stmt                     {{ $$ = $1; }}
                | closed_for_stmt                       {{ $$ = $1; }}
                ;
open_stmt       : open_if_stmt                          {{ $$ = $1; }}
                | open_while_stmt                       {{ $$ = $1; }}
                | open_for_stmt                         {{ $$ = $1; }}
                ;
repeat_stmt     : REPEAT stmts      UNTIL expr          {{ $$ = {node:'stmt_repeat',expr:$4,stmts:$2}; }}
                | REPEAT stmts SEMI UNTIL expr          {{ $$ = {node:'stmt_repeat',expr:$5,stmts:$2}; }}
                ;
closed_if_stmt  : IF expr THEN closed_stmt ELSE closed_stmt {{ $$ = {node:'stmt_if',expr:$2,tstmt:$4,fstmt:$6}; }}
                ;
open_if_stmt    : IF expr THEN stmt                         {{ $$ = {node:'stmt_if',expr:$2,tstmt:$4,fstmt:null}; }}
                | IF expr THEN closed_stmt ELSE open_stmt   {{ $$ = {node:'stmt_if',expr:$2,tstmt:$4,fstmt:$6}; }}
                ;
closed_while_stmt : WHILE expr DO closed_stmt           {{ $$ = {node:'stmt_while',expr:$2,stmt:$4}; }}
                ;
open_while_stmt : WHILE expr DO open_stmt               {{ $$ = {node:'stmt_while',expr:$2,stmt:$4}; }}
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
expr            : INTEGER_LITERAL                       {{ $$ = {node:'integer',type:{node:'type',name:'INTEGER'},val:parseInt($1)}; }}
                | REAL_LITERAL                          {{ $$ = {node:'real',type:{node:'type',name:'REAL'},val:parseFloat($1)}; }}
                | STRING_LITERAL                        {{ $$ = {node:'string',type:{node:'type',name:'STRING'},val:$1.substr(1,$1.length-2)}; }}
                | CHARACTER_LITERAL                     {{ $$ = {node:'character',type:{node:'type',name:'CHARACTER'},val:$1}; }}
                | TRUE_LITERAL                          {{ $$ = {node:'boolean',type:{node:'type',name:'BOOLEAN'},val:true}; }}
                | FALSE_LITERAL                         {{ $$ = {node:'boolean',type:{node:'type',name:'BOOLEAN'},val:false}; }}
                | lvalue                                {{ $$ = $1; }}
                | LPAREN expr RPAREN                    {{ $$ = $2; }}
                | MINUS expr                            {{ $$ = {node:'expr_unop',op:'minus',expr:$2}; }}
                | NOT expr                              {{ $$ = {node:'expr_unop',op:'not',expr:$2}; }}
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
                | lvalue call_params                    {{ $$ = {node:'expr_call',id:$1.id,call_params:$2}; }}
                ;

call_params     : LPAREN exprs RPAREN                   {{ $$ = $2; }}
                | LPAREN RPAREN                         {{ $$ = []; }}
                ;

lvalue          : id                                    {{ $$ = {node:'variable',id:$1}; }}
                | lvalue LBRACK exprs RBRACK            {{ $$ = $1;
                                                           for(var i=0; i < $3.length; i++) {
                                                             $$ = {node:'expr_array_deref',lvalue:$$,expr:$3[i]} } }} 
                | lvalue DOT id                         {{ $$ = {node:'expr_record_deref',lvalue:$1,component:$3}; }}
                ;
ids             : ids COMMA id                          {{ $$ = $1.concat([$3]); }}
                | id                                    {{ $$ = [$1]; }}
                ;
id              : ID                                    {{ $$ = yytext.toUpperCase(); }}
                ;
