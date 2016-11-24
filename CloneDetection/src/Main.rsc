module Main

import IO;
import Prelude;
import List;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import demo::lang::Exp::Concrete::WithLayout::Syntax;
import ParseTree;
import vis::Figure;
import vis::ParseTree;
import vis::Render;


void main(){
	loc project = |project://TestProject|;	
	//loc project = |project://smallsql0.21_src|;	
	//loc project = |project://hsqldb-2.3.1|;
	
	M3 model = createM3FromEclipseProject(project);
	list[Declaration] asts = [];
	for (m <- methods(model)){
		 asts += getMethodASTEclipse(m, model=model);
	}
	
	nodes = [];
	for(ast <- asts){
		visit(ast){
			case node x: nodes += x;
		}
	}
	
	println(nodes);
	for (i <- [0 .. size(nodes)]){
		a = nodes[i];
		tmpnodes = delete(nodes, i);
		if(a in tmpnodes){
			println();
			println();
			println (a);
			println (tmpnodes[indexOf(tmpnodes, a)]);
		}
		
	}
	
		
}


