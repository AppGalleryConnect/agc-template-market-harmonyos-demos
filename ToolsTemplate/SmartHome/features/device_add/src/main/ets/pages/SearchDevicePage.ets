import { Constants } from 'utils';
import { BleScanView } from '../view/BleScanView'
import { BleScanViewModel } from '../viewmodel/BleScanViewModel';
import { DeviceBaseInfoView } from 'uicomponents'
import { SearchDeviceViewModel } from '../viewmodel/SearchDeviceViewModel';
import { BleScannedDevicesView } from '../view/BleScannedDevicesView';

@Builder
export function SearchDevicePageBuilder(name: string, param: Object) {
  SearchDevicePage({deviceName: param as string})
}

@ComponentV2
export struct SearchDevicePage {
  @Require @Param deviceName: string = ''
  pathStack: NavPathStack = new NavPathStack()
  bleScanViewModel: BleScanViewModel = new BleScanViewModel([this.deviceName])
  searchDeviceViewModel: SearchDeviceViewModel = new SearchDeviceViewModel(this.deviceName)

  build() {
    NavDestination() {
      DeviceBaseInfoView({image: this.searchDeviceViewModel.deviceImage, name: this.searchDeviceViewModel.deviceName})
      BleScanView({pathStack: this.pathStack, bleScanViewModel: this.bleScanViewModel})
        .margin({top: 20})
      BleScannedDevicesView({pathStack : this.pathStack, bleClientViewModel: this.bleScanViewModel})
        .margin({top: 20})
    }
    .title('搜索设备')
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