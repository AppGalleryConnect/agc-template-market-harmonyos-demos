import { TourModel, TourPageParam, MockTourListService } from 'common_travel_guide'
import { phoneRouterControl } from 'oh_router'
import { RouterMap } from 'common'
import { TourDetailPageBuilder } from '../view/TourDetailPage'

const TAG = 'TourListPageVM'

@ObservedV2
export class TourListPageVM {
  @Trace mockTourList: TourModel[] = MockTourListService.tourResult
  @Trace tourList: TourModel[] = []
  @Trace searchParam: TourPageParam = new TourPageParam(0, '', '')
  @Trace searchList: TourModel[] = []

  //搜索按钮查询数据
  doSearch(searchParam: TourPageParam) {
    // 将选项卡映射为文案（与 mock 数据的 groupType 对齐）
    const groupTypeExpect: string = searchParam.chooseStatus === 0 ? '跟团游' : '定制游'
    // 关键字与天数预处理
    const keyword: string = (searchParam?.keyword ?? '').trim().toLowerCase()
    const daysNum: number = Number.parseInt(searchParam?.playDays ?? '')
    // 执行筛选
    this.searchList = (this.tourList ?? []).filter((item: TourModel) => {
      let match:Boolean = this.getFilterItem(item,groupTypeExpect,keyword,daysNum)
      return match
    })
  }

  getFilterItem(item: TourModel,groupTypeExpect:string,keyword:string,daysNum:number ){
    // 天数预处理
    const hasDaysFilter: boolean = !Number.isNaN(daysNum) && daysNum > 0
    // 选项卡筛选（如果有期望值则匹配 groupType，否则忽略）
    const matchStatus = groupTypeExpect ? (item.groupType === groupTypeExpect) : true
    // 天数筛选（仅当输入了有效数字时）
    const matchDays = hasDaysFilter ? (item.days === daysNum) : true
    // 关键字筛选（标题、副标题、省份、城市、标签）
    const kw = keyword
    const matchTitle = kw ? item.title?.includes(kw) : true
    const matchSubTitle = kw ? item.subTitle?.includes(kw) : true
    const matchProvince = kw ? item.province?.includes(kw) : true
    const matchCities = kw ? (item.cities ?? []).some(c => c.includes(kw)) : true
    const matchTags = kw ? (item.tags ?? []).some(c => c.includes(kw)) : true

    const matchKeyword = matchTitle || matchSubTitle || matchProvince || matchCities || matchTags
    return matchStatus && matchDays && matchKeyword
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

