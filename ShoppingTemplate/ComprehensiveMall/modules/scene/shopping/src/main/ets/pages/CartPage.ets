import { TitleBar } from '@components/titlebar';
import { IWaterFlow } from '@components/iwaterflow';
import { Style } from '@common/const';

import { CartPageLogic, CartStatus } from '../logic/CartPageLogic';
import { LoginButton } from '@components/loginbutton';
import { CartCardVM } from '@common/customtypes';

@ComponentV2
struct CartPage {

  @Param
  public pageName?: string = undefined;

  private logic: CartPageLogic = new CartPageLogic();

  aboutToAppear(): void {
    this.logic.isSubPage = Boolean(this.pageName);
  }

  build(): void {
    NavDestination() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Column() {
          buildTitleArea(this.logic)
          Refresh({
            refreshing: $$this.logic.isDownRefreshing,
            builder: buildRefreshingContent(this.logic)
          }) {
            Scroll() {
              Column() {
                Column() {
                  if (this.logic.status === CartStatus.NOT_LOGGED_IN) {
                    Column() {
                      Image($r('app.media.empty_status_logo'))
                        .width(160)
                        .height(160)
                        .draggable(false)
                        .objectFit(ImageFit.Cover)
                        .margin({ bottom: 15 })
                      Text('关联后可同步购物车中的商品')
                        .fontSize(13)
                        .fontColor($r('sys.color.mask_secondary'))
                        .margin({ bottom: 15 })
                      LoginButton({
                        onFinish: () => this.logic.onLoginButtonFinish()
                      }) {
                        Button() {
                          Text('关联账号')
                            .fontSize(13)
                            .fontColor(Color.White)
                        }
                        .width(100)
                        .height(37)
                        .type(ButtonType.Normal)
                        .backgroundColor('#FFE64566')
                        .borderRadius(21)
                      }
                    }
                    .width('100%')
                    .height('65%')
                    .borderRadius(12)
                    .alignItems(HorizontalAlign.Center)
                    .justifyContent(FlexAlign.Center)
                    .backgroundColor(Color.White)
                  } else if (this.logic.status === CartStatus.EMPTY) {
                    Column() {
                      Image($r('app.media.empty_status_logo'))
                        .width(160)
                        .height(160)
                        .draggable(false)
                        .objectFit(ImageFit.Cover)
                        .margin({ bottom: 15 })
                      Text('购物车空空如也，去逛逛吧~')
                        .fontSize(13)
                        .fontColor($r('sys.color.mask_secondary'))
                        .margin({ bottom: 15 })
                    }
                    .width('100%')
                    .height('45%')
                    .borderRadius(12)
                    .alignItems(HorizontalAlign.Center)
                    .justifyContent(FlexAlign.Center)
                    .backgroundColor(Color.White)
                  } else if (this.logic.status === CartStatus.NOT_EMPTY) {
                    Column() {
                      ForEach(this.logic.cartCards, (card: CartCardVM) => {
                        buildCartCard(this.logic, card)
                      })
                    }
                    .width('100%')
                  }
                }
                .width('100%')
                .alignItems(HorizontalAlign.Center)
                .justifyContent(FlexAlign.Start)
                .padding({ left: 10, right: 10, top: this.logic.status === CartStatus.NOT_EMPTY ? 0 : 10 })
                if ((this.logic.status === CartStatus.EMPTY || this.logic.status === CartStatus.NOT_EMPTY) &&
                  this.logic.iWaterFlowLogic.viewData.length > 0) {
                  buildSpecialDivider()
                  IWaterFlow({
                    logic: this.logic.iWaterFlowLogic,
                    footerPadding: { bottom: 48, top: 37 }
                  })
                    .padding({ left: 10, right: 10 })
                }
              }
              .width('100%')
              .constraintSize({ minHeight: '100%' })
              .alignItems(HorizontalAlign.Center)
              .justifyContent(FlexAlign.Start)
              .expandSafeArea(
                [SafeAreaType.SYSTEM, SafeAreaType.CUTOUT],
                this.logic.isSubPage ? [SafeAreaEdge.BOTTOM] : []
              )
            }
            .height('100%')
            .scrollBar(BarState.Off)
            .expandSafeArea(
              [SafeAreaType.SYSTEM, SafeAreaType.CUTOUT],
              this.logic.isSubPage ? [SafeAreaEdge.BOTTOM] : []
            )
          }
          .layoutWeight(1)
          .onStateChange(this.logic.onDownRefreshStateChange)
          .expandSafeArea(
            [SafeAreaType.SYSTEM, SafeAreaType.CUTOUT],
            this.logic.isSubPage ? [SafeAreaEdge.BOTTOM] : []
          )
        }
        .width('100%')
        .height('100%')
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .padding({ bottom: this.logic.status === CartStatus.NOT_EMPTY ? 60 : 0 })
        if (this.logic.status === CartStatus.NOT_EMPTY) {
          buildControlPanel(this.logic)
        }
        if (this.logic.status === CartStatus.LOADING || this.logic.isShowLoadingLogo) {
          Column() {
            LoadingProgress()
              .width(37)
              .height(37)
              .offset({ y: -50 })
          }
          .width('100%')
          .height('100%')
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .hitTestBehavior(HitTestMode.Block)
        }
      }
      .width('100%')
      .height('100%')
      .padding(this.logic.isSubPage ? {} : { bottom: Style.BOTTOM_NAV_HEIGHT })
      .bindContentCover(this.logic.skuSelectorId !== '', buildSkuLoadingLogo(), {
        modalTransition: ModalTransition.NONE,
        onWillDismiss: () => this.logic.skuSelectorId = ''
      })
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM])
      .backgroundColor('#FFF1F3F5')
    }
    .hideTitleBar(true)
    .onShown(() => {
      if (this.logic.isSubPage) {
        this.logic.refresh(false);
      }
    })
  }
}

@Builder
export function buildCartPage(pageName?: string) {
  CartPage({ pageName: pageName })
}

@Builder
function buildSkuLoadingLogo() {
  Column() {
    LoadingProgress()
      .width(37)
      .height(37)
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
  .backgroundColor('#40000000')
  .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
}

@Builder
function buildCartCard(logic: CartPageLogic, card: CartCardVM) {
  List() {
    ListItem() {
      Row() {
        Row() {
          Checkbox({ group: 'checkboxGroup', name: card.skuCode })
            .selectedColor('#FFE64566')
            .shape(CheckBoxShape.CIRCLE)
            .margin({ right: 9 })
            .select(card.isSelected)
          Image(card.banner)
            .width(80)
            .height(80)
            .draggable(false)
            .objectFit(ImageFit.Cover)
            .borderRadius(7)
        }
        .alignItems(VerticalAlign.Center)
        Column() {
          Column() {
            Text(card.title)
              .width('100%')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontSize(14)
              .fontColor('#E6000000')
            Text(card.serviceDesc)
              .fontColor($r('sys.color.mask_tertiary'))
              .fontSize(12)
              .margin({ top: 3 })
            Row() {
              Text(card.skuDesc)
                .fontColor($r('sys.color.mask_tertiary'))
                .fontSize(10)
              Image($r('app.media.ic_left_arrow'))
                .height(11)
                .objectFit(ImageFit.Contain)
                .rotate({ angle: 180 })
                .fillColor($r('sys.color.mask_tertiary'))
                .draggable(false)
            }
            .margin({ top: 7, bottom: 7 })
            .borderRadius(5)
            .padding({ top: 2, bottom: 2, left: 8, right: 3 })
            .backgroundColor('#0D000000')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          Row() {
            Text() {
              Span('¥')
                .fontSize(12)
              Span(card.price.toString())
                .fontSize(16)
            }
            .fontColor('#FFE84026')
            .fontWeight(500)
            Row() {
              Row() {
                Image($r('app.media.ic_minus'))
                  .width(13)
                  .objectFit(ImageFit.Contain)
                  .fillColor(card.count <= 1 ? '#FFCACFD7' : '#E6000000')
              }
              .width(25)
              .height(18)
              .justifyContent(FlexAlign.Center)
              .onClick(() => logic.onSkuCountChange(card, -1))
              Row() {
                Text(card.count.toString())
                  .fontSize(10)
                  .fontWeight(500)
                  .fontColor(Color.Black)
                  .backgroundColor('#00FFFFFF')
              }
              .width(30)
              .height(18)
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.Center)
              Row() {
                Image($r('app.media.ic_plus'))
                  .width(13)
                  .height(18)
                  .objectFit(ImageFit.Contain)
                  .fillColor(card.count < card.stock ? '#E6000000' : '#FFCACFD7')
                  .onClick(() => logic.onSkuCountChange(card, 1))
              }
              .width(25)
              .justifyContent(FlexAlign.Center)
            }
            .backgroundColor('#FFF6F6F6')
            .borderRadius(5)
            .margin({ right: 10 })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .constraintSize({ minHeight: 80 })
        .layoutWeight(1)
        .padding({ left: 10 })
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.Start)
      }
      .alignItems(VerticalAlign.Top)
      .width('100%')
      .padding({ left: 7, right: 7, top: 13, bottom: 13 })
    }
    .swipeAction({
      end: buildDeleteButton(logic, card),
      edgeEffect: SwipeEdgeEffect.None
    })
  }
  .width('100%')
  .height('auto')
  .listDirection(Axis.Vertical)
  .edgeEffect(EdgeEffect.None)
  .borderRadius(8)
  .margin({ top: 10 })
  .backgroundColor(Color.White)
  .clip(true)
}

@Builder
function buildDeleteButton(logic: CartPageLogic, card: CartCardVM) {
  Column() {
    Text('删除')
      .fontSize(13)
      .fontColor(Color.White)
      .fontWeight(500)
  }
  .width(55)
  .height('100%')
  .backgroundColor(Color.Red)
  .alignItems(HorizontalAlign.Center)
  .justifyContent(FlexAlign.Center)
  .onClick(() => logic.onSkuDelete([card.skuCode]))
}

@Builder
function buildControlPanel(logic: CartPageLogic) {
  Column() {
    Row() {
      Row() {
        CheckboxGroup({ group: 'checkboxGroup' })
          .selectedColor('#FFE64566')
          .checkboxShape(CheckBoxShape.CIRCLE)
          .onChange((event: CheckboxGroupResult) => logic.onCheckBoxChange(event.name))
        Text('全选')
          .fontColor($r('sys.color.mask_secondary'))
          .fontSize(13)
          .baselineOffset(-1)
          .margin({ left: 8, right: 8 })
      }
      Row() {
        if (logic.isEditingMode) {
          Button() {
            Text('删除')
              .fontSize(13)
              .fontColor(Color.White)
              .fontWeight(500)
          }
          .width(80)
          .height(32)
          .type(ButtonType.Normal)
          .backgroundColor(Color.Red)
          .borderColor('#FFE64566')
          .borderRadius(21)
          .margin({ left: 16 })
          .onClick(() => logic.onSkuDelete([]))
        } else {
          Text() {
            Span('合计: ')
              .fontSize(13)
              .fontColor('#E6000000')
            Span('¥')
              .fontSize(12)
              .fontColor('#FFE84026')
            Span(logic.totalPrice.toString())
              .fontSize(16)
              .fontColor('#FFE84026')
          }
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.MARQUEE })
          .textAlign(TextAlign.End)
          Button() {
            Text('结算')
              .fontSize(13)
              .fontColor(Color.White)
              .fontWeight(500)
          }
          .width(80)
          .height(32)
          .type(ButtonType.Normal)
          .backgroundColor('#FFE64566')
          .borderRadius(21)
          .margin({ left: 16 })
          .onClick(() => logic.onSettlement())
        }
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .height(60)
    .shadow(logic.isSubPage ? undefined : { radius: 10, color: '#30000000' })
    .borderWidth(logic.isSubPage ? { top: 0.1 } : { bottom: 0.1 })
    .borderColor('#30000000')
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 16, right: 16 })
  }
  .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM])
  .backgroundColor(Color.White)
}

@Builder
function buildRefreshingContent(logic: CartPageLogic) {
  Stack() {
    if (logic.downRefreshStatus === RefreshStatus.Refresh) {
      LoadingProgress()
        .height(32)
    } else if (logic.downRefreshStatus === RefreshStatus.OverDrag) {
      Text('释放可刷新页面')
        .fontColor($r('sys.color.mask_secondary'))
        .fontSize(13)
        .lineHeight(32)
        .halfLeading(true)
    } else if (logic.downRefreshStatus === RefreshStatus.Drag) {
      Text('下拉刷新')
        .fontColor($r('sys.color.mask_secondary'))
        .fontSize(13)
        .lineHeight(32)
        .halfLeading(true)
    }
  }
  .align(Alignment.Center)
  .clip(true)
  .constraintSize({ minHeight: 32 })
  .width('100%')
}

@Builder
function buildTitleArea(logic: CartPageLogic) {
  TitleBar({
    hideBackButton: !logic.isSubPage,
    barPadding: {
      left: Style.MENU_BAR_MARGIN_RIGHT,
      right: Style.MENU_BAR_MARGIN_RIGHT
    },
    barColor: Color.White
  }) {
    Row() {
      Text('购物车')
        .fontSize(16)
        .fontWeight(500)
        .fontColor('#E6000000')
        .margin(logic.isSubPage ? {} : { left: 8 })
      if (logic.status === CartStatus.NOT_EMPTY) {
        Column() {
          Text(logic.isEditingMode ? '退出管理' : '管理')
            .fontColor($r('sys.color.mask_secondary'))
            .fontSize(14)
        }
        .height(Style.MENU_BAR_HEIGHT)
        .padding({ left: 8, right: 8 })
        .justifyContent(FlexAlign.Center)
        .onClick(() => logic.isEditingMode = !logic.isEditingMode)
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}

@Builder
function buildSpecialDivider() {
  Row() {
    Column()
      .width(5.5)
      .height(5.5)
      .borderRadius(10)
      .linearGradient({
        angle: -130.6,
        colors: [['#FFE64566', 0.3], ['#00E64566', 1.0]]
      })
      .margin({ right: 10 })
    Column()
      .width(7)
      .height(7)
      .borderRadius(10)
      .linearGradient({
        angle: -130.6,
        colors: [['#FFE64566', 0.3], ['#00E64566', 1.0]]
      })
    Text('推荐商品')
      .fontSize(15)
      .fontColor('#E6000000')
      .margin({ left: 15, right: 15 })
    Column()
      .width(7)
      .height(7)
      .borderRadius(10)
      .linearGradient({
        angle: 130.6,
        colors: [['#FFE64566', 0.3], ['#00E64566', 1.0]]
      })
    Column()
      .width(5.5)
      .height(5.5)
      .borderRadius(10)
      .linearGradient({
        angle: 130.6,
        colors: [['#FFE64566', 0.3], ['#00E64566', 1.0]]
      })
      .margin({ left: 10 })
  }
  .width('100%')
  .height(47)
  .alignItems(VerticalAlign.Center)
  .justifyContent(FlexAlign.Center)
}
