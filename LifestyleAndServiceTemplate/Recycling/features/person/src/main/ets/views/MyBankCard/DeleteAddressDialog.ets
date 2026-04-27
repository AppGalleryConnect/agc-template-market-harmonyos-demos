import { promptAction } from '@kit.ArkUI'
import { AddressManagerItem, AddressManagerPageVM } from '../../viewmodel/AddressManagerPageVM'

@ComponentV2
export struct DeleteAddressDialog {
  @Param @Require vm: AddressManagerPageVM
  @Param deleteId: string = ''

  @Builder
  renderBtn() {
    Row() {
      Text('取消')
        .height(40)
        .fontSize(16)
        .textAlign(TextAlign.Center)
        .layoutWeight(1)
        .border({ color: 'rgba(0, 0, 0, 0.2)', width: 1, radius: 22 })
        .backgroundColor('rgba(255, 255, 255, 1)')
        .fontColor('rgba(0, 0, 0, 0.6)')
        .margin({ right: 8 })
        .onClick(() => {
          promptAction.closeCustomDialog(this.vm.deleteDialogId)
        })

      Text('确定')
        .height(40)
        .fontSize(16)
        .textAlign(TextAlign.Center)
        .layoutWeight(1)
        .fontColor('rgba(255, 255, 255, 1)')
        .backgroundColor('rgba(255, 75, 75, 1)')
        .borderRadius(22)
        .onClick(() => {
          this.vm.addressList = this.vm.addressList.filter((item: AddressManagerItem, index: number) => {
            return item.id !== this.deleteId
          })
          promptAction.closeCustomDialog(this.vm.deleteDialogId)
          // 给出提示
          promptAction.showToast({
            message: '地址已删除成功'
          })
        })
    }.width('100%').margin({ bottom: 24 })
  }

  build() {
    Column() {
      // 标题
      Text('是否删除该地址')
        .width('100%')
        .height(56)
        .fontSize(20)
        .fontColor('rgba(0, 0, 0, 0.90)')
        .textAlign(TextAlign.Center)
        .margin({ top: 16, bottom: 16 })

      this.renderBtn()

    }.width('100%').padding({ left: 16, right: 16 })
  }
}