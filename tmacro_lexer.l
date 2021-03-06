
%{

#include <string.h>
#include "include/util.h"
#include "include/tmacro_parser.tab.h"

/* this defines the End of File token and behavior; without it, 
 * bison rules which rely on EOF can't work */
#define yyterminate() return END

%}

%option stack
%option noyywrap 
%option yylineno 

/* define states here */
%x LEX_ERR

/* regex section */
SINGLE_LINE_COMMENT "//".*
MULTI_LINE_COMMENT "/*".*"*/"

STRING_LITERAL (\"[^"]*\")
CHARACTER_LITERAL ('[^']*')

OPEN_CMD  (?i:"open")
CLOSE_CMD (?i:"close")
WRITE_CMD (?i:"write")
BOL_CMD   (?i:"bol")
EOL_CMD	  (?i:"eol")
FL_CMD	  (?i:"fl")
LL_CMD	  (?i:"ll")
BOF_CMD	  (?i:"bof")
EOF_CMD	  (?i:"eof")
INSERT_CMD (?i:"insert")
UPDATE_CMD (?i:"update")
DELETE_CMD (?i:"delete")
GET_CMD    (?i:"get")
SPLIT_CMD  (?i:"split")
INCR_CMD   (?i:"incr")
DECR_CMD   (?i:"decr")
IF_CMD	   (?i:"if")
ELSE_CMD   (?i:"else")
SWITCH_CMD (?i:"switch")
CASE_CMD   (?i:"case")
DEFAULT_CMD (?i:"default")
DO_CMD      (?i:"do")
WHILE_CMD   (?i:"while")
TIMES_CMD   (?i:"times")

GENERIC_IDENTIFIER [a-zA-Z][a-zA-Z0-9_-]*

MOVE_LR   [lrLR]
MOVE_UD   [udUD]

AND_COND  (?i:"and")
OR_COND   (?i:"or")

INTEGER_LITERAL [0-9]+
DECIMAL_LITERAL [0-9]*(\.[0-9]+)

%%

"\n" |
"\t" 
" " { /* DO NOTHING */ }

"[" |
"]"	|
"," |
"=" { return yytext[0]; }

"+" |
"-" |
"*" |
"/" |
"%" |
"^" { yylval.s = strdup(yytext); return MATH_OP; }

"||" { return CONCAT_OP; }

{STRING_LITERAL}    { yylval.s = strdup(yytext); return STR_LIT; }
{CHARACTER_LITERAL} { yylval.s = strdup(yytext); return CHAR_LIT; }

{INTEGER_LITERAL}   { yylval.i = strtoll(yytext, &yytext, 10); return INT_TOK; }
{DECIMAL_LITERAL}   { yylval.s = strdup(yytext); return DEC_TOK; }

{OPEN_CMD}   { return OPEN_TOK; }
{CLOSE_CMD}  { return CLOSE_TOK; }
{WRITE_CMD}  { return WRITE_TOK; }
{BOL_CMD}    { return BOL_TOK; }
{EOL_CMD}    { return EOL_TOK; }
{FL_CMD}     { return FL_TOK; }
{LL_CMD}     { return LL_TOK; }
{BOF_CMD}	 { return BOF_TOK; }
{EOF_CMD}    { return EOF_TOK; }
{INSERT_CMD} { return INSERT_TOK; }
{UPDATE_CMD} { return UPDATE_TOK; }
{DELETE_CMD} { return DELETE_TOK; }
{GET_CMD}    { return GET_TOK; }
{SPLIT_CMD}  { return SPLIT_TOK; }
{INCR_CMD}   { return INCR_TOK; }
{DECR_CMD}   { return DECR_TOK; }
{IF_CMD}	 { return IF_TOK; }
{ELSE_CMD}   { return ELSE_TOK; }
{SWITCH_CMD} { return SWITCH_TOK; }
{CASE_CMD}   { return CASE_TOK; }
{DEFAULT_CMD} { return DEFAULT_TOK; }
{DO_CMD}      { return DO_TOK; }
{WHILE_CMD}   { return WHILE_TOK; }
{TIMES_CMD}   { return TIMES_TOK; }

{MOVE_LR}   { yylval.c = yytext[0]; return MOVE_LR_TOK; }
{MOVE_UD}   { yylval.c = yytext[0]; return MOVE_UD_TOK; }

{AND_COND} { return AND_TOK; }
{OR_COND}  { return OR_TOK; }

{GENERIC_IDENTIFIER} { yylval.s = strdup(yytext); return ID; }


{SINGLE_LINE_COMMENT} |
{MULTI_LINE_COMMENT} { /* DO NOTHING */ }

.  { BEGIN(LEX_ERR); yyless(1); }
<LEX_ERR>.+ { printf("Syntax error at token: \"%s\", line: %d\n", yytext, yylineno);	
			  BEGIN(INITIAL); }

%%

#pragma warn