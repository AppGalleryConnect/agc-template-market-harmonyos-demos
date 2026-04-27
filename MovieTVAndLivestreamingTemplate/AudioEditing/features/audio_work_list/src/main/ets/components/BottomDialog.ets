import { BarVM } from 'common';

export class BottomDialogController {
  changeStatus = (status: boolean) => {
  }
}

export interface BottomDialogParams {
  checkAllHandle: (status: boolean) => void //全选点击事件
  delHandle: () => void //删除点击事件
  saveHandle: () => void //保存点击事件
  bdController: BottomDialogController
}

@ComponentV2
export struct BottomDialog {
  @Param @Require params: BottomDialogParams
  @Local status: boolean = false
  changeStatus = (status: boolean) => {
    this.status = status
  }

  aboutToAppear(): void {
    this.params.bdController.changeStatus = this.changeStatus
  }

  build() {
    Row() {
      Row() {
        Image(this.status ? $r('app.media.ic_checked') : $r('app.media.ic_uncheck'))
          .width(18).height(18)
          .margin({ right: 8 })
        Text('全选').fontSize(14).fontColor('#ffffff')
      }.alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.status = !this.status
        this.params.checkAllHandle(this.status)
      })

      Row() {
        Text('删除')
          .width(88)
          .height(32)
          .fontSize(14)
          .halfLeading(true)
          .textAlign(TextAlign.Center)
          .borderRadius(4)
          .fontColor('#99FFFFFF')
          .border({ width: 1, color: '#33FFFFFF' })
          .margin({ right: 8 })
          .onClick(() => {
            this.params.delHandle()
          })

        Text('保存')
          .width(88)
          .height(32)
          .fontSize(14)
          .halfLeading(true)
          .textAlign(TextAlign.Center)
          .borderRadius(4)
          .fontColor('#01FCEA')
          .border({ width: 1, color: '#01FCEA' })
          .onClick(() => {
            this.params.saveHandle()
          })
      }.alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(62 + BarVM.instance.aiBarH)
    .backgroundColor('#232635')
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
  }
}