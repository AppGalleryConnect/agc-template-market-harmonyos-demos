export class BtnTitle {
  // 展示类型：1：默认 2：label2左下右上 3:label2左上右下 4：label1左上右下
  type: number
  label1: string
  label2: string

  constructor(type: number, label1: string, label2: string = '') {
    this.type = type;
    this.label1 = label1;
    this.label2 = label2;
  }
}

// 定义按钮的类型和布局
export class CalcButton {
  title: BtnTitle; // 按钮的文本，如 "1", "sin"
  label: string; // 显示的文本，如 "1", "sin("
  value: string; // 实际输入的值，可能与label相同，也可能不同（如 sin( -> pi）
  type: CalcButtonType; // 按钮类型：数字、运算符、函数、功能键
  memoryAction: string; // 新增：内存操作类型
  fontColor: Resource; // 按钮背景色
  bgColor: Resource; // 按钮文字颜色

  constructor(title: BtnTitle, label: string, value: string, type: CalcButtonType, memoryAction: string = '',
    bgColor: Resource = $r('sys.color.background_tertiary'), fontColor: Resource = $r('sys.color.font_primary')) {
    this.title = title;
    this.label = label;
    this.value = value;
    this.type = type;
    this.memoryAction = memoryAction;
    this.fontColor = fontColor;
    this.bgColor = bgColor;
  }
}

export enum CalcButtonType {
  NUMBER,
  OPERATOR,
  FUNCTION,
  CONSTANT,
  CONTROL, // AC, DEL, =
  MEMORY
}