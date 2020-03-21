default:
	flex ekstromn.l
	bison ekstromn.y
	g++ ekstromn.tab.c -o mfpl_parser
	mfpl_parser < $(input) > myOutput.out

.PHONY: clean
clean:
	del lex.yy.c mfpl_parser.exe bison.tab.c
