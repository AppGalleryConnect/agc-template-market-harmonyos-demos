import { Constants } from 'common'
import { phoneRouterControl } from 'oh_router'
import { ProductInfo } from '../viewmodel/MainPageVM'
import { ProductDetailPageVM } from '../viewmodel/ProductDetailPageVM'
import { LengthMetrics } from '@kit.ArkUI'

@Builder
export function ProductDetailPageBuilder(info: Object) {
  ProductDetailPage({ item: info as ProductInfo })
}

@ComponentV2
export struct ProductDetailPage {
  private readonly logTag: string = 'ProductDetailPage'
  @Local vm: ProductDetailPageVM = new ProductDetailPageVM()
  @Param @Require item: ProductInfo

  // 配送信息
  @Builder
  buildDeliveryInfo() {
    Column() {
      Column() {
        // 配送
        Row() {
          Text('配送')
            .width(48)
            .height(16)
            .textAlign(TextAlign.Start)
            .fontSize(12)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .fontWeight(FontWeight.Regular)

          Text('包邮，预计3天后送达（11月13日）送至南京市建邺区')
            .height(14)
            .fontSize(10)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .fontWeight(FontWeight.Regular)

        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .margin({
          top: 12,
          left: 13
        })

        // 服务
        Row() {
          Text('服务')
            .width(47)
            .height(16)
            .textAlign(TextAlign.Start)
            .fontSize(12)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .fontWeight(FontWeight.Regular)

          Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap, space: { cross: LengthMetrics.vp(4) } }) {
            ForEach(this.vm.serviceItems, (item: string, index) => {
              Row() {
                Image($r('app.media.ic_selected')).width(8).height(8).margin({ right: 4 })

                Text(item).height(14).fontColor('rgba(0, 0, 0, 0.6)').fontSize(10).textAlign(TextAlign.Center)
              }
              .alignItems(VerticalAlign.Center)
              .margin({ right: 16 })
            }, (item: string, index: number) => JSON.stringify(item) + index)
          }

        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
        .margin({
          top: 12,
          left: 13,
          bottom: 16
        })

      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .borderRadius(4)
      .backgroundColor('rgba(0, 0, 0, 0.05)')

    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 12
    })
  }

  // 商品其他信息
  @Builder
  buildOtherProductInfo() {
    Column() {
      Column() {
        // 商品评价
        Row() {
          Text('99•A').height(21).fontSize(16).fontWeight(FontWeight.Medium).fontColor('rgba(0, 0, 0, 0.9)')
        }
        .justifyContent(FlexAlign.Start)
        .margin({
          left: 12,
          right: 12,
          top: 12
        })

        // 外观信息
        Row() {
          Row() {
            Text('外观').fontSize(7).fontWeight(FontWeight.Regular).fontColor('rgba(0, 0, 0, 0.6)').margin({ left: 3, right: 2 })

            Text('99').fontSize(8).fontWeight(FontWeight.Bold).fontColor('rgba(255, 75, 75, 1)').margin({ right: 3 })
          }
          .width(32)
          .height(10)
          .borderRadius(2)
          .backgroundColor('rgba(255, 214, 214, 1)')
          .margin({
            right: 4
          })

          Text('屏幕外观完好 | 外壳完好')
            .height(14)
            .fontSize(10)
            .fontWeight(FontWeight.Regular)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .textAlign(TextAlign.Center)
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
        .margin({
          left: 12,
          right: 12,
          top: 2
        })

        // 外观信息
        Row() {
          Row() {
            Text('功能').fontSize(7).fontWeight(FontWeight.Regular).fontColor('rgba(0, 0, 0, 0.6)').margin({ left: 3, right: 4 })

            Text('A').fontSize(8).fontWeight(FontWeight.Bold).fontColor('rgba(255, 75, 75, 1)').margin({ right: 3 })
          }
          .width(32)
          .height(10)
          .borderRadius(2)
          .backgroundColor('rgba(255, 214, 214, 1)')
          .margin({
            right: 4
          })

          Text('电池健康度100%')
            .height(14)
            .fontSize(10)
            .fontWeight(FontWeight.Regular)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .textAlign(TextAlign.Center)
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
        .margin({
          left: 12,
          right: 12,
          top: 2
        })

        // 点划线分割线
        Row() {
          Line().layoutWeight(1).margin({ left: 12, right: 12 }).backgroundColor('rgba(0, 0, 0, 0.1)').strokeDashArray([2, 2])
        }
        .width('100%')
        .height(0.5)
        .backgroundColor('rgba(0, 0, 0, 0.05)')
        .margin({
          top: 12
        })

        // 机况
        Row() {
          Text('机况')
            .width(50)
            .height(30)
            .textAlign(TextAlign.Start)
            .fontSize(12)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .fontWeight(FontWeight.Regular)
            .padding({ bottom: 15 })

          // 存储容量
          Column() {
            Text('512G')
              .height(14)
              .textAlign(TextAlign.Start)
              .fontSize(10)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .fontWeight(FontWeight.Regular)

            Text('存储容量')
              .height(14)
              .textAlign(TextAlign.Start)
              .fontSize(10)
              .fontColor('rgba(0, 0, 0, 0.4)')
              .fontWeight(FontWeight.Regular)
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .width(64)

          // 电池健康度
          Column() {
            Text('100%')
              .height(14)
              .textAlign(TextAlign.Start)
              .fontSize(10)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .fontWeight(FontWeight.Regular)

            Text('电池健康度')
              .height(14)
              .textAlign(TextAlign.Start)
              .fontSize(10)
              .fontColor('rgba(0, 0, 0, 0.4)')
              .fontWeight(FontWeight.Regular)
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .width(74)

          // 保修情况
          Column() {
            Text('过保大于30天')
              .height(14)
              .textAlign(TextAlign.Start)
              .fontSize(10)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .fontWeight(FontWeight.Regular)

            Text('保修情况')
              .height(14)
              .textAlign(TextAlign.Start)
              .fontSize(10)
              .fontColor('rgba(0, 0, 0, 0.4)')
              .fontWeight(FontWeight.Regular)
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)

        }
        .width('100%')
        .margin({
          top: 11,
          left: 13
        })

        // 参数
        Row() {
          Text('参数')
            .width(50)
            .height(30)
            .textAlign(TextAlign.Start)
            .fontSize(12)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .fontWeight(FontWeight.Regular)
            .padding({ bottom: 15 })

          // 双卡双待
          Column() {
            Text('双卡双待')
              .height(14)
              .textAlign(TextAlign.Start)
              .fontSize(10)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .fontWeight(FontWeight.Regular)

            Text('SIM卡')
              .height(14)
              .textAlign(TextAlign.Start)
              .fontSize(10)
              .fontColor('rgba(0, 0, 0, 0.4)')
              .fontWeight(FontWeight.Regular)
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .width(64)

          // 电池健康度
          Column() {
            Text('全网通')
              .height(14)
              .textAlign(TextAlign.Start)
              .fontSize(10)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .fontWeight(FontWeight.Regular)

            Text('网络制式')
              .height(14)
              .textAlign(TextAlign.Start)
              .fontSize(10)
              .fontColor('rgba(0, 0, 0, 0.4)')
              .fontWeight(FontWeight.Regular)
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .width(74)

          // 保修情况
          Column() {
            Text('移动5G联通5G电信5G')
              .height(14)
              .textAlign(TextAlign.Start)
              .fontSize(10)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .fontWeight(FontWeight.Regular)

            Text('网络类型')
              .height(14)
              .textAlign(TextAlign.Start)
              .fontSize(10)
              .fontColor('rgba(0, 0, 0, 0.4)')
              .fontWeight(FontWeight.Regular)
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)

        }
        .width('100%')
        .margin({
          top: 12,
          left: 13,
          bottom: 16
        })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .borderRadius(4)
      .backgroundColor('rgba(0, 0, 0, 0.05)')
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 16
    })

  }

  // 详情内容
  @Builder
  buildContent() {
    Column() {
      // 商品名称
      Text(this.item.name)
        .height(19)
        .textAlign(TextAlign.Center)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('rgba(0, 0, 0, 0.9)')
        .margin({
          left: 16,
          right: 14,
          top: 16
        })

      // 好评率
      Text(this.item.evaluateDes)
        .fontWeight(FontWeight.Regular)
        .fontColor('rgba(8, 48, 45, 0.6)')
        .fontSize(8)
        .backgroundColor('rgba(232, 252, 251, 1)')
        .borderRadius(2)
        .padding({
          left: 3,
          right: 4,
          top: 2,
          bottom: 2
        })
        .margin({
          top: 4,
          left: 16
        })

      // 价格描述
      Row() {
        Text('¥')
          .fontSize(14)
          .fontColor('rgba(255, 75, 75, 1)')
          .fontWeight(FontWeight.Regular)
          .margin({
            top: 4,
            left: 16
          })

        Text(this.item.price.toString())
          .height('100%')
          .fontSize(20)
          .fontColor('rgba(255, 75, 75, 1)')
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .margin({
            left: 1
          })
      }
      .height(26)
      .margin({
        top: 4
      })

      // 商品其他信息
      this.buildOtherProductInfo()

      // 配送信息
      this.buildDeliveryInfo()

      Column().layoutWeight(1)

      // 购买布局
      this.buildBuyLayout()
    }
    .width('100%')
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  // 购买布局
  @Builder
  buildBuyLayout() {
    Row() {
      // 加购物车
      Column() {
        Image($r('app.media.ic_shopping_cart'))
          .width(24)
          .height(24)

        Text('加购物车')
          .height(14)
          .fontSize(10)
          .fontColor('rgba(0, 0, 0, 0.6)')
          .fontWeight(FontWeight.Regular)
          .margin({
            top: 2
          })
      }
      .width(44)
      .height(48)
      .alignItems(HorizontalAlign.Center)
      .padding({
        top: 3,
        bottom: 5
      })

      // 收藏
      Column() {
        Image($r('app.media.ic_like'))
          .width(24)
          .height(24)

        Text('收藏')
          .height(14)
          .fontSize(10)
          .fontColor('rgba(0, 0, 0, 0.6)')
          .fontWeight(FontWeight.Regular)
          .margin({
            top: 2
          })
      }
      .width(44)
      .height(48)
      .alignItems(HorizontalAlign.Center)
      .padding({
        top: 3,
        bottom: 5
      })
      .margin({ left: 16 })

      // 以旧换新 和 领劵购买
      Row() {
        // 以旧换新
        Text('以旧换新')
          .height(40)
          .layoutWeight(1)
          .margin({ right: 8 })
          .borderRadius(22)
          .borderWidth(1)
          .borderColor('rgba(255, 75, 75, 1)')
          .textAlign(TextAlign.Center)
          .fontColor('rgba(255, 75, 75, 1)')
          .fontSize(16)

        // 领劵购买
        Text('领劵购买')
          .height(40)
          .layoutWeight(1)
          .borderRadius(22)
          .backgroundColor('rgba(255, 75, 75, 1)')
          .textAlign(TextAlign.Center)
          .fontColor('rgba(255, 255, 255, 1)')
          .fontSize(16)
      }
      .layoutWeight(1)
      .height(58)
      .padding({
        top: 2,
        bottom: 6
      })
      .margin({ left: 16 })
    }
    .width('100%')
    .height(58)
    .padding({
      left: 16,
      right: 16,
      bottom: 10
    })
  }

  // 轮播图布局
  @Builder
  buildImagesLayout() {
    RelativeContainer() {
      // 轮播页
      Column() {
        Swiper(this.vm.swiperController) {
          ForEach(this.item.imagesList, (item: ResourceStr) => {
            Image(item)
              .width('100%')
              .height('100%')
          }, (item: ResourceStr) => JSON.stringify(item))
        }
        .loop(true)
        .indicator(true)
        .width('100%')
        .layoutWeight(1)
        .onChange((index: number) => {
          this.vm.selectedImageIndex = index;
        })
      }
      .width('100%')
      .height(320)

      // 返回按钮
      Image($r('app.media.back'))
        .width(40)
        .height(40)
        .alignRules({
          left: { align: HorizontalAlign.Start, anchor: '__container__' },
          top: { align: VerticalAlign.Top, anchor: '__container__' }
        })
        .margin({
          left: 16,
          top: Constants.PADDING_7XL
        })
        .onClick(() => {
          phoneRouterControl.popPage()
        })
    }
    .width('100%')
    .height(320)

  }

  @Builder
  render() {
    Scroll() {
      Column() {
        // 轮播图
        this.buildImagesLayout()

        // 详情内容
        this.buildContent()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('rgba(255, 255, 255, 1)')
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)

  }

  build() {
    NavDestination() {
      Column() {
        this.render()
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
  }
}