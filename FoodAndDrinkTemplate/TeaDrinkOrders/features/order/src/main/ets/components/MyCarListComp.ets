import { CarGoodInfo, CommonUrl, Constants, GoodSpecEnum, HttpRequest, MyCarModel, PkgGoodComp } from 'common/Index';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct MyCarListComp {
  @Local myCarModel: MyCarModel = AppStorageV2.connect(MyCarModel) as MyCarModel
  @Event changeCarPanel: () => void = () => {
  };

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
      }.width(Constants.FULL_SIZE).height(Constants.FULL_SIZE).backgroundColor($r('sys.color.mask_tertiary'))
      .onClick(() => {
        this.changeCarPanel()
      })

      Column() {
        Column() {
          Row().width(48).height(4).backgroundColor($r('sys.color.mask_fourth')).borderRadius(2)
          Row() {
            Row() {
              CheckboxGroup({ group: 'checkboxGroup' })
                .height(12)
                .width(12)
                .checkboxShape(CheckBoxShape.CIRCLE)
                .selectedColor($r('app.color.mainColor'))

              Text($r('app.string.check_all'))
                .fontSize(12)
                .fontColor('#E6000000')
                .lineHeight(16)
                .margin({ left: 13 })
            }

            Row() {
              Image($r('app.media.ic_clear_car')).width(14)
              Text($r('app.string.clear_car'))
                .fontSize(10)
                .fontColor($r('sys.color.mask_tertiary'))
                .lineHeight(14)
                .margin({ left: 4 })
            }.onClick(() => {
              HttpRequest.clearCar().then(() => {
                this.myCarModel.carCheck = []
              })
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
          ForEach(this.myCarModel.myCar.carGoods, (carGoodInfo: CarGoodInfo) => {
            ListItem() {
              Column() {
                Row() {
                  Row() {
                    Checkbox({ name: carGoodInfo.id, group: 'checkboxGroup' })
                      .select(this.myCarModel.carCheck.includes(carGoodInfo.id))
                      .height(12)
                      .width(12)
                      .selectedColor($r('app.color.mainColor'))
                      .shape(CheckBoxShape.CIRCLE)
                      .onChange((value: boolean) => {
                        if (value) {
                          this.myCarModel.carCheck.push(carGoodInfo.id)
                        } else {
                          this.myCarModel.carCheck = this.myCarModel.carCheck.filter(item => item !== carGoodInfo.id)
                        }

                      })
                    Image(`${CommonUrl.CLOUD_STORAGE_URL}${carGoodInfo.logo}`).width(60).height(60).margin({ left: 12 })
                    Column() {
                      Text(carGoodInfo.name)
                        .fontSize(14)
                        .fontWeight(FontWeight.Regular)
                        .fontColor($r('sys.color.font_primary'))
                      Text() {
                        Span($r('app.string.selected'))
                        Span(carGoodInfo.spec?.split(',').join(' | ')).margin({ left: 2 })
                      }
                      .fontSize(10)
                      .fontColor($r('sys.color.mask_tertiary'))
                      .lineHeight(14)
                      .margin({ top: 4 })
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .visibility(carGoodInfo.specType !== GoodSpecEnum.PACKAGE_TYPE ? Visibility.Visible :
                      Visibility.None)

                      Text() {
                        Span($r('app.string.currency_symbol'))
                          .fontSize(8)
                          .fontWeight(FontWeight.Medium)
                          .fontColor($r('sys.color.font_primary'))
                        Span(`${Number(carGoodInfo.money)}`)
                          .fontSize(14)
                          .fontWeight(FontWeight.Medium)
                          .fontColor($r('sys.color.font_primary'))
                      }.margin({ top: 4 })
                    }.margin({ left: 12 }).alignItems(HorizontalAlign.Start).height(60)
                  }.layoutWeight(1)

                  Row() {
                    Image($r('app.media.ic_subtract_car')).width(22).onClick(() => {
                      if (carGoodInfo?.id && carGoodInfo?.num) {
                        let isLastGood = carGoodInfo.num === 1
                        HttpRequest.updateMyCar(carGoodInfo.id, carGoodInfo.num - 1).then(() => {
                          if (isLastGood) {
                            this.myCarModel.carCheck = this.myCarModel.carCheck.filter(item => item !== carGoodInfo.id)
                          }
                        })
                      }
                    })
                    Text(carGoodInfo.num.toString())
                      .margin({ left: 8, right: 8 })
                      .fontSize(14)
                      .fontColor($r('sys.color.mask_secondary'))
                      .lineHeight(20)
                    Image($r('app.media.ic_add_car')).width(22).onClick(() => {
                      if (carGoodInfo?.id && carGoodInfo?.num) {
                        HttpRequest.updateMyCar(carGoodInfo?.id, carGoodInfo.num + 1)
                      } else {
                        console.error(`GoodInfo not in disheList: ${JSON.stringify(carGoodInfo.goodId)}.`);
                        return
                      }
                    })
                  }.height(60).justifyContent(FlexAlign.End).alignItems(VerticalAlign.Bottom)
                }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween)

                PkgGoodComp({ pkgGoods: carGoodInfo.combination })
                  .margin({ top: 12 })
                  .visibility(carGoodInfo.specType === GoodSpecEnum.PACKAGE_TYPE ? Visibility.Visible : Visibility.None)
              }
            }
          }, (carGoodInfo: CarGoodInfo) => `${carGoodInfo.id}+${carGoodInfo.num}`)
          // 购物车占位
          ListItem() {
            Row().width(Constants.FULL_SIZE).height(60)
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
      .backgroundColor('#E6FFFFFF')
      .borderRadius({ topLeft: 32, topRight: 32 })
      .clip(true)
      .constraintSize({ maxWidth: Constants.FULL_SIZE })
    }
  }
}