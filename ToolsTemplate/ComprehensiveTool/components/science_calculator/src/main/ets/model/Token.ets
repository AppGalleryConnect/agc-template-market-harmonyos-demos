export enum TokenType {
  NUMBER,
  OPERATOR,
  FUNCTION, // sin, cos, log
  CONSTANT, // π, e
  LEFT_PAREN,
  RIGHT_PAREN,
  POSTFIX_OPERATOR, // ! 后缀运算符
  EXPONENT, // ^ 新增指数运算符
  PERCENTAGE // 新增：百分比符号
}

export class Token {
  type: TokenType;
  value: string;
  precedence?: number; // 优先级，用于运算符
  isUnary?: boolean; // 新增标志，表示是否是一元运算符

  constructor(type: TokenType, value: string, precedence?: number, isUnary: boolean = false) {
    this.type = type;
    this.value = value;
    this.precedence = precedence;
    this.isUnary = isUnary;
  }
}