
MP: tmacro_lexer.l tmacro_parser.y 
	-bison -v -d tmacro_parser.y  
	flex -o tmacro_lexer.lex.c tmacro_lexer.l
	mv tmacro_parser.tab.h ./include/tmacro_parser.tab.h