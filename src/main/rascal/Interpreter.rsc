module Interpreter

import AST; 
import IO;
import Map;


alias Env = map[str, value];

public void evalProgram(Program p) {
  Env env = ();
  for (m <- p.modules) {
    evalModule(m, env);
  }
}

public void evalModule(Module m, Env env) {
  switch (m) {
    case dataDef(_): println("Data definitions not executed yet.");
    case funcDef(f): evalFunction(f, env);
  }
}

public void evalFunction(FunctionDef f, Env env) {
  println("Executing function ...");
  for (s <- f.body) {
    env = evalStatement(s, env);
  }
  println("End of function ");
}

//Evaluación de Sentencias

public Env evalStatement(Statement s, Env env) {
  switch (s) {
    case assignStmt(varName, val): { // Asignación
      value v = evalExpression(val, env);
      env += (varName: v);
      println("Assigned = ");
      return env;
    }
    
    case conditionalStmt(i): return evalIf(i, env); // Condicional If
    case loopStmt(l): return evalLoop(l, env); // Bucles
    
    case funcCallStmt(call): { // Llamada a función como sentencia
      evalFunctionCall(call, env);
      return env;
    }
    
    case dataConstructionStmt(dataCtor): { // Construcción de datos
      println("Data construction not yet implemented: ");
      return env;
    }
    
    case condStmt(cond): { 
      println("Cond statement not yet implemented."); 
      return env;
    }
    
    default: {
      println("Statement not implemented: ");
      return env;
    }
  }
}

public Env evalIf(IfStmt i, Env env) {
  if (toBool(evalExpression(i.cond, env))) {
    return evalBlock(i.thenBlock, env);
  }
  
  for (<Expression cond, list[Statement] block> <- i.elseifBlocks) {
    if (toBool(evalExpression(cond, env))) {
      return evalBlock(block, env);
    }
  }
  
  return evalBlock(i.elseBlock, env);
}

public Env evalLoop(LoopStmt l, Env env) {
  switch (l) {
    case forRange(v, fromExpr, toExpr, body): { // Bucle For Range
      int startVal = toInt(evalExpression(fromExpr, env));
      int endVal = toInt(evalExpression(toExpr, env));
      
      for (i <- [startVal .. endVal]) {
        env += (v: i);
        env = evalBlock(body, env);
      }
      return env;
    }
    
    case forIn(v, e, body): { // Bucle For In
      value seq = evalExpression(e, env);
      
      if (list[value] lst := seq) {
        for (item <- lst) {
          env += (v: item);
          env = evalBlock(body, env);
        }
      }
      return env;
    }
  }
  
  throw "Unknown loop type";
}

public Env evalBlock(list[Statement] body, Env env) {
  for (s <- body) {
    env = evalStatement(s, env);
  }
  return env;
}

//Evaluación de Expresiones

public value evalExpression(Expression e, Env env) {
  switch (e) {
    case literalExpr(l): return evalLiteral(l);
    case varExpr(n): return env[n] ? "undefined"; 
    case binaryExpr(l, op, r): return evalBinary(l, op, r, env);
    case unaryExpr(op, ex): return evalUnary(op, ex, env);
    case groupExpr(g): return evalExpression(g, env);
    case callExpr(call): return evalFunctionCall(call, env);
    case ctorExpr(ctor): return evalConstructorCall(ctor, env);
    default: return "unsupported expression";
  }
}

public value evalFunctionCall(FunctionCall call, Env env) {
  println("Function call not implemented: ()");
  return "call";
}

public value evalConstructorCall(ConstructorCall ctor, Env env) {
  println("Constructor call not implemented: ()");
  return "ctor";
}

//Operaciones Binarias

public value evalBinary(Expression l, str op, Expression r, Env env) {
  value lv = evalExpression(l, env);
  value rv = evalExpression(r, env);

  switch (op) {
    // Operadores Aritméticos
    case "+": return toInt(lv) + toInt(rv);
    case "-": return toInt(lv) - toInt(rv);
    case "*": return toInt(lv) * toInt(rv);
    case "/": return toReal(lv) / toReal(rv);
    case "%": return toInt(lv) % toInt(rv);
    
    case "**": { // Potencia
      int base = toInt(lv);
      int exp = toInt(rv);
      if (exp == 0) return 1;
      int result = 1;
      for (_ <- [1..exp]) {
        result = result * base;
      }
      return result;
    }
    
    // Operadores de Comparación 
    case "\<": return toInt(lv) < toInt(rv);
    case "\>": return toInt(lv) > toInt(rv);
    case "\<=": return toInt(lv) <= toInt(rv);
    case "\>=": return toInt(lv) >= toInt(rv);
    case "=": return lv == rv;
    case "\<\>": return lv != rv;
    
    // Operadores Lógicos
    case "and": return toBool(lv) && toBool(rv);
    case "or": return toBool(lv) || toBool(rv);
    
    default: return "unsupported op";
  }
}

//Operaciones Unarias

public value evalUnary(str op, Expression e, Env env) {
  value v = evalExpression(e, env);

  switch (op) {
    case "neg": return -toInt(v); 
    case "-": return -toInt(v);
    default: return v;
  }
}

//Evaluación de Literales

public value evalLiteral(Literal l) {
  switch (l) {
    case intLit(intValue): return intValue;
    case floatLit(realValue): return realValue;
    case boolLit(boolValue): return boolValue;
    case charLit(charValue): return charValue;
    case stringLit(strValue): return strValue;
  }
  throw "Unknown literal type";
}

//Utilidades de Conversión de Tipos

public bool toBool(value v) {
  if (v == true) return true;
  if (v == false) return false;
  return v != 0;
}

public int toInt(value v) {
  if (int n := v) return n;
  return 0;
}

public real toReal(value v) {
  if (real r := v) return r;
  if (int n := v) return n * 1.0;
  return 0.0;
}