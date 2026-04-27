import { ReportData, ReportItem } from '../../models/ReportData'
import { promptAction } from '@kit.ArkUI'

@ComponentV2
export struct FullScreenReport {
  private uiContext: UIContext = this.getUIContext();
  @Local reportData: ReportData = new ReportData()
  @Local reasons: Array<string> = []
  @Local inputLength: number = 0
  @Local isEditing: boolean = false
  @Event setHide: () => void
  @Event closeAll: () => void
  @Event onReport: Function = () => {
  }

  build() {
    Row() {
      Column()
        .height('100%')
        .layoutWeight(1)
        .onClick(() => {
          this.closeAll()
        })
      Column() {
        Row() {
          Image($r('app.media.back'))
            .width(40)
            .height(40)
            .borderRadius(20)
            .margin({ left: 24 })
            .onClick(() => {
              this.setHide()
            })
          Text('举报')
            .height(27)
            .fontSize(20)
            .fontWeight(700)
            .fontColor('#fff')
            .margin({ left: 8 })
        }
        .width('100%')
        .height(56)
        .margin({ top: 22 })

        Scroll() {
          Column() {
            Row() {
              Image($r('app.media.cover_1'))
                .width(176)
                .height(100)
            }
            .width(328)
            .height(100)
            .margin({ top: 8 })
            .justifyContent(FlexAlign.Center)

            Grid() {
              ForEach(
                this.reportData.topReasonList,
                (item: ReportItem, index: number) => {
                  GridItem() {
                    Text(item.reason)
                      .width(104)
                      .height(28)
                      .borderRadius(14)
                      .backgroundColor(!item.isSelected ? '#333333' :
                        '#E84026')
                      .fontSize(14)
                      .fontWeight(500)
                      .fontColor('#fff')
                      .textAlign(TextAlign.Center)
                      .margin({ top: 6, bottom: 6 })
                      .onClick(() => {
                        if (!item.isSelected) {
                          this.reasons.push(item.reason)
                        } else {
                          this.reasons.splice(this.reasons.indexOf(item.reason), 1)
                        }
                        this.reportData.topReasonList[index].isSelected =
                          !this.reportData.topReasonList[index].isSelected
                      })
                  }
                },(item: ReportItem, index: number) => { return index + '__' + JSON.stringify(item); }
              )
            }
            .columnsTemplate('1fr 1fr 1fr')
            .rowsTemplate('1fr 1fr')
            .columnsGap(8)
            .rowsGap(4)
            .width(328)
            .height(84)
            .margin({ top: 16 })

            Stack({ alignContent: Alignment.BottomEnd }) {
              TextArea({ placeholder: '请输入详细举报内容，便于平台鉴定违规情况（非必选）' })
                .caretColor('#EE5D1A')
                .selectedBackgroundColor('#EE5D1A')
                .width(328)
                .height(72)
                .fontSize(12)
                .lineHeight(16)
                .fontColor('#fff')
                .fontWeight(400)
                .maxLength(30)
                .backgroundColor('rgb(32, 34, 36)')
                .borderRadius(4)
                .padding(8)
                .placeholderColor('rgba(255, 255, 255, 0.4)')
                .placeholderFont({ size: 12 })
                .onChange((v) => {
                  this.inputLength = v.length
                })
                .onEditChange((isEditing: boolean) => {
                  this.isEditing = isEditing
                })

              Text(`${this.inputLength}/30`)
                .height(16)
                .fontSize(12)
                .fontWeight(400)
                .fontColor('rgba(255, 255, 255, 0.4)')
                .margin({ bottom: 8, right: 8 })
            }
            .width(328)
            .height(72)
            .margin({ top: 4, bottom: this.isEditing ? 75 : 0 })
          }
        }
        .width(328)
        .height(200)
        .scrollBar(BarState.Off)

        Button('提交')
          .width(328)
          .height(40)
          .borderRadius(20)
          .backgroundColor('#E84026')
          .fontWeight(500)
          .margin({ top: 16 })
          .onClick(() => {
            if(this.reasons.length === 0){
              this.uiContext.getPromptAction().showToast({ message: '请选择举报条目后提交' })
              return
            }
            this.uiContext.getPromptAction().showToast({ message: '举报成功' })
            this.onReport(this.reasons)
            this.setHide()
          })
      }
      .width(368)
      .height('100%')
      .backgroundColor($r('app.color.normal_font_color'))
      .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
    }
    .width('100%')
    .height('100%')
  }
}