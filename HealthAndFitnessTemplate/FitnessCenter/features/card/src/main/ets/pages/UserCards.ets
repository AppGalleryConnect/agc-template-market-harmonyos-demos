import {
  BreakpointModel,
  BreakpointNameEnum, CardInfo, ConsumeType, DateUtil, MockService, UserCard } from 'external_interactions';
import { TitleBar } from 'module_recharge/src/main/ets/components/TitleBar';
import { ScreenPropStorage , AccountUpdate} from 'external_interactions'
import { AppStorageV2 } from '@kit.ArkUI';
@ComponentV2
export struct UserCards {
  @Local screenPropStorage : ScreenPropStorage = AppStorageV2.connect(ScreenPropStorage, 'ScreenPropStorage', () =>new ScreenPropStorage())!
  @Local topRectHeight: number = this.screenPropStorage.topRectHeight;
  @Local bottomRectHeight: number = this.screenPropStorage.bottomRectHeight;
  @Param @Once pathStack: NavPathStack = new NavPathStack()
  @Local userCardList: UserCard[] = []
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  @Monitor('screenPropStorage.topRectHeight', 'screenPropStorage.bottomRectHeight')
  onScreenPropStorage(mon: IMonitor) {
    this.topRectHeight = this.screenPropStorage.topRectHeight;
    this.bottomRectHeight = this.screenPropStorage.bottomRectHeight
  }

  @Computed
  get listLanes() {
    if ([BreakpointNameEnum.SM].includes(this.breakPointModel.currentBreakpoint as BreakpointNameEnum)) {
      return 1;
    }
    if ([BreakpointNameEnum.MD].includes(this.breakPointModel.currentBreakpoint as BreakpointNameEnum)) {
      return 2;
    }
    return 3;
  }

  @Builder
  cardItemBuilder(userCard: UserCard, cardDetail: CardInfo) {
    Column() {
      Row() {
        Image($r(cardDetail?.advImage))
          .width(80)
          .height(80)
          .borderRadius(8)
        Column() {
          Text(cardDetail?.name)
            .textAlign(TextAlign.Start)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
          Row() {
            Text(cardDetail?.consumeType === ConsumeType.TIMES ? cardDetail?.quota + '次' :
              MockService.getQuotaDurationDesc(cardDetail?.quota) + '卡')
              .fontSize(14)
            Text() {
              if (cardDetail?.consumeType === ConsumeType.TIMES) {
                Span('剩余次数:')
                Span(userCard.restQuota.toString())
                  .fontColor('#FF9019')
              } else {
                Span('到期时间:')
                Span(DateUtil.formatDate(MockService.getCardExpireDate(userCard)))
                  .fontColor('#FF9019')
              }
            }
            .fontSize(14)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 16 })
        .height(80)
      }
      .width('100%')

      Divider()
        .margin({ top: 12, bottom: 12 })

      Row() {
        Button('退卡')
          .width(72)
          .height(28)
          .controlSize(ControlSize.SMALL)
          .buttonStyle(ButtonStyleMode.NORMAL)
          .role(ButtonRole.ERROR)
          .onClick(() => {
            this.getUIContext().showAlertDialog({
              message: '是否确认退卡，退卡后余额返还余额退回付款账户',
              textStyle: {
                fontColor: $r('sys.float.Body_L'),
                fontWeight: FontWeight.Regular
              },
              autoCancel: false,
              width: 328,
              height: 146,
              primaryButton: {
                value: '取消',
                fontColor: $r('sys.color.font_secondary'),
                action: () => {}
              },
              secondaryButton: {
                value: '确认退卡',
                action: () => {
                  MockService.removeUserCard(userCard.cardId)
                  const removeCardIndex = this.userCardList.findIndex(card => card.id === userCard.id);
                  this.userCardList.splice(removeCardIndex, 1)
                }
              }
            })
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
    }
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding(12)
    .onClick(() => {
      this.pathStack.pushPath({ name: 'card/cardDetail', param: cardDetail })
    })
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({ title: '我的卡项', onBackClick:()=>{this.pathStack.pop()} })

        Column() {
          Image($r('app.media.no_result'))
            .width(144)
            .height(144)
            .margin({ bottom: 12 })
          Text('未查询到我的卡项信息')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor('#999999')
        }
        .height('50%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .visibility(this.userCardList.length > 0 ? Visibility.None : Visibility.Visible)

        List({ space: 12 }) {
          ForEach(this.userCardList, (item: UserCard) => {
            if(item.restQuota > 0){
              ListItem() {
                this.cardItemBuilder(item, MockService.getCardById(item.cardId))
              }
            }
          }, (item: UserCard) => JSON.stringify(item))
        }
        .lanes(this.listLanes, 16)
        .margin({ bottom: 28 })
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .width('100%')
        .height('100%')
        .layoutWeight(1)
      }.margin({ left: 16, right: 16 })
    }
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx?.pathStack
      MockService.userCardList.forEach((item: UserCard) => {
        if (MockService.userCardCanUse(item)) {
          if(item.restQuota > 0){
            this.userCardList.push(item)
          }
        }
      })
    })
    .hideTitleBar(true)
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.main_background_color'))
  }
}