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
#include <cstring>
#include "SymbolTable.h"
using namespace std;

int lineNum = 1; 

void printRule(const char *, const char *);
void prepareToTerminate();
void bail();
void beginScope();
void endScope();
TYPE_INFO findEntryInAnyScope(const string theName);
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
	bool boolType;
}

/*
 *	Token declarations
*/
%token  T_LPAREN T_RPAREN 
%token  T_IF T_LETSTAR T_LAMBDA T_PRINT T_INPUT T_PROGN
%token  T_EXIT T_ADD  T_SUB  T_MULT  T_DIV
%token  T_LT T_GT T_LE T_GE T_EQ T_NE T_AND T_OR T_NOT	 
%token  T_INTCONST T_STRCONST T_T T_NIL T_IDENT T_UNKNOWN

%type <binOpType> T_INTCONST N_LOG_OP N_REL_OP N_ARITH_OP
%type <boolType> T_T T_NIL
%type <text> T_IDENT T_STRCONST  
%type <text> T_LT T_GT T_LE T_GE T_EQ T_NE T_AND T_OR T_ADD  T_SUB  T_MULT  T_DIV
%type <typeInfo> N_CONST N_EXPR N_PARENTHESIZED_EXPR N_IF_EXPR N_ID_EXPR_LIST
%type <typeInfo> N_ARITHLOGIC_EXPR N_LET_EXPR  N_PRINT_EXPR
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
			printf("\n---- Completed parsing ----\n\n");
			printf("\nValue of the expression is: ");
			
			if($2.type == INT)
			{
			printf("%d", $2.intVal);
			}
			else if($2.type == STR)
			{
			printf("%s", $2.strVal);
			}
			else
			{
			if($2.boolVal)
				printf("t");
			else
				printf("nil");
			}	
			
			printf("\n");
			}
			;
N_EXPR		: N_CONST				//gotta cast type from further step from previous step
			{
			$$.type = $1.type;
			$$.numParams = 0;
			$$.returnType = $1.returnType;
			$$.intVal = $1.intVal;
			$$.strVal = $1.strVal;
			$$.boolVal = $1.boolVal;
			}
								| T_IDENT
      {
			
			TYPE_INFO found = findEntryInAnyScope(string($1));
			if(found.type == NOT_APPLICABLE)
				yyerror("undefined identifier");
			
			TYPE_INFO info = findEntryInAnyScope(string($1));
			$$.type = info.type;
			$$.numParams = info.numParams;
			$$.returnType = info.returnType;
			$$.intVal = info.intVal;
			$$.strVal = info.strVal;
			$$.boolVal = info.boolVal;
			}
                | T_LPAREN N_PARENTHESIZED_EXPR T_RPAREN
      {
			$$.type = $2.type;
			$$.numParams = $2.numParams;
			$$.returnType = $2.returnType;
			$$.intVal = $2.intVal;
			$$.strVal = $2.strVal;
			$$.boolVal = $2.boolVal;
			}
			;
N_CONST		: T_INTCONST
			{
			
			$$.type = INT;
			$$.numParams = NOT_APPLICABLE;
			$$.returnType = NOT_APPLICABLE;
			$$.intVal = $1;
			$$.boolVal = true;
			}
                | T_STRCONST
			{
			
			$$.type = STR;
			$$.numParams = NOT_APPLICABLE;
			$$.returnType = NOT_APPLICABLE;
			$$.strVal = $1;
			$$.boolVal = true;
			}
                | T_T
      {
			
			$$.type = BOOL;
			$$.numParams = NOT_APPLICABLE;
			$$.returnType = NOT_APPLICABLE;
			$$.boolVal = true;
			}
                | T_NIL
      {
			
			$$.type = BOOL;
			$$.numParams = NOT_APPLICABLE;
			$$.returnType = NOT_APPLICABLE;
			$$.boolVal = false;
			}
			;
N_PARENTHESIZED_EXPR	: N_ARITHLOGIC_EXPR 
				{
				$$.type = $1.type;
				$$.numParams = UNDEFINED;
				$$.returnType = $1.returnType;
				$$.intVal = $1.intVal;
				$$.strVal = $1.strVal;
				$$.boolVal = $1.boolVal;
				}
                      | N_IF_EXPR 
				{
				$$.type = $1.type;
				$$.numParams = UNDEFINED;
				$$.returnType = $1.returnType;
				$$.intVal = $1.intVal;
				$$.strVal = $1.strVal;
				$$.boolVal = $1.boolVal;
				}
                      | N_LET_EXPR 
				{
				$$.type = $1.type;
				$$.numParams = $1.numParams;
				$$.returnType = $1.returnType;
				$$.intVal = $1.intVal;
				$$.strVal = $1.strVal;
				$$.boolVal = $1.boolVal;
				}
                      | N_PRINT_EXPR 
				{
				$$.type = $1.type;
				$$.numParams = UNDEFINED;
				$$.returnType = $1.returnType;
				$$.intVal = $1.intVal;
				$$.strVal = $1.strVal;
				$$.boolVal = $1.boolVal;
				}
                      | N_INPUT_EXPR 
				{
				$$.type = $1.type;
				$$.numParams = UNDEFINED;
				$$.returnType = $1.returnType;
				$$.intVal = $1.intVal;
				$$.strVal = $1.strVal;
				$$.boolVal = $1.boolVal;
				}
                     | N_PROGN_OR_USERFUNCTCALL 
				{
				$$.type = $1.type;
				$$.numParams = $1.numParams;
				$$.returnType = $1.returnType;
				$$.intVal = $1.intVal;
				$$.strVal = $1.strVal;
				$$.boolVal = $1.boolVal;
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
				$$.intVal = $2.intVal;
				$$.strVal = $2.strVal;
				$$.boolVal = $2.boolVal;
				}
				;
N_ACTUAL_PARAMS : N_EXPR_LIST{
				$$.type = $1.type;
				$$.numParams = $1.numParams;
				$$.returnType = $1.returnType;
				$$.intVal = $1.intVal;
				$$.strVal = $1.strVal;
				$$.boolVal = $1.boolVal;
				}
				| //epsilon
				{
				$$.type = NOT_APPLICABLE;
				$$.numParams = 0;
				$$.returnType = NOT_APPLICABLE;
				$$.intVal = 0;
				$$.boolVal = false;
				}
N_FUNCT_NAME		: T_PROGN
				{
				$$.type = UNDEFINED;
				$$.numParams = 0;
				$$.returnType = UNDEFINED;
				}
                     	;
N_ARITHLOGIC_EXPR	: N_UN_OP N_EXPR
				{
				if($2.type == FUNCTION)
					yyerror("Arg 1 cannot be a function");
				$$.type = BOOL;
				$$.numParams = NOT_APPLICABLE;
				$$.returnType = NOT_APPLICABLE;
				if($2.type == BOOL)
					$$.boolVal = !($2.boolVal);
				else if($2.type == INT)
					$$.boolVal = false;
				}
				| N_BIN_OP N_EXPR N_EXPR
				{
				if($1 == 11 || $1 == 12 || $1 == 13 || $1 == 14)				{  // arithmetic operator
						if(!($2.type & INT)) {
				        yyerror("Arg 1 must be integer");
				    } else if(!($3.type & INT)) {
				        yyerror("Arg 2 must be integer");
				    } else {
				        $$.type = INT;
								if($1 == 11)
									$$.intVal = $2.intVal + $3.intVal;
								else if($1 == 12)
									$$.intVal = $2.intVal - $3.intVal;
								else if($1 == 13)
									$$.intVal = $2.intVal * $3.intVal;
								else
								{
									if($3.intVal == 0)
										yyerror("Attempted division by zero");
									$$.intVal = $2.intVal / $3.intVal;
								}
				    }
				} else if($1 == 21 || $1 == 22) {  // logical operator
				    if($2.type == FUNCTION) {
				        yyerror("Arg 1 cannot be a function");
				    } else if($3.type == FUNCTION) {
				        yyerror("Arg 2 cannot be a function");
				    } else {
				        $$.type = BOOL;
								if($1 == 21)
									$$.boolVal = $2.boolVal && $3.boolVal;
								else
									$$.boolVal = $2.boolVal || $3.boolVal;
				    }
				} else if($1 == 31 || $1 == 32 || $1 == 33 || $1 == 34 
									|| $1 == 35 || $1 == 36) {  // relational operator
                    if(!($2.type & INT) && !($2.type & STR)) {
                        yyerror("Arg 1 must be integer or string");
                    } else if(!($3.type & INT) && !($3.type & STR)) {
                        yyerror("Arg 2 must be integer or string");
                    } else {
                        $$.type = BOOL;
												if($2.type == INT)
												{
													if($3.type != INT)
														yyerror("Arg 2 must be integer");
													else if($1 == 31)
														$$.boolVal = $2.intVal < $3.intVal;
													else if($1 == 32)
														$$.boolVal = $2.intVal > $3.intVal;
													else if($1 == 33)
														$$.boolVal = $2.intVal <= $3.intVal;
													else if($1 == 34)
														$$.boolVal = $2.intVal >= $3.intVal;
													else if($1 == 35)
														$$.boolVal = $2.intVal == $3.intVal;
													else if($1 == 36)
														$$.boolVal = $2.intVal != $3.intVal;
												}
												else
												{
													if($3.type != STR)
														yyerror("Arg 2 must be string");
													else if($1 == 31)
														$$.boolVal = $2.strVal < $3.strVal;
													else if($1 == 32)
														$$.boolVal = $2.strVal > $3.strVal;
													else if($1 == 33)
														$$.boolVal = $2.strVal <= $3.strVal;
													else if($1 == 34)
														$$.boolVal = $2.strVal >= $3.strVal;
													else if($1 == 35)
													{
														if(strcmp($2.strVal, $3.strVal) == 0)
															$$.boolVal = true;
														else
															$$.boolVal = false;
													}
													else if($1 == 36)
														$$.boolVal = $2.strVal != $3.strVal;
												}
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
				if($2.type == INT)
					$2.boolVal = true;
				if($2.boolVal == false)
				{
					if($4.type == INT)
					{
					$$.intVal = $4.intVal;
					$$.type = INT;
					}
					else if($4.type == STR)
					{
					$$.strVal = $4.strVal;
					$$.type = $4.type;
					}
					else if($4.type == BOOL)
					{
					$$.boolVal = $4.boolVal;
					$$.type = $4.type;
					}
				}
				else
				{
					if($3.type == INT)
					{
					$$.intVal = $3.intVal;
					$$.type = INT;
					}
					else if($3.type == STR)
					{
					$$.strVal = $3.strVal;
					$$.type = STR;
					}
					else if($3.type == BOOL)
					{
					$$.boolVal = $3.boolVal;
					$$.type = BOOL;
					}
				}
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
			$$.intVal = $5.intVal;
			$$.strVal = $5.strVal;
			$$.boolVal = $5.boolVal;
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
				$$.intVal = $2.intVal;
				$$.strVal = $2.strVal;
				$$.boolVal = $2.boolVal;
				
				if($2.type == INT)
				{
				printf("%d\n", $2.intVal);
				}
				else if($2.type == STR)
				{
				printf("%s\n", $2.strVal);
				}
				else if($2.type == BOOL)
				{
					if($2.boolVal)
						printf("t\n");
					else
						printf("nil\n");
				}
			}
			}
			;
N_INPUT_EXPR    : T_INPUT
			{
			string userInput;
			getline(cin, userInput);
			if(userInput.at(0) == '+' || userInput.at(0) == '-' 
				|| userInput[0] <= 57 && userInput[0] >= 48)
			{
				$$.type = INT;
				$$.intVal = atoi(userInput.c_str());
			}
			else
			{
				$$.type = STR;
				$$.strVal = const_cast<char*>(userInput.c_str());
			}
			$$.numParams = UNDEFINED;
			$$.returnType = UNDEFINED;
			}
			;
N_EXPR_LIST     : N_EXPR N_EXPR_LIST  
			{
			$$.type = $2.type;
			$$.numParams = $2.numParams + 1;
			$$.returnType = $2.returnType;
			$$.intVal = $2.intVal;
			$$.strVal = $2.strVal;
			$$.boolVal = $2.boolVal;
			}
      | N_EXPR
			{
			$$.type = $1.type;
			$$.numParams = $1.numParams + 1; //add 1 for the current expression
			$$.returnType = $1.returnType;
			$$.intVal = $1.intVal;
			$$.strVal = $1.strVal;
			$$.boolVal = $1.boolVal;
			}
			;
N_BIN_OP	     : N_ARITH_OP
			{
			if($1 == 1)
				$$ = 11;
			else if($1 == 2)
				$$ = 12;
			else if($1 == 3)
				$$ = 13;
			else
				$$ = 14;
			}
			|
			N_LOG_OP
			{
			if($1 == 1)
				$$ = 21;
			else
				$$ = 22;
			}
			|
			N_REL_OP
			{
			if($1 == 1)
				$$ = 31;
			if($1 == 2)
				$$ = 32;
			if($1 == 3)
				$$ = 33;
			if($1 == 4)
				$$ = 34;
			if($1 == 5)
				$$ = 35;
			if($1 == 6)
				$$ = 36;
			}
			;
N_ARITH_OP	     : T_ADD
			{
			$$ = 1;
			}
      | T_SUB
			{
			$$ = 2;
			}
			| T_MULT
			{
			$$ = 3;
			}
			| T_DIV
			{
			$$ = 4;
			}
			;
N_REL_OP	     : T_LT
			{
			$$ = 1;
			}	
			| T_GT
			{
			$$ = 2;
			}	
			| T_LE
			{
			$$ = 3;
			}	
			| T_GE
			{
			$$ = 4;
			}	
			| T_EQ
			{
			$$ = 5;
			}	
			| T_NE
			{
			$$ = 6;
			}
			;	
N_LOG_OP	     : T_AND
			{
			$$ = 1;
			}	
			| T_OR
			{
			$$ = 2;
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
}

void endScope()
{
	scopeStack.pop();
}

TYPE_INFO findEntryInAnyScope(const string theName)
{
	if (scopeStack.empty()) 
	{
		TYPE_INFO temp;
		temp.type = NOT_APPLICABLE;
		return(temp);
	}
	TYPE_INFO finder = scopeStack.top().findEntry(theName);
	int found = finder.type;
	if (found != -1)
		return(finder);
	else 
	{ // check in "next higher" scope
		SYMBOL_TABLE symbolTable = scopeStack.top();
		scopeStack.pop();
		finder = findEntryInAnyScope(theName);
		scopeStack.push(symbolTable); 			// restore the stack
		return(finder);
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

int main(int argc, char** argv)
{
	if(argc < 2)
	{
		printf("You must specify a file in the command line!\n");
		exit(1);
	}
	yyin = fopen(argv[1], "r");
  do 
  {
	yyparse();
  } while (!feof(yyin));

  prepareToTerminate();
  return 0;
}
