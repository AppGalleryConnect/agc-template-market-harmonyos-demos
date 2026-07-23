import { WindowUtil } from '../utils/WindowUtil';

class HeaderConstant {
  // 返回图标尺寸_内
  static readonly ICON_SIZE_INNER: number = 24;
  // 返回图标尺寸_外
  static readonly ICON_SIZE_OUTER: number = 40;
  //返回图标背景色
  static readonly ICON_BG_COLOR: Resource = $r('sys.color.comp_background_tertiary');
  // 标题字体颜色
  static readonly FONT_COLOR: Resource = $r('sys.color.font_primary');
  // 基础高度
  static readonly HEIGHT: number = 56;
  // 内边距
  static readonly PADDING: number = 16;
  // 外边距
  static readonly MARGIN: number = 8;
}

@ComponentV2
export struct CommonHeader {
  // 路由对象
  @Param stack: NavPathStack = new NavPathStack();
  // 标题文字
  @Param title: string = '';
  // 返回动画
  @Param backAnimation: boolean = true;
  @Param showBackButton: boolean = true;
  @Param bgColor: ResourceColor = Color.Transparent;
  @Param inner: boolean = false;
  headerHeight: number = HeaderConstant.HEIGHT;

  async aboutToAppear() {
    AppStorage.setOrCreate('theme_uiContext', this.getUIContext())
    await WindowUtil.initWindowUtil();
  }

  build() {
    Row() {
      if (this.showBackButton) {
        Row() {
          Image($r('app.media.back'))
            .width(HeaderConstant.ICON_SIZE_INNER)
            .fillColor(this.inner ? Color.White : undefined)
        }
        .aspectRatio(1)
        .borderRadius('50%')
        .justifyContent(FlexAlign.Center)
        .width(HeaderConstant.ICON_SIZE_OUTER)
        .margin({ right: HeaderConstant.MARGIN })
        .backgroundColor(this.inner ? Color.Transparent : HeaderConstant.ICON_BG_COLOR)
        .onClick(() => {
          if (this.stack) {
            this.stack.pop(this.backAnimation);
          }
        })
      }
      Text(this.title)
        .fontSize(this.showBackButton ? 20 : 26)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.inner ? Color.White : HeaderConstant.FONT_COLOR)
    }
    .height(this.headerHeight)
    .width('100%')
    .backgroundColor(this.bgColor)
    .justifyContent(FlexAlign.Start)
    .padding({ left: HeaderConstant.PADDING })
    .margin({ top: WindowUtil.getAvoidArea().top })
  }
}