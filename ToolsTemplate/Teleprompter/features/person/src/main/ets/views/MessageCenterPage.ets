import {
  ArticleCard,
  CardData,
  MessageItem,
  MessageList,
  MessageManagerService,
  TabButton,
  TabController,
  TopicCard
} from 'message_manager';
import { phoneRouterControl } from 'oh_router';
import { BarVM } from 'common';

@ComponentV2
export struct MyMessage {
  private navPathStack: NavPathStack = new NavPathStack();
  @Local currentIndex: number = 0;
  messageManagerService: MessageManagerService = MessageManagerService.instance;
  tabList: TabController[] = [
    new TabController('新职位发布'),
    new TabController('推送消息', true),
    new TabController('消息样式')
  ]
  swiperController: SwiperController = new SwiperController();
  messageList: MessageItem[] = this.messageManagerService.getMessageList();
  newJobList: CardData[] = this.messageManagerService.getJobDataList();
  cardList: CardData[] = this.messageManagerService.getCardDataList()

  aboutToAppear(): void {
    this.swiperController.changeIndex(this.currentIndex)
  }

  public build(): void {
    NavDestination() {
      Column() {
        this.buildTitleBar()
        Row({ space: 16 }) {
          ForEach(this.tabList, (item: TabController, index: number) => {
            TabButton({
              isActive: index === this.currentIndex,
              tabController: item,
              statusChange: () => {
                this.currentIndex = index;
                this.swiperController.changeIndex(index)
              }
            })
          }, (item: TabController) => JSON.stringify(item))
        }
        .width('100%')
        .margin({ bottom: 16 })

        Swiper(this.swiperController) {
          List({ space: 12 }) {
            ForEach(this.newJobList, (item: CardData) => {
              ArticleCard({
                cardStyle: {
                  timeColor: '#376BFC',
                  timeFontSize: 16,
                  maxLines: 6
                },
                cardData: item,
                itemClick: () => {
                  console.log('跳转事件')
                }
              })
            }, (item: CardData) => JSON.stringify(item))
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })

          MessageList({
            list: this.messageList,
            itemClick: () => {
              console.log('跳转事件')
            }
          })

          List({ space: 12 }) {
            ForEach(this.cardList, (item: CardData) => {
              ArticleCard({
                cardStyle: {
                  maxLines: 2
                },
                cardData: item,
                itemClick: () => {
                  console.log('跳转事件')
                }
              })
            }, (item: CardData) => JSON.stringify(item))
            TopicCard({
              cardData: this.cardList[0],
              itemClick: () => {
                console.log('跳转事件')
              }
            })
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        }
        .width('100%')
        .height('100%')
        .loop(false)
        .indicator(false)
        .layoutWeight(1)
        .onChange((index: number) => {
          this.currentIndex = index;
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_secondary'))
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .padding({
        left: 16,
        right: 16,
        top: BarVM.instance.staBarH,
        bottom: BarVM.instance.aiBarH
      })
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => this.navPathStack = ctx.pathStack)
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
  }

  @Builder
  private buildTitleBar(): void {
    Row() {
      /**
       * 页面返回按钮
       */
      Button() {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_primary')])
          .fontWeight(FontWeight.Normal)
      }
      .width(40)
      .height(40)
      .margin({ right: 8 })
      .type(ButtonType.Circle)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => this.navPathStack.pop())

      /**
       * 标题文本
       */
      Text('消息通知')
        .layoutWeight(1)
        .fontSize(20)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .maxLines(1)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
  }
}

@Builder
export function MessageCenterPageBuilder(): void {
  MyMessage()
}