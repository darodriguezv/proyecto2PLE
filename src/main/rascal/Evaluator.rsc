module Evaluator

import Syntax;
import ParseTree;
import IO;
import String;
import Map;
import util::Math;

// Environment type: variable name -> value
alias Env = map[str, value];

// Evaluate a program (list of modules)
public void evalProgram(Program prog) {
  Env env = ();
  
  // Extract modules from the program
  if ((Program)`<Module+ modules>` := prog) {
    // Find all function definitions
    for (m <- modules) {
      if ((Module)`<FunctionDef fd>` := m) {
        evalFunction(fd, env);
      }
    }
  }
}

// Evaluate a single function
public void evalFunction(FunctionDef fd, Env env) {
  // Extract function name and body
  if ((FunctionDef)`function <Id name> ( ) do <Statement* body> end <Id _>` := fd) {
    println("Executing function: <name>");
    env = evalStatements(body, env);
  }
  else if ((FunctionDef)`function <Id name> ( <ParameterList _params> ) do <Statement* body> end <Id _>` := fd) {
    println("Executing function: <name> (with parameters - not yet implemented)");
    env = evalStatements(body, env);
  }
}

// Evaluate a sequence of statements
public Env evalStatements(Statement* stmts, Env env) {
  for (stmt <- stmts) {
    env = evalStatement(stmt, env);
  }
  return env;
}

// Evaluate a single statement
public Env evalStatement(Statement stmt, Env env) {
  // Assignment: x = expression
  if ((Statement)`<Id varName> = <Expression val>` := stmt) {
    value v = evalExpression(val, env);
    env["<varName>"] = v;
    println("  <varName> = <v>");
    return env;
  }
  
  // Conditional: if-then-else
  else if ((Statement)`<ConditionalStmt cond>` := stmt) {
    return evalConditional(cond, env);
  }
  
  // Loop: for
  else if ((Statement)`<LoopStmt loop>` := stmt) {
    return evalLoop(loop, env);
  }
  
  // Function call statement
  else if ((Statement)`<FunctionCall fc>` := stmt) {
    evalFunctionCall(fc, env);
    return env;
  }
  
  else {
    println("  Unknown statement: <stmt>");
    return env;
  }
}

// Evaluate conditional statements
public Env evalConditional(ConditionalStmt cond, Env env) {
  // if-then-end
  if ((ConditionalStmt)`<IfStmt ifStmt>` := cond) {
    return evalIf(ifStmt, env);
  }
  return env;
}

// Evaluate if statement
public Env evalIf(IfStmt ifStmt, Env env) {
  // if cond then body end
  if ((IfStmt)`if <Expression cond> then <Statement* thenBody> end` := ifStmt) {
    if (toBool(evalExpression(cond, env))) {
      return evalStatements(thenBody, env);
    }
    return env;
  }
  
  // if cond then body else elseBody end
  else if ((IfStmt)`if <Expression cond> then <Statement* thenBody> else <Statement* elseBody> end` := ifStmt) {
    if (toBool(evalExpression(cond, env))) {
      return evalStatements(thenBody, env);
    } else {
      return evalStatements(elseBody, env);
    }
  }
  
  return env;
}

// Evaluate loop statements
public Env evalLoop(LoopStmt loop, Env env) {
  // for var from expr to expr do body end
  if ((LoopStmt)`for <Id var> from <Expression fromExpr> to <Expression toExpr> do <Statement* body> end` := loop) {
    int startVal = asInt(evalExpression(fromExpr, env));
    int endVal = asInt(evalExpression(toExpr, env));
    
    for (i <- [startVal .. endVal + 1]) {
      env["<var>"] = i;
      env = evalStatements(body, env);
    }
    return env;
  }
  
  // for var in expr do body end
  else if ((LoopStmt)`for <Id var> in <Expression expr> do <Statement* body> end` := loop) {
    value collection = evalExpression(expr, env);
    if (list[value] lst := collection) {
      for (item <- lst) {
        env["<var>"] = item;
        env = evalStatements(body, env);
      }
    }
    return env;
  }
  
  return env;
}

// Evaluate function call
public value evalFunctionCall(FunctionCall fc, Env _env) {
  if ((FunctionCall)`<Id name> ( <{Expression ","}* _args> )` := fc) {
    println("  Function call: <name> (not yet implemented)");
  }
  return 0;
}

// Evaluate expressions
public value evalExpression(Expression expr, Env env) {
  // Delegate to OrExpr level
  if ((Expression)`<OrExpr oe>` := expr) {
    return evalOrExpr(oe, env);
  }
  return 0;
}

public value evalOrExpr(OrExpr expr, Env env) {
  // Binary or expression
  if ((OrExpr)`<OrExpr left> or <AndExpr right>` := expr) {
    return toBool(evalOrExpr(left, env)) || toBool(evalAndExpr(right, env));
  }
  // Delegate to AndExpr
  else if ((OrExpr)`<AndExpr ae>` := expr) {
    return evalAndExpr(ae, env);
  }
  return 0;
}

public value evalAndExpr(AndExpr expr, Env env) {
  // Binary and expression
  if ((AndExpr)`<AndExpr left> and <CmpExpr right>` := expr) {
    return toBool(evalAndExpr(left, env)) && toBool(evalCmpExpr(right, env));
  }
  // Delegate to CmpExpr
  else if ((AndExpr)`<CmpExpr ce>` := expr) {
    return evalCmpExpr(ce, env);
  }
  return 0;
}

public value evalCmpExpr(CmpExpr expr, Env env) {
  // Comparison expressions
  if ((CmpExpr)`<AddExpr left> \< <AddExpr right>` := expr) {
    return toNum(evalAddExpr(left, env)) < toNum(evalAddExpr(right, env));
  }
  else if ((CmpExpr)`<AddExpr left> \> <AddExpr right>` := expr) {
    return toNum(evalAddExpr(left, env)) > toNum(evalAddExpr(right, env));
  }
  else if ((CmpExpr)`<AddExpr left> \<= <AddExpr right>` := expr) {
    return toNum(evalAddExpr(left, env)) <= toNum(evalAddExpr(right, env));
  }
  else if ((CmpExpr)`<AddExpr left> \>= <AddExpr right>` := expr) {
    return toNum(evalAddExpr(left, env)) >= toNum(evalAddExpr(right, env));
  }
  else if ((CmpExpr)`<AddExpr left> = <AddExpr right>` := expr) {
    return evalAddExpr(left, env) == evalAddExpr(right, env);
  }
  else if ((CmpExpr)`<AddExpr left> \<\> <AddExpr right>` := expr) {
    return evalAddExpr(left, env) != evalAddExpr(right, env);
  }
  // Delegate to AddExpr
  else if ((CmpExpr)`<AddExpr ae>` := expr) {
    return evalAddExpr(ae, env);
  }
  return 0;
}

public value evalAddExpr(AddExpr expr, Env env) {
  // Addition/Subtraction
  if ((AddExpr)`<AddExpr left> + <MulExpr right>` := expr) {
    return toNum(evalAddExpr(left, env)) + toNum(evalMulExpr(right, env));
  }
  else if ((AddExpr)`<AddExpr left> - <MulExpr right>` := expr) {
    return toNum(evalAddExpr(left, env)) - toNum(evalMulExpr(right, env));
  }
  // Delegate to MulExpr
  else if ((AddExpr)`<MulExpr me>` := expr) {
    return evalMulExpr(me, env);
  }
  return 0;
}

public value evalMulExpr(MulExpr expr, Env env) {
  // Multiplication/Division/Modulo
  if ((MulExpr)`<MulExpr left> * <PowExpr right>` := expr) {
    return toNum(evalMulExpr(left, env)) * toNum(evalPowExpr(right, env));
  }
  else if ((MulExpr)`<MulExpr left> / <PowExpr right>` := expr) {
    return toNum(evalMulExpr(left, env)) / toNum(evalPowExpr(right, env));
  }
  else if ((MulExpr)`<MulExpr left> % <PowExpr right>` := expr) {
    return asInt(evalMulExpr(left, env)) % asInt(evalPowExpr(right, env));
  }
  // Delegate to PowExpr
  else if ((MulExpr)`<PowExpr pe>` := expr) {
    return evalPowExpr(pe, env);
  }
  return 0;
}

public value evalPowExpr(PowExpr expr, Env env) {
  // Power expression
  if ((PowExpr)`<UnaryExpr left> ** <PowExpr right>` := expr) {
    int base = asInt(evalUnaryExpr(left, env));
    int exp = asInt(evalPowExpr(right, env));
    if (exp == 0) return 1;
    int result = 1;
    for (_ <- [0..exp]) {
      result = result * base;
    }
    return result;
  }
  // Delegate to UnaryExpr
  else if ((PowExpr)`<UnaryExpr ue>` := expr) {
    return evalUnaryExpr(ue, env);
  }
  return 0;
}

public value evalUnaryExpr(UnaryExpr expr, Env env) {
  // Negation
  if ((UnaryExpr)`neg <UnaryExpr e>` := expr) {
    return !toBool(evalUnaryExpr(e, env));
  }
  // Unary minus
  else if ((UnaryExpr)`- <UnaryExpr e>` := expr) {
    return -toNum(evalUnaryExpr(e, env));
  }
  // Delegate to Postfix
  else if ((UnaryExpr)`<Postfix p>` := expr) {
    return evalPostfix(p, env);
  }
  return 0;
}

public value evalPostfix(Postfix expr, Env env) {
  // Function call: expr(args)
  if ((Postfix)`<Postfix _callee> ( <{Expression ","}* _args> )` := expr) {
    println("  Function call in expression (not yet implemented)");
    return 0;
  }
  // Delegate to Primary
  else if ((Postfix)`<Primary p>` := expr) {
    return evalPrimary(p, env);
  }
  return 0;
}

public value evalPrimary(Primary expr, Env env) {
  // Grouped expression: (expr)
  if ((Primary)`( <Expression e> )` := expr) {
    return evalExpression(e, env);
  }
  
  // Literal
  else if ((Primary)`<Literal lit>` := expr) {
    return evalLiteral(lit);
  }
  
  // Variable
  else if ((Primary)`<Id name>` := expr) {
    str varName = "<name>";
    if (varName in env) {
      return env[varName];
    }
    println("  Warning: undefined variable <varName>");
    return 0;
  }
  
  // Constructor call
  else if ((Primary)`<ConstructorCall _ctor>` := expr) {
    println("  Constructor call (not yet implemented)");
    return [];
  }
  
  return 0;
}

// Evaluate literals
public value evalLiteral(Literal lit) {
  // Integer
  if ((Literal)`<Integer intValue>` := lit) {
    return toInt("<intValue>");
  }
  
  // Float
  else if ((Literal)`<Float realValue>` := lit) {
    return toReal("<realValue>");
  }
  
  // Boolean - true
  else if ((Literal)`true` := lit) {
    return true;
  }
  
  // Boolean - false
  else if ((Literal)`false` := lit) {
    return false;
  }
  
  // Character
  else if ((Literal)`<Char charValue>` := lit) {
    return "<charValue>";
  }
  
  // String
  else if ((Literal)`<String strValue>` := lit) {
    return "<strValue>";
  }
  
  return 0;
}

// Helper functions
public bool toBool(value v) {
  if (bool b := v) return b;
  if (int i := v) return i != 0;
  if (real r := v) return r != 0.0;
  return false;
}

public num toNum(value v) {
  if (int i := v) return i;
  if (real r := v) return r;
  if (bool b := v) return b ? 1 : 0;
  return 0;
}

public int asInt(value v) {
  if (int i := v) return i;
  if (real r := v) return toInt(r);
  if (bool b := v) return b ? 1 : 0;
  return 0;
}
