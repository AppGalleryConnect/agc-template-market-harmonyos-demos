class HeaderConstant {
  // 返回图标尺寸_内
  static readonly ICON_SIZE_INNER: number = 24;
  // 返回图标尺寸_外
  static readonly ICON_SIZE_OUTER: number = 40;
  //返回图标背景色
  static readonly ICON_BG_COLOR: Resource = $r('sys.color.comp_background_tertiary');
  // 基础高度
  static readonly HEIGHT: number = 56;
  // 内边距
  static readonly PADDING: number = 16;
  // 外边距
  static readonly MARGIN: number = 8;
  // 全比例
  static readonly FULL_PERCENT: string = '100%';
  // 半比例
  static readonly HALF_PERCENT: string = '50%';
}

@ComponentV2
export struct CommonHeader {
  // 路由对象
  @Require @Param stack: NavPathStack;
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
  // 自定义Ui
  @BuilderParam moreUi?: () => void;
  headerHeight: number = HeaderConstant.HEIGHT;

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
          this.stack.pop(this.backAnimation);
        })
      }

      Text(this.title ? this.title : ' ')
        .fontWeight(FontWeight.Bold)
        .fontSize($r('sys.float.Title_S'))
        .fontColor($r('sys.color.font_primary'))
        .layoutWeight(1)

      this.moreUi?.()
    }
    .height(this.headerHeight)
    .width(HeaderConstant.FULL_PERCENT)
    .justifyContent(FlexAlign.Start)
    .backgroundColor(this.bgColor)
    .padding({ left: HeaderConstant.PADDING, right: HeaderConstant.PADDING })
  }
}