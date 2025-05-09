import { OrderSkuDto, PreOrderRequest } from '@common/customtypes';
import { iResourceMgr } from '@common/resource';
import { TitleBar } from '@components/titlebar';
import { OrderSubmitPageLogic } from '../logic/OrderSubmitPageLogic';

@ComponentV2
export struct OrderSubmitPage {

  @Param
  public preOrderRequest: PreOrderRequest | null = null;

  private logic: OrderSubmitPageLogic = new OrderSubmitPageLogic();

  aboutToAppear(): void {
    this.logic.init(this.preOrderRequest);
  }

  build(): void {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Column()
          .width('100%')
          .height('40%')
          .linearGradient({
            colors: [['#FFE64566', 0.3], ['#00E67C92', 1.0]]
          })
          .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP])
        Column() {
          TitleBar()
          if (this.logic.isLoading) {
            Column() {
              LoadingProgress()
                .width(37)
                .height(37)
                .offset({ y: -50 })
            }
            .width('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
          } else {
            Stack({ alignContent: Alignment.BottomStart }) {
              Scroll() {
                Column() {
                  Text('确认订单')
                    .fontColor(Color.White)
                    .fontSize(24)
                    .fontWeight(500)
                    .margin({ left: 11 })
                  buildAddressSelector(this.logic)
                  buildOrderInfo(this.logic)
                }
                .width('100%')
                .constraintSize({ minHeight: '100%' })
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.Start)
                .padding({ left: 13, right: 13 })
              }
              .height('100%')
              .padding({ bottom: 80 })
              Row() {
                Text() {
                  Span('¥')
                    .fontSize(15)
                    .fontColor('#FFE84026')
                    .fontWeight(500)
                  Span(this.logic.totalPrice.toString())
                    .fontSize(24)
                    .fontWeight(500)
                    .fontColor('#FFE84026')
                }
                .layoutWeight(1)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.MARQUEE })
                .textAlign(TextAlign.Start)
                Button() {
                  Text('提交订单')
                    .fontSize(13)
                    .fontColor(Color.White)
                    .fontWeight(500)
                }
                .width(95)
                .height(37)
                .type(ButtonType.Normal)
                .backgroundColor('#FFE64566')
                .borderRadius(21)
                .onClick(() => this.logic.onSubmit())
              }
              .width('100%')
              .height(52)
              .backgroundColor(Color.White)
              .justifyContent(FlexAlign.SpaceBetween)
              .padding({ left: 16, right: 16 })
            }
            .width('100%')
            .layoutWeight(1)
          }
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFF1F3F5')
    }
    .hideTitleBar(true)
    .backgroundColor(Color.White)
  }
}

@Builder
export function buildOrderSubmitPage(_: string, preOrderRequest: PreOrderRequest) {
  OrderSubmitPage({ preOrderRequest: preOrderRequest })
}

@Builder
function buildOrderInfo(logic: OrderSubmitPageLogic) {
  Column() {
    Column() {
      ForEach(logic.skuList, (item: OrderSkuDto) => {
        buildSkuCard(item)
      })
    }
    .width('100%')
    Row() {
      Text('配送服务')
        .fontColor($r('sys.color.mask_secondary'))
        .fontSize(13)
      Text('快递发货')
        .fontColor('#E6000000')
        .fontSize(13)
        .fontWeight(600)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height(50)
    Row() {
      Text('订单总金额')
        .fontColor($r('sys.color.mask_secondary'))
        .fontSize(13)
      Text('¥' + logic.totalPrice)
        .fontColor('#E6000000')
        .fontSize(13)
        .fontWeight(600)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height(46)
    Row() {
      Text('备注')
        .fontColor($r('sys.color.mask_secondary'))
        .fontSize(13)
        .margin({ right: 10 })
      TextInput({
        placeholder: '选填，建议先与商家沟通后再填写'
      })
        .padding(0)
        .borderRadius(0)
        .placeholderColor($r('sys.color.mask_tertiary'))
        .placeholderFont({ size: 13 })
        .fontColor($r('sys.color.mask_secondary'))
        .fontSize(13)
        .textAlign(TextAlign.End)
        .maxLines(1)
        .layoutWeight(1)
        .backgroundColor(Color.Transparent)
        .caretStyle({ color: '#FFE64566' })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height(46)
  }
  .width('100%')
  .padding({ left: 13, right: 13 })
  .borderRadius(13)
  .backgroundColor(Color.White)
  .margin({ top: 20 })
}

@Builder
function buildSkuCard(sku: OrderSkuDto) {
  Row() {
    Image(iResourceMgr.resolveUri(sku.banner))
      .width(80)
      .height(80)
      .draggable(false)
      .objectFit(ImageFit.Cover)
      .borderRadius(7)
      .margin({ right: 10 })
      .backgroundColor('#90E5E7E9')
    Column() {
      Column() {
        Row() {
          Text(sku.title)
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontSize(14)
            .fontColor($r('sys.color.mask_secondary'))
            .fontWeight(500)
          Text() {
            Span('¥')
              .fontSize(12)
            Span(sku.price.toString())
              .fontSize(16)
          }
          .fontColor('#FFE84026')
          .fontWeight(500)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        Text('规格：' + sku.skuDesc)
          .fontColor($r('sys.color.mask_tertiary'))
          .fontSize(12)
          .margin({ top: 3 })
        Text('数量：' + sku.count)
          .fontColor($r('sys.color.mask_tertiary'))
          .fontSize(12)
          .margin({ top: 3 })
      }
      .alignItems(HorizontalAlign.Start)
      Text(sku.serviceDesc)
        .fontColor($r('sys.color.mask_tertiary'))
        .fontSize(10)
    }
    .height(80)
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.SpaceBetween)
  }
  .width('100%')
  .margin({ top: 13 })
}

@Builder
function buildAddressSelector(logic: OrderSubmitPageLogic) {
  Row() {
    Image($r('app.media.ic_address'))
      .width(25)
      .height(25)
      .draggable(false)
      .margin({ right: 10 })
    Row() {
      Column() {
        Text(logic.addressDesc)
          .fontColor('#E6000000')
          .fontSize(16)
          .fontWeight(500)
        Text(logic.nickname + ' ' + logic.phone)
          .fontColor($r('sys.color.mask_tertiary'))
          .fontSize(12)
          .margin({ top: 10 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Image($r('app.media.ic_left_arrow'))
        .height(16)
        .objectFit(ImageFit.Contain)
        .rotate({ angle: 180 })
        .fillColor($r('sys.color.mask_tertiary'))
        .draggable(false)
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.SpaceBetween)
  }
  .width('100%')
  .borderRadius(13)
  .backgroundColor(Color.White)
  .justifyContent(FlexAlign.Start)
  .margin({ top: 20 })
  .padding({ left: 10, right: 10, top: 15, bottom: 15 })
}