module Main

import IO;
import Prelude;
import List;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

void main(){
	loc project = |project://TestProject|;	
	//loc project = |project://smallsql0.21_src|;	
	//loc project = |project://hsqldb-2.3.1|;
	
	M3 model = createM3FromEclipseProject(project);
	list[Declaration] asts = [];
	for (x <- files(model)){
		 asts += createAstFromFile(x, false);
	}
	
	ast = asts[0];
	
	visit(ast){
		case _: println("test");
	}
		
}


