@ComponentV2
export struct BaseCell {
  /**
   * 标题文本
   */
  @Param cellTitle: ResourceStr = '默认'
  /**
   * 标题颜色
   */
  @Param titleColor: ResourceStr = $r('sys.color.font_primary')
  /**
   * 标题大小
   */
  @Param titleSize: ResourceStr | number = $r('sys.float.Subtitle_L')
  /**
   * 标题文本粗细
   */
  @Param titleWeight: FontWeight = FontWeight.Bold
  /**
   * 内容显示插槽
   */
  @BuilderParam customBuilderParam?: CustomBuilder;
  /**
   * 右侧侧显示插槽
   */
  @BuilderParam rightTextBuilderParam?: CustomBuilder;
  /**
   * 左侧侧侧显示插槽
   */
  @BuilderParam leftTextBuilderParam?: CustomBuilder;
  /**
   * 是否显示右侧内容
   */
  @Param showRightText: boolean = false
  /**
   * 背景颜色
   */
  @Param bgColor: ResourceStr = $r('sys.color.background_primary')
  /**
   * 右侧侧插槽点击事件
   */
  @Event onRightCellClick: () => void = () => {
  }

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        if (this.leftTextBuilderParam) {
          this.leftTextBuilderParam()
        } else {
          Text(this.cellTitle)
            .fontColor(this.titleColor)
            .fontSize(this.titleSize)
            .fontWeight(this.titleWeight)
        }

        if (!this.rightTextBuilderParam) {
          Row({ space: 5 }) {
            Text('更多')
              .fontColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
            Image($r('app.media.chevron_right')).width(12).height(24)
          }
          .onClick(() => {
            this.onRightCellClick()
          })
          .visibility(this.showRightText ? Visibility.Visible : Visibility.None)
        } else {
          this.rightTextBuilderParam()
        }
      }

      /*
       * 内容区域
       * */
      if (this.customBuilderParam) {
        Column() {
          this.customBuilderParam()
        }
      }
    }
    .backgroundColor(this.bgColor)
    .padding(12)
    .borderRadius(16)
  }
}