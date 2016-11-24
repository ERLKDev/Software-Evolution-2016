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
	set[Declaration] ast = createAstsFromEclipseProject(project, false);

	
	map[node, loc] nodes = getSubTrees(ast);
	
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

map[node, loc] getSubTrees(set[Declaration] ast){
	map[node, loc] subtrees = ();
	visit(ast){
		case node x: {
			if("src" in getAnnotations(x)){
				println(x);
				subtrees += (x : x@decl);
			}
		}
	}
	return subtrees;
}


