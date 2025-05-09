import { TitleBar } from '@components/titlebar';
import { iResourceMgr } from '@common/resource';
import { LoadingStatus } from '@common/customtypes';
import { ProductServiceItem } from '@common/customtypes';

import { ProductInfoPageLogic } from '../logic/ProductInfoPageLogic';
import { LengthMetrics } from '@kit.ArkUI';

import { buildSkuSelector } from '../dialog/SkuSelector';
import { iData } from '@common/data';
import { LoginButton } from '@components/loginbutton';
import { router } from '@common/router';

@ComponentV2
export struct ProductInfoPage {

  @Param
  public productId: string = '';

  private logic: ProductInfoPageLogic = new ProductInfoPageLogic();

  aboutToAppear(): void {
    this.logic.load(this.productId);
  }

  build() {
    NavDestination() {
      if (this.logic.loadingStatus === LoadingStatus.SUCCESS) {
        Stack() {
          Column() {
            TitleBar({ barColor: Color.White })
            Scroll() {
              Column() {
                buildBannerArea(this.logic)
                buildPriceArea(this.logic)
                buildTitleArea(this.logic)
                buildTagsArea(this.logic)
                buildServiceInfoArea(this.logic)
                buildProductInfoArea(this.logic)
              }
              .width('100%')
              .constraintSize({ minHeight: '100%' })
            }
            .layoutWeight(1)
            .edgeEffect(EdgeEffect.None)
            .scrollBar(BarState.Off)
            Row() {
              buildCartButton()
              buildPaymentButton(this.logic)
            }
            .width('100%')
            .height(52)
            .padding({ left: 13, right: 13 })
            .backgroundColor(Color.White)
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .width('100%')
          .height('100%')
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Start)
          .backgroundColor('#FFF1F3F5')
          if (this.logic.isPaymentBtnActive || this.logic.isAddCartBtnActive) {
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor('#40000000')
              .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          }
        }
      }
    }
    .hideTitleBar(true)
    .backgroundColor(Color.White)
  }
}

@Builder
export function buildProductInfoPage(_: string, productId: string) {
  ProductInfoPage({ productId: productId })
}

@Builder
function buildBannerArea(logic: ProductInfoPageLogic) {
  Stack({ alignContent: Alignment.BottomEnd }) {
    Swiper() {
      ForEach(logic.info.banners, (item: string) => {
        Image(iResourceMgr.resolveUri(item))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .draggable(false)
      })
    }
    .width('100%')
    .height('100%')
    .indicator(false)
    .loop(false)
    .onAnimationStart(logic.onAnimationStart)
    Text() {
      Span(logic.selectIndex + 1 + '')
      Span('/')
      Span(logic.info.banners.length + '')
    }
    .fontSize(12)
    .fontColor(Color.White)
    .lineHeight(16)
    .halfLeading(true)
    .padding({ left: 4.5, right: 5 })
    .backgroundColor($r('sys.color.mask_tertiary'))
    .margin({ right: 12, bottom: 12 })
    .borderRadius(3)
  }
  .width('100%')
  .aspectRatio(1.0) // height=width/aspectRatio
}

@Builder
function buildPriceArea(logic: ProductInfoPageLogic) {
  Row() {
    Text() {
      buildPriceText(logic.info.price)
      buildDashPriceText(logic.info.dashPrice)
    }
    .maxLines(1)
    Text(logic.info.sales)
      .fontColor($r('sys.color.mask_secondary'))
      .fontSize(12)
      .maxLines(1)
      .layoutWeight(1)
      .textAlign(TextAlign.End)
  }
  .width('100%')
  .backgroundColor(Color.White)
  .padding({ left: 13, right: 13, top: 10, bottom: 6 })
  .alignItems(VerticalAlign.Center)
  .justifyContent(FlexAlign.SpaceBetween)
}

@Builder
function buildTitleArea(logic: ProductInfoPageLogic) {
  Column() {
    Text(logic.info.title)
      .width('100%')
      .fontWeight(500)
      .fontSize(16)
      .fontColor('#E6000000')
      .lineSpacing(LengthMetrics.vp(6))
      .maxLines(2)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
  }
  .width('100%')
  .padding({ left: 13, right: 13 })
  .backgroundColor(Color.White)
}

@Builder
function buildTagsArea(logic: ProductInfoPageLogic) {
  Row() {
    ForEach(logic.info.tags, (item: string) => {
      buildTag(item)
    })
  }
  .width('100%')
  .padding({ left: 13, right: 13, top: 5, bottom: 5 })
  .alignItems(VerticalAlign.Center)
  .justifyContent(FlexAlign.Start)
  .backgroundColor(Color.White)
}

@Builder
function buildServiceInfoArea(logic: ProductInfoPageLogic) {
  Column() {
    buildServiceInfo(logic.info.logistics)
    buildServiceInfo(logic.info.service)
  }
  .width('100%')
  .padding({ left: 13, right: 13, top: 3, bottom: 5 })
  .alignItems(HorizontalAlign.Start)
  .justifyContent(FlexAlign.Center)
  .backgroundColor(Color.White)
}

@Builder
function buildProductInfoArea(logic: ProductInfoPageLogic) {
  Column() {
    Text('商品详情')
      .width('100%')
      .fontSize(15)
      .fontWeight(600)
      .fontColor('#E6000000')
      .lineHeight(52)
      .halfLeading(true)
      .padding({ left: 13 })
      .backgroundColor(Color.White)
    ForEach(logic.info.pictures, (item: string) => {
      Image(iResourceMgr.resolveUri(item))
        .width('100%')
        .objectFit(ImageFit.Contain)
        .draggable(false)
    })
  }
  .margin({ top: 10, bottom: 16 })
}

@Builder
function buildPaymentButton(logic: ProductInfoPageLogic) {
  Row() {
    LoginButton({
      onStart: (needWaitFinish: boolean) => {
        if (!needWaitFinish && iData.global.isLogin) {
          logic.onAddCartBtnClick()
        }
      },
      onFinish: () => {
        if (iData.global.isLogin) {
          logic.onAddCartBtnClick()
        }
      }
    }) {
      Button() {
        Text('加入购物车')
          .fontSize(13)
          .fontColor('#FFE64566')
      }
      .width('35%')
      .height(40)
      .type(ButtonType.Normal)
      .backgroundColor(Color.White)
      .borderWidth(1)
      .borderColor('#FFE64566')
      .borderRadius({ topLeft: 21, bottomLeft: 21 })
      .bindContentCover(logic.isAddCartBtnActive, buildSkuSelector(logic.skuSelectorLogic), {
        modalTransition: ModalTransition.DEFAULT,
        onWillDismiss: () => logic.isAddCartBtnActive = false
      })
    }
    LoginButton({
      onStart: (needWaitFinish: boolean) => {
        if (!needWaitFinish && iData.global.isLogin) {
          logic.onPaymentBtnClick()
        }
      },
      onFinish: () => {
        if (iData.global.isLogin) {
          logic.onPaymentBtnClick()
        }
      }
    }) {
      Button() {
        Text('立即购买')
          .fontSize(13)
          .fontColor(Color.White)
      }
      .width('28%')
      .height(40)
      .type(ButtonType.Normal)
      .backgroundColor('#FFE64566')
      .borderRadius({ topRight: 21, bottomRight: 21 })
      .bindContentCover(logic.isPaymentBtnActive, buildSkuSelector(logic.skuSelectorLogic), {
        modalTransition: ModalTransition.DEFAULT,
        onWillDismiss: () => logic.isPaymentBtnActive = false
      })
    }
  }
}

@Builder
function buildCartButton() {
  LoginButton({
    onStart: (needWaitFinish: boolean) => {
      if (!needWaitFinish && iData.global.isLogin) {
        router.pushPathByName('CartPage', null);
      }
    },
    onFinish: () => {
      if (iData.global.isLogin) {
        router.pushPathByName('CartPage', null);
      }
    }
  }) {
    Column() {
      Image($r('app.media.ic_tab_inactive_cart'))
        .width(21)
        .height(21)
        .fillColor($r('sys.color.mask_secondary'))
        .margin({ bottom: 3 })
      Text('购物车')
        .fontSize(10)
        .fontColor($r('sys.color.mask_secondary'))
      if (iData.global.isLogin) {
        Text(iData.global.cartTotal > 99 ? '99+' : iData.global.cartTotal.toString())
          .constraintSize({ minWidth: 5, minHeight: 5 })
          .fontSize(10)
          .lineHeight(15)
          .halfLeading(true)
          .fontColor(Color.White)
          .borderRadius(10)
          .padding({ left: 5, right: 5 })
          .position({ x: 31, y: 4 })
          .backgroundColor('#FFE84026')
      }
    }
    .width(46)
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}

@Builder
function buildPriceText(content: ResourceStr) {
  Span('¥')
    .fontColor('#FFE84026')
    .fontSize(12)
    .fontWeight(600)
  Span(content)
    .fontColor('#FFE84026')
    .fontSize(22)
    .fontWeight(600)
}

@Builder
function buildDashPriceText(content: ResourceStr) {
  ImageSpan('')
    .margin({ right: 8 })
  Span('¥')
    .fontColor('#FF888888')
    .fontSize(12)
    .decoration({
      type: TextDecorationType.LineThrough,
      color: '#66000000'
    })
  Span(content)
    .fontColor('#FF888888')
    .fontSize(12)
    .decoration({
      type: TextDecorationType.LineThrough,
      color: '#66000000'
    })
}

@Builder
function buildTag(content: ResourceStr) {
  Text(content)
    .fontSize(8)
    .lineHeight(10)
    .fontWeight(400)
    .halfLeading(true)
    .fontColor('#FFFF2D19')
    .maxLines(1)
    .textOverflow({ overflow: TextOverflow.Ellipsis })
    .padding({ top: 0.5, bottom: 0.5, right: 3.5, left: 3.5 })
    .borderWidth(0.7)
    .borderRadius(2.5)
    .borderColor('#FFFF2D19')
}

@Builder
function buildServiceInfo(items: ProductServiceItem[]) {
  if (items && items.length > 0) {
    Row() {
      Column() {
        ForEach(items, (item: ProductServiceItem) => {
          Row() {
            Image(iResourceMgr.resolveUri(item.icon))
              .width(13)
              .height(13)
              .fillColor($r('sys.color.mask_tertiary'))
              .margin({ right: 5 })
            Text(item.content)
              .fontSize(12)
              .fontColor($r('sys.color.mask_tertiary'))
              .lineHeight(18)
              .halfLeading(true)
          }
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Start)
        })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .padding({ bottom: 6 })
  }
}
