module Main

import IO;
import Parser;
import Implode;
import Interpreter;
import AST;
import String;

void main() {
  println("=== ALU Language Demo ===\n");

  runExample("Example 1: Arithmetic and Comparison",
    "function calculate() do x = 10 y = 20 z = x + y * 2 result = z > 30 end calculate");

  runExample("Example 2: For Range Loop",
    "function countdown() do for i from 1 to 5 do sum = i * 2 end end countdown");

  runExample("Example 3: If Statement with Comparison",
    "function checkValue() do x = 15 if x > 10 then y = 100 else y = 0 end end checkValue");

  runExample("Example 4: Boolean Logic",
    "function logic() do a = true b = false c = a and b d = a or b end logic");

  runExample("Example 5: Power and Negation",
    "function power() do base = 2 exp = 3 result = base ** exp negative = neg result end power");

  println("=== Running external file: test1.alu ===\n");
  runFile(|project://proyecto2ple/instance/test1.alu|);
}

void runExample(str title, str code) {
  println(title);
  println("Code: \n<code>");
  println("\nExecuting...");
  runProgram(code);
  println("\n---\n");
}

void runProgram(str code) {
  try {
    println("Parsing...");
    Program ast = implodeProgram(trim(code));
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
  } catch FileNotFound(): {
    println("File not found: <file>"); 
  } catch err: {
    println("Error reading file: <err>"); 
  }
}