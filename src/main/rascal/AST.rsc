module AST

data Program = program(list[Module] modules);

data Module
  = dataDef(DataAbstraction dataAbs)
  | funcDef(FunctionDef func);

data DataAbstraction = dataAbstraction(
  str name,
  list[str] ids,
  list[str] fields
);

data FunctionDef = functionDef(
  str name,
  list[str] params,
  list[Statement] body
);

data Literal
  = intLit(int intValue)
  | floatLit(real realValue)
  | boolLit(bool boolValue)
  | charLit(str charValue)
  | stringLit(str strValue)
  ;

data Expression
  = binaryExpr(Expression left, str op, Expression right)
  | unaryExpr(str op, Expression expr)
  | literalExpr(Literal lit)
  | varExpr(str name)
  | callExpr(FunctionCall call)
  | ctorExpr(ConstructorCall ctor)
  | groupExpr(Expression expr)
  ;

data FunctionCall = funcCall(
  str name,
  list[Expression] args
);

data ConstructorCall = ctorCall(
  str name,
  list[NamedArg] args
);

data NamedArg = namedArg(str name, Expression expr);

data DataConstruction = dataConstruction(
  str name,
  list[NamedArg] args
);

data IfStmt = ifStmt(
  Expression cond,
  list[Statement] thenBlock,
  list[tuple[Expression, list[Statement]]] elseifBlocks,
  list[Statement] elseBlock
);

data CondStmt = condStmt(
  Expression cond,
  list[CondClause] clauses
);

data CondClause = condClause(
  Expression cond,
  list[Statement] body
);

data LoopStmt
  = forRange(str var, Expression fromExpr, Expression toExpr, list[Statement] body)
  | forIn(str var, Expression expr, list[Statement] body);

data Statement =
    assignStmt(str varName, Expression val)
  | funcCallStmt(FunctionCall call)
  | conditionalStmt(IfStmt ifs)
  | condStmt(CondStmt cond)
  | loopStmt(LoopStmt loop)
  | dataConstructionStmt(DataConstruction dataCtor)
  ;
