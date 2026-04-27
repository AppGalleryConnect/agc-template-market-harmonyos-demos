import { ReportData, ReportItem } from '../models/ReportData'
import { promptAction } from '@kit.ArkUI'

@ComponentV2
export struct Report {
  @Local reportData: ReportData = new ReportData()
  @Local inputLength: number = 0
  @Local isEditing: boolean = false
  @Local reasons: Array<string> = []
  @Event setDisappear: () => void
  @Event onReport: Function = () => {
  }
  reportText: string = ''

  build() {
    Column() {
      Row() {
        Image($r('app.media.handle'))
          .width(48)
          .height(4)
          .margin({ top: 8, left: 24 })
          .onClick(() => {
            this.setDisappear()
          })
      }
      .width(96)
      .height(16)

      Row() {
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_primary')])
        }
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .size({ width: 40, height: 40 })
        .onClick(() => {
          this.setDisappear()
        })

        Text('选择举报原因')
          .width(232)
          .height(27)
          .fontSize(20)
          .fontWeight(700)
          .margin({ left: 8, right: 8 })
        Blank()
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_primary')])
        }
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .size({ width: 40, height: 40 })
        .onClick(() => {
          this.setDisappear()
        })
      }
      .width('100%')
      .height(56)
      .margin({ bottom: 16 })

      Row() {
        Image($r('app.media.cover_1'))
          .width(176)
          .height(100)
      }
      .width('100%')
      .height(100)
      .margin({ top: 16 })
      .justifyContent(FlexAlign.Center)
      .visibility(this.isEditing ? Visibility.Hidden : Visibility.Visible)

      Column({ space: 4 }) {
        Grid() {
          ForEach(
            this.reportData.topReasonList,
            (item: ReportItem, index: number) => {
              GridItem() {
                Text(item.reason)
                  .width(104)
                  .height(28)
                  .borderRadius(14)
                  .backgroundColor(!item.isSelected ? $r('sys.color.comp_background_tertiary') :
                    '#E84026')
                  .fontSize(14)
                  .fontWeight(500)
                  .fontColor(!item.isSelected ? $r('sys.color.font_primary') : '#fff')
                  .textAlign(TextAlign.Center)
                  .margin({ top: 6, bottom: 6 })
                  .onClick(() => {
                    if (!item.isSelected) {
                      this.reasons.push(item.reason)
                    } else {
                      this.reasons.splice(this.reasons.indexOf(item.reason), 1)
                    }
                    this.reportData.topReasonList[index].isSelected = !this.reportData.topReasonList[index].isSelected
                  })
              }
            },(item: ReportItem, index: number) => { return index + '__' + JSON.stringify(item); }
          )
        }
        .columnsTemplate('repeat(auto-stretch, 106)')
        .rowsTemplate('1fr 1fr')
        .columnsGap(8)
        .rowsGap(4)
        .width('100%')
        .height(84)

        Stack({ alignContent: Alignment.BottomEnd }) {
          TextArea({ placeholder: '请输入详细举报内容，便于平台鉴定违规情况（非必选）' })
            .caretColor('#EE5D1A')
            .selectedBackgroundColor('#EE5D1A')
            .width('100%')
            .height(72)
            .borderRadius(4)
            .padding({ top: 8, left: 8, right: 8 })
            .fontSize(14)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .placeholderFont({ size: 12 })
            // .placeholderColor($r('app.color.report_placeholder'))
            .maxLength(30)
            .onChange((value: string) => {
              this.inputLength = value.length
              this.reportText = value
            })
            .onEditChange((isEditing: boolean) => {
              this.isEditing = isEditing
            })

          Text(`${this.inputLength}/30`)
            .height(16)
            .fontSize(12)
            .fontWeight(400)
            .fontColor($r('sys.color.font_tertiary'))
            .margin({ right: 8, bottom: 8 })
        }
        .width('100%')
        .height(72)

        Grid() {
          ForEach(
            this.reportData.bottomReasonList,
            (item: ReportItem, index: number) => {
              GridItem() {
                Text(item.reason)
                  .width(104)
                  .height(28)
                  .borderRadius(14)
                  .backgroundColor(!item.isSelected ? $r('sys.color.comp_background_tertiary') :
                    '#E84026')
                  .fontSize(14)
                  .fontWeight(500)
                  .fontColor(!item.isSelected ? $r('sys.color.font_primary') : '#fff')
                  .textAlign(TextAlign.Center)
                  .margin({ top: 6, bottom: 6 })
                  .onClick(() => {
                    if (!item.isSelected) {
                      this.reasons.push(item.reason)
                    } else {
                      this.reasons.splice(this.reasons.indexOf(item.reason), 1)
                    }
                    this.reportData.bottomReasonList[index].isSelected =
                      !this.reportData.bottomReasonList[index].isSelected
                  })
              }
            },(item: ReportItem, index: number) => { return index + '__' + JSON.stringify(item); }
          )
        }
        .columnsTemplate('repeat(auto-stretch, 106)')
        .rowsTemplate('1fr 1fr 1fr 1fr')
        .columnsGap(8)
        .rowsGap(4)
        .width('100%')
        .height(172)
      }
      .width('100%')
      .height(352)
      .padding({ top: 16 })
      .offset({ y: this.isEditing ? -111 : 0})

      Blank()

      Row() {
        Button('提交')
          .width('100%')
          .height(40)
          .borderRadius(20)
          .backgroundColor('#E84026')
          .fontWeight(500)
          .onClick(() => {
            if (this.reasons.length === 0 && this.reportText.length === 0) {
              this.getUIContext().getPromptAction().showToast({ message: '请选择举报原因后提交' })
              return
            }
            this.getUIContext().getPromptAction().showToast({ message: '举报成功' })
            this.onReport(this.reasons)
            this.setDisappear()
          })
      }
      .width('100%')
      .height(80)
      .margin({ bottom: 24 })
      .offset({ y: this.isEditing ? -278 : 0 })
      .justifyContent(FlexAlign.Center)
    }
    .width('95%')
    .height(665)
  }
}