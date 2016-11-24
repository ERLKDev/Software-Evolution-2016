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
	set[Declaration] ast = createAstsFromEclipseProject(project, false);

	
	map[node, loc] nodes = getSubTrees(ast);
	
	getDuplicates(nodes);
	
}

map[node, loc] getSubTrees(set[Declaration] ast){
	map[node, loc] subtrees = ();
	visit(ast){
		case node x: {
			if("src" in getAnnotations(x)){
				loc location = getLocFromNode(x);
				subtrees += (x : location);
			}
		}
	}
	return subtrees;
}



map[node, loc] getDuplicates(map[node, loc] subtrees){
	
	map[node, loc] duplicates = ();
	for (subtree <- subtrees){
		map[node, loc] remain = delete(subtrees, subtree);
		
		println(subtree[0]);
		if(subtree in remain){
			duplicates += (subtree[0] : subtree[1]);
			println(subtree[0]);
		} 
	}
	
	return duplicates;
}

loc getLocFromNode(node subTree){
	if(Declaration x := subTree) return x@src;
	if(Statement x := subTree) return x@src;
	if(Expression x := subTree) return x@src;
	
	
}


