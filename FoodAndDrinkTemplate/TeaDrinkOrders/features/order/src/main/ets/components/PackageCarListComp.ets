import { CommonUrl, Constants, GoodSpecInfo } from 'common'

@ComponentV2
export struct PackageCarListComp {
  @Param @Require packageCarList: Array<GoodSpecInfo>
  @Event changeCarPanel: (showPkgCar: boolean) => void = () => {
  }
  @Event clearCar: (specId?: string) => void = () => {
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 遮罩
      Column() {
      }.width(Constants.FULL_SIZE).height(Constants.FULL_SIZE).backgroundColor($r('sys.color.mask_tertiary'))
      .onClick(() => {
        this.changeCarPanel(false)
      })

      Column() {
        Column() {
          Row().width(48).height(4).backgroundColor($r('sys.color.mask_fourth')).borderRadius(2)
          Row() {
            Text($r('app.string.package_selected'))
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_primary'))
            Row() {
              Image($r('app.media.ic_clear_car')).width(14)
              Text($r('app.string.clear_car'))
                .fontSize(10)
                .fontColor($r('sys.color.mask_tertiary'))
                .lineHeight(14)
                .margin({ left: 4 })
            }.onClick(() => {
              this.clearCar()
            })
          }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween)
        }
        .height(40)
        .padding({
          left: 16,
          right: 16,
          top: 8,
          bottom: 8,
        })
        .justifyContent(FlexAlign.End)

        List({ space: 12 }) {
          ForEach(this.packageCarList, (goodSpec: GoodSpecInfo) => {
            ListItem() {
              Row() {
                Row() {
                  Image(`${CommonUrl.CLOUD_STORAGE_URL}${goodSpec.goodLogo}`).width(60).height(60)
                  Column() {
                    Text(goodSpec.goodName)
                      .fontSize($r('sys.float.Body_M'))
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                    Text() {
                      Span($r('app.string.selected'))
                      Span(goodSpec.specStr).margin({ left: 2 })
                    }
                    .fontSize($r('sys.float.Caption_M'))
                    .fontColor($r('sys.color.font_secondary'))
                    .margin({ top: 4 })
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }.alignItems(HorizontalAlign.Start).height(60).margin({ left: 12 })
                }.layoutWeight(1)

                Row() {
                  Image($r('app.media.ic_subtract_car')).width(24).onClick(() => {
                    this.clearCar(goodSpec.specId)
                  })
                  Text(goodSpec.number)
                    .margin({ left: 12, right: 12 })
                    .fontSize($r('sys.float.Body_L'))
                    .fontColor($r('sys.color.font_primary'))
                    .fontWeight(FontWeight.Medium)
                  Image($r('app.media.ic_add_car')).width(24)
                }.height(60).justifyContent(FlexAlign.End).alignItems(VerticalAlign.Bottom)
              }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween)
            }
          }, (goodSpec: GoodSpecInfo) => `${goodSpec.specId}${goodSpec.goodId}${goodSpec.specStr}`)
          // 购物车占位
          ListItem() {
            Row().width(Constants.FULL_SIZE).height(100)
          }
        }
        .width(Constants.FULL_SIZE)
        .constraintSize({ maxWidth: Constants.FULL_SIZE })
        .margin({ left: 16, right: 16 })
        .padding({ left: 12, right: 14, top: 12 })
        .borderRadius({ topLeft: 12, topRight: 12 })
        .backgroundColor($r('sys.color.white'))
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width(Constants.FULL_SIZE)
      .height(340)
      .backgroundColor($r('sys.color.background_secondary'))
      .borderRadius({ topLeft: 32, topRight: 32 })
      .clip(true)
      .constraintSize({ maxWidth: Constants.FULL_SIZE })
    }
  }
}