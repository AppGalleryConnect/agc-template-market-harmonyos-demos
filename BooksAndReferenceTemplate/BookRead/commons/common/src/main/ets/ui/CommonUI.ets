import { Constants } from '../constant/Constants'
import { TCRouter } from '../comp/TCRouter'
import { MathUtil } from '../utils/MathUtil'

@Builder
export function BookCover(image?: PixelMap | ResourceStr | DrawableDescriptor, isFree?: boolean) {
  Stack() {
    Image($r(image?.toString()))
      .height(144)
      .width(104)
      .objectFit(ImageFit.Auto)
      .borderRadius(10)
    Column() {
      Text(isFree === true ? $r('app.string.free') : $r('app.string.member'))
        .fontSize(12)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .height(20)
        .width(35)
        .backgroundColor(isFree === true ? $r('app.color.free_color') : $r('app.color.member_color'))
        .borderRadius(10)
    }
    .padding({ bottom: 110, left: 45 })
  }
}


@ComponentV2
export struct NavHeaderBar {
  @Param title: ResourceStr | string = 'default';
  @Param hasBackButton: boolean = true;
  @Param hasBgColor: boolean = true;
  @Param backImg: ResourceStr = $r('app.media.ic_arrow_left');
  @Param hasBackgroundImg: boolean = true;
  @Param isMainPage: boolean = false;
  windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77

  build() {
    Column() {
      Row() {
        if (this.hasBackButton) {
          Image(this.backImg)
            .width(28)
            .height(28)
            .onClick(() => {
              TCRouter.pop();
            })
            .margin({ left: 8 })
        }
        Text(this.title)
          .fontColor($r('sys.color.font_primary'))
          .fontSize(this.isMainPage ? $r('sys.float.Title_M') : $r('sys.float.Title_S'))
          .width(Constants.FULL_SIZE)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 8 })
      }.height(36)
      .margin({ left: 12 })
    }
    .alignItems(HorizontalAlign.Start)
    .padding({
      top: 16 + this.windowTopHeight,
      bottom: 8,
    })
    .width(Constants.FULL_SIZE)
    .backgroundColor(this.hasBgColor ? $r('sys.color.background_primary') : '#00000000')
  }
}