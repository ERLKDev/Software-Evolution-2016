module Test
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::Math;
import Prelude;
import util::Benchmark;
import util::Math;


public M3 myModel = emptyM3(|project://empty|);
public set[loc] myMethods = {};
public set[Declaration] decls = {};

void init() {
   myModel = createM3FromEclipseProject(|project://smallsql0.21_src|);
   //myModel = createM3FromEclipseProject(|project://hsqldb-2.3.1|);
   //myModel = createM3FromEclipseProject(|project://TestProject|);
   //decls = createAstsFromEclipseProject(|project://TestProject|, true);
   

   myMethods = methods(myModel);   
}


int getVolume(){
	return size(getAllLinesCommentFree());
}

int getDuplicates(){
list[str] lines = getAllLinesCommentFree();
	return duplicates(lines);
}

real getDuplicatePercentage(){
	list[str] lines = getAllLinesCommentFree();
	return duplicates(lines) * 100.0 / toReal(size(lines));
}

map[loc,int] getUnitSizes(){
	return (m : countLines(readFileLines(m)) | m <- myMethods);
}

int countLines(list[str] lines){
	return size(removeComments(lines));
}

list[str] getAllLinesCommentFree(){
	list[str] lines = [];
	
	for	(f <- files(myModel)){
		lines += removeComments(readFileLines(f));
	}
	println(size(lines));
	return lines;	
}


list[str] removeComments(list[str] lines){
	bool multiLineComment = false;
	list[str] newLines = [];
	
	int i = 0;
	for (l <- lines){
		// Removes white spaces to make matchin easier
		line = trim(l);
		
		switch(line){
			
			// Skips empty line		
			case "": {continue;}
			
			// Skips single line comment
			case /\/\/.*/ : {continue;}
			
			// Skips multi line comment (single)
			case /\/\*.*\*\//: {continue;}
			
			// Skips multi line comment begin
			case /\/\*.*/: {
				multiLineComment = true;
				continue;
			}
			
			// Skips multi line comment end
			case /.*\*\//: {
				multiLineComment = false;
				continue;
			}
				
			default: {
				// Count lines if not in multi line comment block
				if (multiLineComment){
					continue;
				}
				newLines += line;
				i += 1;
			}		
		}
		if(i % 10000 == 0)
			println(i);
	}
	return newLines;
}



public int duplicates(list[str] lines)
{
	map[str, int] processedLines = ();
	int duplicates = 0;
	bool prev = false;
	
	for (i <- [0 .. size(lines) - 6]){
		str line = lines[i] + lines[i + 1] + lines[i + 2] + lines[i + 3] + lines[i + 4] + lines[i + 5];
		if(line in processedLines){
			if(prev)
				duplicates += 1;
			else{
				prev = true;
				duplicates += 6;
			}
		}else{
			prev = false;
			processedLines += (line : i);
		}
	}
	return duplicates;
}