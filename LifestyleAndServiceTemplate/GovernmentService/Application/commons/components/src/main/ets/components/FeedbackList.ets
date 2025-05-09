import { Suggestion } from 'common';

@Component
export struct FeedbackList {
  @StorageLink('suggestionList') suggestionList: Suggestion[] =
    AppStorage.get('SuggestionList') ?? [];

  formatDate(dateString: Date): string {
    const date = new Date(dateString);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');
    const weekDays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
    const weekDay = weekDays[date.getDay()];
    const formattedDate = `${year}-${month}-${day} ${weekDay} ${hours}:${minutes}:${seconds}`;
    return formattedDate
  }

  build() {
    NavDestination() {
      List({ space: 10 }) {
        if (!this.suggestionList.length) {
          ListItem() {
            Column({ space: 10 }) {
              Image($r('app.media.no_data')).width(48).height(48)
              Text($r('app.string.no_data'))
            }.width('100%').height('100%').justifyContent(FlexAlign.Center)
          }
        } else {
          ForEach(this.suggestionList, (item: Suggestion) => {
            ListItem() {
              Column() {
                Text(this.formatDate(item.date) + '')
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(FontWeight.Medium)
                Column() {
                  Text($r('app.string.problem_description'))
                    .fontSize($r('sys.float.Body_L'))
                    .fontColor($r('sys.color.font_primary'))
                    .fontWeight(FontWeight.Medium)
                    .margin({ top: 12, bottom: 12 })
                  Text(item.title)
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor($r('sys.color.font_primary'))
                    .fontWeight(FontWeight.Regular)
                }.margin({ bottom: 13 }).width('100%').alignItems(HorizontalAlign.Start)

                Column() {
                  Text($r('app.string.problem_screenshot'))
                    .fontSize($r('sys.float.Body_L'))
                    .fontColor($r('sys.color.font_primary'))
                    .fontWeight(FontWeight.Medium)
                    .margin({ bottom: 8 })
                  Flex({ justifyContent: FlexAlign.Start, wrap: FlexWrap.Wrap }) {
                    ForEach(item.image, (item: string) => {
                      Row() {
                        Image(item).width(80).height(80)
                      }.margin({ bottom: 10 }).borderRadius(8).clip(true)
                    })
                  }
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
                .visibility(item.image && item.image.length > 0 ? Visibility.Visible : Visibility.None)
              }
              .padding(12)
              .width('100%')
              .borderRadius(16)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor($r('sys.color.background_primary'))
            }
          })
        }
      }
      .padding({ left: 16, right: 16 })
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .title('反馈记录')
    .padding({ top: Number(AppStorage.get('topRectHeight')) })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}