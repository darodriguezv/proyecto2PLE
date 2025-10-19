module AST

data Program = program(list[Module] modules);

data Module
  = dataDef(DataAbstraction dataAbs)
  | funcDef(FunctionDef func);

data DataAbstraction = dataAbstraction(
  str name,
  list[str] ids,
  list[str] fields,
  str endName
);

data FunctionDef = functionDef(
  str name,
  list[str] params,
  list[Statement] body,
  str endName
);

data Literal
  = intLit(int intValue)
  | floatLit(real realValue)
  | boolLit(str boolValue)
  | charLit(str charValue)
  | stringLit(str strValue)
  ;

// Expression hierarchy matching grammar
data Expression = orExpr(OrExpr expr);

data OrExpr
  = binaryOr(OrExpr left, AndExpr right)
  | andExpr(AndExpr expr);

data AndExpr
  = binaryAnd(AndExpr left, CmpExpr right)
  | cmpExpr(CmpExpr expr);

data CmpExpr
  = binaryExpr(AddExpr left, str op, AddExpr right)
  | addExpr(AddExpr expr);

data AddExpr
  = binaryAdd(AddExpr left, str op, MulExpr right)
  | mulExpr(MulExpr expr);

data MulExpr
  = binaryMul(MulExpr left, str op, PowExpr right)
  | powExpr(PowExpr expr);

data PowExpr
  = binaryPow(UnaryExpr left, PowExpr right)
  | unaryExpr(UnaryExpr expr);

data UnaryExpr
  = unaryNeg(UnaryExpr operand)
  | unaryMinus(UnaryExpr operand)
  | postfix(Postfix postfixExpr);

data Postfix
  = postfixCall(Postfix callee, list[Expression] args)
  | primary(Primary primaryExpr);

data Primary
  = literalExpr(Literal lit)
  | varExpr(str name)
  | groupExpr(Expression expr)
  | ctorExpr(ConstructorCall ctor);

data FunctionCall = funcCall(
  str name,
  list[Expression] args
);

data ConstructorCall 
  = ctorCall(list[Expression] args)
  ;

data NamedArg = namedArg(str name, Expression expr);

data DataConstruction = dataConstruction(
  ConstructorCall ctor
);

data ConditionalStmt
  = ifStmt(IfStmt ifs)
  | condStmt(CondStmt cond)
  ;

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

data Statement 
  = assignStmt(str varName, Expression val)
  | funcCallStmt(FunctionCall call)
  | conditionalStmt(ConditionalStmt ifs)
  | loopStmt(LoopStmt loop)
  ;
