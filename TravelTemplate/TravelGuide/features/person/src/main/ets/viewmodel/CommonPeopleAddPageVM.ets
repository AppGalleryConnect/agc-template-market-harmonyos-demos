import { PersistenceV2 } from '@kit.ArkUI';
import { phoneRouterControl } from 'oh_router';
import { TravelPeopleListModel, TravelPeopleModel, TravelPeopleUtil } from 'common_travel_guide';

@ObservedV2
export class CommonPeopleAddPageVM {
  @Trace commonPeopleList: TravelPeopleListModel =
    PersistenceV2.connect(TravelPeopleListModel, 'TravelPeopleList', () => new TravelPeopleListModel())!;
  //  是否是编辑状态
  @Trace isEditPeople: boolean = false;
  @Trace commonPeopleItem: TravelPeopleModel = new TravelPeopleModel()

  // 保存数据
  saveCommonPeopleClick() {
    let validPeople: boolean =
      TravelPeopleUtil.validEditInfo(this.commonPeopleList.list, this.commonPeopleItem, this.isEditPeople)
    if (!validPeople) {
      return;
    }
    if (this.isEditPeople) {
      this.commonPeopleList.editList(this.commonPeopleItem)
    } else {
      this.commonPeopleList.addList(this.commonPeopleItem)
    }
    phoneRouterControl.popPage({
      popData: this.commonPeopleItem
    })
  }

  // 返回上一页
  backPage() {
    phoneRouterControl.popPage()
  }

  @Computed
  get allowSave() {
    if (this.commonPeopleItem.name && this.commonPeopleItem.phone && this.commonPeopleItem.idNumber) {
      return true
    }
    return false;
  }
}