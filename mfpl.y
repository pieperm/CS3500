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
bool printLexemes = false;
bool printProductions = true;

void printRule(const char*, const char*);
int yyerror(const char *s);
void printTokenInfo(const char* tokenType, const char* lexeme);
void beginScope();
void endScope();
void addToSymbolTable(const char* name, const TYPE_INFO typeInfo);
void checkForDefinition(const char* name);
bool findEntryInAnyScope(const string theName);
void printExpressionType(const int type);

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
%type <typeInfo> N_CONST N_EXPR N_PARENTHESIZED_EXPR N_IF_EXPR N_ID_EXPR_LIST
%type <typeInfo> N_ARITHLOGIC_EXPR N_LET_EXPR N_LAMBDA_EXPR N_PRINT_EXPR
%type <typeInfo> N_INPUT_EXPR N_EXPR_LIST

%start N_START

%%
N_START	: {

}
| N_START N_EXPR {

  printf("\n---- Completed parsing ----\n\n");
};

N_EXPR : N_CONST {

  printExpressionType($1.type);
}
| T_IDENT {

  checkForDefinition($1);
  TYPE_INFO info = scopeStack.top().getEntry(string($1)).getTypeInfo();
  printExpressionType(info.type);
}
| T_LPAREN N_PARENTHESIZED_EXPR T_RPAREN {

  $$.type = $2.type;
  $$.numParams = $2.numParams;
  $$.returnType = $2.returnType;
  printExpressionType($2.type);
};

N_CONST : T_INTCONST {

  $$.type = INT;
  $$.numParams = NOT_APPLICABLE;
  $$.returnType = NOT_APPLICABLE;
}
| T_STRCONST {

  $$.type = STR;
  $$.numParams = NOT_APPLICABLE;
  $$.returnType = NOT_APPLICABLE;
}
| T_T {

  $$.type = BOOL;
  $$.numParams = NOT_APPLICABLE;
  $$.returnType = NOT_APPLICABLE;
}
| T_NIL {

  $$.type = BOOL;
  $$.numParams = NOT_APPLICABLE;
  $$.returnType = NOT_APPLICABLE;
};

N_PARENTHESIZED_EXPR : N_ARITHLOGIC_EXPR {

}
| N_IF_EXPR {

}
| N_LET_EXPR {

}
| N_LAMBDA_EXPR {

}
| N_PRINT_EXPR {

}
| N_INPUT_EXPR {

}
| N_PROGN_OR_USERFUNCTCALL {

}
| T_EXIT {

  printf("\nBye!\n");
  exit(0);
};

N_PROGN_OR_USERFUNCTCALL : N_FUNCT_NAME N_ACTUAL_PARAMS {

}
| T_LPAREN N_LAMBDA_EXPR T_RPAREN N_ACTUAL_PARAMS {

};

N_ACTUAL_PARAMS : N_EXPR_LIST {

}
| {

};

N_FUNCT_NAME : T_PROGN {

}
| T_IDENT {

  checkForDefinition($1);
};

N_ARITHLOGIC_EXPR : N_UN_OP N_EXPR {

}
| N_BIN_OP N_EXPR N_EXPR {

};

N_IF_EXPR : T_IF N_EXPR N_EXPR N_EXPR {

};

N_LET_EXPR : T_LETSTAR T_LPAREN N_ID_EXPR_LIST T_RPAREN N_EXPR {

  endScope();
};

N_ID_EXPR_LIST : /*epsilon*/ {

}
| N_ID_EXPR_LIST T_LPAREN T_IDENT N_EXPR T_RPAREN {

//  addToSymbolTable($3, $$);
};

N_LAMBDA_EXPR : T_LAMBDA T_LPAREN N_ID_LIST T_RPAREN N_EXPR {

  endScope();
};

N_ID_LIST : /*epsilon*/ {

}
| N_ID_LIST T_IDENT {

//  addToSymbolTable($2, $$);
};

N_PRINT_EXPR : T_PRINT N_EXPR {

};

N_INPUT_EXPR : T_INPUT {

};

N_EXPR_LIST : N_EXPR N_EXPR_LIST {

}
| {

};

N_BIN_OP : N_ARITH_OP {

}
| N_LOG_OP {

}
| N_REL_OP {

};

N_ARITH_OP : T_MULT {

}
| T_SUB {

}
| T_DIV {

}
| T_ADD {

};

N_LOG_OP : T_AND {

}
| T_OR {

};

N_REL_OP : T_LT {

}
| T_GT {

}
| T_LE {

}
| T_GE {

}
| T_EQ {

}
| T_NE {

};

N_UN_OP : T_NOT {

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

void addToSymbolTable(const char* name, const TYPE_INFO typeInfo) {
  string nameStr = string(name);
  bool multiplyDefined = scopeStack.top().findEntry(nameStr);
  printf("___Adding %s to symbol table\n", name);
  if(multiplyDefined) {
    yyerror("Multiply defined identifier");
  } else {
    scopeStack.top().addEntry(SYMBOL_TABLE_ENTRY(nameStr, typeInfo));
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

void printExpressionType(const int type) {
  char const * typeStr;
  switch(type) {
    case 0:
      typeStr = "FUNCTION";
      break;
    case 1:
      typeStr = "INT";
      break;
    case 2:
      typeStr = "STR";
      break;
    case 3:
      typeStr = "INT_OR_STR";
      break;
    case 4:
      typeStr = "BOOL";
      break;
    case 5:
      typeStr = "INT_OR_BOOL";
      break;
    case 6:
      typeStr = "STR_OR_BOOL";
      break;
    case 7:
      typeStr = "INT_OR_STR_OR_BOOL";
      break;
  }
  printf("EXPR type is: %s\n", typeStr);
}

int main() {
  do {
    yyparse();
  } while(!feof(yyin));

  printf("\nBye!\n");

  return(0);
}
