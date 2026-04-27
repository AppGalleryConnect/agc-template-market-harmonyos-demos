import { RouterMap, TValueType } from 'common';
import { PlaneDetailListModel } from 'common_travel_guide';
import { phoneRouterControl } from 'oh_router';
import { CarOrderPageBuilder } from './CarOrderPage';
import { DetailPageHeader } from '../components/DetailPageHeader';
import { OrderListItem } from '../components/OrderListItem';

@Builder
export function CarDetailPageBuilder(param: TValueType) {
  CarDetailPage({
    pageParam: param
  })
}

@ComponentV2
export struct CarDetailPage {
  @Param pageParam: TValueType = null
  @Local dataInfo: PlaneDetailListModel = this.pageParam as PlaneDetailListModel
  @Local listData: number[] = [1, 2, 3, 4]

  build() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  render() {
    Column() {
      // 使用通用头部组件
      DetailPageHeader({
        currentCity: this.dataInfo.currentCity,
        returnCity: this.dataInfo.returnCity
      })

      // 行程信息
      Column() {
        Row() {
          Column() {
            Row() {
              Text(this.dataInfo.startLocation)
                .fontSize(18)
                .fontColor('#000')
              Image($r('app.media.ic_right'))
                .width(20)
              Text(this.dataInfo.endLocation)
                .fontSize(18)
                .fontColor('#000')
            }

            Row() {
              Text(this.dataInfo.timeDate.split('-').join('月') + '日')
                .fontSize(14)
                .opacity(0.5)
                .fontColor('#000')
              Text(this.dataInfo.weekDate)
                .fontSize(14)
                .opacity(0.5)
                .fontColor('#000')
                .margin({ left: 2, right: 2 })
              Text(this.dataInfo.startDate + '出发')
                .fontSize(14)
                .opacity(0.5)
                .fontColor('#000')
            }
            .margin({ top: 16, bottom: 6 })

            Row() {
              Text('约' + this.dataInfo.duration)
                .fontSize(10)
                .opacity(0.3)
                .fontColor('#000')
            }
          }
        }
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: 12 })

      // 订单列表
      List({ space: 10 }) {
        ForEach(this.listData, (item: number) => {
          ListItem() {
            OrderListItem({
              config: {
                totalPrice: Number(this.dataInfo.price),
                discountPrice: 12,
                description: ['·退票无忧，全程保障'],
                orderPageName: RouterMap.CAR_ORDER_PAGE,
                orderPageBuilder: wrapBuilder(CarOrderPageBuilder),
                orderData: this.dataInfo
              },
              index: 0
            })
          }
        }, (item: number) => item?.toString())
      }
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .justifyContent(FlexAlign.Start)
    .padding(16)
  }
}