module TestImplode

import IO;
import AST;
import Implode;

void main() {
  println("=== Testing Implode with Comparison Operators ===\n");
  
  // Simple test with comparison
  str code1 = "function test() do result = 5 \> 3 end test";
  testImplode("Simple comparison", code1);
  
  // Test with all comparison operators
  str code2 = "function test() do 
              'a = 10
              'b = 20
              'c = a \< b
              'd = a \> b
              'e = a \<= b
              'f = a \>= b
              'g = a \<\> b
              'h = a = b
              'end test";
  testImplode("All comparisons", code2);
}

void testImplode(str title, str code) {
  println(title);
  println("Code: <code>");
  
  try {
    println("Parsing...");
    AST::Program ast = implodeProgram(code);
    println("✓ Parse successful");
    println("✓ Implode successful!");
    println("AST: <ast>");
  } catch value err: {
    println("✗ Error: <err>");
  }
  
  println("\n---\n");
}
