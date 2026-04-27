import { Type } from '@kit.ArkUI';

@ObservedV2
export class TravelPeopleModel {
  // 唯一标识
  @Trace id?: string = ''
  // 证件号码
  @Trace idNumber: string = ''
  // 姓名
  @Trace name: string = ''
  // 手机号
  @Trace phone: string = ''
  // 加***号的身份证号
  @Trace maskedIdNumber?: string = ''
  // 加***手机号
  @Trace maskedPhone?: string = ''
  // 是否是选中状态
  @Trace isCheck: boolean = false;
  // 是否是本人
  @Trace isMyself?: boolean = false;
}

@ObservedV2
export class TravelPeopleListModel {
  @Type(TravelPeopleModel)
  @Trace list: TravelPeopleModel[] = [];
  @Trace myselfId: string = ''

  // 新增
  addList(data: TravelPeopleModel): void {
    data.id = `travel_people_${new Date().getTime()}`
    data.maskedIdNumber = this.maskedIdCard(data.idNumber)
    data.maskedPhone = this.getEncryptionPhone(data.phone)
    data.isCheck = false
    this.list.unshift(data);
    this.setMyself(data)
    this.sortPersons()
  }

  // 删除
  removeList(data: TravelPeopleModel): void {
    let index = this.list.findIndex((item: TravelPeopleModel) => item.id === data.id)
    this.list.splice(index, 1);
  }

  //更新check状态
  updateSelectStatus(isSelect: boolean, data: TravelPeopleModel) {
    let index = this.list.findIndex((item: TravelPeopleModel) => item.id === data.id)
    this.list[index].isCheck = isSelect;
  }

  //编辑更新
  editList(data: TravelPeopleModel) {
    let index = this.list.findIndex((item: TravelPeopleModel) => item.id === data.id)
    data.maskedIdNumber = this.maskedIdCard(data.idNumber)
    data.maskedPhone = this.getEncryptionPhone(data.phone)
    this.list[index] = data
    this.setMyself(data)
    this.sortPersons()
  }

  //  身份证号加密
  maskedIdCard(idNumber: string) {
    return idNumber.replace(/^(\d{4})\d+(\d{3})$/, '$1******$2');
  }

  getEncryptionPhone(phone: string) {
    const reg = /(\d{3})\d{4}(\d{4})/;
    return phone.toString().replace(reg, '$1****$2')
  }

  //设置为本人,当前条数据isMyself设置true，其他数据isMyself就要为false
  setMyself(data: TravelPeopleModel) {
    if (data.isMyself && data.id) {
      this.myselfId = data.id;
    } else if (!data.isMyself && data.id === this.myselfId) {
      this.myselfId = '';
    }
    this.list.forEach((item) => {
      item.isMyself = this.myselfId === item.id &&
        item?.id !== ''
    })
  }

  // 将由本人的数据置顶
  sortPersons() {
    this.list = [...this.list].sort((a, b) => {
      return (b.isMyself && b.id === this.myselfId ? 1 : 0) -
        (a.isMyself && a.id === this.myselfId ? 1 : 0);
    });
  }
}



