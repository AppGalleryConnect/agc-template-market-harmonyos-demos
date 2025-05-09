import { MessageInfo } from 'common';
import { getDataFromJSON } from 'h5';

@Component
export struct Message {
  @State messageInfo: Array<MessageInfo> = [];
  @State currentIndex: number = 0;
  @Consume('pageInfos') pageInfos: NavPathStack

  initDataSource() {
    this.messageInfo = getDataFromJSON<MessageInfo>('MessagePage-message.json', this);
  }

  build() {
    NavDestination() {
      Column() {
        this.buildPageHeadView();
        this.buildMessageContentView();
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .hideTitleBar(true)
    .padding({ top: Number(AppStorage.get('topRectHeight')) })
  }

  @Builder
  buildPageHeadView() {
    Row() {
      Image($r('app.media.mine_model_pic18'))
        .width(20)
        .height(20)
        .objectFit(ImageFit.Cover)
        .onClick(() => this.pageInfos.pop());
      Text($r('app.string.message_management'))
        .fontColor(Color.Black)
        .textAlign(TextAlign.Center)
        .fontSize($r('app.integer.text_font_big'))
        .fontWeight(FontWeight.Bold);
      Text($r('app.string.all_read'))
        .fontColor(Color.Black)
        .textAlign(TextAlign.Center)
        .fontSize($r('sys.float.Body_L'))
    }
    .width('100%')
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .padding(15)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  buildMessageContentView() {
    Column() {
      Row() {
        ForEach(this.messageInfo, (item: MessageInfo, index: number) => {
          Text(item.title)
            .borderWidth({ bottom: this.currentIndex === index ? 2 : 0 })
            .borderColor({ bottom: '#007DFF' })
            .fontColor(Color.Black)
            .padding({ bottom: 4 })
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(this.currentIndex === index ? 'bold' : 'normal')
            .onClick(() => {
              this.currentIndex = index;
            });
        },(item: MessageInfo) => JSON.stringify(item));
      }
      .width('100%')
      .padding({ top: 12, bottom: 12 })
      .justifyContent(FlexAlign.SpaceEvenly);

      List() {
        ForEach(this.messageInfo[this.currentIndex].message, (contentItem: string) => {
          ListItem() {
            Row() {
              Image($r(this.messageInfo[this.currentIndex]?.icon))
                .width(30)
                .height(30)
                .borderRadius(15)
                .margin({ right: 12 })
                .objectFit(ImageFit.Cover);

              Text(`${contentItem}`)
                .width('80%')
                .fontColor(Color.Black)
                .lineHeight(14)
                .fontSize($r('sys.float.Body_L'))
            }
            .width('100%');
          }
          .width('100%')
          .borderWidth({ bottom: 1 })
          .borderColor({ bottom: '#EDEDED' })
          .padding({ top: 10, bottom: 10 });
        },(contentItem: string) => contentItem);
      }
      .width('100%')
      .borderRadius($r('sys.float.corner_radius_level4'))
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .padding({ left: 12, right: 8 });
    }
    .padding({ left: 12, right: 12 })
  }

  aboutToAppear() {
    this.initDataSource()
  }
}