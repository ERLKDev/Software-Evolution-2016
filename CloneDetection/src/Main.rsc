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
	set[Declaration] ast = normTree(createAstsFromEclipseProject(project, false));
	println("loaded");
	
	println(ast);
	map[int, list[list[node]]] bins = subtreesToBins(ast, 5);
	for (kut <- bins) {
		println("<kut>: <size(bins[kut])>");
	}
	println("loaded2");
	
	//list[node] duplicates = getDuplicates(bins);
	
	println("done");
	//for(d <- duplicates){
	//	println();
	//	println();
	//	println(d);
	//}
	
}

map[int, list[list[node]]] subtreesToBins(set[Declaration] ast, int granularity){
	map[int, list[list[node]]] bins = ();
	visit(ast){
		case node x: {
			if("src" in getAnnotations(x)){
				loc location = getLocFromNode(x);
				list[node] l = children2List(x);
				int weight = size(l);  

				if (weight > 40) {
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

list[node] getDuplicates(map[int, list[list[node]]] bins){
	
	println("startdup");
	list[node] duplicates = [];
	int k = 0;
	for (i <- bins){
		println("dup");
		list[list[node]] bin = bins[i];
		map[list[node], int] processed = ();
		
		for(x <- [0 .. size(bin)]){
			for (y <- processed){
				if (similarity(bin[x], y) >= 100){
					list[node] sorted_nodes = sort(bin[x], bool(node a, node b){ return size(toString(a)) > size(toString(b)); });
					loc loc_x = getLocFromNode(sorted_nodes[0]);
					loc loc_y = getLocFromNode(y[0]);
					
					if(!(loc_x >= loc_y || loc_y >= loc_x))
						duplicates += sorted_nodes[0];
				}
			}
			processed += (bin[x] : 0);
		}
		k += 1;
		println("<k> / <size(bins)>");
	}
	
	return dup(duplicates);
}


set[Declaration] normTree(set[Declaration] ast){
	ast = visit(ast){
		case \variable(_, a, b) => \variable("var", a, b)
		case \variable(_, a) => \variable("var", a)
		case \enum(_, a, b, c) => \enum("var", a, b, c)
		case \enumConstant(_, a, b) => \enumConstant("var", a, b)
		case \enumConstant(_, a) => \enumConstant("var", a)
		case \class(_, a, b, c) => \class("var", a, b, c)
		case \method(a, _, b, c, d) => \method(a, "var", b, c, d)
		case \method(a, _, b, c) => \method(a, "var", b, c)
		case \constructor(_, a, b, c) => \constructor("var", a, b, c)

		case \vararg(a, _) => \vararg(a, "var")
		case \parameter(a, _, b) => \parameter(a, "var", b)  
		case \methodCall(a, _, b) => \methodCall(a, "var", b)
		case \methodCall(a, b, _, c) => \methodCall(a, b, "var", c)
		case \fieldAccess(a, _) => \fieldAccess(a, "var") 
		case \fieldAccess(a, b, _) => \fieldAccess(a, b, "var")
		case \simpleName(_) => \simpleName("var")
     	case \memberValuePair(_, a) => \memberValuePair("var", a)
     	case \label(_, a) => \label("var", a) 
	}
	return ast;
}


int similarity(list[node] list_x, list[node] list_y){
	int a = size(list_x & list_y);
		
	return (200 * a) / (2 * a +  size(list_x - list_y) + size(list_y - list_x));
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


