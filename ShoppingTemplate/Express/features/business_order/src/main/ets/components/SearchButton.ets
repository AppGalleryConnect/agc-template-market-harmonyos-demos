import { ScanUtil } from 'module_base'
import { QueryPageVM } from '../viewModels/QueryPageVM'

@ComponentV2
export struct SearchButton {
  vm: QueryPageVM = QueryPageVM.instance
  controller: TextInputController = new TextInputController()

  build() {
    Flex({ alignItems: ItemAlign.Center }) {
      Image($r('app.media.ic_search'))
        .width(16)
        .height(16)
      TextInput({ text: $$this.vm.searchText, placeholder: '请输入运单/手机号或扫码查询', controller: this.controller })
        .placeholderColor($r('sys.color.font_secondary'))
        .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
        .height(40)
        .fontSize(14)
        .backgroundColor(Color.Transparent)
        .flexGrow(1)
        .onSubmit(() => {
          this.vm.getOrderList()
        })
      Image($r('app.media.ic_scans'))
        .width(16)
        .height(16)
        .onClick(async () => {
          const id = await ScanUtil.getScanResult(this)
        })
    }
    .width('100%')
    .height(40)
    .padding({ left: 12, right: 12 })
    .margin({ bottom: 18 })
    .backgroundColor('rgba(0,0,0,0.05)')
    .borderRadius(8)
  }
}