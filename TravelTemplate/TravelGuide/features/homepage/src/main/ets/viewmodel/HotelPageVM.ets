import { City, OVERSEAS_CITY_LIST_SAMPLE } from 'city_select'
import { RouterMap } from 'common'
import { HotelDateModel } from 'common_travel_guide'
import { phoneRouterControl } from 'oh_router'
import { CitySelectPageBuilder } from '../view/CitySelectPage'
import { OverseasCitySelectPageBuilder } from '../view/OverseasCitySelectPage'

@ObservedV2
export class HotelPageVM {
  @Trace searchContent: string = ''
  @Trace chooseStatus: number = 0
  @Trace currentCity: string = '南京市'
  @Trace currentCity1: string = '南京市'
  @Trace placeName: string = ''
  @Trace locationPermission: boolean = false
  @Trace showLocation: boolean = false
  @Trace hotelDateModel: HotelDateModel = new HotelDateModel()
  // 弹框id，用于关闭
  dialogId: number = 0;

  // 跳转城市搜索页面
  jumpCitySelectPage() {
    if (this.chooseStatus === ChooseStatus.Overseas) {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.OVERSEAS_CITY_SELECT_PAGE,
        builder: wrapBuilder(OverseasCitySelectPageBuilder),
        param: this.currentCity,
        onPop: (popInfo: PopInfo) => {
          let result = popInfo?.result as City;
          if (result && result.name) {
            this.currentCity = result.name
          }
          this.showLocation = false
          if (OVERSEAS_CITY_LIST_SAMPLE.map(item => item.name).includes(this.currentCity)) {
            this.chooseStatus = ChooseStatus.Overseas
          }
        }
      })
    } else {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.CITY_SELECT_PAGE,
        builder: wrapBuilder(CitySelectPageBuilder),
        param: this.currentCity,
        onPop: (popInfo: PopInfo) => {
          let result = popInfo?.result as City;
          if (result && result.name) {
            this.currentCity = result.name
          }
          this.showLocation = false
          if (OVERSEAS_CITY_LIST_SAMPLE.map(item => item.name).includes(this.currentCity)) {
            this.chooseStatus = ChooseStatus.Overseas
          }
        }
      })
    }
  }
}

export enum ChooseStatus {
  Domestic = 0, //国内
  Overseas = 1, //海外
  Hourly = 2, //钟点房
  Homestay = 3 //民宿
}