import { getStringSync } from '@agctemplate/resources'
import { PreferConstant, PreferenceUtil } from '@agctemplate/utils'
import { FontModel } from '@agctemplate/widgets'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct UserInfoRow {
  @Param leftTitle: ResourceStr = ''
  @Param subTitle: string = ''
  @Param rightContent: string = ''
  @Event rightOnClick: () => void
  @Event switchButton: (isOn: boolean) => void
  @Local isToggleOn: boolean = false
  @Param isSwitch: boolean = false
  @Param isTriangle: boolean = false
  @BuilderParam rightMenu: () => void
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  aboutToAppear(): void {
    this.isToggleOn = PreferenceUtil.getInstance(this.getUIContext().getHostContext()).get(
      PreferConstant.BACKGROUND_MINI_WINDOW_PLAYBACK, false) as boolean
  }

  build() {
    Row() {
      Column({ space: 2 }) {
        Text(this.leftTitle)
          .fontWeight(500)
          .fontColor($r('sys.color.font_primary'))
          .fontSize(this.fontModel.getFg(16))
        if (this.subTitle) {
          Text(this.subTitle)
            .fontWeight(400)
            .fontSize(this.fontModel.getFg(14))
            .fontColor($r('sys.color.font_secondary'))
            .width('72%')
        }
      }
      .padding({ top: this.subTitle ? 9 : 0, bottom: this.subTitle ? 9 : 0 })
      .alignItems(HorizontalAlign.Start)

      Blank()
      Text(this.rightContent)
        .textAlign(TextAlign.End)
        .fontSize(this.fontModel.getFg(14))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_secondary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      if (this.isSwitch) {
        Toggle({ type: ToggleType.Switch, isOn: this.isToggleOn })
          .accessibilityText(getStringSync(this.leftTitle as Resource))
          .size({ width: 36, height: 20 })
          .onChange(() => {
            this.isToggleOn = !this.isToggleOn
            if (this.switchButton) {
              this.switchButton(this.isToggleOn)
            }
          })
      } else if (this.isTriangle) {
        SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
          .fontSize(this.fontModel.getFg(24))
          .fontColor([$r('sys.color.icon_fourth')])
          .margin({ left: 8 })
      } else {
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(this.fontModel.getFg(24))
          .fontColor([$r('sys.color.icon_fourth')])
      }
    }
    .bindMenu(this.isTriangle ? this.rightMenu : [], { placement: Placement.BottomRight })
    .onClick(() => {
      if (this.rightOnClick) {
        this.rightOnClick()
      }
    })
    .width('100%')
    .constraintSize({
      minHeight: 48
    })
    .padding({ left: 12, right: 12 })
  }
}