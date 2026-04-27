import { PrompterListVM } from '../viewmodel/PrompterListVM'

import window from '@ohos.window';

@ComponentV2
export struct TelePrompterDialog {
  fontColorList: string[] = ['#FFFFFFFF', '#CCFFFFFF', '#99FFFFFF', '#66FFFFFF', '#33FFFFFF', '#FF01A8FE']
  @Param @Require teleprompterListVM: PrompterListVM

  aboutToAppear(): void {
    //键盘唤起时采用压缩模式，避免textArea换行且超过三行时最后一行被键盘遮挡
    this.getUIContext().setKeyboardAvoidMode(1)
  }

  build() {
    Column() {
      Row() {
        TextArea({
          placeholder: '输入文字...',
          text: this.teleprompterListVM.editTexts[this.teleprompterListVM.activeIndex]?.textVal
        })
          .id('editTextInputId')
          .placeholderColor('rgba(255,255,255,0.4)')
          .fontColor('rgba(255,255,255,0.4)')
          .fontSize(12)
          .placeholderFont({ size: 12 })
          .border({ width: 0 })
          .borderRadius(8)
          .backgroundColor('rgba(255,255,255,0.1)')
          .layoutWeight(1)
          .lineHeight(20)
          .constraintSize({ minHeight: 36, maxHeight: 96 })
          .enterKeyType(EnterKeyType.NEW_LINE)
          .barState(BarState.Off)
          .onAppear(() => {
            // 设置指定组件id获得焦点
            this.getUIContext().getFocusController().requestFocus('editTextInputId')
          })
          .onChange((value) => {
            if (this.teleprompterListVM.editTexts[this.teleprompterListVM.activeIndex]) {
              this.teleprompterListVM.editTexts[this.teleprompterListVM.activeIndex].textVal = value
              this.teleprompterListVM.editTexts[this.teleprompterListVM.activeIndex]?.scroller?.scrollEdge(Edge.Bottom)
            }
          })
        Image($r('app.media.icon_telepromter_sure')).width(20).height(13).margin({ left: 18 })
          .onClick(() => {
            this.teleprompterListVM.editStatus = false
            if (!this.teleprompterListVM.editTexts[this.teleprompterListVM.activeIndex].textVal) {
              this.teleprompterListVM.delEditText(this.teleprompterListVM.activeIndex)
            } else {
              this.teleprompterListVM.editTexts[this.teleprompterListVM.activeIndex].scroller?.scrollTo({
                yOffset: 0,
                xOffset: 0
              })
            }
          })
      }.margin({ top: 16, left: 16, right: 16 })

      Column() {
        Text('颜色选择').fontSize(12).fontColor('rgba(255,255,255,0.4)').width('100%')
        Row() {
          Image($r('app.media.icon_color_select')).width(32).height(32).borderRadius(32)
            .onClick(() => {
              this.teleprompterListVM.colorSelectStatus = true
            })
          Divider().vertical(true).color('rgba(255,255,255,0.5)').height(32).margin({ left: 16, right: 16 })
          Row() {
            ForEach(this.fontColorList, (item: string, index: number) => {
              Stack() {
                Circle({ width: 32, height: 32 }).fill(item)
                Circle({ width: 24, height: 24 }).fill(item)
                  .stroke('#000000')
                  .strokeWidth(2)
                  .visibility(this.teleprompterListVM.editTexts[this.teleprompterListVM.activeIndex]?.colorVal ===
                    item ? Visibility.Visible : Visibility.None)
              }.onClick(() => {
                this.teleprompterListVM.editTexts[this.teleprompterListVM.activeIndex].setColor(item)
              })

            })
          }.layoutWeight(1).justifyContent(FlexAlign.SpaceAround)
        }.margin({ top: 9 })
      }
      .margin({
        top: 12,
        left: 16,
        right: 16,
        bottom: 29
      })
    }
    .width('100%')
    .borderRadius({
      topLeft: 20,
      topRight: 20,
      bottomLeft: 0,
      bottomRight: 0
    })
    .backgroundColor('#262626')
  }
}