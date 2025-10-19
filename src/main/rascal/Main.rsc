module Main

import IO;
import Syntax;
import ParseTree;
import AST;
import Interpreter;
import String;
import ParseTree;

void main() {
  println("=== Running external file: test1.alu ===\n");
  runFile(|project://proyecto2/instance/test1.alu|);
}

void runExample(str title, str code) {
  println(title);
  println("Code: \n<code>");
  println("\nExecuting...");
  runProgram(code);
  println("\n---\n");
}

Tree resolveAmb(Tree t) {
  return bottom-up visit(t) {
    case a:amb({Tree first, *Tree rest}) => first
  };
}

void runProgram(str code) {
  try {
    println("Parsing...");
    pt = parse(#start[Program], trim(code), allowAmbiguity=true);
    println("Resolving ambiguities...");
    // Prefer literalExpr over varExpr for boolean literals
    pt = resolveAmb(pt);
    println("Imploding to AST...");
    AST::Program ast = implode(#AST::Program, pt.top);
    println("Executing...");
    evalProgram(ast);
    println("Done!");
  } catch ParseError(loc l): {
    println("Parse Error at <l>"); 
  } catch err: {
    println("Error: <err>"); 
  }
}

void runFile(loc file) {
  try {
    println("Reading file: <file>"); 
    str code = readFile(file);
    runProgram(code);
  } catch IO(str msg): {
    println("File error: <msg>"); 
  } catch err: {
    println("Error reading file: <err>"); 
  }
}