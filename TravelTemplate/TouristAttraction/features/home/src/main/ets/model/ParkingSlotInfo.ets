export class ParkingSlotInfo {
  /*华为Site唯一id，预留对接开发者服务端*/
  siteId: string = ''
  name: string = ''
  distance: number = 0
  icon: ResourceStr = ''
  longitude: number = 0
  latitude: number = 0
}

export class ParkingSlotList extends Array<ParkingSlotInfo> {}