default:
	flex mfpl.l
	bison mfpl.y
	g++ mfpl.tab.c -o mfpl_parser
	mfpl_parser < $(input) > myOutput.out

.PHONY: clean
clean:
	del lex.yy.c mfpl_parser.exe bison.tab.c
