import { CALC_FUN_BUTTONS, CALC_NORMAL_BUTTONS } from '../common/KeyBoardConstant';
import { AdvancedCalculatorModel } from '../model/AdvancedCalculatorModel';
import { CalcButton, CalcButtonType } from '../model/CalculatorButton';
import { BreakpointModel, BreakpointStorage, BreakpointSystem, BreakpointTypeEnum } from '../utils/BreakpointSystem';
import { HistoryUtils } from '../utils/HistoryUtils';

@ComponentV2
export struct ScienceCalcKeyboard {
  // 状态变量：当前显示的表达式
  @Param expression: string = '';
  // 状态变量：当前计算结果或历史记录
  @Param result: string = '0';
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Local calcNormalButtons: CalcButton[] = CALC_NORMAL_BUTTONS
  @Local calcFunButtons: CalcButton[] = CALC_FUN_BUTTONS
  @Local eeModeIndicator: boolean = false;
  layoutOptions: GridLayoutOptions = {
    regularSize: [1, 1],
    onGetRectByIndex: (index: number) => {
      if (index === 16) { // key是“=”按键对应的index
        return [5, 0, 1, 2];
      }
      return [0, 0, 0, 0];
    },
  };
  // 持有计算逻辑的实例
  private calcModel: AdvancedCalculatorModel = new AdvancedCalculatorModel();
  @Local angleModeText: string = this.calcModel.getAngleModeText()

  @Computed
  get gridColumnGap(): number {
    return new BreakpointModel<number>({
      [BreakpointTypeEnum.SM]: 10,
      [BreakpointTypeEnum.MD]: 10,
      [BreakpointTypeEnum.LG]: 16,
      [BreakpointTypeEnum.XL]: 16,
    }).getValue(this.curBreakpoint.wight)
  }

  @Event changeResult: (result: string, expression: string) => void = () => {
  };

  build() {
    Column({
      space: new BreakpointModel<number>({
        [BreakpointTypeEnum.LG_WIDE]: 8,
        [BreakpointTypeEnum.LG_NORMAL]: 14,
      }).getValue(this.curBreakpoint.height),
    }) {
      this.funcGridBuilder();
      this.normalGridBuilder();
    };
  }

  @Builder
  funcGridBuilder() {
    Grid(undefined) {
      ForEach(this.calcFunButtons, (item: CalcButton) => {
        GridItem() {
          if (item.title.type === 2) {
            Button({ controlSize: ControlSize.SMALL }) {
              Row() {
                Text(item.title.label1)
                  .fontSize($r('sys.float.Caption_L'))
                  .fontColor($r('sys.color.font_primary'))
                  .margin({ top: 3 })
                Text(item.title.label2).fontSize($r('sys.float.Caption_M')).fontColor($r('sys.color.font_primary'))
              }.alignItems(VerticalAlign.Top)
            }
            .width('100%')
            .height(28)
            .backgroundColor($r('sys.color.background_tertiary'))
          } else if (item.title.type === 3) {
            Button({ controlSize: ControlSize.SMALL }) {
              Row() {
                Text(item.title.label1).fontSize($r('sys.float.Caption_L')).fontColor($r('sys.color.font_primary'))
                Text(item.title.label2)
                  .fontSize($r('sys.float.Caption_S'))
                  .fontColor($r('sys.color.font_primary'))
                  .margin({ top: 8 })
              }.alignItems(VerticalAlign.Top)
            }
            .width('100%')
            .height(28)
            .backgroundColor($r('sys.color.background_tertiary'))
          } else if (item.title.type === 4) {
            Button({ controlSize: ControlSize.SMALL }) {
              Row() {
                Text(item.title.label1)
                  .fontSize($r('sys.float.Caption_S'))
                  .fontColor($r('sys.color.font_primary'))
                  .textAlign(TextAlign.Center)
                  .width(6)
                  .height(10)
                  .offset({ x: 4, y: -1 })
                Text(item.title.label2)
                  .fontSize($r('sys.float.Body_M'))
                  .fontColor($r('sys.color.font_primary'))
                  .width(18)
                  .height(19)

              }.alignItems(VerticalAlign.Top)
            }
            .width('100%')
            .height(28)
            .backgroundColor($r('sys.color.background_tertiary'))
          } else {
            Button(item.title.label1 === 'Deg' ? this.angleModeText : item.title.label1,
              { controlSize: ControlSize.SMALL })
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Normal)
              .backgroundColor($r('sys.color.background_tertiary'))
              .width('100%')
          }
        }
        .onClick(() => {
          this.onButtonClick(item);
        })
      }, (item: CalcButton) => JSON.stringify(item));
    }
    .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr')
    .columnsGap(8)
    .rowsGap(new BreakpointModel<number>({
      [BreakpointTypeEnum.LG_WIDE]: 8,
      [BreakpointTypeEnum.LG_NORMAL]: 12,
    }).getValue(this.curBreakpoint.height))
    .height(new BreakpointModel<number>({
      [BreakpointTypeEnum.LG_WIDE]: 136,
      [BreakpointTypeEnum.LG_NORMAL]: 148,
    }).getValue(this.curBreakpoint.height));
  }

  @Builder
  normalGridBuilder() {
    Grid(undefined, this.layoutOptions) {
      ForEach(this.calcNormalButtons, (item: CalcButton) => {
        GridItem() {
          Column() {
            Button(item.title.label1)
              .fontSize($r('sys.float.Title_L'))
              .fontColor(item.fontColor)
              .fontWeight(FontWeight.Normal)
              .backgroundColor(item.bgColor)
              .width('100%')
          };
        }
        .onClick(() => {
          this.onButtonClick(item);
        });
      }, (item: CalcButton) => JSON.stringify(item));
    }
    .columnsTemplate('1fr 1fr 1fr 1fr')
    .rowsTemplate('1fr 1fr 1fr 1fr 1fr')
    .columnsGap(this.gridColumnGap)
    .rowsGap(new BreakpointModel<number>({
      [BreakpointTypeEnum.LG_WIDE]: 8,
      [BreakpointTypeEnum.LG_NORMAL]: 12,
    }).getValue(this.curBreakpoint.height))
    .height(250);
  }

  // 按钮点击事件处理
  onButtonClick(button: CalcButton) {
    let expression = this.expression
    let result = this.result
    switch (button.type) {
      case CalcButtonType.NUMBER:
        expression = this.handleNumberInput(button);
        break;
      case CalcButtonType.OPERATOR:
      case CalcButtonType.CONSTANT:
        this.calcModel.appendInput(button.label, button.value);
        expression = this.calcModel.getDisplayExpression();
        break;
      case CalcButtonType.FUNCTION:
        if (button.label === 'Rand') {
          // 直接生成 0-1 的随机小数
          this.calcModel.appendRandomNumber();
          expression = this.calcModel.getDisplayExpression();
        } else if (button.label === 'EE') {
          expression = this.handleEEButton();
        } else {
          this.calcModel.appendInput(button.label, button.value);
          expression = this.calcModel.getDisplayExpression();
        }
        break;
      case CalcButtonType.MEMORY:
        expression = this.handleMemoryAction(button.memoryAction);
        break;
      case CalcButtonType.CONTROL:
        if (button.value === 'AC') {
          this.calcModel.clear();
          expression = '';
          result = '0';
        } else if (button.value === 'DEL') {
          this.calcModel.deleteLast();
          expression = this.calcModel.getDisplayExpression();
        } else if (['Deg', 'Rad'].includes(button.value)) {
          this.calcModel.toggleAngleMode();
          this.angleModeText = this.calcModel.getAngleModeText()
        } else if (button.value === '=') {
          result = this.calcModel.calculate();
          HistoryUtils.updateHistoryResult(`${expression}=${result}`);
        }
        break;
    }
    // 更新EE模式指示器
    this.eeModeIndicator = this.calcModel.isInEEMode();
    this.changeResult(result, expression)
  }

  // 处理EE按钮点击
  private handleEEButton(): string {
    const currentDisplay = this.calcModel.getDisplayExpression();

    if (this.endsWithNumber(currentDisplay)) {
      // 如果以数字结尾，直接添加E
      this.calcModel.appendInput('E', 'E', true);
    } else if (currentDisplay === '' || currentDisplay === 'Error') {
      // 如果为空或错误，插入1E
      this.calcModel.appendInput('1E', '1E');
    } else {
      // 其他情况也添加E
      this.calcModel.appendInput('E', 'E', true);
    }

    this.eeModeIndicator = this.calcModel.isInEEMode();
    return this.calcModel.getDisplayExpression();
  }

  // 处理数字输入（EE模式特殊处理）
  private handleNumberInput(button: CalcButton): string {
    const isEEMode = this.calcModel.isInEEMode();

    if (isEEMode) {
      // EE模式下特殊处理
      this.calcModel.appendInput(button.label, button.value, true);
    } else {
      // 正常数字输入
      this.calcModel.appendInput(button.label, button.value);
    }

    this.eeModeIndicator = this.calcModel.isInEEMode();
    return this.calcModel.getDisplayExpression();
  }

  // 检查是否以数字结尾
  private endsWithNumber(expr: string): boolean {
    if (!expr) {
      return false;
    }
    const lastChar = expr.slice(-1);
    return /[0-9]/.test(lastChar);
  }

  // 处理内存操作
  private handleMemoryAction(action: string | undefined): string {
    let displayExpression = ''
    if (!action) {
      return displayExpression;
    }
    // 获取当前值（需要同时考虑显示和计算表达式）
    const currentValue = this.getCurrentValue();
    switch (action) {
      case 'clear':
        this.calcModel.memoryClear();
        this.showMemoryStatus('存储已清除');
        break;

      case 'plus':
        this.calcModel.memoryPlus(currentValue);
        this.showMemoryStatus('存储已添加');
        break;

      case 'minus':
        this.calcModel.memoryMinus(currentValue);
        this.showMemoryStatus('存储已减少');
        break;

      case 'recall':
        this.handleMemoryRecall();
        break;

      case 'store':
        this.calcModel.memoryStore(currentValue);
        this.showMemoryStatus('记录已存储');
        break;
    }
    return this.calcModel.getDisplayExpression()
  }

  // 处理内存读取（特殊处理，因为要同时更新两个表达式）
  private handleMemoryRecall(): void {
    const memoryValue = this.calcModel.memoryRecall();

    // 同时更新显示表达式和计算表达式
    this.calcModel.appendInput(memoryValue, memoryValue);
    this.showMemoryStatus('存储已获取');
  }

  // 当前值获取方法
  private getCurrentValue(): number {
    // 优先使用计算结果
    if (this.result !== '0' && this.result !== 'Error') {
      const resultValue = parseFloat(this.result);
      if (!isNaN(resultValue)) {
        return resultValue;
      }
    }

    // 其次尝试从显示表达式解析最后一个完整数值
    const displayExpr = this.calcModel.getDisplayExpression();
    if (displayExpr) {
      return this.parseDisplayValue(displayExpr);
    }

    return 0;
  }

  // 从显示表达式解析数值
  private parseDisplayValue(displayExpr: string): number {
    // 移除末尾可能的不完整运算符
    let cleanExpr = this.cleanExpression(displayExpr);

    if (!cleanExpr) {
      return 0;
    }

    // 提取最后一个数值
    const numbers = cleanExpr.split(/[+\-*/^()]/);
    if (numbers.length > 0) {
      const lastNumber = numbers[numbers.length - 1].trim();
      if (lastNumber) {
        const value = parseFloat(lastNumber);
        if (!isNaN(value)) {
          return value;
        }
      }
    }

    return 0;
  }

  // 清理表达式（移除末尾不完整运算符）
  private cleanExpression(expr: string): string {
    if (!expr) {
      return '';
    }

    let cleanExpr = expr;

    // 移除末尾的运算符、括号、小数点等
    const invalidEndChars = ['+', '-', '*', '/', '^', '(', ')', '.'];
    while (cleanExpr.length > 0 && invalidEndChars.includes(cleanExpr.slice(-1))) {
      cleanExpr = cleanExpr.slice(0, -1);
    }

    return cleanExpr;
  }

  private showMemoryStatus(message: string): void {
    this.getUIContext().getPromptAction().showToast({
      message: message,
      duration: 1000,
    });
  }
}