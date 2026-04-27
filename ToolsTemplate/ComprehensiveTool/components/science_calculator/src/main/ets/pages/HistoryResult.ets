import { HistoryItem, HistoryUtils } from '../utils/HistoryUtils';

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
      Column() {
        Column() {
          if (this.calcHistory.length) {
            List() {
              ForEach(this.calcHistory, (item: HistoryItem) => {
                ListItem() {
                  this.ResultItem(item.value);
                };
              }, (item: HistoryItem) => item.id.toString());
            }.divider({ strokeWidth: 1 });
          } else {
            Image($r('app.media.no_result')).height(120).width(120);
            Text('暂无记录~~')
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: 24 });
          }
        }
        .layoutWeight(1)
        .padding(12)

        Image(this.calcHistory.length ? $r('app.media.ic_public_trash_active') : $r('app.media.ic_public_trash'))
          .height(40)
          .width(40)
          .margin({ top: 64, bottom: 50 })
          .onClick(() => {
            if (this.calcHistory.length) {
              this.calcHistory = [];
              HistoryUtils.clearHistoryResult();
              this.getUIContext().getPromptAction().showToast({ message: '历史记录已清空！' });
            }
          });
      };
    }.title('历史记录')
    .onReady(() => {
      this.calcHistory = HistoryUtils.getHistoryResult().reverse();
    });
  }

  getFirstEx(str: string): string {
    if (typeof str === 'undefined' || str === null || str === '') {
      return '';
    }
    return str;
  }

  @Builder
  ResultItem(record: string) {
    Column() {
      Row() {
        Text(this.getFirstEx(record?.split('=')[0]))
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_secondary'))
      }.width('100%')

      Row() {
        Text(`=${record?.split('=')[1]}`)
          .fontSize($r('sys.float.Subtitle_M'))
          .fontColor($r('sys.color.font_primary'));
      }.width('100%')
    }.padding({ top: 12, bottom: 12 });
  }
}