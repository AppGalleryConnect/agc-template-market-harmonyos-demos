import { OrderStatus, PassengerInfo, TravelPeopleModel } from 'common_travel_guide'

@ObservedV2
export class SubmitOrderPageVM {
  @Trace roomNum: number = 1
  @Trace check: boolean = true
  @Trace payType:string = '' //支付方式
  @Trace orderStatus: OrderStatus = OrderStatus.PENDING
  @Trace travelPersonList: TravelPeopleModel[] = []
  @Trace contactPhone: string | number = '' // 联系人电话
  @Trace selectPersonNum: number = 0 // 选中的人员数量

  // 回显出行人信息
  getTravelPersonList(list: PassengerInfo[]) {
    this.travelPersonList = []
    list.forEach((personItem: PassengerInfo) => {
      let travelPerson: TravelPeopleModel = {
        name: personItem.name,
        idNumber: personItem.idNumber,
        phone: personItem.phone,
        isCheck: true,
      }
      this.travelPersonList.push(travelPerson)
    })
  }
}