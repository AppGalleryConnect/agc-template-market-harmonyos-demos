import { RouterMap } from 'commonlib'
import { IProfile } from 'network/src/main/ets/types/responseTypes/GetProductResp'
import { promptAction } from '@kit.ArkUI'
import { CommonRow } from './CommonRow'

@ComponentV2
export struct CommonProductProfile {
  @Param productProfile: IProfile | undefined = undefined
  @Event changeFactory: (router: RouterMap, param?: ESObject) => void = () => {
  }

  @Builder
  leftBuilder(text: string) {
    Row() {
      Text(text)
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))
    }
    .width('25%')
  }

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.Start }) {
        Text('产品档案')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
      }
      .margin({ top: 8, bottom: 24 })

      CommonRow({ text: '产品类型', value: this.productProfile?.type })

      Row() {
        this.leftBuilder('产品文档')

        Row() {
          Text('理财产品合同')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
          Image($r('app.media.icc_arrow_right'))
            .width(12)
            .height(12)
        }
        .justifyContent(FlexAlign.End)
        .width('75%')
        .onClick(() => {
          if (this.productProfile && this.productProfile.contract) {
            this.changeFactory(RouterMap.PREVIEW, this.productProfile.contract)
          } else {
            promptAction.showToast({
              alignment: Alignment.Center,
              duration: 2000,
              message: '暂无产品文档'
            });
          }
        })
      }
      .margin({ bottom: 12 })

      Row() {
        this.leftBuilder('信息披露')

        Row() {
          Text('定期披露、公告')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
          Image($r('app.media.icc_arrow_right'))
            .width(12)
            .height(12)
        }
        .justifyContent(FlexAlign.End)
        .width('75%')
        .onClick(() => {
          if (this.productProfile && this.productProfile.contract) {
            this.changeFactory(RouterMap.PREVIEW, this.productProfile.contract)
          } else {
            promptAction.showToast({
              alignment: Alignment.Center,
              duration: 2000,
              message: '暂无披露、公告'
            });
          }
        })
      }
      .alignItems(VerticalAlign.Top)
      .margin({ bottom: 12 })

      CommonRow({ text: '产品管理人', value: this.productProfile?.managementCompany })
      CommonRow({ text: '登记编码', value: this.productProfile?.number })
      CommonRow({ text: '成立日期', value: this.productProfile?.date })
    }
    .backgroundColor(Color.White)
    .padding({
      left: 12,
      right: 12,
      top: 16,
      bottom: 12
    })
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 12 })
    .borderRadius(16)
  }
}