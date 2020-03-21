/*
pieperm.l
Lex specification for MFPL language
*/

%{

%}

/* Named definitions of regular expressions */

WHITESPACE     [ \t\v\r]+
NEWLINE        \n
COMMENT        ";".*$
DIGIT		   [0-9]
LETTER		   [a-zA-Z]
IDENT		   ({LETTER}|_)({LETTER}|{DIGIT}|_)*
INTCONST	   (\+|-)*{DIGIT}+
STRCONST	   \".*\"

%%

"let*" {

    beginScope();
    return T_LETSTAR;
}

"lambda" {

    beginScope();
    return T_LAMBDA;
}

"input" {

    return T_INPUT;
}

"print" {

    return T_PRINT;
}

"if" {

    return T_IF;
}

"exit" {

    return T_EXIT;
}

"progn" {

    return T_PROGN;
}

"(" {

    return T_LPAREN;
}

")" {

    return T_RPAREN;
}

"+" {

    return T_ADD;
}

"*" {

    return T_MULT;
}

"/" {

    return T_DIV;
}

"-" {

    return T_SUB;
}

"and" {

    return T_AND;
}

"or" {

    return T_OR;
}

"not" {

    return T_NOT;
}

"<" {

    return T_LT;
}

">" {

    return T_GT;
}

"<=" {

    return T_LE;
}

">=" {

    return T_GE;
}

"=" {

    return T_EQ;
}

"/=" {

    return T_NE;
}

"t" {

    return T_T;
}

"nil" {

    return T_NIL;
}

{WHITESPACE} {

}

{COMMENT} {

}

{NEWLINE} {
    lineNumber++;
}

{IDENT} {
    yylval.text = strdup(yytext);
    printTokenInfo("IDENT", yytext);
    return T_IDENT;
}

{INTCONST} {
    printTokenInfo("INTCONST", yytext);
    return T_INTCONST;
}

{STRCONST} {
    printTokenInfo("STRCONST", yytext);
    return T_STRCONST;
}

. {
    printTokenInfo("UNKNOWN", yytext);
    return T_UNKNOWN;
}

%%