import { Token, TokenType } from '../model/Token';

export class Lexer {
  private input: string;
  private pos: number = 0;
  private previousToken: Token | null = null; // 跟踪前一个token

  constructor(expression: string) {
    // 预处理：移除所有空格，方便处理
    this.input = expression.replace(/\s+/g, '');
  }

  getTokens(): Token[] {
    const tokens: Token[] = [];
    this.previousToken = null;

    while (this.pos < this.input.length) {
      const char = this.input[this.pos];

      if (this.isDigit(char) || char === '.') {
        const token = this.readNumber();
        tokens.push(token);
        this.previousToken = token;
      } else if (char === '%') {
        // 处理百分比符号
        const token = new Token(TokenType.PERCENTAGE, '%', 4);
        tokens.push(token);
        this.previousToken = token;
        this.pos++;
      } else if (this.isOperator(char)) {
        const token = this.readOperator();
        tokens.push(token);
        this.previousToken = token;
      } else if (char === '!') {
        const token = new Token(TokenType.POSTFIX_OPERATOR, '!', 4);
        tokens.push(token);
        this.previousToken = token;
        this.pos++;
      } else if (char === '^') {
        const token = new Token(TokenType.OPERATOR, '^', 3);
        tokens.push(token);
        this.previousToken = token;
        this.pos++;
      } else if (this.isLetter(char)) {
        const token = this.readFunctionOrConstant();
        tokens.push(token);
        this.previousToken = token;
      } else if (char === '(') {
        const token = new Token(TokenType.LEFT_PAREN, '(');
        tokens.push(token);
        this.previousToken = token;
        this.pos++;
      } else if (char === ')') {
        const token = new Token(TokenType.RIGHT_PAREN, ')');
        tokens.push(token);
        this.previousToken = token;
        this.pos++;
      } else {
        this.pos++;
      }
    }
    return tokens;
  }

  private readNumber(): Token {
    let startPos = this.pos;
    let hasDecimal = false;
    let hasExponent = false;
    // 读取连续的数字和小数点
    while (this.pos < this.input.length) {
      const char = this.input[this.pos];

      if (this.isDigit(char)) {
        this.pos++;
      } else if (char === '.' && !hasDecimal) {
        hasDecimal = true;
        this.pos++;
      } else if ((char === 'E' || char === 'e') && !hasExponent) {
        hasExponent = true;
        this.pos++;
        // 处理指数符号
        if (this.pos < this.input.length && (this.input[this.pos] === '+' || this.input[this.pos] === '-')) {
          this.pos++;
        }
      } else {
        break;
      }
    }

    const numberStr = this.input.substring(startPos, this.pos);
    return new Token(TokenType.NUMBER, numberStr);
  }

  private readOperator(): Token {
    const op = this.input[this.pos];
    this.pos++;
    let precedence = 0;
    let isUnary = false;

    // 判断是否是一元负号
    if (op === '-') {
      isUnary = this.isUnaryMinusContext();
    }

    if (isUnary) {
      return new Token(TokenType.FUNCTION, 'neg', 4, true);
    }
    // 定义运算符优先级
    if (op === '+' || op === '-') {
      precedence = 1;
    }
    if (op === '*' || op === '÷') {
      precedence = 2;
    }
    if (op === '^') {
      precedence = 3;
    } // 指数优先级最高

    return new Token(TokenType.OPERATOR, op, precedence);
  }

  // 增强的判断函数，特别处理指数后的负号
  private isUnaryMinusContext(): boolean {
    // 表达式开头：-5
    if (this.pos === 1) {
      return true;
    }

    const prevChar = this.input[this.pos - 2];

    // 前面是左括号：(-5) 或 3*(-2)
    if (prevChar === '(') {
      return true;
    }

    // 前面是其他运算符：3*-2 或 3+ -2
    if (this.isOperator(prevChar)) {
      return true;
    }

    // 前面是函数或常数：sin(-x)
    if (this.previousToken &&
      (this.previousToken.type === TokenType.FUNCTION ||
        this.previousToken.type === TokenType.CONSTANT)) {
      return true;
    }

    // 特别处理：指数符号后的负号是一元的：2^-3
    if (prevChar === '^') {
      return true;
    }

    // 前面是逗号：max(3,-2)
    if (prevChar === ',') {
      return true;
    }

    return false;
  }

  private readFunctionOrConstant(): Token {
    let startPos = this.pos;
    while (this.pos < this.input.length && this.isLetter(this.input[this.pos])) {
      this.pos++;
    }
    const name = this.input.substring(startPos, this.pos);

    // 判断是函数还是常量
    if (['sin', 'cos', 'tan', 'sinh', 'cosh', 'tanh', 'log', 'ln', 'sqrt'].includes(name)) {
      return new Token(TokenType.FUNCTION, name);
    } else if (['π', 'e'].includes(name)) {
      // 将常量名替换为其数值
      let value = (name === 'π') ? Math.PI.toString() : Math.E.toString();
      return new Token(TokenType.NUMBER, value);
    }
    // 如果不是已知函数或常量，按错误处理或抛出异常
    return new Token(TokenType.NUMBER, '0'); // 简单错误处理
  }

  private isDigit(char: string): boolean {
    return /\d/.test(char);
  }

  private isOperator(char: string): boolean {
    return /[+\-*÷^√]/.test(char);
  }

  private isLetter(char: string): boolean {
    return /[a-zA-Zπ]/.test(char);
  }
}