import { webview } from '@kit.ArkWeb';
import { AddedDevicesModel } from './AddedDevicesModel';
import { BusinessError } from '@kit.BasicServicesKit';

export class WebInteractModel {
  controller: webview.WebviewController;
  ports: webview.WebMessagePort[] = [];
  deviceId: string;

  constructor(deviceId: string, controller: webview.WebviewController) {
    this.deviceId = deviceId;
    this.controller = controller;
  }

  sendDataToHtml(data: string) {
    try {
      if (this.ports && this.ports[1]) {
        this.ports[1].postMessageEvent(data);
      } else {
        console.error(`ports is null, Please initialize first`);
      }
    } catch (error) {
      console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
    }
  }

  createMessagePort() {
    try {
      // 1、创建两个消息端口。
      this.ports = this.controller.createWebMessagePorts();
      // 2、在应用侧的消息端口(如端口1)上注册回调事件。
      this.ports[1].onMessageEvent((result: webview.WebMessage) => {
        if (typeof (result) === 'string') {
          let message: Record<string, string> = JSON.parse(result);
          if (message.type === 'publish') {
            let publish: Record<string, string> = JSON.parse(message.payload);
            AddedDevicesModel.getInstance().publishTopic(this.deviceId, publish.topic, publish.payload);
          } else if (message.type === 'record') {
            AddedDevicesModel.getInstance().addDeviceMessageRecord(this.deviceId, message.payload);
          } else if (message.type === 'state') {
            AddedDevicesModel.getInstance().updateDeviceBriefStateText(this.deviceId, message.payload);
          } else if (message.type === 'connect') {
            AddedDevicesModel.getInstance().updateDeviceMqttBrokerConnectState(this.deviceId, message.payload);
          } else if (message.type === 'subscribe') {
            let subscribe: Record<string, string> = JSON.parse(message.payload);
            AddedDevicesModel.getInstance().subscribeTopic(this.deviceId, subscribe.topic);
          }
        }
      });
      // 3、将另一个消息端口(如端口0)发送到HTML侧，由HTML侧保存并使用。
      this.controller.postMessage('__init_port__', [this.ports[0]], '*');
    } catch (error) {
      console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
    }
  }
}