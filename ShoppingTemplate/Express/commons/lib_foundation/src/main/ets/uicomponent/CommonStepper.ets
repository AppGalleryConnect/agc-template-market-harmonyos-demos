import { CommonUtil } from '../utils/CommonUtil';

type StepperBtnType = 'increase' | 'decrease';

@ComponentV2
export struct CommonStepper {
  // 绑定值
  @Param @Require value: number;
  // 单位
  @Param unit: string = 'kg';
  // 最小值
  @Param min: number = 1;
  // 最大值
  @Param max: number = 9999;
  // 步长，每次点击时改变的值
  @Param step: number = 1;
  // 是否禁用步进器
  @Param disabled: boolean = false;
  // 输入框的宽度
  @Param inputWidth: Length = 32;
  // 按钮的尺寸
  @Param buttonSize: Length = 26;
  // 按钮形状
  @Param buttonType: ButtonType = ButtonType.Normal;
  // 是否有边框
  @Param isBorder: boolean = true;
  // 改变数字
  @Event onChange: (value: number) => void = () => {};
  // 输入框的值
  @Local inputNum: string = '';
  // 增加按钮是否禁用
  @Local increaseBtnDisabled: boolean = false;
  // 减少按钮是否禁用
  @Local decreaseBtnDisabled: boolean = false;

  aboutToAppear(): void {
    this.inputNum = this.value.toString();
  }

  @Monitor('value')
  onValueChange(monitor: IMonitor) {
    if (monitor.value()?.now) {
      let num: number = monitor.value()?.now as number;
      this.inputNum = num.toString();
    }
  }

  // 按钮的状态，是否禁用
  handleStepperBtnStatus() {
    const val = parseFloat(this.inputNum);
    this.decreaseBtnDisabled = val <= this.min;
    this.increaseBtnDisabled = val >= this.max;
  }

  // 按钮是否能点击
  getBtnDisabled(type: StepperBtnType): boolean {
    return this.disabled || (type === 'decrease' ? this.decreaseBtnDisabled : this.increaseBtnDisabled);
  }

  // 处理增加、减少
  handleClickStepperBtn(type: StepperBtnType) {
    if (this.disabled) {
      return;
    }
    let nextValue = '0';
    // 增加
    if (type === 'increase') {
      nextValue = String(CommonUtil.calcAdd(Number(this.inputNum), this.step));
    } else {
      nextValue = String(CommonUtil.calcSub(Number(this.inputNum), this.step));
    }
    if (parseFloat(nextValue) <= 0) {
      this.onChange(0);
      return;
    }
    if (parseFloat(nextValue) > this.max) {
      this.onChange(this.max + 1);
      return;
    }
    this.inputNum = nextValue;
  }

  // 处理数据变化
  handleValueChange() {
    if (parseFloat(this.inputNum) > 0) {
      this.onChange(parseFloat(this.inputNum));
    }
    this.handleStepperBtnStatus();
  }

  build() {
    Row() {
      this.StepperBtn('decrease');

      Row() {
        TextInput({ text: $$this.inputNum })
          .fontSize(14)
          .type(InputType.Number)
          .width(this.inputWidth)
          .height(this.buttonSize)
          .padding(0)
          .borderRadius(0)
          .textAlign(TextAlign.Center)
          .backgroundColor(Color.Transparent)
          .onChange((val) => {
            const temp = val || this.min.toString();
            if (temp) {
              this.inputNum = parseFloat(temp) < this.max ? temp : this.max.toString();
              this.handleValueChange();
            }
          })
          .onBlur(() => {
            this.inputNum = parseFloat(this.inputNum) < this.min ? this.min.toString() : this.inputNum;
            this.handleValueChange();
          })

        Text(this.unit)
          .fontSize(14).fontColor($r('sys.color.font_secondary'))
          .margin({ right: 8 })
      }

      this.StepperBtn('increase');
    }
    .border(this.isBorder ? {
      width: 1,
      color: '#E6E6E6',
      style: BorderStyle.Solid,
      radius: this.buttonSize,
    } : null)
  }

  @Builder
  StepperBtn(type: StepperBtnType) {
    Button() {
      SymbolGlyph(type === 'decrease' ? $r('sys.symbol.minus') : $r('sys.symbol.plus'))
        .fontSize(16)
        .fontColor([this.getBtnDisabled(type) ? '#838485' : '#191919'])
    }
    .type(this.buttonType)
    .width(this.buttonSize)
    .height(this.buttonSize)
    .backgroundColor(this.disabled ? '#f7f8fa' : '#0d000000')
    .opacity(this.getBtnDisabled(type) ? 0.6 : 1)
    .onClick(() => {
      this.handleClickStepperBtn(type);
    })
  }
}