import { RouterModule } from '../utils/RouterModule';
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
  // 副标题字体颜色
  static readonly SUB_FONT_COLOR: Resource = $r('sys.color.font_secondary');
  // 基础高度
  static readonly HEIGHT: number = 56;
  // 内边距
  static readonly PADDING: number = 16;
  // 外边距
  static readonly MARGIN: number = 8;
  // 通用间距
  static readonly SPACE: number = 2;
  // 全比例
  static readonly FULL_PERCENT: string = '100%';
  // 半比例
  static readonly HALF_PERCENT: string = '50%';
}

@ComponentV2
export struct CommonHeader {
  // 标题文字
  @Param title: string = '';
  // 副标题文字
  @Param subTitle: string = '';
  // 返回动画
  @Param backAnimation: boolean = true;
  // 是否带返回按钮
  @Param showBackButton: boolean = true;
  // 背景颜色
  @Param bgColor: ResourceColor = Color.Transparent;
  headerHeight: number = HeaderConstant.HEIGHT;
  // 标题左边距
  @Param leftPadding: number = 16;

  build() {
    Row() {
      if (this.showBackButton) {
        Row() {
          Image($r('app.media.ic_back'))
            .width(HeaderConstant.ICON_SIZE_INNER)
            .fillColor($r('sys.color.icon_primary'))
        }
        .aspectRatio(1)
        .borderRadius(HeaderConstant.HALF_PERCENT)
        .justifyContent(FlexAlign.Center)
        .width(HeaderConstant.ICON_SIZE_OUTER)
        .margin({ right: HeaderConstant.MARGIN })
        .backgroundColor(HeaderConstant.ICON_BG_COLOR)
        .onClick(() => {
          RouterModule.pop(this.backAnimation);
        })
      }
      Column({ space: HeaderConstant.SPACE }) {
        Text(this.title)
          .fontSize(this.showBackButton ? 20 : 26)
          .lineHeight(this.showBackButton ? 27 : 35)
          .fontWeight(FontWeight.Bold)
          .fontColor(HeaderConstant.FONT_COLOR)

        if (this.subTitle) {
          Text(this.subTitle)
            .fontSize($r('sys.float.Body_M'))
            .fontColor(HeaderConstant.SUB_FONT_COLOR)
        }
      }
      .alignItems(HorizontalAlign.Start)
    }
    .height(this.headerHeight + WindowUtil.getAvoidArea().top)
    .width(HeaderConstant.FULL_PERCENT)
    .justifyContent(FlexAlign.Start)
    .backgroundColor(this.bgColor)
    .padding({ left: this.leftPadding, top: WindowUtil.getAvoidArea().top })
  }
}