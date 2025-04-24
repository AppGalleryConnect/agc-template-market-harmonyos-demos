import { Constants } from '../constants/Common';

@Component
export struct NavHeaderBar {
  @Consume('pageStack') pageStack: NavPathStack
  @Prop title: ResourceStr;
  @Prop hasBackButton: boolean = true;
  @Prop hasBgColor: boolean = true;
  @Prop backImg: ResourceStr = $r('app.media.ic_back');
  @Prop hasBackgroundImg: boolean = true;
  @Prop isMainPage: boolean = false;
  windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77

  build() {
    Column() {
      Row() {
        if (this.hasBackButton) {
          Image(this.backImg)
            .width(24)
            .height(24)
            .onClick(() => {
              this.pageStack?.pop()
            })
        }
        Text(this.title)
          .fontColor($r('sys.color.font_primary'))
          .fontSize(this.isMainPage ? $r('sys.float.Title_M') : $r('sys.float.Title_S'))
          .width(Constants.FULL_SIZE)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 8 })
      }.height(36).margin({ left: 16 })
    }
    .alignItems(HorizontalAlign.Start)
    .padding({
      top: 12 + this.windowTopHeight,
      bottom: 8,
    })
    .width(Constants.FULL_SIZE)
    .backgroundColor(this.hasBgColor ? $r('sys.color.background_primary') : '#00000000')
  }
}