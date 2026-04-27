@ObservedV2
export class CurrentDeviceViewModel {
  //设备名称
  @Trace currentDeviceName?: string
  //设备系统
  @Trace currentDeviceEquipmentSystem?: string
  //添加设备时间
  @Trace currentDeviceTime?: string
  @Trace index?: number
}