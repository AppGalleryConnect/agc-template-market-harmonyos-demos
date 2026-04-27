import { PersistenceV2 } from '@kit.ArkUI';
import { RouterMap } from 'common';
import { TravelPeopleListModel, TravelPeopleModel } from 'common_travel_guide';
import { phoneRouterControl } from 'oh_router';
import { TravelPeopleAddPageBuilder } from '../view/TravelPeopleAddPage'

@ObservedV2
export class TravelPeopleListPageVM {
  @Trace peopleList: TravelPeopleListModel =
    PersistenceV2.connect(TravelPeopleListModel, 'TravelPeopleList', () => new TravelPeopleListModel())!;
  // 选中的人员数据
  @Trace selectList: TravelPeopleModel [] = []

  // 路由传过来的数据，都会被勾选上
  initData() {
    let ids: string [] = []
    if (this.selectList.length) {
      ids = this.selectList.map((user: TravelPeopleModel) => user.idNumber);
    }
    this.peopleList.list.forEach((item: TravelPeopleModel) => {
      item.isCheck = ids.includes(item.idNumber)
    })
  }

  //跳转到新增、编辑出行人页面
  jumpTravelPeopleAddPage(item: TravelPeopleModel | null) {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.TRAVEL_PEOPLE_ADD_PAGE,
      builder: wrapBuilder(TravelPeopleAddPageBuilder),
      param: item
    })
  }

  //确认按钮
  confirmClick() {
    phoneRouterControl.popPage({
      popData: this.selectList
    })
  }

  //更新是否选中状态
  operateCheck(isSelect: boolean, item: TravelPeopleModel): void {
    this.peopleList.updateSelectStatus(isSelect, item)
    this.selectList = this.peopleList.list.filter((item: TravelPeopleModel) => item.isCheck)
  }


  // 返回上一页
  backPage() {
    phoneRouterControl.popPage({
      popData: this.selectList
    })
  }
}