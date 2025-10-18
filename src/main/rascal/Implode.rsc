module Implode

import Syntax;
import AST;
import ParseTree;

public Program implodeProgram(str code) {
  Tree parsed = parse(#Program, code);
  return implode(#Program, parsed);
}

