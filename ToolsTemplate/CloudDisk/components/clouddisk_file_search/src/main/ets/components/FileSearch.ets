
/**
 * @usage: 用于文件搜索场景。提供搜索输入框、返回按钮和取消按钮，支持搜索提交操作。
 * 关键数据结构：searchText（搜索文本字符串）、showBack（是否显示返回按钮布尔值）、
 * pageParam（页面参数字符串，用于显示搜索占位符）、searchQuery（搜索回调函数，参数为搜索文本）。
 * 包含if逻辑：根据showBack判断是否显示返回按钮，根据pageParam判断搜索框占位符文字。
 * @layout: 横向布局。左侧为返回按钮（showBack为true时显示），中间为搜索框（灰色背景，
 * 占据剩余空间），右侧为"取消"文字按钮。所有元素垂直居中对齐。
 * @constraints: searchQuery回调函数必须正确处理搜索文本，searchText最大长度为10个字符，
 * pageParam可为空（默认显示"搜索全部内容"）
 * @isGen: true
 * @fileType: component
 * @domain: 云存储,
 * @zhName: 文件搜索框组件
 * @subPage:
 * @image: screenshot/Home/file_search.jpg
 */
@ComponentV2
export struct FileSearch {
  @Require @Param showBack: boolean
  @Require @Param pageParam?: string
  @Local searchText: string = ''
  @Event searchQuery: (x: string) => void = () => {
  };
  @Event popPage: () => void = () => {
  };

  build() {
    Row() {
      if (this.showBack) {
        Image($r('app.media.icon_back')).width(28).height(28)
          .onClick(() => {
            this.popPage()
          })
      }

      Search({ value: $$this.searchText, placeholder: this.pageParam ? `搜索${this.pageParam}` : '搜索全部内容' })
        .placeholderFont({ size: $r('sys.float.Body_L') })
        .placeholderColor($r('sys.color.font_secondary'))
        .backgroundColor('#F0F3F7')
        .layoutWeight(1)
        .margin({ left: this.showBack ? 12 : 0, right: 13 })
        .onSubmit(() => {
          this.searchQuery(this.searchText.trim());
        })
        .onChange((value: string) => {
          this.searchText = value.slice(0, 10)
        })
      Text('取消')
        .fontSize(14)
        .fontColor('#000000')
        .onClick(() => {
          this.popPage()
        })
    }
    .height(40)
    .width('100%')
    .margin({ bottom: 15 })
  }
}