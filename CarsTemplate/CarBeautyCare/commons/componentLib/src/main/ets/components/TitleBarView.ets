import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib'

@ComponentV2
export struct TitleBarView {
  @Param title:string | Resource = '';
  @Param routePath: string = '';
  @Param routeDescription: string = '';
  @Param showRight: boolean = false;

  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();

  build() {
    Row() {
      Text(this.title)
        .fontSize(18)
        .fontColor('#000')
        .fontWeight(FontWeight.Bold)

      if (this.showRight) {
        Row() {
          Text(this.routeDescription)
            .fontSize(12)
            .fontColor('#666')
            .margin({
              right:2
            })

          Image($r('app.media.ic_right_arrow_lined'))
            .width(18)
            .height(18)

        }
      }
    }
    .width(CommonConstants.FULL_WIDTH)
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => {
      if (this.showRight) {
        this.appPathStack.pushPathByName(this.routePath, true)
      }
    })
  }
}