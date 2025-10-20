module Implode

import Syntax;
import AST;
import ParseTree;
import String;

public AST::Program implodeProgram(str code) {
  Tree t = parse(#start[Program], code);
  return implode(#AST::Program, t.top);
}

public AST::Program implodeTree(Tree t) {
  return implode(#AST::Program, t);
}

// Optional finer control for Data mapping (bridge from parse tree to AST for new Data rules)
public AST::Program implodeWithData(str code) {
  Tree pt = parse(#start[Program], code);
  return toAST(pt.top);
}

AST::Program toAST(pt:(Program)`<Module+ modules>`) {
  // touch parameter to avoid unused warning in some analyzers
  pt = pt;
  list[AST::Module] mods = [];
  for (m <- modules) {
    if ((Module)`<Data d>` := m) mods += AST::dataDecl(toDataDecl(d));
    else mods += implode(#AST::Module, m);
  }
  return AST::program(mods);
}

AST::DataDecl toDataDecl(Data d) {
  if ((Data)`<Id a> = data with <Variables vs> <DataBody b> end <Id e>` := d) {
    list[str] vars = varsFrom(vs);
    return AST::dataCtorWithAssign("<a>", vars, toCtorDef(b), "<e>");
  }
  else if ((Data)`data with <Variables vs> <DataBody b> end <Id e>` := d) {
    list[str] vars = varsFrom(vs);
    return AST::dataCtorNoAssign(vars, toCtorDef(b), "<e>");
  }
  throw "Unknown Data";
}

AST::ConstructorDef toCtorDef(DataBody b) {
  if ((DataBody)`<Constructor c>` := b) return toCtorOnly(c);
  // For now, if FunctionDef appears in DataBody, just synthesize a constructor with function name
  if ((DataBody)`<FunctionDef f>` := b) return AST::constructorDef("<f.name>", []);
  throw "Unknown DataBody";
}

AST::ConstructorDef toCtorOnly(Constructor c) {
  if ((Constructor)`<Id n> = struct ( <Variables vs> )` := c) {
    return AST::constructorDef("<n>", varsFrom(vs));
  }
  throw "Unknown Constructor";
}

list[str] varsFrom(Variables vs) {
  list[str] out = [];
  visit(vs) {
    case (Id)`<Id n>`: out += "<n>";
  }
  return out;
}
