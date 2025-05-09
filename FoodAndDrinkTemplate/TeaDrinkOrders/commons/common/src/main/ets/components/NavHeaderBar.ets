import { Constants } from '../constants/Common';
import { WindowModel } from '../models/StorageModel';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct NavHeaderBar {
  @Consumer('pageStack') pageStack?: NavPathStack
  @Param @Require title: ResourceStr;
  @Param hasBackButton: boolean = true;
  @Param hasBgColor: boolean = true;
  @Param backImg: ResourceStr = $r('app.media.ic_back');
  @Param hasBackgroundImg: boolean = true;
  @Param isMainPage: boolean = false;
  @Param headOpacity: number = 1;
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!

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
      top: 8 + this.windowModel.getWindowTopHeight(),
      bottom: 8,
    })
    .width(Constants.FULL_SIZE)
    .opacity(this.headOpacity)
    .backgroundColor(this.hasBgColor ? $r('sys.color.background_primary') : '#00000000')
  }
}