import { PersistenceV2 } from '@kit.ArkUI';
import { baseToast, TravelPeopleListModel, TravelPeopleModel, TravelPeopleUtil } from 'common_travel_guide';
import { phoneRouterControl } from 'oh_router';

@ObservedV2
export class TravelPeopleAddPageVM {
  @Trace peopleList: TravelPeopleListModel =
    PersistenceV2.connect(TravelPeopleListModel, 'TravelPeopleList', () => new TravelPeopleListModel())!;
  //  是否是编辑状态
  @Trace isEdit: boolean = false;
  @Trace peopleItem: TravelPeopleModel = new TravelPeopleModel()

  private showDeleteTravelPeopleDialog() {
    baseToast.show({
      type: 'dialog',
      message: '确定要删除吗？',
      confirmColor: $r('sys.color.font_primary'),
      cancelColor: $r('sys.color.icon_secondary'),
      confirmAction: () => {
        this.peopleList.removeList(this.peopleItem)
        phoneRouterControl.popPage({
          popData: this.peopleItem
        })
        baseToast.hide();
      },
      cancelAction: () => {
        baseToast.hide();
      },
    });
  }

  // 保存数据
  saveClick() {
    let valid: boolean = TravelPeopleUtil.validEditInfo(this.peopleList.list, this.peopleItem, this.isEdit)
    if (!valid) {
      return;
    }
    if (this.isEdit) {
      this.peopleList.editList(this.peopleItem)
    } else {
      this.peopleList.addList(this.peopleItem)
    }
    phoneRouterControl.popPage({
      popData: this.peopleItem
    })
  }


  // 删除当前编辑数据
  deleteClick() {
    this.showDeleteTravelPeopleDialog()
  }

  // 返回上一页
  backPage() {
    phoneRouterControl.popPage()
  }
}