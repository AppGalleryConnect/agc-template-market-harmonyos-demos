/**
 * @usage: 用于通用卡片单元格场景。提供标题、内容区域和右侧操作区域的卡片布局，支持自定义插槽。
 * 关键数据结构：cellTitle（标题字符串或资源）、titleColor（标题颜色）、titleSize（标题大小）、
 * titleWeight（标题粗细）、customBuilderParam（内容插槽）、rightTextBuilderParam（右侧插槽）、
 * leftTextBuilderParam（左侧插槽）、showRightText（是否显示右侧内容布尔值）、bgColor（背景颜色）、
 * onRightCellClick（右侧点击回调函数）。包含if逻辑：根据插槽是否存在显示不同内容。
 * @layout: 垂直布局。顶部为标题行（左侧标题或自定义插槽、右侧"更多"按钮或自定义插槽，横向排列），
 * 下方为内容区域（自定义插槽）。整体使用圆角卡片背景。
 * @constraints: cellTitle标题可选（有leftTextBuilderParam时可不传），customBuilderParam内容插槽可选
 * @isGen: true
 * @fileType: component
 * @zhName: 基础单元格组件
 */
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