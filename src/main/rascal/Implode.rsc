module Implode

import Syntax;
import AST;
import ParseTree;
import String;

public AST::Program implodeProgram(str code) {
  pt = parse(#start[Program], code).top;
  return toAST(pt);
}

AST::Program toAST(pt:(Program)`<Module+ modules>`) {
  list[AST::Module] mods = [];
  
  for (m <- modules) {
    if ((Module)`<DataAbstraction da>` := m) {
      mods += AST::dataDef(toDataAbs(da));
    }
    else if ((Module)`<FunctionDef fd>` := m) {
      mods += AST::funcDef(toFuncDef(fd));
    }
  }
  
  return AST::program(mods);
}

AST::DataAbstraction toDataAbs(DataAbstraction da) {
  if ((DataAbstraction)`data <Id n> with <{Id ","}+ ids> end <Id _>` := da) {
    return AST::dataAbstraction("<n>", ["<id>" | id <- ids], []);
  }
  else if ((DataAbstraction)`data <Id n> with <{Id ","}+ ids> rep struct ( <{Id ","}* flds> ) end <Id _>` := da) {
    return AST::dataAbstraction("<n>", ["<id>" | id <- ids], ["<f>" | f <- flds]);
  }
  throw "Unknown DataAbstraction";
}

AST::FunctionDef toFuncDef(FunctionDef fd) {
  if ((FunctionDef)`function <Id n> ( <{Id ","}* ps> ) do <Statement* stmts> end <Id _>` := fd) {
    return AST::functionDef("<n>", ["<p>" | p <- ps], [toStmt(s) | s <- stmts]);
  }
  throw "Unknown FunctionDef";
}

AST::Statement toStmt(Statement s) {
  if ((Statement)`<Id v> = <Expression e>` := s)
    return AST::assignStmt("<v>", toExpr(e));
  else if ((Statement)`<ConditionalStmt cs>` := s)
    return AST::conditionalStmt(toCondStmt(cs));
  else if ((Statement)`<LoopStmt ls>` := s)
    return AST::loopStmt(toLoop(ls));
  else if ((Statement)`<FunctionCall fc>` := s)
    return AST::funcCallStmt(toFuncCall(fc));
  throw "Unknown Statement";
}

AST::ConditionalStmt toCondStmt(ConditionalStmt cs) {
  if ((ConditionalStmt)`<IfStmt ifs>` := cs)
    return AST::ifStmt(toIfStmt(ifs));
  else if ((ConditionalStmt)`<CondStmt cond>` := cs)
    return AST::condStmt(toCondStmt2(cond));
  throw "Unknown ConditionalStmt";
}

AST::IfStmt toIfStmt(IfStmt ifs) {
  if ((IfStmt)`if <Expression c> then <Statement* tb> end` := ifs)
    return AST::ifStmt(toExpr(c), [toStmt(s) | s <- tb], [], []);
  throw "Complex IfStmt not implemented";
}

AST::CondStmt toCondStmt2(CondStmt cs) {
  if ((CondStmt)`cond <Expression c> do <CondClause+ cls> end` := cs)
    return AST::condStmt(toExpr(c), [toCondClause(cl) | cl <- cls]);
  throw "Unknown CondStmt";
}

AST::CondClause toCondClause(CondClause cc) {
  if ((CondClause)`<Expression c> -\> <Statement+ body>` := cc)
    return AST::condClause(toExpr(c), [toStmt(s) | s <- body]);
  throw "Unknown CondClause";
}

AST::LoopStmt toLoop(LoopStmt ls) {
  if ((LoopStmt)`for <Id v> from <Expression f> to <Expression t> do <Statement* body> end` := ls)
    return AST::forRange("<v>", toExpr(f), toExpr(t), [toStmt(s) | s <- body]);
  else if ((LoopStmt)`for <Id v> in <Expression e> do <Statement* body> end` := ls)
    return AST::forIn("<v>", toExpr(e), [toStmt(s) | s <- body]);
  throw "Unknown LoopStmt";
}

AST::FunctionCall toFuncCall(FunctionCall fc) {
  if ((FunctionCall)`<Id n> ( <{Expression ","}* args> )` := fc)
    return AST::funcCall("<n>", [toExpr(e) | e <- args]);
  throw "Unknown FunctionCall";
}

AST::Expression toExpr(Expression e) {
  if ((Expression)`<OrExpr oe>` := e)
    return toOrExpr(oe);
  throw "Unknown Expression";
}

AST::Expression toOrExpr(OrExpr oe) {
  if ((OrExpr)`<OrExpr l> or <AndExpr r>` := oe)
    return AST::binaryExpr(toOrExpr(l), toAndExpr(r));
  else if ((OrExpr)`<AndExpr ae>` := oe)
    return toAndExpr(ae);
  throw "Unknown OrExpr";
}

AST::Expression toAndExpr(AndExpr ae) {
  if ((AndExpr)`<AndExpr l> and <CmpExpr r>` := ae)
    return AST::binaryExpr(toAndExpr(l), toCmpExpr(r));
  else if ((AndExpr)`<CmpExpr ce>` := ae)
    return toCmpExpr(ce);
  throw "Unknown AndExpr";
}

AST::Expression toCmpExpr(CmpExpr ce) {
  if ((CmpExpr)`<AddExpr l> <CmpOp _> <AddExpr r>` := ce)
    return AST::binaryExpr(toAddExpr(l), toAddExpr(r));
  else if ((CmpExpr)`<AddExpr ae>` := ce)
    return toAddExpr(ae);
  throw "Unknown CmpExpr";
}

AST::Expression toAddExpr(AddExpr ae) {
  if ((AddExpr)`<AddExpr l> + <MulExpr r>` := ae)
    return AST::binaryExpr(toAddExpr(l), toMulExpr(r));
  else if ((AddExpr)`<AddExpr l> - <MulExpr r>` := ae)
    return AST::binaryExpr(toAddExpr(l), toMulExpr(r));
  else if ((AddExpr)`<MulExpr me>` := ae)
    return toMulExpr(me);
  throw "Unknown AddExpr";
}

AST::Expression toMulExpr(MulExpr me) {
  if ((MulExpr)`<MulExpr l> * <PowExpr r>` := me)
    return AST::binaryExpr(toMulExpr(l), toPowExpr(r));
  else if ((MulExpr)`<MulExpr l> / <PowExpr r>` := me)
    return AST::binaryExpr(toMulExpr(l), toPowExpr(r));
  else if ((MulExpr)`<MulExpr l> % <PowExpr r>` := me)
    return AST::binaryExpr(toMulExpr(l), toPowExpr(r));
  else if ((MulExpr)`<PowExpr pe>` := me)
    return toPowExpr(pe);
  throw "Unknown MulExpr";
}

AST::Expression toPowExpr(PowExpr pe) {
  if ((PowExpr)`<UnaryExpr l> ** <PowExpr r>` := pe)
    return AST::binaryExpr(toUnaryExpr(l), toPowExpr(r));
  else if ((PowExpr)`<UnaryExpr ue>` := pe)
    return toUnaryExpr(ue);
  throw "Unknown PowExpr";
}

AST::Expression toUnaryExpr(UnaryExpr ue) {
  if ((UnaryExpr)`neg <UnaryExpr e>` := ue)
    return AST::unaryExpr(toUnaryExpr(e));
  else if ((UnaryExpr)`- <UnaryExpr e>` := ue)
    return AST::unaryExpr(toUnaryExpr(e));
  else if ((UnaryExpr)`<Postfix pf>` := ue)
    return toPostfix(pf);
  throw "Unknown UnaryExpr";
}

AST::Expression toPostfix(Postfix pf) {
  if ((Postfix)`<Postfix _> ( <{Expression ","}* args> )` := pf)
    return AST::callExpr([toExpr(e) | e <- args]);
  else if ((Postfix)`<Primary pr>` := pf)
    return toPrimary(pr);
  throw "Unknown Postfix";
}

AST::Expression toPrimary(Primary pr) {
  if ((Primary)`( <Expression e> )` := pr)
    return AST::groupExpr(toExpr(e));
  else if ((Primary)`<Literal lit>` := pr)
    return AST::literalExpr(toLiteral(lit));
  else if ((Primary)`<Id n>` := pr)
    return AST::varExpr("<n>");
  else if ((Primary)`<ConstructorCall cc>` := pr)
    return AST::ctorExpr(toCtorCall(cc));
  throw "Unknown Primary";
}

AST::ConstructorCall toCtorCall(ConstructorCall cc) {
  if ((ConstructorCall)`sequence [ <{Expression ","}* args> ]` := cc)
    return AST::ctorCall([toExpr(e) | e <- args]);
  else if ((ConstructorCall)`tuple ( <{Expression ","}* args> )` := cc)
    return AST::ctorCall([toExpr(e) | e <- args]);
  else if ((ConstructorCall)`struct ( <{NamedArg ","}* _> )` := cc)
    return AST::ctorCall([]);
  throw "Unknown ConstructorCall";
}

AST::Literal toLiteral(Literal lit) {
  if ((Literal)`<Integer i>` := lit)
    return AST::intLit(toInt("<i>"));
  else if ((Literal)`<Float f>` := lit)
    return AST::floatLit(toReal("<f>"));
  else if ((Literal)`<Boolean b>` := lit)
    return AST::boolLit("<b>" == "true");
  else if ((Literal)`<Char c>` := lit)
    return AST::charLit("<c>");
  else if ((Literal)`<String s>` := lit)
    return AST::stringLit("<s>");
  throw "Unknown Literal";
}
