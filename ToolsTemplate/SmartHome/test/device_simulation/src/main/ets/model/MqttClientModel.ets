import {
  MqttClient,
  MqttConnectOptions,
  MqttMessage,
  MqttPublishOptions,
  MqttResponse,
  MqttSubscribeOptions,
} from '@ohos/mqtt';
import { LogUtil } from './LogUtil';
import { prompt } from 'utils';

export enum MQTT_STATE {
  INITIALIZE,
  CONNECTED,
  CONNECTING,
  DISCONNECTED,
  DISCONNECTING,
}

const TAG = 'MqttClient';

@ObservedV2
export class MqttClientModel {
  @Trace receivedMessage: string = '';
  latestState: string = '';
  @Trace mqttConnectState: string = 'init';
  private mqttAsyncClient: MqttClient | null = null;
  private subscribedTopics: string[] = [];

  constructor(subTopics: string[], willTopic: string, willMessage: string) {
    this.init(subTopics, willTopic, willMessage);
  }

  async ConnectMqttBroker(willTopic: string, willMessage: string) {
    if (await this.isConnected()) {
      return;
    }
    let options: MqttConnectOptions = {
      userName: '',
      password: '',
      connectTimeout: 30,
      willOptions: {
        topicName: willTopic,
        message: willMessage,
      },
    };
    await this.mqttAsyncClient?.connect(options).then((data: MqttResponse) => {
      this.RegisterMessageHandler();
      this.RegisterConnectLostHandler();
      this.subscribeTopics(this.subscribedTopics);
      this.mqttConnectState = 'connected';
    }).catch((data: MqttResponse) => {
      prompt('connect failed, rerun. ');
      LogUtil.error(TAG, "connect fail result:" + JSON.stringify(data));
    });
  }

  async isConnected(): Promise<undefined | boolean> {
    if (this.mqttAsyncClient == null) {
      return;
    }
    return this.mqttAsyncClient?.isConnected().then((data: boolean) => {
      if (!data) {
      }
      return data;
    });
  }

  async subscribeTopics(subscribeTopic: string[]) {
    if (subscribeTopic.length === 0) {
      return;
    }
    let options: MqttSubscribeOptions[] = [];
    subscribeTopic.forEach((item) => {
      options.push({ topic: item, qos: 2 });
      this.subscribedTopics.push(item);
    });
    this.mqttAsyncClient?.subscribeMany(options).then((data: MqttResponse) => {
    }).catch((err: MqttResponse) => {
    });
  }

  async publish(topic: string, payload: string): Promise<undefined | void> {
    let publishOption: MqttPublishOptions = {
      topic: topic,
      qos: 1,
      payload: payload,
    };
    if (this.mqttAsyncClient === null) {
      prompt('mqttAsyncClient is null, rerun');
      return;
    }
    this.mqttAsyncClient.publish(publishOption).then((data: MqttResponse) => {
      LogUtil.debug(TAG, 'publish:' + topic + payload + JSON.stringify(data));
    }).catch((err: MqttResponse) => {
      prompt('publish failed, rerun. ' + topic + payload);
      LogUtil.error(TAG, 'publish:' + topic + payload + JSON.stringify(err));
    });
  }

  async init(subTopics: string[], willTopic: string, willMessage: string) {
    this.CreateMqttClient();
    await this.ConnectMqttBroker(willTopic, willMessage);
    this.subscribeTopics(subTopics);
  }

  private ReconnectMqttBroker() {
    this.mqttAsyncClient?.reconnect().then((data: boolean) => {
      if (data) {
        this.mqttConnectState = 'connected';
        this.subscribeTopics(this.subscribedTopics);
        LogUtil.debug(TAG, 'reconnect success');
      } else {
        this.mqttConnectState = 'disconnected';
        LogUtil.debug(TAG, 'reconnect failed');
      }
    });
  }

  private RegisterConnectLostHandler() {
    this.mqttAsyncClient?.connectLost((err: Error, data: MqttResponse) => {
      if (!err) {
        this.mqttConnectState = 'disconnected';
        this.ReconnectMqttBroker();
      } else {
        LogUtil.error(TAG, "connect lost error:" + JSON.stringify(err));
      }
    });
  }

  private CreateMqttClient() {
    this.mqttAsyncClient = new MqttClient({
      url: 'tcp://broker.emqx.io:1883',
      clientId: 'clientId' + Math.random().toString(),
      persistenceType: 1,
    });
  }

  private RegisterMessageHandler() {
    this.mqttAsyncClient?.messageArrived((err: Error, data: MqttMessage) => {
      if (!err) {
        LogUtil.debug(TAG, 'Receive msg:' + JSON.stringify(data));
        this.latestState = data.payload;
        this.receivedMessage = JSON.stringify(data);
      } else {
        LogUtil.error(TAG, "messageArrived error:" + JSON.stringify(err));
      }
    });
  }
}