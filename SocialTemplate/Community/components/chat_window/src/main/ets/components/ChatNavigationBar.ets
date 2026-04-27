import { AppStorageV2 } from '@kit.ArkUI'
import { ChatBreakpoint } from 'chat_base';

@ComponentV2
export struct ChatNavigationBar {
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  @Param title: string = ''
  @Param fontWightParam: FontWeight | number = 700
  @Param backgroundColorParam: ResourceStr | undefined = $r('sys.color.background_secondary')
  @Param rowFlexAlign: FlexAlign | undefined = FlexAlign.Start
  @Param leftImageMargin: Length | undefined = undefined;
  @Param isShowLeftImage: boolean = true;
  @Param @Require onReturnClick?: () => void
  @Param rightImageRes: Resource | undefined = undefined
  @Param rightImageMargin: Length | undefined = undefined;
  @Param isShowRightImage: boolean = false;
  @Local isShowMenu: boolean = false;
  @Param menuList: MenuElement[] = [];
  @Event rightOnClick: () => void = () => {
  }

  build() {
    Column() {
      Blank().height(this.chatBreakpoint.topValue);
      Row() {
        if (this.isShowLeftImage) {
          Button() {
            SymbolGlyph($r('sys.symbol.chevron_backward'))
              .fontSize($r('app.float.vp_24'))
              .fontColor([$r('sys.color.icon_primary')])
              .fontWeight(FontWeight.Normal)
          }
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .margin({ left: this.leftImageMargin ?? this.chatBreakpoint.pagePadding })
          .type(ButtonType.Circle)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .onClick(() => {
            if (this.onReturnClick) {
              this.onReturnClick?.()
            }
          })
        }

        Text(this.title)
          .size({ height: $r('app.float.vp_40') })
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(this.fontWightParam)
          .fontColor($r('sys.color.font_primary'))
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({
            left: this.isShowLeftImage ?
              this.chatBreakpoint.pagePadding / 2 :
            this.leftImageMargin
          })

        if (this.isShowRightImage) {
          Image(this.rightImageRes)
            .size({ width: 24, height: 24 })
            .onClick(() => {
              this.isShowMenu = !this.isShowMenu;
            })
            .bindMenu(this.isShowMenu, this.menuList,
              {
                placement: Placement.BottomRight,
                onDisappear: () => {
                  this.isShowMenu = false;
                }
              })
          Blank().width(this.rightImageMargin ?? this.chatBreakpoint.pagePadding)
        }
      }
      .height(40)
      .width('100%')
      .justifyContent(this.rowFlexAlign)

      Blank().height($r('app.float.vp_12'))
    }
    .width('100%')
    .height(52 + this.chatBreakpoint.topValue)
    .backgroundColor(this.backgroundColorParam)
  }
}