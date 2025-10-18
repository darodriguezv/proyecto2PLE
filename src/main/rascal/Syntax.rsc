module Syntax

// Programa y módulos

start syntax Program = Module+ ;

syntax Module
  = dataDef: DataAbstraction
  | funcDef: FunctionDef
  ;

// Abstracciones de datos

syntax DataAbstraction =
  dataAbstraction: "data" Id name "with" IdList ids
                   ("rep" "struct" "(" FieldList? fields ")")?
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
  = assignStmt: Id varName "=" Expression val
  | funcCallStmt: FunctionCall call
  | conditionalStmt: ConditionalStmt ifs
  | loopStmt: LoopStmt loop
  ;

// Llamadas a funciones

syntax FunctionCall = funcCall: Id name "(" {Expression ","}* args ")" ;

// Construcción de datos

syntax DataConstruction
  = dataConstruction: ConstructorCall ;

syntax ConstructorCall =
  ctorCall: "sequence" "[" {Expression ","}* "]"
  | ctorCall: "tuple" "(" {Expression ","}* ")"
  | ctorCall: "struct" "(" {NamedArg ","}* args ")" ;

syntax NamedArg = namedArg: Id name ":" Expression expr ;

// Condicionales

syntax ConditionalStmt
  = ifStmt: IfStmt
  | condStmt: CondStmt
  ;

syntax IfStmt =
  ifStmt: "if" Expression cond "then" Statement* thenBlock
          ("elseif" Expression "then" Statement*)*  elseifBlocks
          ("else" Statement* elseBlock)?
          "end" ;

syntax CondStmt =
  condStmt: "cond" Expression cond "do" CondClause+ clauses "end" ;

syntax CondClause = condClause: Expression cond "-\>" Statement+ body ;

// Bucles

syntax LoopStmt =
    forRange: "for" Id var "from" Expression fromExpr "to" Expression toExpr "do" Statement* body "end"
  | forIn: "for" Id var "in" Expression expr "do" Statement* body "end"
  ;

// Jerarquía de expresiones

syntax Expression = OrExpr ;

syntax OrExpr
  = AndExpr
  | left binaryExpr: OrExpr left "or" op AndExpr right
  ;

syntax AndExpr
  = CmpExpr
  | left binaryExpr: AndExpr left "and" op CmpExpr right
  ;

syntax CmpExpr
  = AddExpr
  | non-assoc binaryExpr: AddExpr left CmpOp op AddExpr right
  ;

lexical CmpOp = [\<] | [\>] | "\<=" | "\>=" | "\<\>" | "=" ;

syntax AddExpr
  = MulExpr
  | left binaryExpr: AddExpr left ("+" | "-") op MulExpr right
  ;

syntax MulExpr
  = PowExpr
  | left binaryExpr: MulExpr left ("*" | "/" | "%") op PowExpr right
  ;

syntax PowExpr
  = UnaryExpr
  | right binaryExpr: UnaryExpr left "**" op PowExpr right
  ;

syntax UnaryExpr
  = Postfix
  | unaryExpr: "neg" op UnaryExpr expr
  | unaryExpr: "-" op UnaryExpr expr
  ;

// Postfix y expresiones primarias

syntax Postfix
  = Primary
  | left callExpr: Postfix "(" {Expression ","}* args ")"
  ;

syntax Primary
  = bracket groupExpr: "(" Expression expr ")"
  | literalExpr: Literal lit
  | varExpr: Id name
  | ctorExpr: ConstructorCall ctor
  ;

// Literales

syntax Literal
  = floatLit: Float realValue
  | intLit: Integer intValue
  | boolLit: Boolean boolValue
  | charLit: Char charValue
  | stringLit: String strValue
  ;

// Tokens léxicos

lexical Id = [a-zA-Z_][a-zA-Z0-9_\-]* \ Reserved ;

lexical Float = [0-9]+ "." [0-9]+ ;

lexical Integer = [0-9]+ ;

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
