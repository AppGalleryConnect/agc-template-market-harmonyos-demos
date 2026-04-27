import { PersistenceV2 } from '@kit.ArkUI';
import { RouterMap } from 'common';
import { phoneRouterControl } from 'oh_router';
import { PurchaseNotesPageBuilder } from '../view/PurchaseNotesPage'
import { TourOrderPageBuilder } from '../view/TourOrderPage'
import { TourModel, detailRouterParam, TourCollectListModel, MockTourListService} from 'common_travel_guide'


@ObservedV2
export class TourDetailPageVM {
  //所有数据
  @Trace mockTourList: TourModel[] = MockTourListService.tourResult
  // 收藏列表
  @Trace tourCollectList: TourCollectListModel =
    PersistenceV2.connect(TourCollectListModel, 'tourCollectListArr', () => new TourCollectListModel())!;

  @Trace detailInfo: TourModel | null = null
  // tabs标题数据
  @Trace classifyTitleList: string[] = ['详情', '须知', '行程']
  // 详情、须知、行程 ，tabs当前索引
  @Trace classifyCurrentIndex: number = 0;
  // 行程天数tabs当前索引
  @Trace itineraryCurrentIndex: number = 0;
  // 线路班期
  @Trace selectedScheduleIndex: number = 0
  // 判断是否展示顶部标题
  @Trace isShowHeadTitle: boolean = false;
  // 选中的班期价格
  @Trace price: number = 0;
  // 选中的班期时间戳
  @Trace scheduleCreateDate: number | Date = 0;
  // 选中的班期时间
  @Trace scheduleDateCode:string = ''
  // 是否收藏
  @Trace isCollect: boolean = false

  // 跳转到购买须知页面
  jumpPurchaseNotesPage() {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.PURCHASE_NOTES_PAGE,
      builder: wrapBuilder(PurchaseNotesPageBuilder),
    })
  }

  // 跳转到订单页
  jumpTourOrderPage() {
    let days = this.detailInfo?.days || 1;
    let param: detailRouterParam = {
      scenicMockInfo: this.detailInfo,
      price: this.price,
      scheduleDateCode:this.scheduleDateCode,
      starTime: this.getDate(this.scheduleCreateDate, 0),
      endTime: this.getDate(this.scheduleCreateDate, days > 1 ? days - 1 : 0)
    }
    phoneRouterControl.jumpPage({
      pageName: RouterMap.TOUR_ORDER_PAGE,
      builder: wrapBuilder(TourOrderPageBuilder),
      param: param
    })
  }

  getDate(timestamp: number | Date, days: number) {
    const pad2 = (n: number) => n.toString().padStart(2, '0');
    const result = new Date(timestamp);
    result.setDate(result.getDate() + days);
    let date = `${result.getFullYear()}-${pad2(result.getMonth() + 1)}-${pad2(result.getDate())}`
    return date;
  }

  // 收藏
  handleCollect(){
    this.isCollect = !this.isCollect
    let id = this.detailInfo?.id ?? 0
    if (this.isCollect && this.detailInfo) {
      this.tourCollectList.addList(this.detailInfo.id)
    } else {
      this.tourCollectList.removeList(id)
    }
  }

  //返回上一级
  backPage() {
    phoneRouterControl.popPage()
  }
}
