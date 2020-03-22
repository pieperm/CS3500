/*
    	mfpl.y

 	Specifications for the MFPL language, bison input file.

     	To create syntax analyzer:

        flex mfpl.l
        bison mfpl.y
        g++ mfpl.tab.c -o mfpl_parser
        mfpl_parser < inputFileName
 */

/*
 *	Declaration section.
 */
%{
#include <stdio.h>
#include <iostream>
#include <stack>
#include "SymbolTable.h"
using namespace std;

int lineNum = 1; 

void printRule(const char *, const char *);
void prepareToTerminate();
void bail();
void beginScope();
void endScope();
bool findEntryInAnyScope(const string theName);
void printExpressionType(const int type);

stack<SYMBOL_TABLE> scopeStack;



int yyerror(const char *s) 
{
  printf("Line %d: %s\n", lineNum, s);
  bail();
  return 0;
}

extern "C" 
{
    int yyparse(void);
    int yylex(void);
    int yywrap() {return 1;}
}

%}

%union
{
	char* text;
	TYPE_INFO typeInfo;
	int binOpType;
}

/*
 *	Token declarations
*/
%token  T_LPAREN T_RPAREN 
%token  T_IF T_LETSTAR T_LAMBDA T_PRINT T_INPUT T_PROGN
%token  T_EXIT T_ADD  T_SUB  T_MULT  T_DIV
%token  T_LT T_GT T_LE T_GE T_EQ T_NE T_AND T_OR T_NOT	 
%token  T_INTCONST T_STRCONST T_T T_NIL T_IDENT T_UNKNOWN

%type <text> T_IDENT
%type <typeInfo> N_CONST N_EXPR N_PARENTHESIZED_EXPR N_IF_EXPR N_ID_EXPR_LIST
%type <typeInfo> N_ARITHLOGIC_EXPR N_LET_EXPR N_LAMBDA_EXPR N_PRINT_EXPR
%type <typeInfo> N_INPUT_EXPR N_EXPR_LIST N_ACTUAL_PARAMS N_PROGN_OR_USERFUNCTCALL
%type <typeInfo> N_FUNCT_NAME
%type <binOpType> N_BIN_OP
/*
 *	Starting point.
 */
%start  N_START

/*
 *	Translation rules.
 */
%%
N_START		: // epsilon 
			{
			
			}
			| N_START N_EXPR
			{
			printExpressionType($2.type);
			printf("---- Completed parsing ----\n\n");
			}
			;
N_EXPR		: N_CONST				//gotta cast type from further step from previous step
			{
			$$.type = $1.type;
			$$.numParams = 0;
			$$.returnType = $1.returnType;
			}
								| T_IDENT
      {
			
			bool found = findEntryInAnyScope(string($1));
			if(!found)
				yyerror("undefined identifier");
			
			TYPE_INFO info = scopeStack.top().findEntry(string($1));
			$$.type = info.type;
			$$.numParams = info.numParams;
			$$.returnType = info.returnType;
			}
                | T_LPAREN N_PARENTHESIZED_EXPR T_RPAREN
      {
			$$.type = $2.type;
			$$.numParams = $2.numParams;
			$$.returnType = $2.returnType;
			}
			;
N_CONST		: T_INTCONST
			{
			
			$$.type = INT;
			$$.numParams = NOT_APPLICABLE;
			$$.returnType = NOT_APPLICABLE;
			}
                | T_STRCONST
			{
			
			$$.type = STR;
			$$.numParams = NOT_APPLICABLE;
			$$.returnType = NOT_APPLICABLE;
			}
                | T_T
      {
			
			$$.type = BOOL;
			$$.numParams = NOT_APPLICABLE;
			$$.returnType = NOT_APPLICABLE;
			}
                | T_NIL
      {
			
			$$.type = BOOL;
			$$.numParams = NOT_APPLICABLE;
			$$.returnType = NOT_APPLICABLE;
			}
			;
N_PARENTHESIZED_EXPR	: N_ARITHLOGIC_EXPR 
				{
				$$.type = $1.type;
				$$.numParams = UNDEFINED;
				$$.returnType = $1.returnType;
				}
                      | N_IF_EXPR 
				{
				$$.type = $1.type;
				$$.numParams = UNDEFINED;
				$$.returnType = $1.returnType;
				}
                      | N_LET_EXPR 
				{
				$$.type = $1.type;
				$$.numParams = $1.numParams;
				$$.returnType = $1.returnType;
				}
                      | N_LAMBDA_EXPR 
				{
				$$.type = $1.type;
				$$.numParams = UNDEFINED;
				$$.returnType = $1.returnType;
				}
                      | N_PRINT_EXPR 
				{
				$$.type = $1.type;
				$$.numParams = UNDEFINED;
				$$.returnType = $1.returnType;
				}
                      | N_INPUT_EXPR 
				{
				$$.type = $1.type;
				$$.numParams = UNDEFINED;
				$$.returnType = $1.returnType;
				}
                     | N_PROGN_OR_USERFUNCTCALL 
				{
				$$.type = $1.type;
				$$.numParams = $1.numParams;
				$$.returnType = $1.returnType;
				}
				| T_EXIT
				{
				bail();
				}
				;
N_PROGN_OR_USERFUNCTCALL : N_FUNCT_NAME N_ACTUAL_PARAMS
				{
				$$.type = $1.type;
				if($1.type == UNDEFINED)
				{
					$$.type = $2.type;
					if($2.type == -1)
					{
						if($1.numParams < $2.numParams)
							yyerror("Too many parameters in function call");
						if($1.numParams > $2.numParams)
							yyerror("Too few parameters in function call");
					if($2.type == -1)
						$$.type = BOOL;
					}
				}
				}
				| T_LPAREN N_LAMBDA_EXPR T_RPAREN N_ACTUAL_PARAMS
				{
				if($2.numParams < $4.numParams)
					yyerror("Too many parameters in function call");
				if($2.numParams > $4.numParams)
					yyerror("Too few parameters in function call");
				$$.type = $2.returnType;
				}
				;
N_ACTUAL_PARAMS : N_EXPR_LIST{
				$$.type = $1.type;
				$$.numParams = $1.numParams;
				$$.returnType = $1.returnType;
				}
				| //epsilon
				{
				$$.type = NOT_APPLICABLE;
				$$.numParams = 0;
				$$.returnType = NOT_APPLICABLE;
				}
N_FUNCT_NAME		: T_PROGN
				{
				$$.type = UNDEFINED;
				$$.numParams = 0;
				$$.returnType = UNDEFINED;
				}
				| T_IDENT
				{
				bool found = findEntryInAnyScope(string($1));
				if(!found)
					yyerror("undefined identifier");
				else
				{
					TYPE_INFO info = scopeStack.top().findEntry(string($1));
					if(info.type != 0)
						yyerror("Arg 1 must be a function");
					$$.type = info.returnType;
					$$.numParams = info.numParams;
					$$.returnType = UNDEFINED;
				}
				}
                     	;
N_ARITHLOGIC_EXPR	: N_UN_OP N_EXPR
				{
				if($2.type == FUNCTION)
					yyerror("Arg 1 cannot be a function");
				$$.type = BOOL;
				$$.numParams = NOT_APPLICABLE;
				$$.returnType = NOT_APPLICABLE;
				}
				| N_BIN_OP N_EXPR N_EXPR
				{
				if($1 == 1) {  // arithmetic operator
				    if(!($2.type & INT)) {
				        yyerror("Arg 1 must be integer");
				    } else if(!($3.type & INT)) {
				        yyerror("Arg 2 must be integer");
				    } else {
				        $$.type = INT;
				    }
				} else if($1 == 2) {  // logical operator
				    if($2.type == FUNCTION) {
				        yyerror("Arg 1 cannot be a function");
				    } else if($3.type == FUNCTION) {
				        yyerror("Arg 2 cannot be a function");
				    } else {
				        $$.type = BOOL;
				    }
				} else if($1 == 3) {  // relational operator
                    if(!($2.type & INT) && !($2.type & STR)) {
                        yyerror("Arg 1 must be integer or string");
                    } else if(!($3.type & INT) && !($3.type & STR)) {
                        yyerror("Arg 2 must be integer or string");
                    } else {
                        $$.type = BOOL;
                    }
				}
				}
                     	;
N_IF_EXPR    	: T_IF N_EXPR N_EXPR N_EXPR
			{
			if($2.type == FUNCTION)
				yyerror("Arg 1 cannot be a function");
			else if($3.type == FUNCTION)
				yyerror("Arg 2 cannot be a function");
			else if($4.type == FUNCTION)
				yyerror("Arg 3 cannot be a function");
			else
			{
			$$.type = $3.type | $4.type;
			$$.numParams = UNDEFINED;
			$$.returnType = UNDEFINED;
			}
			}
			;
N_LET_EXPR      : T_LETSTAR T_LPAREN N_ID_EXPR_LIST T_RPAREN N_EXPR
			{
			endScope();
			if($5.type == FUNCTION)
				yyerror("Arg 2 cannot be a function");
			else
			{
			$$.type = $5.type;
			$$.numParams = $5.numParams;
			$$.returnType = $5.returnType;
			}
			}
			;
N_ID_EXPR_LIST  : /* epsilon */
			{
			$$.type = NOT_APPLICABLE;
			$$.numParams = 0;
			$$.returnType = NOT_APPLICABLE;
			}
      | N_ID_EXPR_LIST T_LPAREN T_IDENT N_EXPR T_RPAREN 
			{
			
			TYPE_INFO info = scopeStack.top( ).findEntry(string($3));
			if (info.type != -1)
				yyerror("multiply defined identifier");
			else
			{
				SYMBOL_TABLE_ENTRY x(string($3), $4);
				scopeStack.top().addEntry(x);
				printf("___Adding %s to symbol table\n", $3);
			}
			}
			;
N_LAMBDA_EXPR   : T_LAMBDA T_LPAREN N_ID_LIST T_RPAREN N_EXPR
			{
			if($5.type == FUNCTION)
				yyerror("Arg 2 cannot be a function");
			else
			{
			$$.type = FUNCTION;
			$$.numParams = scopeStack.top().size(); //supposed to be length of N_ID_LIST
			$$.returnType = $5.type;
			}
			endScope();
			}
			;
N_ID_LIST       : /* epsilon */
			{
			
			}
      | N_ID_LIST T_IDENT 
			{
			
			TYPE_INFO finder = scopeStack.top( ).findEntry(string($2));
			if (finder.type != -1)
				yyerror("multiply defined identifier");
			else
			{
				TYPE_INFO temp;
				temp.type = INT_OR_STR_OR_BOOL;
				SYMBOL_TABLE_ENTRY x(string($2), temp);
				scopeStack.top().addEntry(x);
				printf("___Adding %s to symbol table\n", $2);
			}
			}
			;
N_PRINT_EXPR    : T_PRINT N_EXPR
			{
			if($2.type == FUNCTION)
				yyerror("Arg 1 cannot be a function");
			else
				{
				$$.type = $2.type;
				$$.numParams = UNDEFINED;
				$$.returnType = UNDEFINED;
				}
			}
			;
N_INPUT_EXPR    : T_INPUT
			{
			$$.type = INT_OR_STR;
			$$.numParams = UNDEFINED;
			$$.returnType = UNDEFINED;
			}
			;
N_EXPR_LIST     : N_EXPR N_EXPR_LIST  
			{
			$$.type = $2.type;
			$$.numParams = $2.numParams + 1;
			$$.returnType = $2.returnType;
			}
      | N_EXPR
			{
			$$.type = $1.type;
			$$.numParams = $1.numParams + 1; //add 1 for the current expression
			$$.returnType = $1.returnType;
			}
			;
N_BIN_OP	     : N_ARITH_OP
			{
			$$ = 1;
			}
			|
			N_LOG_OP
			{
			$$ = 2;
			}
			|
			N_REL_OP
			{
			$$ = 3;
			}
			;
N_ARITH_OP	     : T_ADD
			{
			
			}
      | T_SUB
			{
			
			}
			| T_MULT
			{
			
			}
			| T_DIV
			{
			
			}
			;
N_REL_OP	     : T_LT
			{
			
			}	
			| T_GT
			{
			
			}	
			| T_LE
			{
			
			}	
			| T_GE
			{
			
			}	
			| T_EQ
			{
			
			}	
			| T_NE
			{
			
			}
			;	
N_LOG_OP	     : T_AND
			{
			
			}	
			| T_OR
			{
			
			}
			;
N_UN_OP	     : T_NOT
			{
			
			}
			;
%%

#include "lex.yy.c"
extern FILE *yyin;

void printRule(const char *lhs, const char *rhs) 
{
  printf("%s -> %s\n", lhs, rhs);
  return;
}

void prepareToTerminate()
{
  cout << endl << "Bye!" << endl;
}

void bail()
{
  prepareToTerminate();
  exit(1);
}

void beginScope()
{
	scopeStack.push(SYMBOL_TABLE());
	printf("\n___Entering new scope...\n\n");
}

void endScope()
{
	scopeStack.pop();
	printf("\n___Exiting scope...\n\n");
}

bool findEntryInAnyScope(const string theName)
{
	if (scopeStack.empty()) return(false);
	TYPE_INFO finder = scopeStack.top().findEntry(theName);
	int found = finder.type;
	if (found != -1)
		return(true);
	else 
	{ // check in "next higher" scope
		SYMBOL_TABLE symbolTable = scopeStack.top();
		scopeStack.pop();
		found = findEntryInAnyScope(theName);
		scopeStack.push(symbolTable); 			// restore the stack
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

int main()
{
  do 
  {
	yyparse();
  } while (!feof(yyin));

  prepareToTerminate();
  return 0;
}
