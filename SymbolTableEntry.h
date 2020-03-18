#ifndef SYMBOL_TABLE_ENTRY_H
#define SYMBOL_TABLE_ENTRY_H

#include <string>
using namespace std;

#define UNDEFINED  -1

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
		//all 3
	}

  SYMBOL_TABLE_ENTRY(const string theName, const TYPE_INFO theType) 
  {
    name = theName;
    typeInfo.type = theType.type;
		//all 3
  }

  // Accessors
  string getName() const { return name; }
  TYPE_INFO getTypeInfo() const { return TYPE_INFO; }
};

#endif  // SYMBOL_TABLE_ENTRY_H
