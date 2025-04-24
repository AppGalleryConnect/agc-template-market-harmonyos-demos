import { webview } from '@kit.ArkWeb';
import { StorageUtil } from 'utils';
import { WebInteractModel } from '../model/WebInteractModel';
import { DeviceCardViewModel } from '../viewmodel/DeviceCardViewModel';

interface HtmlMessage {
  topic: string;
  payload: string;
}

@Styles
function cardStyle() {
  .height(110)
  .width('100%')
  .backgroundColor('#FFFFFF')
  .borderRadius(16)
}

@ComponentV2
export struct DeviceCardView {
  @Require @Param deviceId: string = '';
  @Require @Param pathStack: NavPathStack = new NavPathStack();
  @Param deviceCardViewModel: DeviceCardViewModel = new DeviceCardViewModel(this.deviceId);
  controller: webview.WebviewController = new webview.WebviewController();
  webInteractModel: WebInteractModel = new WebInteractModel(this.deviceCardViewModel.deviceId, this.controller);

  @Monitor('deviceCardViewModel.deviceLatestMessage')
  deviceLatestMessageChange(monitor: IMonitor) {
    this.updateHtml();
  }

  notifyHtmlIsLocalMqttBrokerConnected() {
    let payload: string = '';
    if (this.deviceCardViewModel.isLocalMqttBrokerConnected) {
      payload = '{"onOff":"on"}';
    } else {
      payload = '{"onOff":"off"}';
    }
    let message: HtmlMessage = {
      topic: 'local/connect',
      payload: payload,
    };
    this.webInteractModel.sendDataToHtml(JSON.stringify(message));
  }

  @Monitor('deviceCardViewModel.isLocalMqttBrokerConnected')
  isLocalMqttBrokerConnectedChange(monitor: IMonitor) {
    this.notifyHtmlIsLocalMqttBrokerConnected();
  }

  updateHtml() {
    this.webInteractModel.sendDataToHtml(this.deviceCardViewModel.deviceLatestMessage);
  }

  @Builder
  BuildConnectState() {
    Row() {
      Blank();
      Circle()
        .width(8)
        .height(8)
        .fill(this.deviceCardViewModel.isDeviceE2EConnected ? '#006400' : '#999999')
        .opacity(0.5)
        .margin({ right: 0 });
    }
    .height('10%')
    .width('100%');
  }

  @Builder
  BuildDeviceImageAndName() {
    Column() {
      Image(this.deviceCardViewModel.deviceImage)
        .size({ width: 76 })
        .hitTestBehavior(HitTestMode.None);
      Text(this.deviceCardViewModel.deviceName)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .fontSize(16);
    }
    .width('60%')
    .height('100%')
    .justifyContent(FlexAlign.Center);
  }

  @Builder
  BuildWeb() {
    Web({
      src: this.deviceCardViewModel.briefUrl,
      controller: this.controller,
    })
      .fileAccess(false)
      .geolocationAccess(false)
      .backgroundColor(Color.Transparent)
      .onPageEnd((event) => {
        this.webInteractModel.createMessagePort();
      })
      .zoomAccess(false)
      .horizontalScrollBarAccess(false)
      .verticalScrollBarAccess(false)
      .width('100%')
      .height('90%')
      .hitTestBehavior(HitTestMode.None);
  }

  @Builder
  BuildDeviceBriefInfo() {
    Column() {
      this.BuildConnectState();
      this.BuildWeb();
    }
    .height('100%')
    .width('40%');
  }

  @Builder
  BuildDeviceCard() {
    this.BuildDeviceImageAndName();
    this.BuildDeviceBriefInfo();
  }

  build() {
    Row() {
      Row() {
        this.BuildDeviceCard();
      }
      .height('80%')
      .width('80%');
    }
    .onClick(() => {
      if(StorageUtil.exists('isLogin')) {
        this.pathStack.pushPathByName('DeviceDetailPage', this.deviceCardViewModel.deviceId);
      } else {
        this.pathStack.pushPathByName('QuickLoginPage', null);
      }

    })
    .justifyContent(FlexAlign.Center)
    .cardStyle();
  }
}

@ComponentV2
export struct DeviceCardAddView {
  @Require @Param pathStack: NavPathStack = new NavPathStack();
  @Builder
  BuildAddDevice() {
    Row() {
      Image($r('app.media.plus_blue'))
        .size({ height: 16, width: 16 });

      Text(' 添加设备')
        .fontColor('#0A59F7')
        .fontSize(14)
        .fontWeight(FontWeight.Medium);
    }
    .justifyContent(FlexAlign.Center)
    .width(120)
    .height(32)
    .backgroundColor('#F1F3F5')
    .borderRadius(8);
  }

  build() {
    Row() {
      Row() {
        this.BuildAddDevice();
      }
      .justifyContent(FlexAlign.Center)
      .height('95%')
      .width('95%');
    }
    .onClick(() => {
      if (StorageUtil.exists('isLogin')) {
        this.pathStack.pushPathByName('AddDevicePage', null);
      } else {
        this.pathStack.pushPathByName('QuickLoginPage', null);
      }

    })
    .justifyContent(FlexAlign.Center)
    .cardStyle();
  }
}