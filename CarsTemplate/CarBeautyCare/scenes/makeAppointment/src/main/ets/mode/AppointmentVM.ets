import { BTN_TYPE, SelectedData, DateModel, TimeModel } from './AppointmentModel'
import { LocationVM ,ShopCardModel} from '@ohos_agcit/car_beauty_care_shop'
import { VehicleVM, VehicleModel } from '@ohos_agcit/car_beauty_care_garage'

@ObservedV2
export class AppointmentVM {
  locationVM: LocationVM = LocationVM.instance;
  vehicleVM: VehicleVM = VehicleVM.instance;

  //控制提交按钮是否显示
  @Trace showSubmitBtn: boolean = false;
  //店铺信息属性为内存里所在城市店铺列表的第一个
  @Trace card:ShopCardModel = this.locationVM.shopCardList[0]
  @Trace selectedData: SelectedData = {
    date: new DateModel('', '', false),
    time: new TimeModel('', 0, false, false),
    card: this.locationVM.shopCardList[0],
    type: BTN_TYPE.MAINTENANCE,
  };
  @Trace appointmentOrder: SelectedData [] = [];
  private static _instance: AppointmentVM
  public static get instance() {
    if (!AppointmentVM._instance) {
      AppointmentVM._instance = new AppointmentVM();
    }
    return AppointmentVM._instance;
  }



  public updateSelectedData(date:DateModel, time:TimeModel, card: ShopCardModel) {
    const type = this.selectedData.type
    this.selectedData = {card, date, time, type };
  }

  public updateSelectedType(type: BTN_TYPE) {
    this.selectedData.type = type;
  }

  public setShowSubmitBtn(isShow:boolean) {
    this.showSubmitBtn = isShow;
  }

  // 确定预约
  public makeAppointOrder():boolean {
    let appointedSuccess = true;
    this.appointmentOrder.forEach((item: SelectedData) => {
      if (item.date.date === this.selectedData.date.date && item.time.time === this.selectedData.time.time) {
        appointedSuccess = false;
        return;
      }
    })
    if (appointedSuccess) {
      if (this.vehicleVM.vehicle !== null) {
        this.selectedData.licenseNumber = this.vehicleVM.vehicle.license;
      }
      this.selectedData.id = String(new Date().getTime());
      this.appointmentOrder.push(this.selectedData)
    }
    return appointedSuccess;
  }

  // 取消预约
  public cancelAppointOrder(data: SelectedData): boolean {
     const index = this.appointmentOrder.findIndex((item:SelectedData) => item.id === data.id);
     let cancelSuccess = false;
     if (index !== -1) {
       this.appointmentOrder.splice(index, 1);
       cancelSuccess = true;
     }
     return cancelSuccess;
  }

  public getAppointOrderData() {
    return this.appointmentOrder;
  }
}
