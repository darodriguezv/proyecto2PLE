module Main

import IO;
import Parser;
import Implode;
import Interpreter;
import AST;
import String;

void main() {
    println("=== Rascal Project Demo ===\n");
    
    // Example 1: Simple arithmetic
    str example1 = "function test() do x = 10 y = 20 z = x + y end test";
    
    println("Example 1: Simple arithmetic");
    println("Code: <example1>");
    println("\nExecuting...");
    runProgram(example1);
    println("\n---\n");
    
    // Example 2: For loop
    str example2 = "function countdown() do for i from 5 to 10 do i end end countdown";
    
    println("Example 2: For loop");
    println("Code: <example2>");
    println("\nExecuting...");
    runProgram(example2);
    println("\n---\n");
    
    // Example 3: If statement
    str example3 = "function checkValue() do x = 15 if x then y = 100 else y = 0 end end checkValue";
    
    println("Example 3: If statement");
    println("Code: <example3>");
    println("\nExecuting...");
    runProgram(example3);
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
