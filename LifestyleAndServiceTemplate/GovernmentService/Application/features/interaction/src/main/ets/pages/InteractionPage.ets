import { getDataFromJSON, goH5 } from 'h5';
import { buildSwiperArea } from 'components';
import { NavigationParams, questionAnswer, ItemInfo } from 'common';

@Component
export struct InteractionPage {
  @StorageLink('isLogin') isLogin: boolean = false
  arrowDown: string = 'app.media.interaction_page_pic1';
  arrowUp: string = 'app.media.interaction_page_pic2';
  voiceOnlineList: Array<ItemInfo> = []
  @State questionAnswerList: Array<questionAnswer> = [];
  @Consume('pageInfos') pageInfos: NavPathStack
  goH5Page = (title: string) => {
    this.pageInfos.pushPathByName('Empty', new NavigationParams(title))
  }

  initDataSource() {
    this.voiceOnlineList = getDataFromJSON<ItemInfo>('InteractionPage-VoiceOnlineList.json', this);
    this.questionAnswerList = getDataFromJSON<questionAnswer>('InteractionPage-QuestionAnswerList.json', this);
  }

  build() {
    List() {
      ListItem() {
        Column() {
          buildSwiperArea({
            swiperHeight: 168,
            isNeedPadding: false,
          })
          this.buildVoiceOnLineGrid();
          this.buildCustomerService();
        }
        .width('100%')
        .constraintSize({ minHeight: '100%' })
        .backgroundColor('#F5F5F5')
        .padding({ left: 12, right: 12 })
        .justifyContent(FlexAlign.Start)

      }
    }
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.Spring)
    .padding({ top: Number(AppStorage.get('topRectHeight')) })
    .scrollBar(BarState.Off)
    .backgroundColor('#f5f5f5')
  }

  /**
   * 构造占位图
   */
  @Builder
  buildPlaceholderMap() {
    Text($r('app.string.interaction_title'))
      .width('100%')
      .height(80)
      .borderRadius($r('sys.float.corner_radius_level4'))
      .backgroundImage($r('app.media.interaction_page_pic3'))
      .backgroundImageSize(ImageSize.FILL)
      .fontColor($r('sys.color.comp_background_list_card'))
      .margin({ top: 10, bottom: 13 })
      .textAlign(TextAlign.Center)
      .fontSize($r('app.integer.text_font_big'))
      .fontWeight(FontWeight.Bold)
  }

  /**
   * 构造民声在线栅格
   */
  @Builder
  buildVoiceOnLineGrid() {
    Column() {
      Text($r('app.string.voice_online'))
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Bold)
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(this.voiceOnlineList, (voiceOnlineItem: ItemInfo) => {
          buildGridItem(voiceOnlineItem, this.goH5Page);
        }, (voiceOnlineItem: ItemInfo) => voiceOnlineItem.name);
      }
      .width('100%')
    }
    .width('100%')
    .borderRadius(16)
    .padding(12)
    .backgroundColor($r('sys.color.background_primary'))
    .margin({ bottom: 12, top: 12 })
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 构造有事问客服
   */
  @Builder
  buildCustomerService() {
    Column() {
      Row() {
        Text($r('app.string.customer_service'))
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Bold);
      }
      .width('100%')
      .margin({ top: 10, bottom: 15 })
      .padding({ left: 12, right: 12 })
      .justifyContent(FlexAlign.SpaceBetween);

      ForEach(this.questionAnswerList, (questionAnswerItem: questionAnswer) => {
        Column() {
          Row() {
            Row() {
              Image($r('app.media.interaction_page_pic5'))
                .width(20)
                .height(20)
                .margin({ right: 7 })
                .objectFit(ImageFit.Cover);
              Text(`${questionAnswerItem.question}`)
                .fontColor($r('sys.color.font_primary'))
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Regular);
            };

            Image($r(questionAnswerItem.isExpand ? this.arrowUp : this.arrowDown))
              .width(16)
              .height(16)
              .objectFit(ImageFit.Cover);
          }
          .width('100%')
          .margin({ bottom: 15 })
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => this.changeExpand(questionAnswerItem));

          if (questionAnswerItem.isExpand) {
            Row() {
              Image($r('app.media.interaction_page_pic6'))
                .width(20)
                .height(20)
                .margin({ right: 7 })
                .objectFit(ImageFit.Cover);
              Text(`${questionAnswerItem.answer}`)
                .width('90%')
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Regular);
            }
            .width('100%')
            .margin({ bottom: 18 })
            .alignItems(VerticalAlign.Top);
          }
        }
        .width('100%')
        .padding({ left: 15, right: 10 });
      }, (questionAnswerItem: questionAnswer) => JSON.stringify(questionAnswerItem));
    }
    .width('100%')
    .borderRadius($r('sys.float.corner_radius_level6'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .shadow({
      offsetX: 0,
      offsetY: -4,
      radius: 9,
      color: '#00000008',
    })
  }

  changeExpand(item: questionAnswer): void {
    item.isExpand = !item.isExpand;
    this.questionAnswerList = [...this.questionAnswerList]
  }

  aboutToAppear() {
    this.initDataSource()
  }
}

@Builder
function buildGridItem(itemInfo: ItemInfo, event: (title: string) => void) {
  Column({ space: 5 }) {
    Image($r(itemInfo.pic))
      .width(40)
      .height(40)

    Text(`${itemInfo.name}`)
      .fontColor($r('sys.color.font_primary'))
      .fontSize($r('sys.float.Body_S'))
      .fontWeight(FontWeight.Regular)
  }
  .onClick(() => {
    event(itemInfo.name)
  })
  .margin({ top: 11 })
}

@Builder
function buildMoreIconComponent(promptMessage: ResourceStr, moreIcon: string, event?: () => void | undefined) {
  Row() {
    Text(promptMessage)
      .fontColor($r('sys.color.font_secondary'))
      .fontSize($r('sys.float.Body_S'))
      .fontWeight(FontWeight.Regular);
    Image($r(moreIcon))
      .width(12)
      .height(12)
      .objectFit(ImageFit.Cover);
  }
  .width('20%')
  .justifyContent(FlexAlign.SpaceBetween)
  .onClick(event);
}

