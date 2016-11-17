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
	return size(duplicate());
}

real getDuplicatePercentage(){
	return getDuplicates() / toReal(getVolume());
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
	
	int i = 0;
	for (l <- lines){
		// Removes white spaces to make matchin easier
		line = trim(l);
		
		switch(line){
			
			// Skips empty line		
			case "": {lines = delete(lines, i); continue;}
			
			// Skips single line comment
			case /\/\/.*/ : {lines = delete(lines, i); continue;}
			
			// Skips multi line comment (single)
			case /\/\*.*\*\//: {lines = delete(lines, i); continue;}
			
			// Skips multi line comment begin
			case /\/\*.*/: {
				multiLineComment = true;
				lines = delete(lines, i); 
				continue;
			}
			
			// Skips multi line comment end
			case /.*\*\//: {
				multiLineComment = false;
				lines = delete(lines, i);
				continue;
			}
				
			default: {
				// Count lines if not in multi line comment block
				if (multiLineComment){
					lines = delete(lines, i); 
					continue;
				}
				i += 1;
			}		
		}
		if(i % 10000 == 0)
			println(i);
	}
	return lines;
}



public void duplicates()
{
	list[str]lines = getAllLinesCommentFree();
	list[int] hashes = [];
	
	for (i <- [0 .. size(lines) - 6]){
		hashes += hash(lines[i] + lines[i + 1] + lines[i + 2] + lines[i + 3] + lines[i + 4] + lines[i + 5]);
	}
}

str listToString (list[str] lines){
	return ("" | it + e | str e <- lines);	
}

int hash (str string) {
	return  toInt(("" | it + toString(i) | i <- chars(string))) * 2654435761 mod toInt(pow(2,32));
}