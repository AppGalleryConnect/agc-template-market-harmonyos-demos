import { BleScanView } from '../view/BleScanView'
import { AddButtonView } from '../view/AddButtonView';
import { BleScanViewModel } from '../viewmodel/BleScanViewModel';
import { BleScannedDevicesView } from '../view/BleScannedDevicesView';
import { AddDeviceViewModel } from '../viewmodel/AddDeviceViewModel';

@Builder
export function AddDevicePageBuilder(name: string, param: Object) {
  AddDevicePage()
}

@ComponentV2
export struct AddDevicePage {
  pathStack: NavPathStack = new NavPathStack()
  addDeviceViewModel: AddDeviceViewModel = new AddDeviceViewModel()
  bleScanViewModel: BleScanViewModel = new BleScanViewModel(this.addDeviceViewModel.deviceNamesToScan)

  build() {
    NavDestination() {
      Column() {
        BleScanView({pathStack : this.pathStack, bleScanViewModel: this.bleScanViewModel})
        AddButtonView({pathStack : this.pathStack})
          .margin({top: 20})
        BleScannedDevicesView({pathStack : this.pathStack, bleClientViewModel: this.bleScanViewModel})
          .margin({top: 20})
      }
      .height('100%')
      .width('100%')
      .expandSafeArea([SafeAreaType.SYSTEM])
    }
    .title('添加设备')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
    .onBackPressed(() => {
      const popDestinationInfo = this.pathStack.pop() // 弹出路由栈栈顶元素
      console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo))
      return true
    })
    .backgroundColor('#F1F3F5')
  }
}