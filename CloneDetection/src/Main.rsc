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

map[int, list[list[node]]] subtreesToBins(set[Declaration] ast, int granularity){
	map[int, list[node]] bins = ();
	visit(ast){
		case node x: {
			if("src" in getAnnotations(x)){
				loc location = getLocFromNode(x);
				list[node] l = node2List(x);
				int weight = size(l);  
				if (weight > 20) {
					int index = weight / granularity;
					if(index in bins){
						bins += (index: bins[index] + [l]);
					}else {
						bins += (index: [l]);
					}
				}
			}
		}
	}
	return bins;
}

list[node] children2List(node a) {
	list[node] l = [];
	visit(a) {
		case node x: l += x;
	}
	return l;
}

bool sortNodes(node a, node b){
	return a > b;
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


