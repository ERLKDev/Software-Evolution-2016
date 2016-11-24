module Main

import IO;
import Prelude;
import List;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import demo::lang::Exp::Concrete::WithLayout::Syntax;

void main(){
	loc project = |project://TestProject|;	
	//loc project = |project://smallsql0.21_src|;	
	//loc project = |project://hsqldb-2.3.1|;
	
	M3 model = createM3FromEclipseProject(project);

	
	for (myMethod <- methods(model)) {
		ast = getMethodASTEclipse(myMethod, model=model);
		nodes = [];
		println();
		println();
		println();
		println();
		visit(ast) {
			case m: \method(_,_,_,_, Statement impl): nodes += m;
		}
		for (n <- nodes) {
			println();
			println(n);
		}
	}
}