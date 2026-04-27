import { Token, TokenType } from './Token';
import { Lexer } from '../utils/Lexer';
import { Decimal } from '@kit.ArkTS';
import { CalculatorState } from './CalculatorState';
import { MemoryManager } from './MemoryManager';
import { functionNameMap } from '../common/Constant';

export class AdvancedCalculatorModel {
  // 用于显示的表达式（用户看到的）
  private displayExpression: string = '';
  // 用于计算的表达式（机器使用的）
  private calculationExpression: string = '';
  private state: CalculatorState = new CalculatorState();
  private memoryManager: MemoryManager = new MemoryManager();

  // 追加输入，同时更新两个表达式
  appendInput(displayValue: string, calculationValue: string, isEEMode: boolean = false): void {
    // 如果处于连续计算模式且用户输入的是运算符，保留上次结果
    if (this.state.isInContinuousMode() && this.isOperator(calculationValue)) {
      // 将上次结果作为新表达式的一部分
      const lastResult = this.state.getLastResult()!;
      this.displayExpression = lastResult.toString() + displayValue;
      this.calculationExpression = lastResult.toString() + calculationValue;
      this.state.resetContinuousMode();
    }
    // 如果处于连续计算模式且用户输入的是数字、函数或常量，开始新计算
    else if (this.state.isInContinuousMode() &&
      (this.isNumber(calculationValue) ||
      this.isFunction(calculationValue) ||
      this.isConstant(calculationValue))) {
      // 清空表达式，开始新计算
      this.clear();
      this.state.clearLastResult();

      if (isEEMode) {
        this.handleEEInput(displayValue, calculationValue);
      } else {
        this.displayExpression = displayValue;
        this.calculationExpression = calculationValue;
      }
    }
    // 正常追加输入
    else {
      if (isEEMode) {
        this.handleEEInput(displayValue, calculationValue);
      } else {
        this.displayExpression += displayValue;
        this.calculationExpression += calculationValue;
      }
      // 任何输入都会重置连续计算模式
      this.state.resetContinuousMode();
    }
  }

  // 检查是否在EE输入模式中
  isInEEMode(): boolean {
    return this.displayExpression.endsWith('E') || this.displayExpression.endsWith('e');
  }

  // 清空时也清除连续计算状态
  clear(): void {
    this.displayExpression = '';
    this.calculationExpression = '';
    this.state.clearLastResult();
  }

  deleteLast(): void {
    if (this.displayExpression.length > 0) { // 尝试删除整个函数
      if (this.tryDeleteFunction()) { // 如果删除后表达式为空，重置连续计算状态
        if (this.displayExpression.length === 0) {
          this.state.resetContinuousMode();
        }
        return;
      }
      this.displayExpression = this.displayExpression.substring(0, this.displayExpression.length - 1);
      this.calculationExpression = this.calculationExpression.substring(0, this.calculationExpression.length - 1);
      // 如果删除后表达式为空，重置连续计算状态
      if (this.displayExpression.length === 0) {
        this.state.resetContinuousMode();
      }
    }
  }

  tryDeleteFunction(): boolean {
    for (const pattern of functionNameMap) {
      if (this.displayExpression.endsWith(pattern.display) &&
      this.calculationExpression.endsWith(pattern.calculation)) {
        this.displayExpression =
          this.displayExpression.substring(0, this.displayExpression.length - pattern.display.length);
        this.calculationExpression =
          this.calculationExpression.substring(0, this.calculationExpression.length - pattern.calculation.length);
        return true;
      }
    }
    return false;
  }
  // 设置表达式对
  setExpressions(displayExpr: string, calculationExpr: string): void {
    this.displayExpression = displayExpr;
    this.calculationExpression = calculationExpr;
  }

  // 分别设置显示表达式和计算表达式
  setDisplayExpression(expr: string): void {
    this.displayExpression = expr;
  }

  setCalculationExpression(expr: string): void {
    this.calculationExpression = expr;
  }

  getDisplayExpression(): string {
    return this.displayExpression;
  }

  getCalculationExpression(): string {
    return this.calculationExpression;
  }

  calculate(): string {
    if (!this.calculationExpression) {
      return '0';
    }
    try {
      // 空表达式处理
      if (!this.calculationExpression || this.calculationExpression.trim() === '') {
        // 如果没有表达式但有上次结果，返回上次结果
        if (this.state.isInContinuousMode()) {
          return this.state.getLastResult()!.toString();
        }
        return '0';
      }

      // 使用计算表达式进行计算
      const result = this.shuntingYardCalculate(this.calculationExpression);
      // 处理特殊值
      if (!isFinite(result)) {
        throw new Error('Result is not finite');
      }

      // 存储上次结果
      this.state.setLastResult(result);
      return result.toString();
    } catch (error) {
      this.clear();
      this.state.clearLastResult();
      // 根据错误类型返回不同的提示
      if (error.message?.includes('non-negative integers')) {
        return 'Math Error';
      } else if (error.message?.includes('too large')) {
        return 'Too Large';
      } else {
        return 'Error';
      }
    }
  }

  // 内存功能方法
  memoryClear(): void {
    this.memoryManager.memoryClear();
  }

  memoryPlus(value: number): void {
    this.memoryManager.memoryPlus(value);
  }

  memoryMinus(value: number): void {
    this.memoryManager.memoryMinus(value);
  }

  memoryRecall(): string {
    if (!this.memoryManager.hasValue()) {
      return '0';
    }
    return this.memoryManager.memoryRecall().toString();
  }

  memoryStore(value: number): void {
    this.memoryManager.memoryStore(value);
  }

  // 检查内存中是否有值
  hasMemoryValue(): boolean {
    return this.memoryManager.hasValue();
  }

  // 角度模式相关方法
  toggleAngleMode(): void {
    this.state.toggleAngleMode();
  }

  getAngleMode(): boolean {
    return this.state.getAngleMode();
  }

  getAngleModeText(): string {
    return this.state.getAngleModeText();
  }

  // RAND 相关方法
  generateRandom(): number {
    return this.state.generateRandom();
  }

  generateRandomInt(min: number, max: number): number {
    return this.state.generateRandomInt(min, max);
  }

  generateRandomFloat(min: number, max: number, decimals: number = 2): number {
    return this.state.generateRandomFloat(min, max, decimals);
  }

  resetRandomSeed(): void {
    this.state.resetRandomSeed();
  }

  // 添加随机数到表达式
  appendRandomNumber(): void {
    const randomValue = this.generateRandom();
    const displayValue = randomValue.toFixed(6); // 显示6位小数
    const calculationValue = randomValue.toString();

    this.appendInput(displayValue, calculationValue);
  }

  appendRandomInt(min: number, max: number): void {
    const randomValue = this.generateRandomInt(min, max);
    const displayValue = randomValue.toString();

    this.appendInput(displayValue, displayValue);
  }

  appendRandomFloat(min: number, max: number, decimals: number = 2): void {
    const randomValue = this.generateRandomFloat(min, max, decimals);
    const displayValue = randomValue.toString();

    this.appendInput(displayValue, displayValue);
  }

  // 检查是否是运算符
  private isOperator(value: string): boolean {
    return ['+', '-', '*', '/', '^'].includes(value);
  }

  // 检查是否是数字
  private isNumber(value: string): boolean {
    return /^\d+$/.test(value);
  }

  // 检查是否是函数
  private isFunction(value: string): boolean {
    return ['sin(', 'cos(', 'tan(', 'log(', 'ln(', 'sqrt(', 'sinh(', 'cosh(', 'tanh('].includes(value);
  }

  // 检查是否是常量
  private isConstant(value: string): boolean {
    return ['π', 'e'].includes(value);
  }

  // 处理EE模式输入
  private handleEEInput(displayValue: string, calculationValue: string): void {
    const lastChar = this.displayExpression.slice(-1);

    // 如果当前以E结尾，需要添加符号
    if (lastChar === 'E' || lastChar === 'e') {
      if (displayValue !== '+' && displayValue !== '-') {
        // 自动添加+号
        this.displayExpression += '+';
        this.calculationExpression += '+';
      }
    }

    this.displayExpression += displayValue;
    this.calculationExpression += calculationValue;
  }

  // 调度场算法实现
  private shuntingYardCalculate(expression: string): number {
    if (!expression) {
      return 0;
    }

    const lexer = new Lexer(this.calculationExpression);
    const tokens = lexer.getTokens();

    // 统计括号数量并自动补全
    let parenCount = 0;
    for (const token of tokens) {
      if (token.type === TokenType.LEFT_PAREN) {
        parenCount++;
      } else if (token.type === TokenType.RIGHT_PAREN) {
        parenCount--;
      }
    }

    // 补全缺失的右括号
    for (let i = 0; i < parenCount; i++) {
      tokens.push(new Token(TokenType.RIGHT_PAREN, ')'));
    }

    // 重置用于显示
    parenCount = 0;
    // 1. 使用调度场算法将中缀Tokens转换为后缀Tokens（RPN）
    const outputQueue: Token[] = [];
    const operatorStack: Token[] = [];

    for (const token of tokens) {
      switch (token.type) {
        case TokenType.NUMBER:
          outputQueue.push(token);
          break;
        case TokenType.FUNCTION:
          operatorStack.push(token);
          break;
        case TokenType.OPERATOR:
          // 处理运算符优先级
          // 特殊处理指数运算符的右结合性
          if (token.value === '^') {
            // 指数运算符的特殊处理
            while (operatorStack.length > 0) {
              const topOp = operatorStack[operatorStack.length - 1];
              if (topOp.type === TokenType.LEFT_PAREN) {
                break;
              }

              // 对于指数，只有优先级更高的才弹出（保持右结合性）
              // 特别注意：一元运算符的优先级比指数高，应该先计算
              if ((topOp.precedence ?? 0) > (token.precedence ?? 0)) {
                outputQueue.push(operatorStack.pop()!);
              } else {
                break;
              }
            }
          } else {
            // 其他运算符的正常处理
            while (
              operatorStack.length > 0 &&
                operatorStack[operatorStack.length - 1].type !== TokenType.LEFT_PAREN &&
                (operatorStack[operatorStack.length - 1].precedence ?? 0) >= (token.precedence ?? 0)
            ) {
              outputQueue.push(operatorStack.pop()!);
            }
          }
          operatorStack.push(token);
          break;
        case TokenType.PERCENTAGE:
          // 百分比作为后缀运算符，直接加入输出队列
          outputQueue.push(token);
          break;
        case TokenType.POSTFIX_OPERATOR: // 处理阶乘
          // 后缀运算符直接加入输出队列，不需要压栈
          outputQueue.push(token);
          break;
        case TokenType.LEFT_PAREN:
          operatorStack.push(token);
          break;
        case TokenType.RIGHT_PAREN:
          // 弹出直到左括号
          while (operatorStack.length > 0 && operatorStack[operatorStack.length - 1].type !== TokenType.LEFT_PAREN) {
            outputQueue.push(operatorStack.pop()!);
          }
          if (operatorStack.length > 0 && operatorStack[operatorStack.length - 1].type === TokenType.LEFT_PAREN) {
            operatorStack.pop(); // 弹出左括号并丢弃
          }
          // 如果栈顶是函数，也弹出加入队列
          if (operatorStack.length > 0 && operatorStack[operatorStack.length - 1].type === TokenType.FUNCTION) {
            outputQueue.push(operatorStack.pop()!);
          }
          break;
      }
    }

    // 将栈中剩余运算符全部弹出
    while (operatorStack.length > 0) {
      outputQueue.push(operatorStack.pop()!);
    }

    // 2. 计算后缀表达式
    const calculationStack: number[] = [];

    for (const token of outputQueue) {
      if (token.type === TokenType.NUMBER) {
        calculationStack.push(parseFloat(token.value));
      } else {
        // 根据运算符或函数从栈中取出操作数进行计算
        const result = this.applyOperatorOrFunction(token, calculationStack);
        calculationStack.push(result);
      }
    }

    if (calculationStack.length !== 1) {
      throw new Error('Invalid expression');
    }

    return calculationStack[0];
  }

  private applyOperatorOrFunction(token: Token, stack: number[]): number {
    if (token.type === TokenType.PERCENTAGE) {
      // 处理百分比运算
      return this.handlePercentage(stack);
    }
    if (token.type === TokenType.NUMBER) {
      // 处理科学计数法数字
      return this.parseNumber(token.value);
    }
    if (token.type === TokenType.FUNCTION) {
      // 函数通常只有一个参数
      const a = stack.pop();
      if (a === undefined) {
        throw new Error('Not enough operands');
      }
      switch (token.value) {
        case 'sin':
          return this.sin(a);
        case 'cos':
          return this.cos(a);
        case 'tan':
          return this.tan(a);
        case 'sinh':
          return this.sinh(a);
        case 'cosh':
          return this.cosh(a);
        case 'tanh':
          return this.tanh(a);
        case 'log':
          return new Decimal(a).log(10).toNumber();
        case 'ln':
          return new Decimal(a).ln().toNumber();
        case 'neg':
          return -a; // 一元负号
        default:
          throw new Error(`Unknown function: ${token.value}`);
      }
    } else if (token.type === TokenType.POSTFIX_OPERATOR) {
      // 处理阶乘：只有一个操作数
      const a = stack.pop();
      if (a === undefined) {
        throw new Error('Not enough operands');
      }
      return this.factorial(a);
    } else {
      // 运算符需要两个参数
      const b = stack.pop();
      const a = stack.pop();
      if (a === undefined || b === undefined) {
        throw new Error('Not enough operands');
      }
      switch (token.value) {
        case '+':
          return a + b;
        case '-':
          return a - b;
        case '*':
          return new Decimal(a).mul(b).toNumber();
        case '÷':
          if (b === 0) {
            throw new Error('Division by zero');
          }
          return Number(new Decimal(a).div(b).toFixed(16, 4));
        case '^':
          return Math.pow(a, b);
        case '√':
          return Math.pow(b, 1 / a);
        default:
          throw new Error(`Unknown operator: ${token.value}`);
      }
    }
  }

  // 处理百分比计算
  private handlePercentage(stack: number[]): number {
    const value = stack.pop();
    if (value === undefined) {
      throw new Error('Not enough operands for percentage');
    }

    // 百分比的基本含义：除以100
    return value / 100;
  }

  // 解析数字（支持科学计数法）
  private parseNumber(numberStr: string): number {
    // 处理科学计数法
    if (numberStr.includes('E') || numberStr.includes('e')) {
      return this.parseScientificNotation(numberStr);
    }

    // 普通数字
    const value = parseFloat(numberStr);
    if (isNaN(value)) {
      throw new Error(`Invalid number: ${numberStr}`);
    }
    return value;
  }

  // 解析科学计数法
  private parseScientificNotation(sciNotation: string): number {
    // 分离底数和指数
    const parts = sciNotation.split(/[eE]/);
    if (parts.length !== 2) {
      throw new Error(`Invalid scientific notation: ${sciNotation}`);
    }

    const base = parseFloat(parts[0]);
    let exponent = parseFloat(parts[1]);

    if (isNaN(base) || isNaN(exponent)) {
      throw new Error(`Invalid scientific notation: ${sciNotation}`);
    }

    return base * Math.pow(10, exponent);
  }

  // 自定义三角函数方法
  private sin(x: number): number {
    return new Decimal(this.state.toRadiansIfNeeded(x)).sin().toNumber();
  }

  private cos(x: number): number {
    return new Decimal(this.state.toRadiansIfNeeded(x)).cos().toNumber();
  }

  private tan(x: number): number {
    const radians = this.state.toRadiansIfNeeded(x);

    // 检查是否接近无穷大的点
    if (this.state.getAngleMode()) {
      // 角度模式：90°, 270°, 等
      if (new Decimal(x).mod(180)
        .add(180)
        .mod(180)
        .sub(90)
        .abs()
        .toNumber() < 1e-10) {
        throw new Error(`Tangent of ${x}° is undefined`);
      }
    } else {
      // 弧度模式：π/2, 3π/2, 等
      if (new Decimal(radians).mod(Math.PI)
        .add(Math.PI)
        .mod(Math.PI)
        .sub(new Decimal(Math.PI).div(2))
        .abs()
        .toNumber() < 1e-10) {
        throw new Error(`Tangent of ${x} is undefined`);
      }
    }

    return new Decimal(radians).tan().toNumber();
  }

  private sinh(x: number): number {
    return new Decimal(x).sinh().toNumber();
  }

  private cosh(x: number): number {
    return new Decimal(x).cosh().toNumber();
  }

  private tanh(x: number): number {
    return new Decimal(x).tanh().toNumber();
  }

  // 阶乘计算函数
  private factorial(n: number): number {
    // 检查是否为非负整数
    if (n < 0 || !Number.isInteger(n)) {
      throw new Error('Factorial is only defined for non-negative integers');
    }

    // 0! = 1, 1! = 1
    if (n === 0 || n === 1) {
      return 1;
    }

    // 计算阶乘
    let result = 1;
    for (let i = 2; i <= n; i++) {
      result *= i;
      // 防止数值过大（可选）
      if (!isFinite(result)) {
        throw new Error('Factorial result too large');
      }
    }
    return result;
  }
}