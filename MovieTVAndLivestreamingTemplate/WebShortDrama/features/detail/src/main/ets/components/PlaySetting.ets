import { SpeedSegmentButton } from './SpeedSegmentButton'
import { getString } from '@agctemplate/resources';
import { BulletVM } from '../viewmodels/BulletVM';
import { Preferences } from '../viewdata/Preferences'
import { fp2pxUtil } from '@agctemplate/widgets';

@Preview
@ComponentV2
export struct PlaySetting {
  @Param @Require bulletVM: BulletVM
  @Param isShowBullet: boolean = true
  @Event onSpeedSet: Function = (speed: number) => {
  }
  @Event onBulletSet: Function = (isOn: boolean) => {
  }
  @Event onClear: Function = (isOn: boolean) => {
  }
  @Event openBulletSetting: () => void
  @Event openScreenSetting: () => void
  @Event openReportSetting: () => void
  @Event openTimeoutSetting: () => void

  build() {
    Column({ space: 12 }) {
      Row() {
        Row() {
          Text(getString('app.string.play_speed_setting'))
            .textStyle()
          Column() {
            SpeedSegmentButton({ onSpeedSet: this.onSpeedSet })
              .width('100%')
          }
          .layoutWeight(1)
          .margin({ left: 12 })
          .height('100%')
        }
        .width('100%')
        .height(36)
      }
      .width('100%')
      .height(48)

      // clear screen
      Row() {
        Text(getString('app.string.clear_screen_switch'))
          .textStyle()
        Toggle({ type: ToggleType.Switch, isOn: Preferences.readData('showControl') })
          .accessibilityText('清屏')
          .width(36)
          .height(20)
          .onChange((isOn: boolean) => {
            this.onClear(isOn)
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height(48)

      // danmu
      Row() {
        Text(getString('app.string.danmaku_switch'))
          .textStyle()
        Toggle({ type: ToggleType.Switch, isOn: Preferences.readData('isShowBullet') })
          .accessibilityText('弹幕')
          .width(36)
          .height(20)
          .onChange((isOn: boolean) => {
            this.onBulletSet(isOn)
            if (isOn) {
              this.bulletVM.startBullet()
            } else {
              this.bulletVM.closeBullet()
            }
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height(48)

      // set danmu
      playSetItem('app.string.danmaku_setting', '进入弹幕设置', this.openBulletSetting)

      //weaknet
      playSetItem('app.string.screen_setting', '进入画面设置', this.openScreenSetting)

      playSetItem('app.string.report_setting', '进入举报页面', this.openReportSetting)

      playSetItem('app.string.Timeout_setting', '设置定时关闭', this.openTimeoutSetting)
    }
    .width('100%')
    .padding({ bottom: 68 })
  }
}

@Extend(Text)
function textStyle(size: number = 16, weight: FontWeight = FontWeight.Medium) {
  .fontSize(fp2pxUtil(size))
  .fontWeight(weight)
  .fontColor($r('sys.color.font_primary'))
}

@Builder
function playSetItem(itemName: string, itemText: string, clickFuc: () => void) {
  Row() {
    Text(getString(itemName))
      .textStyle()

    SymbolGlyph($r('sys.symbol.chevron_right'))
      .accessibilityText(itemText)
      .fontSize(fp2pxUtil(24))
      .fontColor([$r('sys.color.icon_fourth')])
  }
  .onClick(() => {
    clickFuc()
  })
  .justifyContent(FlexAlign.SpaceBetween)
  .width('100%')
  .height(48)
}