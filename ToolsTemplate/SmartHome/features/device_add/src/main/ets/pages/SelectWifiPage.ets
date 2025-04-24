import { Constants } from 'utils';
import { DeviceBaseInfoView } from 'uicomponents';
import { SelectWifiViewModel } from '../viewmodel/SelectWifiViewModel';
import { window } from '@kit.ArkUI';

@Builder
export function SelectWifiPageBuilder(name: string, param: Object) {
  SelectWifiPage({ deviceId: param as string })
}

@ComponentV2
export struct SelectWifiPage {
  pathStack: NavPathStack = new NavPathStack()
  @Require @Param deviceId: string = ''
  selectWifiViewModel: SelectWifiViewModel = new SelectWifiViewModel(this.deviceId)
  windowClass: window.Window | undefined
  options: Array<SelectOption> = [];
  selectedWifiIndex: number = 0
  wifiName: string = ''

  @Styles
  InputStyle() {
    .width('80%')
    .backgroundColor(Color.White)
  }

  GetSelectOption(): void {
    this.selectWifiViewModel.allWifi.forEach((item) => {
      this.options.push({ value: item, icon: $r('app.media.wlan') });
    })
  }

  aboutToAppear(): void {
    this.GetSelectOption();
    window.getLastWindow(getContext(this), (error, data) => {
      if (error.code) {
        return
      }
      this.windowClass = data
      this.setWindowPrivacyMode(true)
    })
  }

  setWindowPrivacyMode(isPrivacy: boolean) {
    try {
      this.windowClass?.setWindowPrivacyMode(isPrivacy, (err) => {
        if (err.code) {
          console.error('Failed to set the window privacy mode ' + isPrivacy + '. Cause:' + JSON.stringify(err));
          return;
        }
      });
    } catch (exception) {
      console.error('Failed to set the window privacy mode ' + isPrivacy + '. Cause:' + JSON.stringify(exception));
    }
  }

  @Builder
  BuildWifiNameInput() {
    Select(this.options)
      .optionHeight(300)
      .value('点击选择Wi-Fi')
      .margin({ top: 50 })
      .InputStyle()
      .onSelect((index: number, text?: string | undefined) => {
        if (text) {
          this.wifiName = text
        }
      })
  }

  @Local wifiPassword: string = ''

  @Builder
  BuildWifiPasswordInput() {
    TextInput({ placeholder: 'Wi-Fi密码' })
      .type(InputType.Password)
      .margin({ top: 20 })
      .InputStyle()
      .onChange((value: string) => {
        this.wifiPassword = value
      })
  }

  @Builder
  BuildNextButton() {
    Button('下一步')
      .margin({ top: 100 })
      .width('60%')
      .onClick(() => {
        this.selectWifiViewModel.setWifi(this.wifiName, this.wifiPassword)
        this.pathStack.pushPathByName('ConfigDevicePage', this.deviceId)
      })
  }

  @Builder
  BuildSetWifi() {
    this.BuildWifiNameInput()
    this.BuildWifiPasswordInput()
  }

  build() {
    NavDestination() {
      Column() {
        DeviceBaseInfoView({ image: this.selectWifiViewModel.deviceImage, name: this.selectWifiViewModel.deviceName })
        this.BuildSetWifi()
        this.BuildNextButton()
      }
      .height('100%')
      .width('100%')
      .expandSafeArea([SafeAreaType.SYSTEM])
    }
    .title('选择Wi-Fi')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
    .onBackPressed(() => {
      const popDestinationInfo = this.pathStack.pop() // 弹出路由栈栈顶元素
      console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo))
      return true
    })
    .onShown(() => {
      this.setWindowPrivacyMode(true)
    })
    .onHidden(() => {
      this.setWindowPrivacyMode(false)
    })
    .backgroundColor(Constants.NAV_DESTINATION_BACKGROUND_COLOR)
  }
}