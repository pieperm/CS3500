#ifndef SYMBOL_TABLE_ENTRY_H
#define SYMBOL_TABLE_ENTRY_H

#include <string>
using namespace std;

#define UNDEFINED  -1
#define FUNCTION 0							//0000
#define INT 1										//0001
#define STR 2										//0010
#define INT_OR_STR 3						//0011
#define BOOL 4									//0100
#define INT_OR_BOOL 5						//0101
#define STR_OR_BOOL 6						//0110
#define INT_OR_STR_OR_BOOL 7		//0111
#define NOT_APPLICABLE -1

typedef struct {
    int type;
    int numParams;
    int returnType;
		char* strVal;
		int intVal;
		bool boolVal;
} TYPE_INFO;

class SYMBOL_TABLE_ENTRY 
{
private:
  // Member variables
  string name;
  int typeCode;  
	TYPE_INFO typeInfo;

public:
  // Constructors
  SYMBOL_TABLE_ENTRY( ) 
	{
		name = ""; 
		typeInfo.type = UNDEFINED; 
		typeInfo.numParams = UNDEFINED;
		typeInfo.returnType = UNDEFINED;
		typeInfo.intVal = 0;
		typeInfo.boolVal = true;
		typeInfo.strVal = "a";
	}

  SYMBOL_TABLE_ENTRY(const string theName, const TYPE_INFO theType) 
  {
    name = theName;
    typeInfo.type = theType.type;
		typeInfo.numParams = theType.numParams;
		typeInfo.returnType = theType.returnType;
		typeInfo.strVal = theType.strVal;
		typeInfo.intVal = theType.intVal;
		typeInfo.boolVal = theType.boolVal;
  }

  // Accessors
  string getName() const { return name; }
  TYPE_INFO getTypeInfo() const { return typeInfo; }
	
	// Setter
	void setType(int x) { typeInfo.type = x; }
};

#endif  // SYMBOL_TABLE_ENTRY_H
