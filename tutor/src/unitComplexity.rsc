module unitComplexity

import IO;
import Prelude;
import List;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

public void init() {
	loc project = |project://test|;	
	model = createM3FromEclipseProject(project);
	myMethods = methods(model);
	println("loaded");
	for(unit <- myMethods) {
		ast = getMethodASTEclipse(unit, model = model);
		count = 0;
		visit(ast) {
			case m: \method(_,_,_,_, Statement impl):count += countcomplex(impl);
			case c: \constructor(_,_,_, Statement impl):count += countcomplex(impl);
		}
		
		println(count);
	}
	printStats(1,2,3,4);
}

public void printStats(int volume, int complexity, int duplicate, int unitSize){
	
	int analysability = (volume + duplicate + unitSize) / 3;
	int changeability = (complexity + duplicate) / 2;
	int stability = 2;
	int testability = (complexity + unitSize) / 2;
	
	println("
		+---------------------+
		|Analisability  |  <analysability>  |
		+---------------------+
		|Changeability  |  <changeability>  |
		+---------------------+
		|Stability      |  <stability>  |
		+---------------------+
		|Testability    |  <testability>  |
		+-------------+-------+");
}

public int countcomplex(Statement impl){
	count = 0;
	
	visit (impl) {
		case \case(_): count += 1;
		case \catch(_,_): count += 1;
		case \conditional(_,_,_): count += 1;
		case \do(_,_): count += 1;
		case \for(_,_): count += 1;
		case \foreach(_,_,_): count += 1;
		case \if(_,_): count += 1;
		case \if(_,_,_): count += 1;
		case \infix(_,"||", _): count += 1;
		case \infix(_, "&&", _): count += 1;
		case \while(_,_): count += 1;
	}
	return count;
}


