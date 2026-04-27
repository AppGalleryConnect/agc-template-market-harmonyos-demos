import { ComponentContent } from '@kit.ArkUI';
import { LoanPrimeRate } from '../../types/Index';
import { HistoryBuilder } from './HistoryRateList';

@ComponentV2
export struct LPRTips {
  @Require @Param historyRate: Array<LoanPrimeRate> = [];
  private ctx: UIContext = this.getUIContext();

  @Computed
  get lprUpdateDate(): string {
    if (this.historyRate.length) {
      return this.historyRate[0].date.slice(5)
    }
    return ''
  }

  @Computed
  get lprRateTip(): string {
    if (this.historyRate.length) {
      return `LPR：一年期${this.historyRate[0].one}%，五年期${this.historyRate[0].five}%`
    }
    return ''
  }

  openHistoryRateDialog() {
    const contentNode = new ComponentContent(this.ctx, wrapBuilder(HistoryBuilder), this.historyRate);
    this.ctx.getPromptAction().openCustomDialog(
      contentNode
      , {
      autoCancel: true,
      alignment: DialogAlignment.Center,
      offset: { dx: 0, dy: 0 },
    })
  }

  build() {
    Row() {
      Text(this.lprUpdateDate)
        .fontSize($r('sys.float.Caption_M'))
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor($r('app.string.theme_color'))
        .margin({ right: 12 })
        .padding({
          top: 3,
          bottom: 3,
          left: 8,
          right: 8
        })
        .borderRadius(4)
      Text(this.lprRateTip).fontSize(12).layoutWeight(1)
      Text('历史LPR').fontSize(12).fontColor($r('app.string.theme_color')).fontWeight(FontWeight.Bold)
        .onClick(() => {
          this.openHistoryRateDialog();
        })
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#f5f8ff')
    .borderRadius(4)
  }
}
