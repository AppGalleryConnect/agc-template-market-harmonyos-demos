import { connection, http } from '@kit.NetworkKit';
import { netQuality } from '@kit.NetworkBoostKit';
import { PersistenceV2 } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { NetworkModel } from '../models/NetworkModel';
import { Logger } from './Logger';
import { SettingModel } from '../models/SettingModel';

const TAG = '[NetworkUtil]'

export class NetworkUtil {
  private static instance?: NetworkUtil
  private networkModel: NetworkModel = NetworkModel.getInstance()
  // 创建网络NetConnection对象
  private netCon: connection.NetConnection = connection.createNetConnection();
  private settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;

  public static getInstance(): NetworkUtil {
    if (!NetworkUtil.instance) {
      NetworkUtil.instance = new NetworkUtil()
    }
    return NetworkUtil.instance
  }

  init() {
    // 获取默认网络
    this.getNetwork();
    // 获取网络的连接信息
    this.getConnectNetAddress()
    // 订阅指定网络状态变化的通知。
    this.registerNet()
    // 通过访问网络图片来判断流量管理中的网络是否可用
    this.handleNetworkAvailable()
    // 监听网络质量
    this.netQualityListener()
  }

  getNetwork() {
    let netHandle = connection.getDefaultNetSync();
    // 是否有网络
    if (netHandle.netId >= 100) {
      this.networkModel.hasNet = true;
      // 获取netHandle对应网络的能力信息
      let capInfo = connection.getNetCapabilitiesSync(netHandle)
      if (capInfo.bearerTypes[0] === 0) {
        this.networkModel.isCellular = true
        this.networkModel.isWiFi = false
      } else if (capInfo.bearerTypes[0] === 1) {
        this.networkModel.isCellular = false
        this.networkModel.isWiFi = true
      }
    } else {
      this.networkModel.hasNet = false;
      this.networkModel.isCellular = false
      this.networkModel.isWiFi = false
    }

    Logger.info(TAG, `getDefaultNetSync: ${JSON.stringify(netHandle)}`)
  }

  getConnectNetAddress() {
    let netHandle = connection.getDefaultNetSync();
    // 是否有网络
    if (netHandle.netId >= 100) {
      const connectInfo = connection.getConnectionPropertiesSync(netHandle);
      if (connectInfo.dnses.length > 0) {
        this.networkModel.netAddress = connectInfo.dnses.map((item: connection.NetAddress) => item.address)
      }
    }
    Logger.info(TAG, `getConnectNetAddress, get current netAddress is: ${JSON.stringify(this.networkModel.netAddress)}`)
  }

  handleNetworkAvailable() {
    try {
      let httpRequest = http.createHttp();
      let options: http.HttpRequestOptions = {
        readTimeout: 3000,
        connectTimeout: 3000,
      };
      httpRequest.request(
        'https://www-file.huawei.com/admin/asset/v1/pro/view/2644ff4ada00431f91c7d31209cf5f9b.jpg',
        options,
        (err: BusinessError, data: http.HttpResponse) => {
          if (err) {
            const noNetworkErrors = [2300005, 2300006, 2300007]
            if (noNetworkErrors.includes(err.code)) {
              this.networkModel.isNetworkAvailable = false
            }
          } else {
            this.networkModel.isNetworkAvailable = true
          }
        })
    } catch (error) {
      Logger.error(TAG, `handleNetworkAvailable error: ${JSON.stringify(error)}`);
    }
  }

  netQualityListener() {
    try {
      netQuality.on('netSceneChange', (list: Array<netQuality.NetworkScene>) => {
        if (list.length > 0) {
          list.forEach((scene) => {
            // WiFi是弱网情况，且流量管理里面的移动数据开关打开，则切换到移动数据
            if (this.settingInfo.network.optimizeWith4G && scene.scene === 'weakSignal' &&
              scene.pathType === netQuality.PathType.WIFI_PRIMARY
            ) {
              try {
                let netHandles = connection.getAllNetsSync();
                for (let i = 0; i < netHandles.length; i++) {
                  let item = netHandles[i];
                  if (item.netId !== 0) {
                    let netCapabilities = connection.getNetCapabilitiesSync(item);
                    if (netCapabilities.bearerTypes[0] === connection.NetBearType.BEARER_CELLULAR) {
                      connection.setAppNet(item);
                      return;
                    }
                  }
                }
              } catch (error) {
                Logger.error(TAG, `netQualityListener error: ${JSON.stringify(error)}`);
              }
            }
          });
        }
      });
    } catch (error) {
      Logger.error(TAG, `netQuality.on error: ${JSON.stringify(error)}`);
    }
  }

  registerNet() {
    this.netCon.register((error: BusinessError) => {
      Logger.error(TAG, `network register error: ${JSON.stringify(error)}`)
    });
    // 订阅网络可用事件。调用register后，才能接收到此事件通知。
    this.netCon.on('netAvailable', (data: connection.NetHandle) => {
      Logger.info(TAG, `netAvailable, get data: ${JSON.stringify(data)}`)
    });
    // 订阅网络阻塞状态事件。调用register后，才能接收到此事件通知。
    this.netCon.on('netBlockStatusChange', (data: connection.NetBlockStatusInfo) => {
      Logger.info(TAG, `netBlockStatusChange, get data: ${JSON.stringify(data)}`)
    });
    // 订阅网络能力变化事件。调用register后，才能接收到此事件通知。
    this.netCon.on('netCapabilitiesChange', (data: connection.NetCapabilityInfo) => {
      Logger.info(TAG, `netCapabilitiesChange, get data: ${JSON.stringify(data)}`)

      if (data.netHandle.netId >= 100) {
        this.networkModel.hasNet = true;
        // 蜂窝网络
        if (data.netCap.bearerTypes[0] === 0) {
          this.networkModel.isCellular = true
          this.networkModel.isWiFi = false
        } else if (data.netCap.bearerTypes[0] === 1) { // Wi-Fi网络
          this.networkModel.isCellular = false
          this.networkModel.isWiFi = true
        }
        // 有网络时，重置状态
        this.networkModel.hasOfflineTip = false;
      } else {
        this.networkModel.hasNet = false;
        this.networkModel.isCellular = false
        this.networkModel.isWiFi = false
      }

      // 通过网络图片判断网络是否可以使用
      this.handleNetworkAvailable()
    });
    // 订阅网络连接信息变化事件。调用register后，才能接收到此事件通知。
    this.netCon.on('netConnectionPropertiesChange', (data: connection.NetConnectionPropertyInfo) => {
      const connectionProperties = data.connectionProperties;
      const dnses = connectionProperties.dnses;
      this.networkModel.netAddress = dnses.map((item: connection.NetAddress) => item.address);
      Logger.info(TAG,
        `netConnectionPropertiesChange, current netAddress is: ${JSON.stringify(this.networkModel.netAddress)}`)
    });
    // 订阅网络丢失事件。调用register后，才能接收到此事件通知。
    this.netCon.on('netLost', (data: connection.NetHandle) => {
      Logger.info(TAG, `netLost, get data: ${JSON.stringify(data)}`)
      this.networkModel.hasNet = false;
      this.networkModel.isCellular = false
      this.networkModel.isWiFi = false
      this.networkModel.isNetworkAvailable = false
    });
  }

  unregister() {
    this.netCon.unregister((error: BusinessError) => {
      Logger.error(TAG, `unregister network: ${JSON.stringify(error)}`)
    });
    try {
      netQuality.off('netSceneChange');
    } catch (err) {
      Logger.info(TAG, `off netSceneChange error: ${JSON.stringify(err)}`)
    }
  }
}