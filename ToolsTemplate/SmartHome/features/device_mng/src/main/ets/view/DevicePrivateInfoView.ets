import { webview } from '@kit.ArkWeb';
import { WebInteractModel } from '../model/WebInteractModel';
import { DeviceDetailViewModel } from '../viewmodel/DeviceDetailViewModel';

@ComponentV2
export struct DevicePrivateInfoView {
  @Require @Param deviceDetailViewModel!: DeviceDetailViewModel;
  ports: webview.WebMessagePort[] = [];
  controller: webview.WebviewController = new webview.WebviewController();
  webInteractModel: WebInteractModel = new WebInteractModel(this.deviceDetailViewModel.deviceId, this.controller);

  @Monitor('deviceDetailViewModel.deviceLatestMessage')
  stateChange(monitor: IMonitor) {
    this.updateHtml();
  }

  updateHtml() {
    this.webInteractModel.sendDataToHtml(this.deviceDetailViewModel.deviceLatestMessage);
  }

  build() {
    Column() {
      Web({ src: this.deviceDetailViewModel.detailUrl, controller: this.controller })
        .onPageEnd((event) => {
          this.webInteractModel.createMessagePort();
          this.updateHtml();
        })
        .backgroundColor(Color.Transparent)
        .width('90%');
    };
  }
}