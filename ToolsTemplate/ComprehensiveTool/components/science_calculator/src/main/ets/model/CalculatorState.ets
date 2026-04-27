import { Decimal } from '@kit.ArkTS';

export class CalculatorState {
  private isDegreeMode: boolean = true; // 默认角度模式
  private randomSeed: number = Date.now(); // 随机数种子
  private lastResult: number | null = null; // 存储上次计算结果
  private isContinuousCalculation: boolean = false; // 是否处于连续计算模式

  // 切换角度/弧度模式
  toggleAngleMode(): void {
    this.isDegreeMode = !this.isDegreeMode;
  }

  // 获取当前模式
  getAngleMode(): boolean {
    return this.isDegreeMode;
  }

  // 获取模式显示文本
  getAngleModeText(): string {
    return this.isDegreeMode ? 'Deg' : 'Rad';
  }

  // 角度转弧度（如果当前是角度模式）
  toRadiansIfNeeded(angle: number): Decimal {
    new Decimal(angle).sin()
    return this.isDegreeMode ? new Decimal(angle).mul(Math.PI).div(180) : new Decimal(angle);
  }

  // 弧度转角度（如果当前是角度模式）
  toDegreesIfNeeded(radians: number): Decimal {
    return this.isDegreeMode ? new Decimal(radians).mul(180).div(Math.PI) : new Decimal(radians);
  }

  // 生成随机数
  generateRandom(): number {
    // 使用线性同余生成器 (LCG) 算法
    this.randomSeed = (this.randomSeed * 1664525 + 1013904223) % 4294967296;
    return this.randomSeed / 4294967296; // 返回 0-1 之间的随机数
  }

  // 生成指定范围的随机整数
  generateRandomInt(min: number, max: number): number {
    return Math.floor(this.generateRandom() * (max - min + 1)) + min;
  }

  // 生成指定范围的随机小数
  generateRandomFloat(min: number, max: number, decimals: number = 2): number {
    const value = this.generateRandom() * (max - min) + min;
    return parseFloat(value.toFixed(decimals));
  }

  // 重置随机数种子
  resetRandomSeed(): void {
    this.randomSeed = Date.now();
  }

  // 连续计算相关方法
  setLastResult(result: number): void {
    this.lastResult = result;
    this.isContinuousCalculation = true;
  }

  getLastResult(): number | null {
    return this.lastResult;
  }

  clearLastResult(): void {
    this.lastResult = null;
    this.isContinuousCalculation = false;
  }

  isInContinuousMode(): boolean {
    return this.isContinuousCalculation && this.lastResult !== null;
  }

  // 重置连续计算状态（当用户开始新输入时）
  resetContinuousMode(): void {
    this.isContinuousCalculation = false;
  }
}