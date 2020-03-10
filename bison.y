/*
pieperm.y
Bison specification for MFPL language
*/

%{
#include <stdio.h>
#include "SymbolTable.h"
#include <stack>

int lineNumber = 1;
stack<SYMBOL_TABLE> scopeStack;
bool printLexemes = true;
bool printProductions = true;

void printRule(const char*, const char*);
int yyerror(const char *s);
void printTokenInfo(const char* tokenType, const char* lexeme);
void beginScope();
void endScope();
void addToSymbolTable(const char* name);
void checkForDefinition(const char* name);
bool findEntryInAnyScope(const string theName);

extern "C"
{
  int yyparse(void);
  int yylex(void);
  int yywrap() { return 1; }
}

%}

%union
{
  char* text;
  TYPE_INFO typeInfo;
}

%token T_LETSTAR T_LAMBDA T_INPUT T_PRINT T_IF T_EXIT T_PROGN T_LPAREN T_RPAREN
%token T_ADD T_MULT T_DIV T_SUB T_AND T_OR T_NOT
%token T_LT T_GT T_LE T_GE T_EQ T_NE
%token T_T T_NIL T_IDENT T_INTCONST T_STRCONST T_UNKNOWN

%type <text> T_IDENT
%type <typeInfo> N_CONST N_EXPR N_PARENTHESIZED_EXPR N_IF_EXPR

%start N_START

%%
N_START	: {
  printRule("START", "epsilon");
}
| N_START N_EXPR {
  printRule("START", "START EXPR");
  printf("\n---- Completed parsing ----\n\n");
};

N_EXPR : N_CONST {
  printRule("EXPR", "CONST");
  $$.type = $1.type;
  $$.numParams = $1.numParams;
  $$.returnType = $1.returnType;
}
| T_IDENT {
  printRule("EXPR", "IDENT");
  checkForDefinition($1);
  $$.type = $1.type;
  $$.numParams = $1.numParams;
  $$.returnType = $1.returnType;
}
| T_LPAREN N_PARENTHESIZED_EXPR T_RPAREN {
  printRule("EXPR", "( PARENTHESIZED_EXPR )");
  $$.type = $2.type;
  $$.numParams = $2.numParams;
  $$.returnType = $2.returnType;
};

N_CONST : T_INTCONST {
  printRule("CONST", "INTCONST");
  $$.type = INT;
  $$.numParams = NOT_APPLICABLE;
  $$.returnType = NOT_APPLICABLE;
}
| T_STRCONST {
  printRule("CONST", "STRCONST");
  $$.type = STR;
  $$.numParams = NOT_APPLICABLE;
  $$.returnType = NOT_APPLICABLE;
}
| T_T {
  printRule("CONST", "t");
  $$.type = BOOL;
  $$.numParams = NOT_APPLICABLE;
  $$.returnType = NOT_APPLICABLE;
}
| T_NIL {
  printRule("CONST", "nil");
  $$.type = BOOL;
  $$.numParams = NOT_APPLICABLE;
  $$.returnType = NOT_APPLICABLE;
};

N_PARENTHESIZED_EXPR : N_ARITHLOGIC_EXPR {
  printRule("PARENTHESIZED_EXPR", "ARITHLOGIC_EXPR");
}
| N_IF_EXPR {
  printRule("PARENTHESIZED_EXPR", "IF_EXPR");
}
| N_LET_EXPR {
  printRule("PARENTHESIZED_EXPR", "LET_EXPR");
}
| N_LAMBDA_EXPR {
  printRule("PARENTHESIZED_EXPR", "LAMBDA_EXPR");
}
| N_PRINT_EXPR {
  printRule("PARENTHESIZED_EXPR", "PRINT_EXPR");
}
| N_INPUT_EXPR {
  printRule("PARENTHESIZED_EXPR", "INPUT_EXPR");
}
| N_PROGN_OR_USERFUNCTCALL {
  printRule("PARENTHESIZED_EXPR", "PROGN_OR_USERFUNCTCALL");
}
| T_EXIT {
  printRule("PARENTHESIZED_EXPR", "EXIT");
  printf("\nBye!\n");
  exit(0);
};

N_PROGN_OR_USERFUNCTCALL : N_FUNCT_NAME N_ACTUAL_PARAMS {
  printRule("PROGN_OR_USERFUNCTCALL", "FUNCT_NAME ACTUAL_PARAMS");
}
| T_LPAREN N_LAMBDA_EXPR T_RPAREN N_ACTUAL_PARAMS {
  printRule("PROGN_OR_USERFUNCTCALL", "( LAMBDA_EXPR ) ACTUAL_PARAMS");
};

N_ACTUAL_PARAMS : N_EXPR_LIST {
  printRule("ACTUAL_PARAMS", "EXPR_LIST");
}
| {
  printRule("ACTUAL_PARAMS", "epsilon");
};

N_FUNCT_NAME : T_PROGN {
  printRule("FUNCT_NAME", "PROGN");
}
| T_IDENT {
  printRule("FUNCT_NAME", "IDENT");
  checkForDefinition($1);
};

N_ARITHLOGIC_EXPR : N_UN_OP N_EXPR {
  printRule("ARITHLOGIC_EXPR", "UN_OP EXPR");
}
| N_BIN_OP N_EXPR N_EXPR {
  printRule("ARITHLOGIC_EXPR", "BIN_OP EXPR EXPR");
};

N_IF_EXPR : T_IF N_EXPR N_EXPR N_EXPR {
  printRule("IF_EXPR", "if EXPR EXPR EXPR");
};

N_LET_EXPR : T_LETSTAR T_LPAREN N_ID_EXPR_LIST T_RPAREN N_EXPR {
  printRule("LET_EXPR", "let* ( ID_EXPR_LIST ) EXPR");
  endScope();
};

N_ID_EXPR_LIST : {
  printRule("ID_EXPR_LIST", "epsilon");
}
| N_ID_EXPR_LIST T_LPAREN T_IDENT N_EXPR T_RPAREN {
  printRule("ID_EXPR_LIST", "ID_EXPR_LIST ( IDENT EXPR )");
  addToSymbolTable($3);
};

N_LAMBDA_EXPR : T_LAMBDA T_LPAREN N_ID_LIST T_RPAREN N_EXPR {
  printRule("LAMBDA_EXPR", "lambda ( ID_LIST ) EXPR");
  endScope();
};

N_ID_LIST : {
  printRule("ID_LIST", "epsilon");
}
| N_ID_LIST T_IDENT {
  printRule("ID_LIST", "ID_LIST IDENT");
  addToSymbolTable($2);
};

N_PRINT_EXPR : T_PRINT N_EXPR {
  printRule("PRINT_EXPR", "print EXPR");
};

N_INPUT_EXPR : T_INPUT {
  printRule("INPUT_EXPR", "input");
};

N_EXPR_LIST : N_EXPR N_EXPR_LIST {
  printRule("EXPR_LIST", "EXPR EXPR_LIST");
}
| {
  printRule("EXPR_LIST", "epsilon");
};

N_BIN_OP : N_ARITH_OP {
  printRule("BIN_OP", "ARITH_OP");
}
| N_LOG_OP {
  printRule("BIN_OP", "LOG_OP");
}
| N_REL_OP {
  printRule("BIN_OP", "REL_OP");
};

N_ARITH_OP : T_MULT {
  printRule("ARITH_OP", "*");
}
| T_SUB {
  printRule("ARITH_OP", "-");
}
| T_DIV {
  printRule("ARITH_OP", "/");
}
| T_ADD {
  printRule("ARITH_OP", "+");
};

N_LOG_OP : T_AND {
  printRule("LOG_OP", "and");
}
| T_OR {
  printRule("LOG_OP", "or");
};

N_REL_OP : T_LT {
  printRule("REL_OP", "<");
}
| T_GT {
  printRule("REL_OP", ">");
}
| T_LE {
  printRule("REL_OP", "<=");
}
| T_GE {
  printRule("REL_OP", ">=");
}
| T_EQ {
  printRule("REL_OP", "=");
}
| T_NE {
  printRule("REL_OP", "/=");
};

N_UN_OP : T_NOT {
  printRule("UN_OP", "not");
};

%%

#include "lex.yy.c"
extern FILE *yyin;

void printRule(const char *lhs, const char *rhs)
{
  if(printProductions) {
    printf("%s -> %s\n", lhs, rhs);
  }
  return;
}

int yyerror(const char *s) {
  printf("Line %d: %s\n", lineNumber, s);
  printf("\nBye!\n");
  exit(0);
}

void printTokenInfo(const char* tokenType, const char* lexeme) {
  if(printLexemes) {
    printf("TOKEN: %s  LEXEME: %s\n", tokenType, lexeme);
  }
}

void beginScope() {
  scopeStack.push(SYMBOL_TABLE());
  printf("\n___Entering new scope...\n\n");
}

void endScope() {
  scopeStack.pop();
  printf("\n___Exiting scope...\n\n");
}

void addToSymbolTable(const char* name) {
  string nameStr = string(name);
  bool multiplyDefined = scopeStack.top().findEntry(nameStr);
  printf("___Adding %s to symbol table\n", name);
  if(multiplyDefined) {
    yyerror("Multiply defined identifier");
  } else {
    scopeStack.top().addEntry(SYMBOL_TABLE_ENTRY(nameStr, UNDEFINED));
  }
}

void checkForDefinition(const char* name) {
  string nameStr = string(name);
  bool found = findEntryInAnyScope(nameStr);
  if(!found) {
    yyerror("Undefined identifier");
  }
}

bool findEntryInAnyScope(const string theName) {
  if(scopeStack.empty()) {
    return(false);
  }
  bool found = scopeStack.top().findEntry(theName);
  if(found) {
    return(true);
  } else {
    SYMBOL_TABLE symbolTable = scopeStack.top();
    scopeStack.pop();
    found = findEntryInAnyScope(theName);
    scopeStack.push(symbolTable);
    return(found);
  }
}

int main() {
  do {
    yyparse();
  } while(!feof(yyin));

  printf("\nBye!\n");

  return(0);
}
