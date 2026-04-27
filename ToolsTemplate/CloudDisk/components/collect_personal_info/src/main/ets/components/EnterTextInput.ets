import { AppStorageV2 } from '@kit.ArkUI';
import { Constants } from '../common/Constant';
import { ConfirmButtonModifier, InnerTitleModifier, SheetColumnModifier } from '../common/CustomModifier';
import { encryptPhone } from '../common/Util';
import { WindowModel } from '../common/WindowModel';

/**
 * @usage: 用于单行文本输入场景。提供单行文本输入框，支持字符数限制和验证，适用于姓名、昵称等短文本输入。
 * 关键数据结构：inputType（输入类型枚举，如Normal、PhoneNumber）、title（标题字符串）、
 * value（初始值字符串）、placeholder（占位符字符串）、valueFg（字体大小）、minLength（最小字符数）、
 * maxLength（最大字符数）、onChange（输入完成回调函数，参数为输入的文本）、
 * WindowModel（窗口模型，用于监听键盘弹出）。包含if逻辑：根据inputType判断是否加密显示手机号，
 * 根据isKeyboardPopUp判断是否显示标题和清除按钮，根据isInValidLength判断是否显示错误提示。
 * @layout: 垂直布局。顶部为标题（键盘弹出时隐藏），中间为TextInput单行输入框（白色背景，
 * 键盘弹出时显示清除按钮，字符数不足时显示红色边框），下方为错误提示文字（字符数不足时显示），
 * 底部为"确定"按钮（字符数不足时禁用）。
 * @constraints: minLength最小字符数必须大于等于0，maxLength最大字符数必须大于minLength，
 * onChange回调函数必须正确处理输入的文本，inputType为PhoneNumber时会自动加密显示
 * @isGen: true
 * @fileType: component
 * @zhName: 单行文本输入组件
 */
@ComponentV2
export struct EnterTextInput {
  @Param inputType: InputType = InputType.Normal;
  @Param title: ResourceStr = '';
  @Param value: string = '';
  @Param placeholder: ResourceStr = '';
  @Param valueFg: Length = 16;
  @Param minLength: number = 0
  @Param maxLength: number = 10
  @Event onChange: (value: string) => void;
  @Event onKeyboardPopUp: (value: boolean) => void = () => {
  };
  @Local isKeyboardPopUp: boolean = true;
  @Local tempValue: string = '';
  @Local sheetColumnModifier: SheetColumnModifier = new SheetColumnModifier();
  @Local innerTitleModifier: InnerTitleModifier = new InnerTitleModifier();
  @Local confirmButtonModifier: ConfirmButtonModifier = new ConfirmButtonModifier();
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;

  aboutToAppear(): void {
    this.tempValue = this.value;
    if (this.inputType === InputType.PhoneNumber) {
      this.tempValue = encryptPhone(this.tempValue);
    }
    this.windowModel.registerKeyboardListener(this.onKeyBoardCB);
  }

  aboutToDisappear(): void {
    this.windowModel.unRegisterKeyboardListener(this.onKeyBoardCB);
  }

  onKeyBoardCB: (height: number) => void = (height: number) => {
    this.isKeyboardPopUp = height > 0;
    this.sheetColumnModifier.needAvoidBottom = !this.isKeyboardPopUp;
    this.onKeyboardPopUp(this.isKeyboardPopUp);
  };

  @Computed
  get isInValidLength() {
    return this.tempValue.length < this.minLength;
  }

  build() {
    Scroll() {
      Column() {
        Text(this.title)
          .visibility(this.title && !this.isKeyboardPopUp ? Visibility.Visible : Visibility.None)
          .attributeModifier(this.innerTitleModifier)

        Row() {
          TextInput({ text: $$this.tempValue, placeholder: this.placeholder })
            .type(this.inputType)
            .fontSize(this.valueFg)
            .fontColor($r('sys.color.font_primary'))
            .backgroundColor($r('sys.color.background_primary'))
            .cancelButton({
              style: this.isKeyboardPopUp ? CancelButtonStyle.INPUT : CancelButtonStyle.INVISIBLE,
              icon: { size: 24 },
            })
            .maxLength(this.maxLength)
            .constraintSize({ minHeight: 48 })
            .defaultFocus(true)
            .borderWidth(1)
            .borderColor(this.isInValidLength ? $r('sys.color.warning') : Color.Transparent)
        }
        .width(Constants.FULL_PERCENT)
        .padding({
          top: Constants.SPACE_S,
          bottom: Constants.SPACE_S,
        })

        Text(`${this.placeholder}需要至少 ${this.minLength} 个字符`)
          .fontSize(10)
          .fontColor($r('sys.color.warning'))
          .alignSelf(ItemAlign.Start)
          .padding({
            left: Constants.SPACE_S,
            right: Constants.SPACE_S,
          })
          .visibility(this.isInValidLength ? Visibility.Visible : Visibility.None)

        Blank()

        Button('确定')
          .attributeModifier(this.confirmButtonModifier)
          .enabled(!this.isInValidLength)
          .onClick(() => {
            this.onChange(this.tempValue);
          })
      }
      .attributeModifier(this.sheetColumnModifier)
    }
    .layoutWeight(1)
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Off)
  }
}
