module unitComplexity

import IO;
import Prelude;
import List;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

public void init() {
	loc project = |project://hsqldb-2.3.1|;	
	model = createM3FromEclipseProject(project);
	myMethods = methods(model);
	println("loaded");
	//Magic
	rPercent = [(rBin / size(myMethods)) * 100 | rBin <- riskBins([ analyzeUnit(r, model) | r <- myMethods])];
	println(rPercent);
	//println(size(myMethods));
	//printStats(1,complexity(rPercent),3,4);
}

//Returns the proper complexity risk based on the percentage and gradation of complexity of the methods.
public int complexity(list[num] bins) {
	if (bins[3] >= 5.0 || bins[2] >= 15.0 || bins[1] >= 50.0) return 4;
	if (bins[2] >= 10.0 || bins[1] >= 40.0) return 3;
	if (bins[2] >= 5.0 || bins[1] >= 30.0) return 2;
	if (bins[1] >= 25.0) return 1;
	return 0;
}

//Construct bins corresponding to the risk level.
public list[num] riskBins(list[num] riskArr) {
	bins = [
		size([x | x <- riskArr, x == 0]),
		size([x | x <- riskArr, x == 1]),
		size([x | x <- riskArr, x == 2]),
		size([x | x <- riskArr, x == 3])
	];
	return bins;
}

//Analyses a unit of code and returns the risk number (numbers were based on the paper of Heitlager).
public num analyzeUnit(loc unitLoc, M3 model) {
	ast = getMethodASTEclipse(unitLoc, model = model);
	count = 0;
	num risk = 0;
	visit(ast) {
		case m: \method(_,_,_,_, Statement impl): count += countcomplex(impl);
		case c: \constructor(_,_,_, Statement impl): count += countcomplex(impl);
	}
	
	if (count > 10 && count < 21) risk = 1;
	if (count > 20 && count < 51) risk = 2;
	if (count > 50) risk = 3;
	println(count);
	return risk;
}

//Counts the complex statements.
public int countcomplex(Statement impl){
	count = 0;
	
	visit (impl) {
		case \case(_): count += 1;
		case \catch(_,_): count += 1;
		case \conditional(_,_,_): count += 1;
		case \do(_,_): count += 1;
		case \for(_,_,_): count += 1;
		case \for(_,_,_,_) : count += 1;
		case \foreach(_,_,_): count += 1;
		case \if(_,_): count += 1;
		case \if(_,_,_): count += 1;
		case \infix(_,"||", _): count += 1;
		case \infix(_, "&&", _): count += 1;
		case \while(_,_): count += 1;
	}
	
	return count;
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


