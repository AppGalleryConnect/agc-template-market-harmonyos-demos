import { TCLogger } from 'common';
import { ArticleCard, CardData, MessageList, TabButton, TabController, TopicCard } from 'message_manager';
import { phoneRouterControl } from 'oh_router';
import { MessageCenterVM } from '../viewmodel/MessageCenterVM';

/**
 * 消息中心页面
 */
@ComponentV2
export struct MyMessage {
  vm: MessageCenterVM = new MessageCenterVM();

  aboutToAppear(): void {
    this.vm.swiperController.changeIndex(this.vm.currentIndex)
  }

  public build(): void {
    NavDestination() {
      Column() {
        this.buildTitleBar()
        Row({ space: 16 }) {
          ForEach(this.vm.tabList, (item: TabController, index: number) => {
            TabButton({
              isActive: index === this.vm.currentIndex,
              tabController: item,
              statusChange: () => {
                this.vm.currentIndex = index;
                this.vm.swiperController.changeIndex(index)
              }
            })
          }, (item: TabController) => JSON.stringify(item))
        }
        .width('100%')
        .margin({ bottom: 16 })

        Swiper(this.vm.swiperController) {
          List({ space: 12 }) {
            ForEach(this.vm.newJobList, (item: CardData) => {
              ArticleCard({
                cardStyle: {
                  timeColor: '#376BFC',
                  timeFontSize: 16,
                  maxLines: 6
                },
                cardData: item,
                itemClick: () => {
                  TCLogger.info('跳转事件')
                }
              })
            }, (item: CardData) => JSON.stringify(item))
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off)

          MessageList({
            list: this.vm.messageList,
            itemClick: () => {
              TCLogger.info('跳转事件')
            }
          })

          List({ space: 12 }) {
            ForEach(this.vm.cardList, (item: CardData) => {
              ArticleCard({
                cardStyle: {
                  maxLines: 2
                },
                cardData: item,
                itemClick: () => {
                  TCLogger.info('跳转事件')
                }
              })
            }, (item: CardData) => JSON.stringify(item))
            TopicCard({
              cardData: this.vm.cardList[0],
              itemClick: () => {
                TCLogger.info('跳转事件')
              }
            })
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off)
        }
        .width('100%')
        .height('100%')
        .loop(false)
        .indicator(false)
        .layoutWeight(1)
        .onChange((index: number) => {
          this.vm.currentIndex = index;
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_secondary'))
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .padding({
        left: this.vm.breakPointModel.pagePadding,
        right: this.vm.breakPointModel.pagePadding,
      })
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => this.vm.navPathStack = ctx.pathStack)
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
      .onClick(() => this.vm.navPathStack.pop())

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
  }
}

@Builder
export function MessageCenterPageBuilder(): void {
  MyMessage()
}