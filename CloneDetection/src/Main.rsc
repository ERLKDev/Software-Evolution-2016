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

	
	list[node] nodes = getSubTrees(ast);
	
	list[node] duplicates = getDuplicates(nodes);
	
	for(d <- duplicates){
		println();
		println();
		println(d);
	}
	
}

list[node] getSubTrees(set[Declaration] ast){
	list[node] subtrees = [];
	visit(ast){
		case node x: {
			if("src" in getAnnotations(x)){
				loc location = getLocFromNode(x);
				subtrees += x;
			}
		}
	}
	return sort(subtrees, sortNodes);
}

bool sortNodes(node a, node b){
	return a > b;
}



list[node] getDuplicates(list[node] subtrees){
	
	list[node] duplicates = [];
	
	for (i <- [0 .. size(subtrees)]){
		
		list[node] remain = delete(subtrees, i);
		
		node subtree = subtrees[i];
		
		for (j <- [0 .. size(remain)]){
			similarity(subtree, remain[j]); 
		}
		
		
		//if(subtree in remain){
		//	duplicates += subtree;
		//	for (x <- getChildren(subtree)){
		//		if (x in duplicates){
		//			duplicates = delete(duplicates, indexOf(duplicates, x));
		//		}
		//	}
		//} 
	}
	
	return duplicates;
}

int similarity(node x, node y){
	list[node] list_x = [];
	list[node] list_y = [];
	
	visit(x){
		case node a: list_x += a; 
	}
	
	visit(y){
		case node b: list_y += b; 
	}
	
	return 0;
}

node toNode(value x){
	if(node n := x) return n;
	
	return empty;
}

loc getLocFromNode(node subTree){
	if(Declaration x := subTree) return x@src;
	if(Statement x := subTree) return x@src;
	if(Expression x := subTree) return x@src;
}


