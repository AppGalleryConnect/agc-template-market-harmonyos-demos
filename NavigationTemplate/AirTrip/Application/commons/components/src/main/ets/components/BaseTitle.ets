@ComponentV2
export struct BaseTitle {
  /** 标题 */
  @Param title: ResourceStr = ''

  /** 如果标题存在图片或其他自定义组件，可以使用该属性 */
  @Builder
  customTitleBuilder() {
  };

  @BuilderParam customTitle: () => void = this.customTitleBuilder;

  @Param isScrollY: boolean = false
  // 页面滚动距离大于100时，头部背景色
  @Param scrollY: number = 0

  /** 背景色 */
  @Param bgColor?: ResourceColor = ''

  /** 是否需要返回按钮 */
  @Param showBackBtn: boolean = false
  @Event onBack: () => void = () => {
  }

  private getContentColor() {
    if (this.isScrollY) {
      return this.scrollY > 1
        ? $r('sys.color.ohos_id_color_text_primary')
        : $r('sys.color.white')
    }
    return $r('sys.color.ohos_id_color_text_primary')
  }

  private getBgColor() {
    if (this.isScrollY) {
      return this.scrollY > 1 ? $r('sys.color.white') : this.bgColor
    }
    return this.bgColor
  }

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.Start,alignItems:ItemAlign.Center }) {
        if (this.showBackBtn) {
          Row() {
            Image($r(`app.media.icon_back`))
              .width(24)
              .height(24)
              .fillColor(this.getContentColor())
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .onClick(() => {
            if (this.onBack) {
              this.onBack()
            }
          })
        }
        Row() {
          if (this.title) {
            Text(this.title)
              .fontSize($r('app.float.title_default_font_size'))
              .textAlign(TextAlign.Start)
              .maxLines(1)
              .textOverflow({overflow: TextOverflow.Ellipsis})
              .fontColor(this.getContentColor())
              .width('calc(100% - 105vp)')
          } else {
            this.customTitle()
          }
        }
        .margin({left: this.showBackBtn ? 8 : 0})
      }
      .padding({ left: 16, right: 16 })
      .height(56)
    }
    .backgroundColor(this.getBgColor())
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }
}