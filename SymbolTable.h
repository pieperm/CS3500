#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#define UNDEFINED -1
#define FUNCTION 0							//0000
#define INT 1										//0001
#define STR 2										//0010
#define INT_OR_STR 3						//0011
#define BOOL 4									//0100
#define INT_OR_BOOL 5						//0101
#define STR_OR_BOOL 6						//0110
#define INT_OR_STR_OR_BOOL 7		//0111
#define NOT_APPLICABLE -1

#include <map>
#include <string>
#include "SymbolTableEntry.h"
using namespace std;

class SYMBOL_TABLE 
{
private:
  std::map<string, SYMBOL_TABLE_ENTRY> hashTable;
	TYPE_INFO typeInfo;
	
public:
  //Constructor
  SYMBOL_TABLE( ) { }

  // Add SYMBOL_TABLE_ENTRY x to this symbol table.
  // If successful, return true; otherwise, return false.
  bool addEntry(SYMBOL_TABLE_ENTRY x) 
  {
    // Make sure there isn't already an entry with the same name
    map<string, SYMBOL_TABLE_ENTRY>::iterator itr;
    if ((itr = hashTable.find(x.getName())) == hashTable.end()) 
    {
      hashTable.insert(make_pair(x.getName(), x));
      return(true);
    }
    else return(false);
  }

  // If a SYMBOL_TABLE_ENTRY with name theName is
  // found in this symbol table, then return the type info for the entry;
  // otherwise, return undefined.
  TYPE_INFO findEntry(string theName) 
  {
    map<string, SYMBOL_TABLE_ENTRY>::iterator itr;
    if ((itr = hashTable.find(theName)) == hashTable.end())
		{
			TYPE_INFO info;
			info.type = NOT_APPLICABLE;
			return(info);
    }
		else return(hashTable.at(theName).getTypeInfo());
  }

	int size() const { return hashTable.size(); }
};

#endif  // SYMBOL_TABLE_H
