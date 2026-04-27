import { AppStorageV2 } from '@kit.ArkUI';
import { Constants } from '../common/Constant';
import { ConfirmButtonModifier, InnerTitleModifier, SheetColumnModifier } from '../common/CustomModifier';
import { WindowModel } from '../common/WindowModel';

/**
 * @usage: 用于多行文本输入场景。提供多行文本输入框，支持字数统计和限制，适用于简介、备注等长文本输入。
 * 关键数据结构：title（标题字符串）、value（初始值字符串）、placeholder（占位符字符串）、
 * valueFg（字体大小）、maxLength（最大字符数）、customMinHeight（最小高度）、customMaxHeight（最大高度）、
 * onChange（输入完成回调函数，参数为输入的文本）、WindowModel（窗口模型，用于监听键盘弹出）。
 * 包含if逻辑：根据isKeyboardPopUp判断是否显示标题。
 * @layout: 垂直布局。顶部为标题（键盘弹出时隐藏），中间为TextArea多行输入框（灰色背景，显示字数统计），
 * 底部为"确定"按钮。
 * @constraints: maxLength最大字符数必须大于0，customMinHeight和customMaxHeight必须合理设置，
 * onChange回调函数必须正确处理输入的文本
 * @isGen: true
 * @fileType: component
 * @zhName: 多行文本输入组件
 */
@ComponentV2
export struct EnterTextArea {
  @Param title: ResourceStr = '';
  @Param value: ResourceStr = '';
  @Param placeholder: ResourceStr = '';
  @Param valueFg: Length = 16;
  @Param maxLength: number = 70
  @Param customMinHeight: number = 150;
  @Param customMaxHeight: number = 300;
  @Event onChange: (value: ResourceStr) => void;
  @Event onKeyboardPopUp: (value: boolean) => void = () => {
  };
  @Local isKeyboardPopUp: boolean = true;
  @Local tempValue: ResourceStr = '';
  @Local sheetColumnModifier: SheetColumnModifier = new SheetColumnModifier();
  @Local innerTitleModifier: InnerTitleModifier = new InnerTitleModifier();
  @Local confirmButtonModifier: ConfirmButtonModifier = new ConfirmButtonModifier();
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;

  aboutToAppear(): void {
    this.tempValue = this.value;
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

  build() {
    Scroll() {
      Column() {
        Text(this.title)
          .visibility(this.title && !this.isKeyboardPopUp ? Visibility.Visible : Visibility.None)
          .attributeModifier(this.innerTitleModifier)

        Row() {
          TextArea({ text: $$this.tempValue, placeholder: this.placeholder })
            .fontSize(this.valueFg)
            .fontColor($r('sys.color.font_primary'))
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .placeholderColor($r('sys.color.font_tertiary'))
            .placeholderFont({ size: this.valueFg })
            .maxLength(this.maxLength)
            .showCounter(true)
            .defaultFocus(true)
            .constraintSize({
              minHeight: this.customMinHeight,
              maxHeight: this.customMaxHeight,
            })
        }
        .width(Constants.FULL_PERCENT)
        .padding({
          top: Constants.SPACE_S,
          bottom: Constants.SPACE_S,
        })

        Blank()

        Button('确定')
          .attributeModifier(this.confirmButtonModifier)
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
