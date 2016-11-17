module demo

import IO;

void hello() {
	println("Hello world, this is my first Rascal program.");
}

public int fac(int N) = N <= 0 ? 1 : N * fac(N - 1);

str bottles(0) = "No more bottles";
str bottles(1) = "one bottle";
default str bottles (int n) = "<n> bottles";

bool bla() {
	return /a/ := "bla";
}

