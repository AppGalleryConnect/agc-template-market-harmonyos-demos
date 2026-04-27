import { Logger } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';

const TAG = '[ReportReasonDialog]'

export interface IReportReasonDialogParams {
  reasons?: string[];
  onReport?: (reason: string) => void;
}

export class ReportReasonDialogParams implements IReportReasonDialogParams {
  reasons: string[] = [];
  onReport: (reason: string) => void = () => {
  };

  constructor(item: IReportReasonDialogParams) {
    if (item.reasons) {
      this.reasons = item.reasons;
    }
    if (item.onReport) {
      this.onReport = item.onReport;
    }
  }
}

@ComponentV2
export struct ReportReasonView {
  @Require @Param params: ReportReasonDialogParams;
  private pageStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '举报',
          showBackBtn: true,
          headerBarHeight: 40,
          customPadding: {
            top: 0,
            bottom: 8,
            left: 0,
            right: 0,
          },
          onBack: () => {
            this.pageStack.pop();
          },
        })
        Column() {
          ForEach(this.params.reasons, (reason: string, index: number) => {
            Column() {
              Text(reason)
                .fontSize(16)
                .fontColor($r('sys.color.ohos_id_color_text_primary'))
                .width('100%')
                .height(48)
                .onClick(() => {
                  Logger.info(TAG, `Report reason: ${reason}`);
                  this.params.onReport(reason);
                })
              if (index !== this.params.reasons.length - 1) {
                Divider()
              }
            }
          }, (reason: string, index: number) => `${index}_${reason}`)
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.common_sheet_bg'))
    .onReady((context) => {
      this.pageStack = context.pathStack;
    })
  }
}
