import {
  CarGoodInfo,
  clearCarUtil,
  CommonUrl,
  Constants,
  DishesType,
  GetMyCarResp,
  updateMyCarUtil,
} from 'common/Index'
import { MustGoodsController } from '../models/MustGoodsController'

@Component
export struct MyCarListComp {
  @StorageProp('myCar') myCar: GetMyCarResp = new GetMyCarResp()
  @Consume('mustGoodsCtrl') mustGoodsCtrl: MustGoodsController
  close: () => void = () => {
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
      }.width(Constants.FULL_SIZE).height(Constants.FULL_SIZE).backgroundColor($r('sys.color.mask_fourth'))
      .onClick(() => {
        this.close()
      })

      Column() {
        Column() {
          Row()
            .width(48)
            .height(4)
            .backgroundColor($r('sys.color.mask_fourth'))
            .borderRadius(2)
            .margin({ top: 8, bottom: 4 })
          Row() {
            Row() {
              Image($r('app.media.clear_car')).width(14)
              Text($r('app.string.clear_car'))
                .fontSize($r('sys.float.Caption_M'))
                .fontColor($r('sys.color.font_secondary'))
                .margin({ left: 4 })
            }.onClick(() => {
              clearCarUtil().then(() => {
                this.mustGoodsCtrl.cleanCar()
              })
            })
          }
          .width(Constants.FULL_SIZE)
          .justifyContent(FlexAlign.End)
        }
        .width(Constants.FULL_SIZE)
        .constraintSize({ maxWidth: Constants.FULL_SIZE })
        .margin({ left: 16, right: 16 })

        List({ space: 8 }) {
          ForEach(this.myCar.res, (carGoodInfo: CarGoodInfo) => {
            ListItem() {
              CarCard({ carGoodInfo: carGoodInfo })
            }
          }, (carGoodInfo: CarGoodInfo, index: number) => `${carGoodInfo.id}+${carGoodInfo.num}`)
          // 购物车占位
          ListItem() {
            Row().width(Constants.FULL_SIZE).height(60)
          }
        }
        .width(Constants.FULL_SIZE)
        .constraintSize({ maxWidth: Constants.FULL_SIZE })
        .margin({ left: 16, right: 16, top: 8 })
        .padding({ left: 12, right: 12, top: 12 })
        .borderRadius({ topLeft: 12, topRight: 12 })
        .layoutWeight(1)
        .backgroundColor($r('sys.color.background_primary'))
        .scrollBar(BarState.Off)
      }
      .width(Constants.FULL_SIZE)
      .height(300)
      .backgroundColor($r('sys.color.background_secondary'))
      .borderRadius({ topLeft: 32, topRight: 32 })
      .constraintSize({ maxWidth: Constants.FULL_SIZE })
    }

  }
}

@Component
struct CarCard {
  @StorageProp('myCar') myCar: GetMyCarResp = new GetMyCarResp()
  @Consume('mustGoodsCtrl') mustGoodsCtrl: MustGoodsController
  @Consume('dishesList') dishesList: Array<DishesType>
  @ObjectLink carGoodInfo: CarGoodInfo

  build() {
    Row() {
      Row() {
        Image(`${CommonUrl.CLOUD_STORAGE_URL}${this.carGoodInfo.logo}`).width(60).height(60)
        Column() {
          Column() {
            Text(this.carGoodInfo.name)
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
            Text() {
              Span($r('app.string.selected'))
              Span(this.carGoodInfo.spec?.split(',').join(' | ')).margin({ left: 2 })
            }
            .fontSize($r('sys.float.Caption_M'))
            .fontColor($r('sys.color.font_secondary'))
            .margin({ top: 2 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          }.alignItems(HorizontalAlign.Start).layoutWeight(1)

          Text() {
            Span($r('app.string.currency_symbol'))
              .fontSize($r('sys.float.Caption_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            Span(`${Number(this.carGoodInfo.money)}`)
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
          }.margin({ top: 6 })
        }
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.SpaceBetween)
        .height(60)
        .layoutWeight(1)
      }.layoutWeight(1)

      Row() {
        Image($r('app.media.ic_subtract')).width(24).onClick(() => {
          if (this.carGoodInfo?.id && this.carGoodInfo?.num) {
            updateMyCarUtil(this.carGoodInfo?.id, Number(this.carGoodInfo?.num) - 1)
          }
        })
        Text(this.carGoodInfo.num)
          .margin({ left: 12, right: 12 })
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
        Image($r('app.media.add_car')).width(24).onClick(() => {
          if (this.carGoodInfo?.id && this.carGoodInfo?.num) {
            updateMyCarUtil(this.carGoodInfo?.id, Number(this.carGoodInfo?.num) + 1)
          } else {
            console.error(`GoodInfo not in disheList: ${JSON.stringify(this.carGoodInfo.goodId)}.`);
            return
          }
        })
      }.justifyContent(FlexAlign.End)
    }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Bottom)
  }
}