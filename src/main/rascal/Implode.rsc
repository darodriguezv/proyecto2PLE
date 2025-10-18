module Implode

import Syntax;
import AST;
import ParseTree;
import IO;

public Program implodeProgram(str code) {
  Tree parsed = parse(#Program, code);
  return implodeProgramTree(parsed);
}

public Program implodeProgramTree(Tree parsed) {
  Program p = implode(#Program, parsed);
  return p;
}

