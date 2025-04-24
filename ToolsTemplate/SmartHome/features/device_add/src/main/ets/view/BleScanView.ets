import { abilityAccessCtrl } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { BleScanViewModel, BLE_SCAN_STATE } from '../viewmodel/BleScanViewModel';
import { jumpToAppSettings, LogUtil  } from 'utils';

const TAG = 'BleScanView';

@ComponentV2
export struct BleScanView {
  @Require @Param pathStack: NavPathStack;
  @Require @Param bleScanViewModel: BleScanViewModel;

  @Local scanStateBrief: string = '无蓝牙权限'
  @Local scanStateDetail: string = ''
  @Local isShowReScan: boolean = false
  @Local bleScanImage: ResourceStr = $r('app.media.ble_scan')

  @Monitor('bleScanViewModel.scanState')
  scanStateChange(monitor: IMonitor) {
    this.isShowReScan = (this.bleScanViewModel.scanState === BLE_SCAN_STATE.SCANNED_SUCCESS ||
                         this.bleScanViewModel.scanState === BLE_SCAN_STATE.SCANNED_FAIL)
    if (this.bleScanViewModel.scanState === BLE_SCAN_STATE.SCANNED_SUCCESS) {
      this.scanStateBrief = '搜索成功'
      this.scanStateDetail = '已搜索到周边设备'
      this.bleScanImage = $r('app.media.ble_scan')
    } else if (this.bleScanViewModel.scanState === BLE_SCAN_STATE.SCANNED_FAIL) {
      this.scanStateBrief = '搜索失败'
      this.scanStateDetail = '未搜索到周边设备'
      this.bleScanImage = $r('app.media.ble_scan_fail')
    } else if (this.bleScanViewModel.scanState === BLE_SCAN_STATE.SCANNING) {
      this.scanStateBrief = '搜索周边设备'
      this.scanStateDetail = '持续搜索中...'
      this.bleScanImage = $r('app.media.ble_scan')
    }
  }

  openAppInfo() {
    let context = getContext(this) as common.UIAbilityContext;
    jumpToAppSettings(context)
  };

  showBluetoothAlertDialog() {
    this.getUIContext().showAlertDialog(
      {
        title: '蓝牙权限获取',
        message: '应用无蓝牙权限，前往应用中心设置',
        autoCancel: true,
        alignment: DialogAlignment.Bottom,
        offset: { dx: 0, dy: -20 },
        gridCount: 4,
        confirm: {
          value: '确认',
          action: () => {
            this.openAppInfo()
            this.pathStack.pop()
            console.info('Button-clicking callback')
          }
        },
        cancel: () => {
          console.info('Closed callbacks')
        }
      }
    )
  }

  reqBluetoothPermissionFromUser(context: common.UIAbilityContext): void {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(context, ['ohos.permission.ACCESS_BLUETOOTH']).then((data) => {
      this.bleScanViewModel.startBleScan()
    }).catch((err: BusinessError) => {
      LogUtil.error(TAG, 'start scan failed' + err.message)
      this.showBluetoothAlertDialog()
    })
  }

  aboutToAppear(): void {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    this.reqBluetoothPermissionFromUser(context);
  }

  aboutToDisappear(): void {
    this.bleScanViewModel.stopBleScan()
    this.bleScanViewModel.destructor()
  }

  @Builder BuildBleScanImage() {
    Column() {
      Image(this.bleScanImage)
        .size({ width: '50%'})

      Stack() {
        Text('请将手机尽量靠近要添加的设备')
          .fontColor('#666666')
          .fontSize(14)
          .margin({top: 16})
          .visibility(this.isShowReScan ? Visibility.Hidden : Visibility.Visible)

        Text('重新搜索')
          .fontColor('#0A59F7')
          .fontSize(14)
          .margin({top: 16})
          .onClick(() => {
            this.bleScanViewModel.startBleScan()
          })
          .visibility(this.isShowReScan ? Visibility.Visible : Visibility.Hidden)
      }

    }
    .margin({top: 10})
  }

  @Builder BuildBleScanState() {
    Column() {
      Text(this.scanStateBrief)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .height(20)

      Row() {
        Text(this.scanStateDetail)
          .fontColor('#666666')
          .fontSize(14)

        if (this.bleScanViewModel.scanState === BLE_SCAN_STATE.SCANNING) {
          LoadingProgress()
            .color('#666666')
            .size({width: 20, height: 20})
            .margin({left: 5})
        }
      }
      .margin({top: 10})
      .height(20)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Row() {
      Column() {
        this.BuildBleScanState()
        this.BuildBleScanImage()
      }
      .width('90%')
      .height('80%')
    }
    .justifyContent(FlexAlign.Center)
    .width('90%')
    .height(250)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }
}
