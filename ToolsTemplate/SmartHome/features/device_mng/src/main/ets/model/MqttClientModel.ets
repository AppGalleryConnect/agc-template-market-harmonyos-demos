import {
  MqttClient,
  MqttConnectOptions,
  MqttMessage,
  MqttPublishOptions,
  MqttResponse,
  MqttSubscribeOptions,
} from '@ohos/mqtt';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { LogUtil } from 'utils';
import { prompt, ObserverMngModel } from 'utils';

export enum MQTT_STATE {
  INITIALIZE,
  CONNECTED,
  CONNECTING,
  DISCONNECTED,
  DISCONNECTING,
}

const TAG = 'MqttClient';

export interface MqttClientObserverIntf {
  OnMessageReceive(message: string, data: MqttMessage): void;

  OnMqttStateChange(mqttState: MQTT_STATE): void;
}

export class MqttClientModel extends ObserverMngModel<MqttClientObserverIntf> {
  private mqttAsyncClient: MqttClient | null = null;
  private mqttState: MQTT_STATE = MQTT_STATE.INITIALIZE;
  private subscribedTopics: string[] = [];

  constructor() {
    super();
    this.init();
  }

  async ConnectMqttBroker() {
    if (await this.isConnected()) {
      return;
    }
    this.SetMqttState(MQTT_STATE.CONNECTING);

    let options: MqttConnectOptions = {
      userName: '',
      password: '',
      connectTimeout: 30,
    };
    await this.mqttAsyncClient?.connect(options).then((data: MqttResponse) => {
      this.RegisterMessageHandler();
      this.RegisterConnectLostHandler();
      this.SetMqttState(MQTT_STATE.CONNECTED);
      this.subscribeTopics(this.subscribedTopics);
      LogUtil.debug(TAG, 'connect success');
    }).catch((data: MqttResponse) => {
      LogUtil.debug(TAG, 'connect failed');
      prompt('Connect mqtt broker failed, rerun')
      this.SetMqttState(MQTT_STATE.DISCONNECTED);
    });
  }

  async isConnected() {
    if (this.mqttAsyncClient == null) {
      return false;
    }
    let ret: boolean = false;
    await this.mqttAsyncClient?.isConnected().then((data: boolean) => {
      ret = data;
    });
    return ret;
  }

  async subscribeTopics(subscribeTopic: string[]) {
    if (subscribeTopic.length === 0) {
      return;
    }
    let options: MqttSubscribeOptions[] = [];
    subscribeTopic.forEach((item) => {
      options.push({ topic: item, qos: 2 });
    });
    this.mqttAsyncClient?.subscribeMany(options).then((data: MqttResponse) => {
      LogUtil.debug(TAG, 'subscribeTopics success:' + JSON.stringify(data));
    }).catch((err: MqttResponse) => {
      LogUtil.debug(TAG, 'subscribeTopics failed:' + JSON.stringify(err));
    });
  }

  subscribeTopic(subscribeTopic: string) {
    LogUtil.debug(TAG, 'subscribeTopic:' + subscribeTopic);
    this.subscribedTopics.push(subscribeTopic);
    let topics: string[] = [];
    topics.push(subscribeTopic);
    this.subscribeTopics(topics);
  }

  public async publishTopic(topic: string, payload: string) {
    LogUtil.debug(TAG, 'publishTopic:' + topic + payload);
    let publishOption: MqttPublishOptions = {
      topic: topic,
      qos: 1,
      payload: payload,
    };
    if (this.mqttAsyncClient == null) {
      return;
    }
    this.mqttAsyncClient.publish(publishOption).then((data: MqttResponse) => {
      LogUtil.debug(TAG, 'publishTopic success:' + topic + payload);
    }).catch((err: MqttResponse) => {
      LogUtil.error(TAG, 'publishTopic failed:' + topic + payload);
    });
  }

  async init() {
    this.CreateMqttClient();
    await this.ConnectMqttBroker();
  }

  private CreateMqttClient() {
    let rand = cryptoFramework.createRandom();
    let randData = rand.generateRandomSync(24);
    if (randData === null) {
      return;
    }
    this.mqttAsyncClient = new MqttClient({
      url: 'tcp://broker.emqx.io:1883',
      clientId: 'clientId' + randData.data,
      persistenceType: 1,
    });
  }

  private RegisterMessageHandler() {
    this.mqttAsyncClient?.messageArrived((err: Error, data: MqttMessage) => {
      if (!err) {
        LogUtil.debug(TAG, 'Receive msg:' + JSON.stringify(data));
        this.observers.forEach((item) => {
          item.OnMessageReceive(JSON.stringify(data), data);
        });
      } else {
      }
    });
  }

  private SetMqttState(mqttState: MQTT_STATE) {
    this.mqttState = mqttState;
    this.observers.forEach((item) => {
      item.OnMqttStateChange(mqttState);
    });
  }

  private ReconnectMqttBroker() {
    this.mqttAsyncClient?.reconnect().then((data: boolean) => {
      if (data) {
        LogUtil.debug(TAG, 'reconnect success');
        this.SetMqttState(MQTT_STATE.CONNECTED);
        this.subscribeTopics(this.subscribedTopics);
      } else {
        LogUtil.debug(TAG, 'reconnect failed');
        this.SetMqttState(MQTT_STATE.DISCONNECTED);
      }
    });
  }

  private RegisterConnectLostHandler() {
    this.mqttAsyncClient?.connectLost((err: Error, data: MqttResponse) => {
      if (!err) {
        this.SetMqttState(MQTT_STATE.DISCONNECTED);
        this.ReconnectMqttBroker();
        LogUtil.debug(TAG, 'connect lost:' + JSON.stringify(data));
      } else {
        LogUtil.debug(TAG, 'connect lost2:' + JSON.stringify(data));
      }
    });
  }
}
