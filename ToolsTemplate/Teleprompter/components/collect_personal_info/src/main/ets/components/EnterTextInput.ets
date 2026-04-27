import { AppStorageV2 } from '@kit.ArkUI';
import { Constants } from '../common/Constant';
import { ConfirmButtonModifier, InnerTitleModifier, SheetColumnModifier } from '../common/CustomModifier';
import { encryptPhone } from '../common/Util';
import { WindowModel } from '../common/WindowModel';

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
