import { TitleBar } from 'component';
import { Constants, CustomerServiceModel } from 'constant';

@Builder
export function CustomerBuilder() {
  Customer();
}

@Component
export struct Customer {
  @State status: Array<boolean> = [];
  @Consume('mainPathStack') mainPathStack: NavPathStack;
  @State answerList: Array<CustomerServiceModel> = [
    {
      key: 0,
      ask: '我预订的房间可以退款吗？',
      answer: '可以退款',
    },
    {
      key: 1,
      ask: '如何取消预订？',
      answer: '请联系客服电话取消预定',
    },
  ];

  aboutToAppear(): void {
    this.status = new Array(this.answerList.length).fill(false);
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '常见问题', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Scroll() {
          Column({ space: 16 }) {
            ForEach(this.answerList, (item: CustomerServiceModel) => {
              Column() {
                Row() {
                  Text(`${item.ask}`).fontSize(16).fontWeight(600).fontWeight(500).width('90%');
                  Image($r('app.media.icon_more'))
                    .size({ width: 12, height: 12 })
                    .rotate({ angle: this.status[item.key] ? 180 : 0 });
                }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.SpaceBetween).onClick(() => {
                  this.status[item.key] = !this.status[item.key];
                }).alignItems(VerticalAlign.Top);

                if (this.status[item.key]) {
                  Divider().vertical(false).margin({ top: 12, bottom: 12 });
                  Text(`${item.answer}`).width(Constants.FULL_SCREEN).fontSize(14).fontColor(Color.Gray);
                }
              }
              .width(Constants.FULL_SCREEN)
              .backgroundColor(Color.White)
              .borderRadius(8)
              .padding(12);
            }, (item: CustomerServiceModel) => item.key.toString());
          }
          .padding(16);
        }.height('90%').align(Alignment.Top).backgroundColor('#F5F6FA').scrollBar(BarState.Off);
      };
    }.hideTitleBar(true);
  }
}
