import { Constants } from 'utils'
import { ConfigDeviceViewModel } from '../viewmodel/ConfigDeviceViewModel'

@Builder
export function ConfigDevicePageBuilder(name: string, param: Object) {
  ConfigDevicePage({ deviceId: param as string })
}

@ComponentV2
export struct ConfigDevicePage {
  pathStack: NavPathStack = new NavPathStack()

  @Param deviceId: string = ''

  private connectDeviceViewModel = new ConfigDeviceViewModel(this.deviceId)

  @Builder BuildCompleteButton() {
    Button('完成')
      .onClick(() => {
        this.connectDeviceViewModel.complete()
        this.pathStack.clear()
      })
      .width('80%')
      .visibility((this.connectDeviceViewModel.progress === 100) ? Visibility.Visible: Visibility.Hidden)
  }

  @Builder BuildProgress() {
    Column() {
      Progress({ value: this.connectDeviceViewModel.progress, total: 100, type: ProgressType.Ring })
        .width(200)
        .style({ strokeWidth: 35, enableScanEffect: true })
      Text('配置进展: ' + this.connectDeviceViewModel.progress + '%')
        .margin({top: 10})
    }
    .height('60%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    NavDestination() {
      Column() {
        this.BuildProgress()
        this.BuildCompleteButton()
      }
      .height('100%')
      .width('100%')
      .expandSafeArea([SafeAreaType.SYSTEM])
    }
    .title('配置设备')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
    .onBackPressed(() => {
      const popDestinationInfo = this.pathStack.pop()
      console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo))
      return true
    })
    .backgroundColor(Constants.NAV_DESTINATION_BACKGROUND_COLOR)
  }
}