class HeaderConstant {
  // 返回图标尺寸_外
  static readonly ICON_SIZE: number = 40;
  // 基础高度
  static readonly HEIGHT: number = 56;
  // 内边距
  static readonly PADDING: number = 16;
  // 外边距
  static readonly MARGIN: number = 8;
  // 全比例
  static readonly FULL_PERCENT: string = '100%';
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
  // 返回事件
  @Event backClick?:()=>void;
  // 背景颜色
  @Param bgColor: ResourceColor = Color.Transparent;
  headerHeight: number = HeaderConstant.HEIGHT;

  build() {
    Row() {
      Image($r('app.media.ic_back_network'))
        .aspectRatio(1)
        .width(HeaderConstant.ICON_SIZE)
        .margin({ right: HeaderConstant.MARGIN })
        .onClick(() => {
          this.backClick?.();
          this.stack.pop(this.backAnimation);
        })

      Text(this.title ? this.title : ' ')
        .fontWeight(FontWeight.Bold)
        .fontSize($r('sys.float.Title_S'))
        .fontColor($r('sys.color.font_on_primary'))
        .layoutWeight(1)
    }
    .height(this.headerHeight)
    .width(HeaderConstant.FULL_PERCENT)
    .justifyContent(FlexAlign.Start)
    .backgroundColor(this.bgColor)
    .padding({ left: HeaderConstant.PADDING, right: HeaderConstant.PADDING })
  }
}