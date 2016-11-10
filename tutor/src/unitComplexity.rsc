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
	
	for(unit <- myMethods) {
		ast = getMethodASTEclipse(unit, model = model);
		complexity = countBranches(ast);
		println(complexity);
	}
}

public int countBranches(value tree) {
	int count = 0;
	visit(tree) {
		case \case(_): count += 1;
		case \catch(_,_): count += 1;
		case \conditional(_, Statement thenBranch,Statement elseBranch): count += (countNested(thenBranch) + countNested(elseBranch));
		case \do(_,_): count += 1;
		case \for(_,_): count += 1;
		case \foreach(_,_,_): count += 1;
		case \if(_,Statement thenBranch): count += 1 + countNested(thenBranch);
		case \if(_,Statement thenBranch,Statement elseBranch): count += 1 + (countNested(thenBranch) + countNested(elseBranch));
		case \while(_,_): count += 1;
	}
	return count;
}
