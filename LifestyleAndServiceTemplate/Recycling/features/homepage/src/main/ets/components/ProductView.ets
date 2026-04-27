import { RouterMap, UserInfo } from 'common';
import { NavPageInfo, phoneRouterControl } from 'oh_router';
import { LoginPageBuilder } from 'person';
import { ProductInfo } from '../viewmodel/MainPageVM';
import { OrderSubmitPageBuilder } from './valuation/OrderSubmitPage';
import { OrderParams, SubmitData, ValuationInfoParam } from './valuation/ProductCategoryPage';
import { ValuationInfoHostPageBuilder } from './valuation/ValuationInfoHostPage';
import { PersistenceV2 } from '@kit.ArkUI';

@ComponentV2
export struct ProductView {
  private logTag: string = 'ProductView'
  @Param @Require product: ProductInfo;
  // 图片正方形，宽高一致
  @Local imageWidthAndHeight: number = 150
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

  // 图片区域
  @Builder
  buildImage() {
    Column() {
      Image(this.product.image)
        .width(this.imageWidthAndHeight)
        .height(this.product.priceDes !== '' ? this.imageWidthAndHeight - 24 : this.imageWidthAndHeight)
        .borderRadius({
          topLeft: 8,
          topRight: 8,
          bottomLeft: this.product.priceDes !== '' ? 0 : 8,
          bottomRight: this.product.priceDes !== '' ? 0 : 8
        })
        .borderWidth({
          left: this.product.priceDes !== '' ? 2 : 0,
          right: this.product.priceDes !== '' ? 2 : 0,
          top: this.product.priceDes !== '' ? 2 : 0
        })
        .borderColor('rgba(255, 75, 75, 1)')

      if (this.product.priceDes !== '') {
        Row() {
          Row() {
            Text(this.product.priceDes)
              .fontSize(14)
              .fontColor(Color.White)

            Text('折后')
              .fontSize(8)
              .fontColor(Color.White)
              .margin({
                top: 2,
                left: 2
              })
          }
          .height('100%')
          .alignItems(VerticalAlign.Center)
          .margin({
            left: 9
          })

          Blank().layoutWeight(1)

          Text(this.product.discountDes)
            .fontSize(10)
            .fontColor(Color.White)
            .margin({
              right: 8
            })

        }
        .width(this.imageWidthAndHeight)
        .height(24)
        .alignItems(VerticalAlign.Center)
        .borderRadius({
          bottomLeft: 8,
          bottomRight: 8
        })
        .linearGradient({
          angle: 90, // 渐变角度（0点方向顺时针）
          colors: [
            ['rgba(255, 75, 75, 1)', 0.0], // 起始颜色及位置
            ['rgba(255, 119, 153, 1)', 1.0]// 结束颜色及位置
          ]
        })
      }

    }
    .width(this.imageWidthAndHeight)
    .height(this.imageWidthAndHeight)
    .borderRadius(8)
  }

  // 描述区域
  @Builder
  buildDescription() {
    Column() {
      // 价格描述
      RelativeContainer() {
        Image($r('app.media.ic_new_99'))
          .width(18)
          .height(10)
          .alignRules({
            top: { anchor: '__container__', align: VerticalAlign.Top },
            left: { anchor: '__container__', align: HorizontalAlign.Start }
          })
          .margin({ top: 2 })

        Text(this.product.name)
          .fontSize(14)
          .fontColor('rgba(0, 0, 0, 0.85)')
          .fontWeight(FontWeight.Regular)
          .textIndent(24)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

      }
      .width(this.imageWidthAndHeight)
      .height(32)

      // 价格描述
      Row() {
        Text('最高可卖')
          .fontColor('rgba(0, 0, 0, 0.85)')
          .fontSize(10)
          .fontWeight(FontWeight.Regular)
          .margin({ top: 4, right: 4 })

        Text('¥')
          .fontSize(10)
          .fontColor('rgba(0, 0, 0, 0.85)')
          .fontWeight(FontWeight.Regular)
          .margin({
            top: 4
          })

        Text(this.product.price.toString())
          .height('100%')
          .fontSize(16)
          .fontColor('rgba(0, 0, 0, 0.85)')
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .margin({
            left: 1
          })
      }
      .height(19)
      .margin({
        top: 8
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({
      top: 6
    })
    .onAreaChange((oldArea, newArea) => {
      this.imageWidthAndHeight = parseInt(newArea.width.toString())
    })
  }

  build() {
    Column() {
      // 图片区域
      this.buildImage()

      // 描述区域
      this.buildDescription()
    }
    .width('100%')
    .margin({ bottom: 12 })
    .onClick(() => {
      if (!this.userInfo.isLogin) {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.LOGIN_PAGE,
          builder: wrapBuilder(LoginPageBuilder)
        })
        return
      }
      const dev: string = this.product.labels === '手机' ? 'phone' : 'computer'
      const params: ValuationInfoParam = {
        modelName: this.product.name,
        imageSrc: this.product.image,
        deviceType: dev,
        onBack: () => phoneRouterControl.popPage(),
        onSubmit: (data: SubmitData) => {
          const orderParam: OrderParams = {
            modelName: data.modelName,
            imageSrc: data.imageSrc,
            deviceType: data.deviceType,
            price: data.price,
            selections: data.selections
          }
          const orderPage: NavPageInfo = {
            pageName: RouterMap.VALUATION_ORDER_PAGE,
            builder: wrapBuilder(OrderSubmitPageBuilder),
            param: orderParam
          }
          phoneRouterControl.jumpPage(orderPage)
        }
      }
      const pageInfo: NavPageInfo = {
        pageName: RouterMap.VALUATION_INFORMATION_PAGE,
        builder: wrapBuilder(ValuationInfoHostPageBuilder),
        param: params
      }
      phoneRouterControl.jumpPage(pageInfo)
    })
  }
}