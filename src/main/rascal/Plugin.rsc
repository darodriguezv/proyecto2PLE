module Plugin

import ParseTree;
import Syntax;
import IO;

public Tree parseALU(str src, loc origin) {
  return parse(#start[Program], src, origin);
}

public Tree parseALU(str src) {
  return parse(#start[Program], src);
}

void demo() {
  println("ALU Language Plugin Loaded");
  println("Use Parser module to parse ALU programs");
}
