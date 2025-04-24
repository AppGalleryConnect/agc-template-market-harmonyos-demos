import { PackageCardModel } from '../model/packageModel'
import { PackageVM } from '../model/PackageVM'
import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib'

@ComponentV2
export struct PackagesCardView {
  packageVM: PackageVM = PackageVM.instance;
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  @Param card: PackageCardModel  = new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '001'
  );

  build() {
    Row() {
      Image(this.card.coverImg)
        .width(96)
        .height(96)
        .borderRadius(8)

      Column() {
        Text(this.card.packageContent)
          .width(CommonConstants.FULL_WIDTH)
          .fontSize(14)
          .fontColor('#000')
          .lineHeight(19)

        Text(this.card.introduction)
          .width(CommonConstants.FULL_WIDTH)
          .fontSize(12)
          .fontColor('#000')
          .lineHeight(16)
          .margin({
            top:2
          })

        Text() {
          Span(`${this.card.buyTimes}`)
          Span($r('app.string.buy_peoples'))
        }
          .width(CommonConstants.FULL_WIDTH)
          .fontSize(12)
          .fontColor('#999')
          .lineHeight(16)
          .margin({
            top:2
          })

        Row() {
          Row() {
            Text(`￥${this.card.discountedPrice}`)
              .fontSize(16)
              .fontColor('#EE3B55')

            Text(`￥${this.card.markedPrice}`)
              .fontSize(12)
              .fontColor('#999')
              .decoration({
                type:TextDecorationType.LineThrough
              })
          }
          .margin({
            top:8
          })
          .alignItems(VerticalAlign.Bottom)

          Button($r('app.string.detail'))
            .height(28)
            .width(72)
            .fontSize(12)
            .backgroundColor('#EE3B55')
            .padding(8)
        }
        .width(CommonConstants.FULL_WIDTH)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        .margin({
          top:6
        })

        Blank()
        Divider()

      }
      .height(CommonConstants.FULL_HEIGHT)
      .layoutWeight(1)
      .margin({
        left:10
      })
    }
    .height(96)
    .width(CommonConstants.FULL_WIDTH)
    .alignItems(VerticalAlign.Top)
    .onClick(() => {
      this.packageVM.updatePackageSelect(this.card)
      this.appPathStack.pushPathByName('packageDetail', true)
    })
  }
}