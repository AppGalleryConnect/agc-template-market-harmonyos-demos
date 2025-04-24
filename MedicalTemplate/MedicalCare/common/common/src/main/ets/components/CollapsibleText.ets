import measure from '@ohos.measure';
import curves from '@ohos.curves';
import { BusinessError } from '@ohos.base';
import display from '@ohos.display';

/**
 * 可折叠的Text
 */
@Component
@Preview
export struct CollapsibleText {
  @State fontSize: number = 12
  @State longMessage: string = ''
  @State lines: number = 3;
  @State collapseText: string = '...展开'
  screenWidth: number = 0;
  @State isExpanded: boolean = false
  @State textWidth: number = 0
  promise: Promise<Array<display.Display>> = display.getAllDisplays()

  aboutToAppear() {
    this.textWidth = measure.measureText({
      textContent: this.longMessage,
      fontSize: this.fontSize
    })
    console.log(`文本宽度为：${this.textWidth}`)
    this.promise.then((data: Array<display.Display>) => {
      console.log(`所有的屏幕信息：${JSON.stringify(data)}`)
      this.screenWidth = data[0].width
      this.isExpanded = this.screenWidth * this.lines * 1 <= this.textWidth
    }).catch((err: BusinessError) => {
      console.error(`Failed to obtain all the display objects. Code: ${JSON.stringify(err)}`)
    })
  }

  build() {
    Row() {
      Column() {
        if (this.isExpanded) {
          Stack({ alignContent: Alignment.BottomEnd }) {
            Text(this.longMessage)
              .fontSize(this.fontSize)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .maxLines(this.lines)
              .width('100%')
              .textAlign(TextAlign.Start)
            Row() {
              Text(this.collapseText)
                .fontSize(this.fontSize)
                .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
                .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
                .padding({ left: 10 })
            }
            .justifyContent(FlexAlign.End)
            .onClick(() => {
              if (this.collapseText === '...展开') {
                this.collapseText = '收起';
                // 展开动画
                animateTo({
                  duration: 150,
                  curve: curves.springMotion(0.5, 0.8),
                }, () => {
                  this.lines = -1; // 使得设置的最大行属性无效
                })
              } else {
                this.collapseText = '...展开';
                // 收起动画
                animateTo({
                  duration: 100,
                  curve: Curve.Friction,
                }, () => {
                  this.lines = 3; // 只显示3行
                })
              }
            })
          }
        } else {
          Text(this.longMessage)
            .fontSize(this.fontSize)
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
        }
      }
      .width('100%')
    }
  }
}
