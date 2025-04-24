import { MqttClientModel } from '../model/MqttClientModel';
import { BleServerModel } from '../model/BleServerModel';

@Entry
@ComponentV2
struct Index {
  @Styles
  deviceStyle() {
    .margin({ top: 20 })
    .width('80%');
  }

  @Styles
  cardStyle() {
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: '#B0B1B3',
      offsetY: 10,
      fill: false,
    });
  }

  build() {
    Column() {
      Column() {
        Text('模拟灯');
        Row() {
          MyLight({ deviceUuid: '3' });
        }
        .cardStyle()
        .justifyContent(FlexAlign.Center);
      }
      .deviceStyle()
      .alignItems(HorizontalAlign.Start);
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#F1F3F5')
    .expandSafeArea([SafeAreaType.SYSTEM])
    .justifyContent(FlexAlign.Center);
  }
}

@ComponentV2
struct MyLight {
  @Param deviceUuid: string = '';
  bleServerModel = new BleServerModel(this.deviceUuid);
  bleIsOn: boolean = false;
  marginAttr: number = 10;

  onChangeBleState(isOn: boolean) {
    if (isOn) {
      this.bleServerModel.startAdvertiser();
    } else {
      this.bleServerModel.stopAdvertiser();
    }
  }

  @Builder
  BuildBleSwitch() {

    Row() {
      Text('蓝牙开关')
        .height(30)
        .margin({ left: this.marginAttr });
      Blank();
      Toggle({ type: ToggleType.Switch, isOn: this.bleIsOn })
        .selectedColor('#007DFF')
        .switchPointColor('#FFFFFF')
        .onChange((isOn: boolean) => {
          this.onChangeBleState(isOn);
        })
        .margin({ left: 70 })
        .height(20);
    }
    .width('90%')
    .height(50)
    .borderRadius(16)
    .margin({ top: 20 });

  }

  @Styles
  TextStyle() {
    .height(30)
    .margin({ left: this.marginAttr });
  }

  @Builder
  BuildLightInfo() {
    Column() {
      Text('设备信息').TextStyle();
      Column() {
        Text('蓝牙状态：' + this.bleServerModel.bleState).TextStyle();
        Text('wifi配置：' + this.bleServerModel.wifi).TextStyle();
      }
      .height(90)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
      .width('90%')
      .backgroundColor('#F1F3F5');
    }
    .margin({ bottom: 20 })
    .alignItems(HorizontalAlign.Start);

  }

  build() {
    Column() {
      MyLightBrief({ deviceUuid: this.deviceUuid });

      this.BuildBleSwitch();
      this.BuildLightInfo();
    };
  }
}


@ComponentV2
struct MyLightBrief {
  @Local lightIsOn: boolean = false;
  @Param deviceUuid: string = '';
  subTopics: string[] = [
    'light/' + this.deviceUuid + '/cmd',
    'light/' + this.deviceUuid + '/getState',
  ];
  willTopic = 'light/' + this.deviceUuid + '/connect';
  willMessage = '{"onOff": "off"}';
  mqttClient = new MqttClientModel(this.subTopics, this.willTopic, this.willMessage);
  marginAttr: number = 10;

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  @Monitor('mqttClient.mqttConnectState')
  isConnectChange(monitor: IMonitor) {
    if (this.mqttClient.mqttConnectState === 'connected') {
      this.delay(2000).then(() => {
        this.publishLightState();
      })
    }
  }

  handleCmdMsg(payload: string) {
    let cmd: Record<string, string> = JSON.parse(payload);
    this.lightIsOn = (cmd.lightSwitch == 'on');
  }

  handleGetStateMsg() {
    this.publishLightState();
  }

  @Monitor('mqttClient.receivedMessage')
  receivedMessageChange(monitor: IMonitor) {
    let message: Record<string, string> = JSON.parse(this.mqttClient.receivedMessage);
    let topic = message.topic;
    topic = topic.replace(this.deviceUuid, '$deviceUuid');
    if (topic === 'light/$deviceUuid/cmd') {
      this.handleCmdMsg(message.payload);
    } else if (topic === 'light/$deviceUuid/getState') {
      this.handleGetStateMsg();
    }
  }

  getLightImg(): Resource {
    if (this.lightIsOn) {
      return $r('app.media.light_on');
    } else {
      return $r('app.media.light_off');
    }
  }

  publishLightState() {
    let topic = 'light/$deviceUuid/state';
    topic = topic.replace('$deviceUuid', this.deviceUuid);
    if (this.lightIsOn) {
      this.mqttClient.publish(topic, '{"onOff": "on"}');
    } else {
      this.mqttClient.publish(topic, '{"onOff": "off"}');
    }
  }

  @Builder
  BuildLightImg() {
    Column() {
      Image(this.getLightImg())
        .size({ width: 70, height: 70 });

      Text(this.mqttClient.mqttConnectState)
        .fontSize(12);
    }
    .height(100)
    .width(100)
    .justifyContent(FlexAlign.Center);
  }

  @Builder
  BuildLightSwitch() {

    Row() {
      Text('灯开关')
        .height(30)
        .margin({ left: this.marginAttr });

      Blank();
      Toggle({ type: ToggleType.Switch, isOn: this.lightIsOn })
        .selectedColor('#007DFF')
        .switchPointColor('#FFFFFF')
        .onChange((isOn: boolean) => {
          this.lightIsOn = isOn;
          this.publishLightState();
        })
        .height(20)
        .margin({ right: 10 });
    }
    .width('40%')
    .height(50)
    .borderRadius(16)
    .margin({ left: 70 });
  }

  build() {
    Row() {
      this.BuildLightImg();
      Blank();
      this.BuildLightSwitch();
    };
  }
}
