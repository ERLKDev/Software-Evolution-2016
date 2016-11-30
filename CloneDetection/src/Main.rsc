module Main

import IO;
import Prelude;
import List;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import demo::lang::Exp::Concrete::WithLayout::Syntax;

void main(){
	//loc project = |project://TestProject|;	
	loc project = |project://smallsql0.21_src|;	
	//loc project = |project://hsqldb-2.3.1|;
	
	M3 model = createM3FromEclipseProject(project);
	set[Declaration] ast = createAstsFromEclipseProject(project, false);
	println("loaded");
	
	map[int, list[node]] bins = subtreesToBins(ast, 10);
	for (kut <- bins) {
		println("<kut>: <size(bins[kut])>");
	}
	println("loaded2");
	
	list[node] duplicates = getDuplicates(bins);
	
	println("done");
	for(d <- duplicates){
		println();
		println();
		println(d);
	}
	
}

map[int, list[node]] subtreesToBins(set[Declaration] ast, int granularity){
	map[int, list[node]] bins = ();
	visit(ast){
		case node x: {
			if("src" in getAnnotations(x)){
				loc location = getLocFromNode(x);
				weight = getWeight(x); 
				if (weight > 20) {
					int index = weight / granularity;
					if(index in bins){
						bins += (index: bins[index] + x);
					}else {
						bins += (index: [x]);
					}
				}
			}
		}
	}
	return bins;
}

bool sortNodes(node a, node b){
	return a > b;
}

int getWeight(node sub){
	int children = 0;
	visit (sub) {
		case node child: children += 1;
	}
	return children;
}

list[node] getDuplicates(map[int, list[node]] bins){
	
	println("startdup");
	list[node] duplicates = [];
	int k = 0;
	for (i <- bins){
		println("dup");
		list[node] bin = bins[i];
		
		for(x <- [0 .. size(bin)]){
			for (y <- [x + 1 .. size(bin)]){
				if (similarity(bin[x], bin[y]) >= 100){
					duplicates += bin[x];
				}
			}
		}
		k += 1;
		println("<k> / <size(bins)>");
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
	
	return (200 * size(list_x & list_y)) / (2 * size(list_x & list_y) +  size(list_x - list_y) + size(list_y - list_x));
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


