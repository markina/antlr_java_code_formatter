grammar Count;

// export CLASSPATH=".:/usr/local/lib/antlr-4.5-complete.jar:$CLASSPATH"
//alias antlr4='java -jar /usr/local/lib/antlr-4.5-complete.jar'
// alias grun='java org.antlr.v4.runtime.misc.TestRig'
//antlr4 Count.g4
//javac *.java
//grun Count start -gui

@headers {
}

@members {
    int countSpaces = 0;
    String repeat(String str, int cnt) {
        String ans = "";
        for(int i = 0; i < cnt * 4; i++) {
            ans += str;
        }
        return ans;
    }
}


TYPE_NAME : 'boolean'|'char'|'byte'|'short'|'int'|'long'|'float'|'double'|'void';
MODIFIER : 'abstract'|'final'|'static'|'public'|'protected'|'private'|'volatile'|'native'|'synchronized';

OP_DIM : '['[ \n\r\t]*']';
IDENTIFIER: [a-zA-Z]+[a-zA-Z0-9_]*;

INT : [0-9]+ ;
WS : [ \r\t\n]+ -> skip ;

start
    : importStatements methodDeclarations {System.out.print($importStatements.toString + "\n" + $methodDeclarations.toString); }
    | methodDeclarations {System.out.print($methodDeclarations.toString); }
    | importStatements {System.out.print($importStatements.toString); }
    ;

methodDeclarations returns [String toString]
    : methodDeclaration {$toString = $methodDeclaration.toString; }
    | methodDeclaration m=methodDeclarations {$toString = $methodDeclaration.toString + $m.toString; }
    ;

importStatements returns [String toString]
	: importStatement {$toString = $importStatement.toString; }
	| importStatement i=importStatements {$toString = $importStatement.toString + $i.toString; }
	;

importStatement returns [String toString]
	: 'import' qualifiedName ';' {$toString = "import " + $qualifiedName.text + ";\n"; }
	| 'import' qualifiedName '.' '*' ';' {$toString = "import " + $qualifiedName.text + ".*;\n"; }
	;

qualifiedName returns [String toString]
	: IDENTIFIER {$toString = $IDENTIFIER.text; }
	| IDENTIFIER '.' qualifiedName {$toString = $IDENTIFIER.text + "." + $qualifiedName.toString; }
	;

methodDeclaration returns [String toString]
    : modifiers typeSpecifier methodDeclarator methodBody {$toString = repeat(" ", countSpaces) + $modifiers.toString + " " + $typeSpecifier.toString + " " + $methodDeclarator.toString  + $methodBody.toString ;}
    |           typeSpecifier methodDeclarator methodBody {$toString = repeat(" ", countSpaces) + $typeSpecifier.toString + " " + $methodDeclarator.toString  + $methodBody.toString ;}
    ;

typeSpecifier returns [String toString]
	: TYPE_NAME {$toString = $TYPE_NAME.text; }
	| TYPE_NAME dims {$toString = $TYPE_NAME.text + $dims.toString ;}
	| IDENTIFIER {$toString = $IDENTIFIER.text ;}
	| IDENTIFIER dims {$toString = $IDENTIFIER.text + $dims.toString ;}
	;

dims returns [String toString]
	: OP_DIM {$toString = "[]" ;}
	| OP_DIM d=dims {$toString = "[]" + $d.text; }
	;

methodDeclarator returns [String toString]
	: IDENTIFIER '(' parameterList ')' {$toString = $IDENTIFIER.text + "(" + $parameterList.toString + ")" ;}
	| IDENTIFIER '(' ')' {$toString = $IDENTIFIER.text + "()" ;}
    ;

modifiers returns [String toString]
	: MODIFIER {$toString = $MODIFIER.text; }
	| MODIFIER m=modifiers {$toString = $MODIFIER.text + " " + $m.toString; }
	;

parameterList returns [String toString]
	: parameter {$toString = $parameter.toString; }
	| parameter ',' p=parameterList {$toString = $parameter.toString + ", " + $p.toString ;}
	;


parameter returns [String toString]
	: typeSpecifier IDENTIFIER {$toString = $typeSpecifier.text + " " + $IDENTIFIER.text; }
	;


methodBody returns [String toString]
	: block {$toString = $block.toString; }
	| ';' {$toString = ";\n"; }
	;



block returns [String toString]
	:  { countSpaces++; } '{' statements '}' {$toString = " {\n" + $statements.toString + repeat(" ", countSpaces - 1)+ "}\n" ; countSpaces--; }
	| '{' '}' {$toString = " {}\n";}
    ;

statements returns [String toString]
	: statement {$toString = $statement.toString; }
	| statement s=statements {$toString = $statement.toString + $s.toString; }
	;

statement returns [String toString]
    : emptyStatement {$toString = repeat(" ", countSpaces) + $emptyStatement.text + "\n"; }
    | selectionStatement {$toString = repeat(" ", countSpaces) + $selectionStatement.toString; }
    | expression ';' {$toString = repeat(" ", countSpaces) + $expression.toString + ";\n";}
    | block {$toString = $block.toString; }
    ;

emptyStatement
	: ';'
    ;

selectionStatement returns [String toString]
	: 'if' '(' expression ')' statement {$toString = "if (" + $expression.toString + ")" + $statement.toString ;}
    | 'if' '(' expression ')' statement 'else' statement {$toString = "if (" + $expression.toString + ")" + $statement.toString + repeat(" ", countSpaces) + "else" + $statement.toString;}
    ;

expression returns [String toString]
    : assignmentExpression {$toString = $assignmentExpression.toString; }
    | arithmeticExpression {$toString = $arithmeticExpression.toString; }
    ;


assignmentExpression returns [String toString]
	: qualifiedName assignmentOperator expression  {$toString = $qualifiedName.text + " " + $assignmentOperator.text + " " + $expression.toString; }
	| typeSpecifier qualifiedName assignmentOperator expression {$toString = $typeSpecifier.text + " " + $qualifiedName.text + " " + $assignmentOperator.text + " " + $expression.toString; }
	;

assignmentOperator
	: '='
	| '*='
	| '/='
	| '+='
	| '-='
	| '&='
	| '^='
	| '|='
	;

arithmeticExpression returns [String toString]
    : primaryExpression {$toString = $primaryExpression.toString; }
    | c=arithmeticExpression operator primaryExpression {$toString = $c.toString + " " + $operator.text + " " + $primaryExpression.toString; }
    ;

operator
    : '&&'
    | '||'
    | '+'
    | '-'
    | '*'
    | '/'
    | '%'
    | '^'
    | '=='
    | '!='
    | '>'
    | '<'
    | '>='
    | '<='
    ;


primaryExpression returns [String toString]
    : INT {$toString = $INT.text; }
    | qualifiedName {$toString = $qualifiedName.text; }
    ;