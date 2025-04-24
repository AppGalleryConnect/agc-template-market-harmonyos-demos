import { CarType } from '../constants/car'

// 店铺信息属性
@ObservedV2
export class VehicleModel {
  @Trace license?: string; //车牌号
  @Trace vehiclemode?: string; //车辆型号
  @Trace mileage?: string; //当前里程
  @Trace roadtime?: string; //上路时间
  @Trace identifynumber?: string; //车辆识别代号
  @Trace engine?: string; //发动机号
  @Trace brandingMessage: CarType; //品牌

  constructor(branding:CarType) {
    this.brandingMessage = branding;
  }
}


