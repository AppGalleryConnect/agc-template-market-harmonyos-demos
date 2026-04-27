import { RouterMap } from 'common';
import { OrderStatus } from 'common_travel_guide';
import { phoneRouterControl } from 'oh_router';

@ObservedV2
export class HotelOrderDetailPageVM {
  @Trace orderStatus: OrderStatus = OrderStatus.PENDING
  dialogId: number = 0;

  formatDate(dateStr: string) {
    const date = new Date(dateStr);
    const year = date.getFullYear();
    const month = date.getMonth() + 1;
    const day = date.getDate();

    return `${year}年${month}月${day}日`;
  }

  //返回上一级
  backPage() {
    let navPageInfoList = phoneRouterControl.getNavPageInfoList();
    let navPageIndex = navPageInfoList.findIndex((item) => item.pageName === RouterMap.HOTEL_DETAILS_PAGE ||
      item.pageName === RouterMap.ORDER_MANAGEMENT_PAGE)
    if (navPageIndex !== -1) {
      let pageName = navPageInfoList[navPageIndex].pageName
      phoneRouterControl.popAppointPageName(pageName, true)
    } else {
      phoneRouterControl.popPage()
    }
  }
}