import { iResourceMgr } from '@common/resource';
import { ComponentEntry } from '@common/customtypes';
import { IGrid } from '@components/igrid';

import { SkuSelectorLogic } from '../logic/SkuSelectorLogic';
import { SpecItemVM } from '../viewmodel/SpecItemVM';

@Builder
export function buildSkuSelector(logic: SkuSelectorLogic) {
  Column() {
    Column()
      .width('100%')
      .layoutWeight(1)
      .onClick(logic.onBack)
    Column() {
      Column() {
        buildSkuInfo(logic)
      }
      .width('100%')
      .padding(13)
      buildSpecInfo(logic)
      Row() {
        if (logic.isOutOfStock) {
          Button() {
            Text('暂时缺货')
              .fontSize(13)
              .fontColor(Color.White)
          }
          .width('100%')
          .height(40)
          .type(ButtonType.Normal)
          .backgroundColor($r('sys.color.mask_tertiary'))
          .borderRadius(21)
          .onClick(() => logic.onAgree())
        } else {
          // LoginButton() {
          //   Button() {
          //     Text('确定')
          //       .fontSize(13)
          //       .fontColor(Color.White)
          //   }
          //   .width('100%')
          //   .height(40)
          //   .type(ButtonType.Normal)
          //   .backgroundColor('#FFE64566')
          //   .borderRadius(21)
          //   //.onClick(() => logic.onAgree())
          // }
          Button() {
            Text('确定')
              .fontSize(13)
              .fontColor(Color.White)
          }
          .width('100%')
          .height(40)
          .type(ButtonType.Normal)
          .backgroundColor('#FFE64566')
          .borderRadius(21)
          .onClick(() => logic.onAgree())
        }
      }
      .padding(13)
      Image($r('app.media.ic_close'))
        .width(24)
        .height(24)
        .draggable(false)
        .fillColor($r('sys.color.mask_secondary'))
        .position({ right: 12, top: 12 })
        .responseRegion({
          x: -12,
          y: -12,
          width: 48,
          height: 48
        })
        .onClick(logic.onBack)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM])
    .borderRadius({ topLeft: 24, topRight: 24 })
    .clip(true)
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.End)
}

@Builder
function buildTest() {
  Column() {
    Text('Hello World')
  }
  .height('100%')
  .width('100%')
  .alignItems(HorizontalAlign.Center)
  .justifyContent(FlexAlign.Center)
}

@Builder
function buildSkuInfo(logic: SkuSelectorLogic) {
  RelativeContainer() {
    Image(iResourceMgr.resolveUri(logic.banner))
      .width(100)
      .height(100)
      .draggable(false)
      .objectFit(ImageFit.Cover)
      .borderRadius(8)
      .alignRules({
        left: { anchor: '__container__', align: HorizontalAlign.Start }
      })
      .id(logic.BANNER_COMP_ID)
      .backgroundColor('#90E5E7E9')
    Column() {
      Text(logic.info.services[0])
        .fontColor($r('sys.color.mask_tertiary'))
        .fontSize(12)
      Text(logic.info.services[1])
        .fontColor($r('sys.color.mask_tertiary'))
        .fontSize(12)
        .margin({ top: 6 })
    }
    .alignRules({
      left: { anchor: logic.BANNER_COMP_ID, align: HorizontalAlign.End },
      right: { anchor: '__container__', align: HorizontalAlign.End },
      bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
    })
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 13 })
    .id(logic.SERVICE_INFO_COMP_ID)
    Column() {
      Text() {
        Span(logic.priceRemark + ' ')
          .fontSize(12)
        Span('¥')
          .fontSize(12)
        Span(logic.price)
          .fontSize(24)
          .fontWeight(500)
        if (logic.skuCode === null) {
          Span(' 起')
            .fontSize(12)
        }
      }
      .width('100%')
      .fontColor('#FFE84026')
      Text() {
        if (logic.skuCode !== null) {
          Span('¥' + logic.dashPrice)
            .decoration({ type: TextDecorationType.LineThrough })
        } else {
          Span('价格范围 ')
          Span('¥' + logic.priceRange)
        }
      }
      .width('100%')
      .fontSize(11)
      .margin({ top: 2 })
      .fontColor('#E6000000')
    }
    .alignRules({
      left: { anchor: logic.BANNER_COMP_ID, align: HorizontalAlign.End },
      right: { anchor: '__container__', align: HorizontalAlign.End },
      top: { anchor: '__container__', align: VerticalAlign.Top },
      bottom: { anchor: logic.SERVICE_INFO_COMP_ID, align: VerticalAlign.Top }
    })
    .padding({ left: 13 })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }
  .width('100%')
  .height(100)
}

@Builder
function buildSpecInfo(logic: SkuSelectorLogic) {
  Scroll() {
    Column() {
      Column() {
        ForEach(logic.specViewData, (item: [string, SpecItemVM[]], index: number) => {
          Text(item[0])
            .fontSize(13)
            .fontColor('#E6000000')
            .fontWeight(500)
            .margin(index === 0 ? { top: 3 } : { top: 16 })
          IGrid({
            gapX: 13,
            gapY: 13,
            viewData: [
              ...item[1].flatMap(vm => new ComponentEntry(wrapBuilder(buildSpecTag), [logic, vm]))
            ]
          })
            .width('100%')
            .height('auto')
            .margin({ top: 15 })
        })
        Row() {
          Text('数量')
            .fontSize(13)
            .fontColor('#E6000000')
            .fontWeight(500)
          Row() {
            Row() {
              Image($r('app.media.ic_minus'))
                .width(13)
                .objectFit(ImageFit.Contain)
                .fillColor(logic.count <= 1 ? '#FFCACFD7' : '#E6000000')
            }
            .width(30)
            .height(25)
            .justifyContent(FlexAlign.Center)
            .onClick(() => logic.onCountChange(-1))
            Row() {
              Text(logic.count.toString())
                .fontSize(13)
                .fontWeight(500)
                .fontColor(Color.Black)
                .backgroundColor('#00FFFFFF')
            }
            .width(35)
            .height(25)
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Center)
            // TextInput({ text: '1' })
            //   .width(30)
            //   .height(25)
            //   .borderRadius(0)
            //   .type(InputType.Number)
            //   .fontSize(13)
            //   .fontWeight(500)
            //   .fontColor(Color.Black)
            //   .textAlign(TextAlign.Center)
            //   .padding(0)
            //   .backgroundColor('#00FFFFFF')
            Row() {
              Image($r('app.media.ic_plus'))
                .width(13)
                .height(25)
                .objectFit(ImageFit.Contain)
                .fillColor(
                  logic.skuCode !== null &&
                  logic.count < logic.skuStock
                  ? '#E6000000' : '#FFCACFD7'
                )
                .onClick(() => logic.onCountChange(1))
            }
            .width(30)
            .justifyContent(FlexAlign.Center)
          }
          .backgroundColor('#FFF6F6F6')
          .borderRadius(5)
          .margin({ right: 10 })
        }
        .width('100%')
        .margin({ top: 40 })
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 45 })
    }
    .width('100%')
    .constraintSize({ minHeight: '35%' })
    .padding(13)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }
  .width('100%')
  .constraintSize({ maxHeight: '60%' })
  .scrollBar(BarState.Auto)
}

@Builder
function buildSpecTag(logic: SkuSelectorLogic, vm: SpecItemVM) {
  Stack({ alignContent: Alignment.TopStart }) {
    if (vm.type === 'image_text') {
      Image(iResourceMgr.resolveUri(vm.image))
        .width(30)
        .height(30)
        .objectFit(ImageFit.Cover)
        .draggable(false)
        .backgroundColor('#90E5E7E9')
    }
    Text() {
      Span(vm.text)
        .fontColor(vm.isSelected ? '#FFE64566' : '#C0000000')
        .fontSize(13)
      if (vm.isSelectable && !vm.isInStock) {
        Span('(缺货)')
          .fontColor('#60000000')
          .fontSize(13)
      }
      ImageSpan('')
        .width(8)
    }
    .height(30)
    .padding(vm.type === 'image_text' ? { left: 37 } : { left: 7 })
    .lineHeight(30)
    .halfLeading(true)
    .maxLines(1)
    .textOverflow({ overflow: TextOverflow.Ellipsis })
    .clip(true)
  }
  .borderWidth(0.7)
  .borderRadius(5)
  .borderColor(vm.isSelected ? '#FFE64566' : '#FFD9D9D9')
  .clip(true)
  .backgroundColor(vm.isSelected ? '#1AE64566' : '#FFFFFFFF')
  .onClick(() => logic.onSpecItemClick(vm))
  .opacity(vm.isSelectable ? 1.0 : 0.4)
}
