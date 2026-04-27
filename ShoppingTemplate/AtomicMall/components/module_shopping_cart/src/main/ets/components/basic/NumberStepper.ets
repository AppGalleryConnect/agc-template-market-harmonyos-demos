import { calcAdd, calcSub } from '../../commons/utils';

type StepperBtnType = 'increase' | 'decrease';

@ComponentV2
export struct NumberStepper {
  // 绑定值
  @Param @Require value: number;
  // 最小值
  @Param min: number = 1;
  // 最大值
  @Param max: number = Infinity;
  // 步长，每次点击时改变的值
  @Param step: number = 1;
  // 是否禁用步进器
  @Param disabled: boolean = false;
  // 输入框的宽度
  @Param inputWidth: Length = 30;
  // 按钮的尺寸
  @Param buttonSize: Length = 20;
  // 按钮形状
  @Param buttonType: ButtonType = ButtonType.Normal;
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
      nextValue = String(calcAdd(Number(this.inputNum), this.step));
    } else {
      nextValue = String(calcSub(Number(this.inputNum), this.step));
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

      TextInput({ text: $$this.inputNum })
        .fontSize(12)
        .fontColor($r('app.color.font_color_level1'))
        .type(InputType.Number)
        .width(this.inputWidth)
        .height(this.buttonSize)
        .padding(0)
        .borderRadius(0)
        .textAlign(TextAlign.Center)
        .backgroundColor(Color.Transparent)
        .onChange((val) => {
          if (val) {
            this.inputNum = parseFloat(val) < this.max ? val : this.max.toString();
            this.handleValueChange();
          }
        })
        .onBlur(() => {
          this.inputNum = parseFloat(this.inputNum) < this.min ? this.min.toString() : this.inputNum;
          this.handleValueChange();
        })

      this.StepperBtn('increase');
    }
    .border({
      width: 1,
      color: $r('sys.color.comp_divider'),
      style: BorderStyle.Solid,
      radius: this.buttonSize,
    })
  }

  @Builder
  StepperBtn(type: StepperBtnType) {
    Button() {
      Image(type === 'decrease' ? $r('app.media.ic_minus') : $r('app.media.ic_plus'))
        .scale({ x: 0.6, y: 0.6 })
        .fillColor(this.getBtnDisabled(type) ? $r('app.color.font_color_level3') : $r('app.color.font_color_level1'))
    }
    .type(this.buttonType)
    .width(this.buttonSize)
    .height(this.buttonSize)
    .backgroundColor(this.disabled ? $r('app.color.background_color_button_grey') : $r('app.color.stepper_btn_bg_color'))
    .opacity(this.getBtnDisabled(type) ? 0.6 : 1)
    .onClick(() => {
      this.handleClickStepperBtn(type);
    })
  }
}