import { AppStorageV2 } from '@kit.ArkUI';
import { Constants } from '../common/Constant';
import { ConfirmButtonModifier, InnerTitleModifier, SheetColumnModifier } from '../common/CustomModifier';
import { WindowModel } from '../common/WindowModel';

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
