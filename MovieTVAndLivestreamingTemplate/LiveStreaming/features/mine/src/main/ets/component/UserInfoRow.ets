import { PreferConstant, PreferenceUtil, GlobalContext } from '@agctemplate/utils'

@ComponentV2
export struct UserInfoRow {
  @Param leftTitle: string = ''
  @Param subTitle: string = ''
  @Param rightContent: string = ''
  @Event rightOnClick: () => void
  @Event switchButton: (isOn: boolean) => void
  @Local isToggleOn: boolean = false
  @Param isSwitch: boolean = false
  @Param isTriangle: boolean = false
  @BuilderParam rightMenu: () => void

  aboutToAppear(): void {
    const preferenceBackgroundPlay =
      PreferenceUtil.getInstance(GlobalContext.getUIContext().getHostContext(), PreferConstant.BACKGROUND_PLAY)
    this.isToggleOn = preferenceBackgroundPlay.get('backgroundPlay', false) as boolean
  }

  build() {
    Row() {
      Column({ space: 2 }) {
        Text(this.leftTitle)
          .height(21)
        if (this.subTitle) {
          Text(this.subTitle).height(19).fontWeight(400).fontSize(14).fontColor($r('sys.color.font_secondary'))
        }
      }
      .alignItems(HorizontalAlign.Start)

      Blank()
      Text(this.rightContent)
        .height(19)
        .textAlign(TextAlign.End)
        .width(120)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_secondary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      if (this.isSwitch) {
        Toggle({ type: ToggleType.Switch, isOn: this.isToggleOn })
          .size({ width: 36, height: 20 })
          .onChange(() => {
            this.isToggleOn = !this.isToggleOn
            if (this.switchButton) {
              this.switchButton(this.isToggleOn)
            }
          })
      } else if (this.isTriangle) {
        SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
          .fontSize(15)
          .fontColor([$r('sys.color.icon_tertiary')])
          .margin({ left: 8 })
      } else {
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_tertiary')])
      }
    }
    .bindMenu(this.isTriangle ? this.rightMenu : [], { placement: Placement.BottomRight })
    .onClick(() => {
      if (this.rightOnClick) {
        this.rightOnClick()
      }
    })
    .size({ width: '100%', height: 48 })
    .padding({ left: 12, right: 12 })
  }
}