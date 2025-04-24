@ObservedV2
export class ToiletInfo {
  // 对接mapkit，预留siteId
  siteId: string = ''
  name: string = ''
  longitude: number = 0
  latitude: number = 0
  distance: number = 0
  remainsForMan: number = 0
  remainsForWoman: number = 0
  icon: ResourceStr = ''
}

export class ToiletList extends Array<ToiletInfo> {}