module Main

import IO;
import Syntax;
import ParseTree;
import Evaluator;
import String;

void main() {
    println("=== ALU Language Demo ===\n");
    
    // Example 1: Arithmetic and comparison
    str example1 = "function calculate() do x = 10 y = 20 z = x + y * 2 result = z \> 30 end calculate";
    
    println("Example 1: Arithmetic and Comparison");
    println("Code: <example1>");
    println("\nExecuting...");
    runProgram(example1);
    println("\n---\n");
    
    // Example 2: For range loop with assignment
    str example2 = "function countdown() do for i from 1 to 5 do sum = i * 2 end end countdown";
    
    println("Example 2: For Range Loop");
    println("Code: <example2>");
    println("\nExecuting...");
    runProgram(example2);
    println("\n---\n");
    
    // Example 3: If-then-else statement
    str example3 = "function checkValue() do x = 15 if x \> 10 then y = 100 else y = 0 end end checkValue";
    
    println("Example 3: If Statement with Comparison");
    println("Code: <example3>");
    println("\nExecuting...");
    runProgram(example3);
    println("\n---\n");
    
    // Example 4: Boolean logic
    str example4 = "function logic() do a = true b = false c = a and b d = a or b end logic";
    
    println("Example 4: Boolean Logic");
    println("Code: <example4>");
    println("\nExecuting...");
    runProgram(example4);
    println("\n---\n");
    
    // Example 5: Power and negation
    str example5 = "function power() do base = 2 exp = 3 result = base ** exp negative = neg result end power";
    
    println("Example 5: Power and Negation");
    println("Code: <example5>");
    println("\nExecuting...");
    runProgram(example5);
    println("\n---\n");
}

void runProgram(str code) {
    try {
        // Parse the code directly to a concrete syntax tree
        Program prog = parse(#Program, trim(code));
        
        // Evaluate the parse tree directly (no AST conversion!)
        evalProgram(prog);
        
        println("Done!");
    } catch ParseError(loc l): {
        println("Parse Error at <l>");
    } catch Ambiguity(loc l, str prod, str sentence): {
        println("Ambiguity Error at <l>");
        println("Production: <prod>");
        println("Sentence: <sentence>");
    } catch err: {
        println("Error: <err>");
    }
}
