@ObservedV2
export class AvoidArea {
  @Trace topRectHeight: number = 0
  @Trace bottomRectHeight: number = 0
  
  constructor(topRectHeight: number, bottomRectHeight: number) {
    this.topRectHeight = topRectHeight
    this.bottomRectHeight = bottomRectHeight
  }
}
