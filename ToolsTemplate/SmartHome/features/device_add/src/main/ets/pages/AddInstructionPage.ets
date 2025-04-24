import { AddInstructionViewModel } from '../viewmodel/AddInstructionViewModel'
import { webview } from '@kit.ArkWeb'
import { DeviceBaseInfoView } from 'uicomponents'
import { Constants } from 'utils';

@Builder
export function AddInstructionPageBuilder(name: string, param: Object) {
  AddInstructionPage({deviceName: param as string})
}

@ComponentV2
export struct AddInstructionPage {
  pathStack: NavPathStack = new NavPathStack()

  @Require @Param deviceName: string = ''

  addInstructionViewModel: AddInstructionViewModel = new AddInstructionViewModel(this.deviceName)

  controller: webview.WebviewController = new webview.WebviewController();

  @Builder BuildNextButton() {
    Button('已操作完成，下一步')
      .onClick(() => {
        this.pathStack.pushPathByName('SearchDevicePage', this.deviceName)
      })
      .margin({top: 50})
      .width('90%')
  }

  @Builder BuildDeviceImage() {
    DeviceBaseInfoView({image: this.addInstructionViewModel.deviceImage, name: this.addInstructionViewModel.deviceName})
  }

  @Builder BuildWeb() {
    Column() {
      Web({ src: this.addInstructionViewModel.addInstructionUrl, controller: this.controller})
        .height('90%')
        .width('80%')
        .backgroundColor(Color.Transparent)
        .verticalScrollBarAccess(false)
        .horizontalScrollBarAccess(false)
        .zoomAccess(false)
    }
    .height('60%')
    .width('90%')
    .borderRadius(16)
    .margin({top: 20})
    .backgroundColor(Color.White)
    .hitTestBehavior(HitTestMode.Block)
  }

  build() {
    NavDestination() {
      this.BuildDeviceImage()
      this.BuildWeb()
      this.BuildNextButton()
    }
    .title('添加向导')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
    .onBackPressed(() => {
      const popDestinationInfo = this.pathStack.pop() // 弹出路由栈栈顶元素
      console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo))
      return true
    })
    .backgroundColor(Constants.NAV_DESTINATION_BACKGROUND_COLOR)
  }
}