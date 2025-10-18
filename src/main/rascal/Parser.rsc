module Parser

import Syntax;
import ParseTree;
import IO;

public Program parseProgram(str code) {
  return parse(#Program, code);
}

public Program parseFile(str path) {
  str code = readFile(|file://<path>|);
  return parseProgram(code);
}

