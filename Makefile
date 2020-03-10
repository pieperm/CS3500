default:
	flex flex.l
	bison bison.y
	g++ bison.tab.c -o mfpl_parser
	mfpl_parser < $(input) > myOutput.out

.PHONY: clean
clean:
	del lex.yy.c mfpl_parser.exe bison.tab.c
