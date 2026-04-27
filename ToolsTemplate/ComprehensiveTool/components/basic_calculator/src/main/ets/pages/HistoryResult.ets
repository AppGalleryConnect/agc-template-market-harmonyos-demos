import { HistoryUtils, HistoryItem } from '../utils/HistoryUtils';
import { CalcConstants } from '../common/Constant';

@Builder
export function HistoryResultBuilder() {
  HistoryResult();
}

@Preview
@ComponentV2
export struct HistoryResult {
  @Local calcHistory: Array<HistoryItem> = [];

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          if (this.calcHistory.length) {
            List() {
              ForEach(this.calcHistory, (item: HistoryItem) => {
                ListItem() {
                  this.ResultItem(item.value);
                };
              }, (item: HistoryItem) => item.id.toString());
            }.height('70%');
          } else {
            Image($r('app.media.no_result')).height(120).width(120);
            Text('暂无记录~~')
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: 24 });
          }
        }
        .padding(12)
        .height('calc(100% - 108vp)')
        .justifyContent(this.calcHistory.length ? FlexAlign.Start : FlexAlign.Center);

        Image(this.calcHistory.length ? $r('app.media.ic_public_trash_active') : $r('app.media.ic_public_trash'))
          .height(40)
          .width(40)
          .onClick(() => {
            if (this.calcHistory.length) {
              this.calcHistory = [];
              HistoryUtils.clearHistoryResult();
              this.getUIContext().getPromptAction().showToast({
                message: '历史记录已清空！',
              });
            }
          });
      };
    }.title('计算结果')
    .onReady(() => {
      this.calcHistory = HistoryUtils.getHistoryResult().reverse();
    });
  }

  getFirstEx(str: string): string {
    if (typeof str === 'undefined' || str === null || str === '') {
      return '';
    }
    return CalcConstants.OPERATORS_ARY.some(item => str.endsWith(item)) ? str.slice(0, str.length - 1) : str;
  }

  @Builder
  ResultItem(record: string) {
    Column() {
      Row() {
        Text(this.getFirstEx(record?.split('=')[0]))
          .fontSize($r('sys.float.Body_L'))
          .textAlign(TextAlign.Start)
          .width('100%')
          .fontColor($r('sys.color.font_secondary'))
          .opacity(0.6)
          .lineHeight(21);
      }
      .padding({ left: 10 })
      .justifyContent(FlexAlign.Start);

      Row() {
        Text(`=${record?.split('=')[1]}`)
          .fontSize($r('sys.float.Subtitle_M'))
          .width('100%')
          .lineHeight(21)
          .opacity(0.9)
          .textAlign(TextAlign.Start)
          .fontColor($r('sys.color.font_primary'));
      }
      .justifyContent(FlexAlign.Start)
      .padding({ left: 10 })
      .margin({ bottom: 13 });

      Divider().margin({ bottom: 12 });
    };
  }
}