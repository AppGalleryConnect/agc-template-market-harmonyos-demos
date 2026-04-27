import { connection, http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { NetworkModel } from '../models/NetworkModel';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG = '[NetworkUtil]'

export class NetworkUtil {
  private static instance?: NetworkUtil
  private networkModel: NetworkModel = NetworkModel.getInstance()
  // 创建网络NetConnection对象
  private netCon: connection.NetConnection = connection.createNetConnection();

  public static getInstance(): NetworkUtil {
    if (!NetworkUtil.instance) {
      NetworkUtil.instance = new NetworkUtil()
    }
    return NetworkUtil.instance
  }

  init() {
    // 获取默认网络
    this.getNetwork();
    // 订阅指定网络状态变化的通知。
    this.registerNet()
    // 通过访问网络图片来判断流量管理中的网络是否可用
    this.handleNetworkAvailable()
  }

  getNetwork() {
    try {
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

      UtilLog.info(TAG, `getDefaultNetSync: ${JSON.stringify(netHandle)}`)
    } catch (e) {
      UtilLog.error(TAG, 'getNetCapabilitiesSync fail, error: ' + JSON.stringify(e));
    }
  }


  handleNetworkAvailable() {
    let httpRequest = http.createHttp();
    let options: http.HttpRequestOptions = {
      readTimeout: 3000,
      connectTimeout: 3000,
    };
    httpRequest.request(
      'https://www-file.huawei.com/admin/asset/v1/pro/view/2644ff4ada00431f91c7d31209cf5f9b.jpg',
      options,
      (err: BusinessError) => {
        if (err) {
          const noNetworkErrors = [2300005, 2300006, 2300007]
          if (noNetworkErrors.includes(err.code)) {
            this.networkModel.isNetworkAvailable = false
          }
        } else {
          this.networkModel.isNetworkAvailable = true
        }
      })
  }

  registerNet() {
    this.netCon.register((error: BusinessError) => {
      if (error) {
        UtilLog.error(TAG, `network register error: ${JSON.stringify(error)}`);
      } else {
        UtilLog.info(TAG, 'Succeed to connection.NetConnection register');
      }
    });
    // 订阅网络可用事件。调用register后，才能接收到此事件通知。
    this.netCon.on('netAvailable', (data: connection.NetHandle) => {
      UtilLog.info(TAG, `netAvailable, get data: ${JSON.stringify(data)}`)
    });
    // 订阅网络能力变化事件。调用register后，才能接收到此事件通知。
    this.netCon.on('netCapabilitiesChange', (data: connection.NetCapabilityInfo) => {
      UtilLog.info(TAG, `netCapabilitiesChange, get data: ${JSON.stringify(data)}`)

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
    // 订阅网络丢失事件。调用register后，才能接收到此事件通知。
    this.netCon.on('netLost', (data: connection.NetHandle) => {
      UtilLog.info(TAG, `netLost, get data: ${JSON.stringify(data)}`)
      this.networkModel.hasNet = false;
      this.networkModel.isCellular = false
      this.networkModel.isWiFi = false
      this.networkModel.isNetworkAvailable = false
    });
  }

  unregister() {
    this.netCon.unregister((error: BusinessError) => {
      UtilLog.error(TAG, `unregister network: ${JSON.stringify(error)}`)
    });
    try {
    } catch (err) {
      UtilLog.info(TAG, `off netSceneChange error: ${JSON.stringify(err)}`)
    }
  }
}