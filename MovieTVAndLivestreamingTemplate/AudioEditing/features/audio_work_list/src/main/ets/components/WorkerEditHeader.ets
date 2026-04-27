/**
 * @usage: 作品列表页头部组件,用于作品列表页顶部,显示当前状态(作品/已选择数量)和编辑/取消编辑按钮。
 * 展示标题和编辑按钮,根据isHideBtn参数控制按钮显示/隐藏。
 * @layout: 采用Row横向布局,左侧为标题文字(占据剩余空间),右侧为编辑按钮。
 * 按钮在列表为空时隐藏。
 * @constraints: 必须提供title、btnText和btnClick参数。isHideBtn为可选参数,默认为false。
 * @modifiable: 可修改标题和按钮的字体样式(fontSize/fontColor/fontWeight)、颜色。
 * 可调整布局和间距(padding/margin)。可定制按钮的显示/隐藏逻辑。
 * @domain: 音频编辑
 * @zhName: 作品列表头部
 * @isGen: true
 * @fileType: component
 */
@ComponentV2
export struct WorkerEditHeader {
  @Param title: string = ''
  @Param btnText: string = ''
  @Param isHideBtn?: boolean = false
  @Param btnClick: () => void = () => {
  }

  build() {
    Row() {
      Row() {
        Text(this.title).fontSize(20).fontColor(Color.White).margin({ left: 8 })
      }.layoutWeight(1)
      .height(40)

      if (!this.isHideBtn) {
        Text(this.btnText).fontSize(14).fontColor('#01FCEA')
          .onClick(() => {
            this.btnClick()
          })
      }
    }.width('100%').justifyContent(FlexAlign.SpaceBetween)
    .padding({ top: 8 })
  }
}