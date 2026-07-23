import { FontModel } from '../model/FontModel'
import { OnlineInfo } from '../model/OnlineInfoModel'
import { OnlineCheckInViewModel } from '../viewmodel/OnlineCheckInViewModel'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct OnlineCheckIn {
  @Local progressVal: number = 0
  @Consumer('balance') balance: number = 0
  @Param addAward: () => void = () => {}
  viewModel: OnlineCheckInViewModel = new OnlineCheckInViewModel()
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  async aboutToAppear(): Promise<void> {
    await this.viewModel.init((progressValue) => {
      this.progressVal = progressValue
    })
    this.viewModel.startProgressTimer((progressValue) => {
      this.progressVal = progressValue
    })
  }

  aboutToDisappear(): void {
    this.viewModel.stopProgressTimer()
    this.viewModel.saveOnlineTime()
  }

  @Builder
  CheckIn(onlineInfo: OnlineInfo) {
    Column() {
      if (!onlineInfo.isObtained) {
        Image($r(onlineInfo.coinIcon))
          .height(16)
          .margin({ bottom: 4 })
      } else {
        Row()
          .height(16)
          .margin({ bottom: 4 })
      }

      Stack() {
        Circle()
          .width(8)
          .aspectRatio(1)
          .fill($r('sys.color.comp_background_tertiary'))

        Circle()
          .width(5)
          .aspectRatio(1)
          .fill($r('sys.color.font_on_primary'))
      }
      .margin({ bottom: 4 })
      .height(8)

      Text(onlineInfo.time)
        .fontSize(this.fontModel.getFg(12))
        .height(16)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_secondary'))
    }
    .onClick(() => {
      if (onlineInfo.canGet && !onlineInfo.isObtained) {
        this.balance = onlineInfo.coin
        this.addAward()
        onlineInfo.canGet = false
        onlineInfo.isObtained = true
      }
    })
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Progress({ value: this.progressVal, total: 8, type: ProgressType.Linear })

      Row() {
        ForEach(this.viewModel.onlineInfoArr, (onlineInfo: OnlineInfo, index: number) => {
          this.CheckIn(onlineInfo)
        }, (onlineInfo: OnlineInfo) => onlineInfo.coin.toString())
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .margin({ top: 25 })
  }
}