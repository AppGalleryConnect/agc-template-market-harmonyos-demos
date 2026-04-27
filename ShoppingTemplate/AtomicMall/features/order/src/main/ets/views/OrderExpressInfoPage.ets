import { MapComponent } from '@kit.MapKit';
import { routerStack, TelUtil } from 'lib_foundation';
import { LogisticsItem, LogisticsItemDetail, OrderItem } from 'lib_network';
import { TextSegment } from '../common/Types';
import { OrderUtil } from '../utils/OrderUtil';
import { OrderExpressInfoVM } from '../viewmodels/OrderExpressInfoVM';

@Builder
export function buildOrderExpressInfoPage() {
  OrderExpressInfoPage()
}

@ComponentV2
export struct OrderExpressInfoPage {
  @Local
  showExpress: boolean = true
  vm: OrderExpressInfoVM = new OrderExpressInfoVM(this.getUIContext())

  aboutToAppear(): void {
    this.vm.initMap(
      () => {
        this.buildCustomInfoWindow('发', this.vm.expressInfo!.sendPosition)
      },
      () => {
        this.buildCustomInfoWindow('收', this.vm.expressInfo!.getPosition)
      },
    )
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        MapComponent({
          mapOptions: this.vm.mapOptions,
          mapCallback: this.vm.callback,
        })
          .width('100%')
          .height('100%')
          .backgroundColor($r('app.color.background_color_grey'))
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }
      .bindSheet($$this.showExpress, this.buildLogisticInfoSheet(), {
        preferType: SheetType.BOTTOM,
        showClose: false,
        dragBar: false,
        scrollSizeMode: ScrollSizeMode.CONTINUOUS,
        enableOutsideInteractive: true,
        backgroundColor: $r('app.color.background_color_transparent'),
        detents: [SheetSize.MEDIUM, SheetSize.LARGE],
        onWillDismiss: (action) => {
          if (action.reason === DismissReason.PRESS_BACK) {
            routerStack.pop()
          }
        },
      })
    }
    .onReady((context) => {
      const param = context.pathInfo.param as OrderItem | undefined
      if (param) {
        this.vm.initData(param)
      }
    })
    .onShown(() => {
      if (this.vm.mapController) {
        this.vm.mapController.show();
      }
      this.showExpress = true
    })
    .onHidden(() => {
      if (this.vm.mapController) {
        this.vm.mapController.hide();
      }
      this.showExpress = false
    })
    .title('物流详情')

  }

  @Builder
  buildLogisticInfoSheet() {
    Column() {
      if (this.vm.expressInfo) {
        if (this.vm.courierInfo) {
          Row() {
            Image($r('app.media.ic_courier'))
              .width(48)
              .height(48)
              .margin({ right: $r('app.float.space_s') })

            Column({ space: 4 }) {
              Text(this.vm.courierInfo.name)
                .fontSize(14)
                .fontColor($r('app.color.font_color_level1'))
              Text(this.vm.expressInfo.expressName)
                .fontSize(12)
                .fontColor($r('app.color.font_color_level2'))
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Image($r('app.media.ic_express_phone'))
              .width(32)
              .height(32)
              .onClick(() => {
                TelUtil.callPhone(this.vm.courierInfo!.contactPhone)
              })

          }
          .padding($r('app.float.space_l'))
          .backgroundColor($r('app.color.background_color_primary'))
          .borderRadius($r('app.float.border_radius_l'))
          .margin($r('app.float.space_l'))
        }

        Column() {
          Row() {
            Text(this.vm.expressInfo.expressName + ' ' + this.vm.expressInfo.expressNo)
              .fontSize(14)
              .fontColor($r('app.color.font_color_level1'))
              .margin({
                top: 12,
                bottom: 16,
              })
            Text('复制')
              .fontSize($r('app.float.font_size_12'))
              .borderWidth(1)
              .borderColor($r('app.color.theme_color'))
              .fontColor($r('app.color.theme_color'))
              .borderRadius($r('app.float.border_radius_capsule'))
              .padding({
                left: 12,
                right: 12,
                top: 6,
                bottom: 6,
              })
              .backgroundColor($r('app.color.background_color_primary'))
              .onClick(() => {
                OrderUtil.copyOrderNumber(this.vm.expressInfo!.expressNo)
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          if (this.vm.orderItem?.logisticInfo) {
            ForEach(this.vm.orderItem.logisticInfo, (node: LogisticsItem, index: number) => {
              Column() {
                Row({ space: 8 }) {
                  Circle()
                    .width(12)
                    .height(12)
                    .fill(index === 0 ? $r('app.color.theme_color') : $r('app.color.background_color_primary'))
                    .stroke(index === 0 ? $r('app.color.theme_color') : $r('sys.color.comp_divider'))
                  Row() {
                    Text(OrderUtil.getLogisticStatusLabel(node.status))
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(index === 0 ? $r('app.color.theme_color') : $r('sys.color.font_primary'))
                      .margin({ right: 12 })
                    Text(OrderUtil.getLogisticStatusTime(node))
                      .fontSize(10)
                      .fontWeight(FontWeight.Regular)
                      .fontColor(index === 0 ? $r('app.color.theme_color') : $r('app.color.font_color_level3'))
                  }
                  .layoutWeight(1)
                  .margin({ bottom: $r('app.float.space_xs') })
                }

                Row() {
                  Column() {
                    ForEach(node.details, (detail: LogisticsItemDetail, index: number) => {
                      if (index !== 0) {
                        Text(detail.time)
                          .fontSize(10)
                          .fontColor($r('app.color.font_color_level3'))
                      }

                      Text() {
                        ForEach(this.vm.splitTextByPhone(detail.desc), (item: TextSegment) => {
                          Span(item.text)
                            .fontColor(item.isPhone ? $r('sys.color.font_emphasize') :
                              $r('app.color.font_color_level2'))
                            .decoration({
                              type: item.isPhone ? TextDecorationType.Underline : TextDecorationType.None,
                              color: item.isPhone ? $r('sys.color.font_emphasize') : $r('app.color.font_color_level2'),
                            })
                            .onClick(() => {
                              if (item.isPhone) {
                                TelUtil.callPhone(item.text)
                              }
                            });
                        }, (_item: TextSegment, index) => index.toString());
                      }
                      .fontSize(10)
                      .margin({ bottom: $r('app.float.space_m') })
                    }, (detail: LogisticsItemDetail, index: number) => index + detail.desc)
                  }
                  .border({
                    style: {
                      left: BorderStyle.Dashed,
                    },
                    width: {
                      left: index < node.details.length - 1 ? 1 : 0,
                    },
                    color: $r('app.color.font_color_level3'),
                  })
                  .padding({ left: 12, bottom: 4 })
                  .alignItems(HorizontalAlign.Start)
                }
                .padding({ left: 6 })
                .width($r('app.string.size_percent_full'))
                .justifyContent(FlexAlign.Start)
              }
            }, (node: LogisticsItem) => node.status + JSON.stringify(node.details))
          }
        }
        .layoutWeight(1)
        .padding($r('app.float.space_l'))
        .backgroundColor($r('app.color.background_color_primary'))
        .borderRadius({
          topLeft: 32,
          topRight: 32,
        })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
    }
    .margin({ top: 56 })
  }

  @Builder
  buildCustomInfoWindow(title: string, name: string) {
    Row() {
      Row() {
        Text(title)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.font_color_level1_invert'))
      }
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.White)
      .height('100%')
      .width(24)
      .backgroundColor($r('app.color.theme_color'))

      Row() {
        Text(name)
          .fontSize(14)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'))
      }
      .width(56)
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.background_color_grey'))
    }
    .width(80)
    .height(32)
    .borderRadius(8)
    .clip(true)
  }
}