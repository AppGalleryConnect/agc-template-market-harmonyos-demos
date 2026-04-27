import { CommonConstants } from '../common/Constants';


@ComponentV2
export struct FormInputItem {

  @Param
  public text: string = '';

  @Param
  public title: string = '';

  @Param
  public placeholder: string = '';

  @Param
  public maxLength: number = Number.POSITIVE_INFINITY;

  @Param
  public type: TextAreaType = TextAreaType.NORMAL;

  @Param
  public isFocusable: boolean = true;

  @BuilderParam
  public buildFunctionalButton: () => void = buildEmptyContent;

  @Event
  public onChange: Callback<string> = () => {};

  @Event
  public onTextClick: Callback<void> = () => {};

  @Local
  private isFocus: boolean = false;

  public build(): void {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Row() {
        Text(this.title)
          .width(80)
          .maxLines(1)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .padding({ top: 14, bottom: 14 })
        TextArea({ text: this.text, placeholder: this.placeholder })
          .layoutWeight(1)
          .constraintSize({ maxHeight: 80 })
          .borderWidth(0)
          .borderRadius(0)
          .maxLength(this.maxLength)
          .type(this.type)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .placeholderColor($r('sys.color.font_secondary'))
          .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_L'))
          .caretColor(CommonConstants.THEME_COLOR)
          .selectedBackgroundColor(CommonConstants.THEME_COLOR)
          .showCounter(false)
          .barState(BarState.Off)
          .onClick(() => this.onTextClick())
          .onChange((value: string) => this.onChange(value))
          .onFocus(() => this.isFocus = true)
          .onBlur(() => this.isFocus = false)
          .focusable(this.isFocusable)
          .padding({ left: 0, right: 0, top: 14, bottom: 14 })
        Column() {
          this.buildFunctionalButton()
        }
        .height(46)
        .constraintSize({ minWidth: 8, maxWidth: 46 })
        .margin({ right: 4 })
        .alignSelf(ItemAlign.Center)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      Row()
        .width('calc(100% - 80vp - 12vp)')
        .height(this.isFocus ? '3px' : '1px')
        .backgroundColor(this.isFocus ? $r('sys.color.comp_focused_primary') : $r('sys.color.comp_focused_tertiary'))
        .hitTestBehavior(HitTestMode.None)
        .margin({ right: 12 })
    }
    .padding({ left: 12 })
  }
}

@Builder
function buildEmptyContent() {
  // No need to do anything
}
