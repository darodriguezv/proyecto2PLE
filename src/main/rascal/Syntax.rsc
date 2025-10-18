module Syntax

// Programa y módulos

start syntax Program = Module+ ;

syntax Module
  = dataDef: DataAbstraction
  | funcDef: FunctionDef
  ;

// Abstracciones de datos

syntax DataAbstraction =
  dataAbstractionDef: "data" Id "with" IdList
                      ("rep" "struct" "(" FieldList? ")")?
                      "end" Id ;

syntax IdList = idList: Id ("," Id)* ;

syntax FieldList = fieldList: Id ("," Id)* ;

// Funciones

syntax FunctionDef =
  functionDef: "function" Id "(" ParameterList? ")"
               "do" Statement*
               "end" Id ;

syntax ParameterList = parameterList: Id ("," Id)* ;

// Sentencias

syntax Statement
  = assignment: Id "=" Expression
  | multiAssign: IdList ":=" ExpressionList
  | funcCallStmt: FunctionCall
  | conditionalStmt: ConditionalStmt
  | loopStmt: LoopStmt
  ;

syntax ExpressionList = expressionList: Expression ("," Expression)* ;

// Llamadas a funciones

syntax FunctionCall = functionCall: Id ArgumentList ;

syntax ArgumentList = argumentList: "(" (Expression ("," Expression)*)? ")" ;

// Construcción de datos

syntax DataConstruction
  = dataConstruction: ConstructorCall ;

syntax ConstructorCall =
  constructorCall: "sequence" "[" (Expression ("," Expression)*)? "]"
                 | "tuple" "(" (Expression ("," Expression)*)? ")"
                 | "struct" "(" NamedArgList? ")" ;

syntax NamedArgList = namedArgList: NamedArg ("," NamedArg)* ;
syntax NamedArg = namedArg: Id ":" Expression ;

// Condicionales

syntax ConditionalStmt
  = ifStmt: IfStmt
  | condStmt: CondStmt
  ;

syntax IfStmt =
  ifStmt: "if" Expression "then" Statement*
          ("elseif" Expression "then" Statement*)*
          ("else" Statement*)?
          "end" ;

syntax CondStmt =
  condStmt: "cond" Expression "do" CondClause+ "end" ;

syntax CondClause = condClause: Expression "-\>" Statement+ ;

// Bucles

syntax LoopStmt =
    forRange: "for" Id "from" Expression "to" Expression "do" Statement* "end"
  | forIn: "for" Id "in" Expression "do" Statement* "end"
  ;

// Jerarquía de expresiones

syntax Expression = OrExpr ;

syntax OrExpr
  = AndExpr
  | left orExpr: OrExpr "or" AndExpr
  ;

syntax AndExpr
  = CmpExpr
  | left andExpr: AndExpr "and" CmpExpr
  ;

syntax CmpExpr
  = AddExpr
  | non-assoc cmpExpr: AddExpr CmpOp AddExpr
  ;

lexical CmpOp = [\<] | [\>] | "\<=" | "\>=" | "\<\>" | "=" ;

syntax AddExpr
  = MulExpr
  | left addExpr: AddExpr ("+" | "-") MulExpr
  ;

syntax MulExpr
  = PowExpr
  | left mulExpr: MulExpr ("*" | "/" | "%") PowExpr
  ;

syntax PowExpr
  = UnaryExpr
  | right powExpr: UnaryExpr "**" PowExpr
  ;

syntax UnaryExpr
  = Postfix
  | unaryNeg: "neg" UnaryExpr
  | unaryMinus: "-" UnaryExpr
  ;

// Postfix y expresiones primarias

syntax Postfix
  = Primary
  | left postfixCall: Postfix ArgumentList
  | left postfixMember: Postfix "." Id
  ;

syntax Primary
  = bracket bracketExpr: "(" Expression ")"
  | primaryLiteral: Literal
  | primaryId: Id
  | primaryConstructor: ConstructorCall
  ;

// Literales

syntax Literal
  = numberLit: Number
  | boolLit: Boolean
  | charLit: Char
  | stringLit: String
  ;

// Tokens léxicos

lexical Id = [a-zA-Z_][a-zA-Z0-9_\-]* \ Reserved ;

lexical Number
  = [0-9]+ "." [0-9]+
  | [0-9]+
  ;

lexical Boolean = "true" | "false" ;

lexical Char = [\'] CharContent [\'] ;
lexical CharContent
  = "\\\\"
  | [\'][\\][\']
  | "\\n"
  | "\\t"
  | "\\r"
  | ![\'\\]
  ;

lexical String = [\"] StringContent* [\"] ;
lexical StringContent
  = "\\\\"
  | [\"][\\][\"]
  | "\\n"
  | "\\t"
  | "\\r"
  | ![\"\\]
  ;

// Palabras reservadas

keyword Reserved =
  "data" | "with" | "rep" | "struct" | "function" | "do" | "end"
| "if" | "then" | "elseif" | "else" | "cond" | "for" | "from" | "to" | "in"
| "iterator" | "yielding" | "sequence" | "tuple"
| "and" | "or" | "neg" | "true" | "false" ;

// Espacios y comentarios

layout Layout = WhitespaceOrComment* !>> [\ \t\n\r#];

lexical WhitespaceOrComment
  = [\ \t\n\r]
  | Comment
  ;

lexical Comment = "#" ![\n\r]* $;
