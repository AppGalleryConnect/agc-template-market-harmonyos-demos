import { phoneRouterControl } from 'oh_router';
import { RouterMap } from 'common'
import { City } from 'city_select';
import { TourModel, TourPageParam, MockTourListService } from 'common_travel_guide'
import { TourListPageBuilder } from '../view/TourListPage'
import { CitySelectPageBuilder } from '../view/CitySelectPage'
import { TourDetailPageBuilder } from '../view/TourDetailPage'

@ObservedV2
export class TourPageVM {
  // 搜索的参数
  @Trace searchParam: TourPageParam = new TourPageParam(0, '南京市', '')
  // 列表数据
  @Trace mockTourList: TourModel[] = MockTourListService.tourResult

  // 点击跳转到选择城市页面
  jumpSelectCityPage() {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.CITY_SELECT_PAGE,
      builder: wrapBuilder(CitySelectPageBuilder),
      onPop: (popInfo: PopInfo) => {
        let result = popInfo?.result as City;
        this.searchParam.keyword = result.name
      },
      param: this.searchParam.keyword
    })
  }

  // 点击搜索按钮跳转搜索列表页
  jumpTourListPage() {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.TOUR_LIST_PAGE,
      builder: wrapBuilder(TourListPageBuilder),
      param: this.searchParam
    })
  }

  // 跳转旅游详情页
  jumpTourDetailPage(item: TourModel) {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.TOUR_DETAIL_PAGE,
      builder: wrapBuilder(TourDetailPageBuilder),
      param: item
    })
  }

  //返回上一级
  backPage() {
    phoneRouterControl.popPage()
  }
}
