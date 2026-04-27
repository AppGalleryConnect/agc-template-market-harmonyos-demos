import { phoneRouterControl } from 'oh_router'
import { RouterMap, UserInfo } from 'common'
import { PersistenceV2 } from '@kit.ArkUI'
import { LoginPageBuilder } from 'person'
import { ValuationPageBuilder } from './valuation/ValuationPage'
import { ValuationInfoHostPageBuilder } from './valuation/ValuationInfoHostPage'
import { OrderParams } from './valuation/ProductCategoryPage';

@ComponentV2
export struct AppraisalView {
  @Param @Require item: AppraisalItem;
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

  build() {
    Column() {
      Text('看看我的宝贝值多少钱')
        .height(16)
        .fontSize(14)
        .fontColor(Color.Black)
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)
        .margin({
          top: 6,
          left: 12
        })

      // 宝贝描述信息
      Row() {
        Row() {
          // 宝贝图片
          Column() {
            Image(this.item.image)
              .width(36)
              .margin({
                top: 3,
                bottom: 5
              })
          }
          .width(48)
          .height(48)
          .alignItems(HorizontalAlign.Center)
          .margin({
            left: 21,
            top: 16,
            bottom: 16
          })

          // 宝贝名称和价格
          Column() {
            // 宝贝名称
            Text(this.item.name)
              .height(14)
              .fontSize(14)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .fontWeight(FontWeight.Regular)

            // 宝贝预估价格
            Row() {
              Text('预估')
                .height(14)
                .fontSize(12)
                .fontColor('rgba(0, 0, 0, 0.6)')
                .fontWeight(FontWeight.Regular)
                .margin({ right: 4 })
                .textAlign(TextAlign.Center)

              Text('¥')
                .fontSize(12)
                .fontColor('rgba(0, 0, 0, 1)')
                .fontWeight(FontWeight.Regular)
                .margin({ right: 1, top: 2 })

              Text(this.item.appraisalPrice.toString())
                .height(14)
                .fontSize(12)
                .fontColor('rgba(0, 0, 0, 1)')
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Center)
            }
            .margin({
              top: 2
            })
            .alignItems(VerticalAlign.Center)

            // 重新估价按钮
            Row() {
              Text('重新估价')
                .width(60)
                .height(20)
                .fontSize(12)
                .fontColor('rgba(255, 75, 75, 1)')
                .fontWeight(FontWeight.Regular)
                .borderWidth(0.5)
                .borderRadius(11)
                .borderColor('rgba(255, 75, 75, 1)')
                .textAlign(TextAlign.Center)
                .backgroundColor(Color.White)
                .onClick(() => {
                  if (!this.userInfo.isLogin) {
                    phoneRouterControl.jumpPage({
                      pageName: RouterMap.LOGIN_PAGE,
                      builder: wrapBuilder(LoginPageBuilder)
                    })
                    return
                  }
                  const orderParam: OrderParams = { modelName: this.item.name, imageSrc: this.item.image }
                  phoneRouterControl.jumpPage({
                    pageName: RouterMap.VALUATION_INFORMATION_PAGE,
                    builder: wrapBuilder(ValuationInfoHostPageBuilder),
                    param: orderParam
                  })
                })

            }
            .visibility(Visibility.None)
            .margin({
              top: 8
            })
          }
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Center)
          .layoutWeight(1)
          .height('100%')
          .margin({
            left: 8
          })
          .padding({
            top: 11,
            bottom: 11
          })

          // 分割线
          Divider()
            .width(0.5)
            .height(50)
            .backgroundColor('rgba(232, 235, 237, 1)')
            .margin({
              top: 16,
              bottom: 14
            })

          // 商品估价
          Column() {
            Image($r('app.media.ic_appraisal_add'))
              .width(24)
              .height(24)
              .margin({
                top: 19
              })

            Text('商品估价')
              .fontSize(12)
              .fontColor('rgba(0, 0, 0, 1)')
              .fontWeight(FontWeight.Regular)
              .height(14)
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .height('100%')
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            if (!this.userInfo.isLogin) {
              phoneRouterControl.jumpPage({
                pageName: RouterMap.LOGIN_PAGE,
                builder: wrapBuilder(LoginPageBuilder)
              })
              return
            }
            phoneRouterControl.jumpPage({
              pageName: RouterMap.VALUATION_PAGE,
              builder: wrapBuilder(ValuationPageBuilder)
            })
          })

        }
        .margin({
          left: 2,
          right: 2,
          bottom: 2
        })
        .borderRadius(8)
        .backgroundColor(Color.White)
      }
      .layoutWeight(1)
      .width('100%')
      .margin({
        top: 4
      })
    }
    .width('100%')
    .height(108)
    .alignItems(HorizontalAlign.Start)
    .borderRadius(8)
    .linearGradient({
      angle: 90, // 渐变角度（0点方向顺时针）
      colors: [
        ['rgba(255, 214, 214, 1)', 0.0], // 起始颜色及位置
        ['rgba(232, 235, 237, 1)', 1.0]// 结束颜色及位置
      ]
    })
  }
}

export interface AppraisalItem {
  // 宝贝名称
  name: string;

  // 宝贝图片
  image: ResourceStr;

  // 宝贝预估价格
  appraisalPrice: number;
}
