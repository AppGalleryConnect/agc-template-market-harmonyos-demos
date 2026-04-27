/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { connection } from '@kit.NetworkKit';
import HashSet from '@ohos.util.HashSet';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '../logger/AppLogger';

const TAG: string = 'NetConnectionUtil';

/**
 * 当前网络状态, 网络类型参考@link{connection.NetBearType}
 */
export enum NetworkStatus {
  // 无网络
  NO_NETWORK = -1,
  BEARER_CELLULAR = 0,
  BEARER_WIFI = 1,
  BEARER_ETHERNET = 3,
  BEARER_VPN = 4
}

export enum NetworkConnected {
  NETWORK_CONNECTED = 0,
  NETWORK_NOT_CONNECTED = 1
}

/**
 * 网络连接变化监听器
 *
 */
export interface NetChangeListener {
  /**
   * 网络变化事件
   *
   * @param lastNetType 之前网络连接类型。-1表示无网络
   * @param currentNetType 当前网络连接类型。-1表示无网络
   */
  onNetChange(lastNetType: number, currentNetType: number): void;
}

export class NetConnectionUtil {
  private static instance: NetConnectionUtil = null;

  private netConnection: connection.NetConnection;

  private currentNetType: number = NetworkStatus.BEARER_WIFI;

  private netListeners = new HashSet<NetChangeListener>();

  private constructor() {
  }

  public isNetworkAvailable(): boolean {
    return this.currentNetType !== NetworkStatus.NO_NETWORK;
  }

  /**
   * 获取单例
   *
   * @returns 单例对象
   */
  public static getInstance(): NetConnectionUtil {
    if (!NetConnectionUtil.instance) {
      NetConnectionUtil.instance = new NetConnectionUtil();
    }
    return NetConnectionUtil.instance;
  }

  /**
   * 开始监听网络变化
   */
  public startListenNetChange(): void {
    Logger.info(TAG, "registerNetListener");
    let thus = NetConnectionUtil.instance;

    thus.netConnection = connection.createNetConnection();
    if (!thus.netConnection) {
      Logger.error(TAG, "registerNetListener netConnection null.");
      return;
    }

    // // 先使用register接口注册订阅事件
    // thus.netConnection.register((error: BusinessError) => {
    //   if (error) {
    //     Logger.error(TAG, `register error: ${error.code}`);
    //   }
    // });

    this.currentNetType = this.getNetworkType()

    // 订阅网络连接信息变化事件。
  /*  thus.netConnection.on('netConnectionPropertiesChange', function (data) {
      Logger.info(TAG, "netConnectionPropertiesChange");
      thus.onReceiveNewNetType(thus.getNetworkType());
    });*/

    // 订阅网络可用事件。需进一步获取网络类型
    thus.netConnection.on('netAvailable', (data: connection.NetHandle) => {
      Logger.info(TAG, "netAvailable");
      thus.onReceiveNewNetType(thus.getNetworkType());
    });

    // 订阅网络丢失事件。
    thus.netConnection.on('netLost', (data: connection.NetHandle) => {
      Logger.info(TAG, "netLost");

      // 网络丢失，那么网络状态就是确定为无网络
      thus.onReceiveNewNetType(NetworkStatus.NO_NETWORK);
    });

    // 订阅网络不可用事件。
    thus.netConnection.on('netUnavailable', () => {
      Logger.info(TAG, "netUnavailable");

      // 网络不可用，那么网络状态就是确定为无网络
      thus.onReceiveNewNetType(NetworkStatus.NO_NETWORK);
    });
  }

  private onReceiveNewNetType(newNetType: number): void {
    let lastNetType = NetConnectionUtil.instance.currentNetType;
    if (lastNetType !== newNetType) {
      NetConnectionUtil.instance.currentNetType = newNetType;
      Logger.info(TAG, "netType changed. last: " + lastNetType + " new: " + newNetType);
      NetConnectionUtil.instance.netListeners.forEach((listener) => {
        listener.onNetChange(lastNetType, newNetType);
      });
    }
  }

  /**
   * 停止监听网络变化
   */
  public stopListenNetChange(): void {
    let thus = NetConnectionUtil.instance;

    if (!thus.netConnection) {
      Logger.error(TAG, "unregisterNetListener netConnection null.");
      return;
    }

    thus.netConnection.unregister((error: BusinessError) => {
      if (error) {
        Logger.error(TAG, `unregister error: ${error.code}`);
      }
    });
    thus.netConnection = null;
    thus.currentNetType = NetworkStatus.NO_NETWORK;
  }

  /**
   * 注册网络变化监听器
   *
   * @param listener 网络变化监听器
   */
  public registerNetChangeListener(listener: NetChangeListener): void {
    if (!listener) {
      Logger.error(TAG, "registerNetChangeListener listener null.");
      return;
    }

    NetConnectionUtil.instance.netListeners.add(listener);
  }

  /**
   * 反注册网络变化监听器
   *
   * @param listener 网络变化监听器
   */
  public unregisterNetChangeListener(listener: NetChangeListener): void {
    if (!listener) {
      Logger.error(TAG, "unregisterNetChangeListener listener null.");
      return;
    }

    NetConnectionUtil.instance.netListeners.remove(listener);
  }

  /**
   * 获取当前网络类型。获取异常则返回无网络
   *
   *  return NetworkStatus 网络类型
   */
  public getNetworkType(): NetworkStatus {
    let networkStatus = NetworkStatus.NO_NETWORK; // 默认无网络
    try {
      // networkStatus = this.getCurrentNetType();
    } catch (err) {
      Logger.info(TAG, `getNetworkType error, ${err}`);
    }
    Logger.info(TAG, "getNetworkType" + networkStatus);
    return networkStatus;
  }

  /**
   * 获取当前连接的网络类型。优先级：以太网>wifi>蜂窝网
   *
   * @returns 当前连接的网络类型（无网络：-1；蜂窝网：0；wifi：1；以太网：3）
   */
  // private getCurrentNetType(): NetworkStatus {
  //   // 调用getDefaultNet方法，获取默认的数据网络(NetHandle)
  //   let netHandler = connection.getDefaultNetSync();
  //   if (!netHandler || netHandler.netId < 100) {
  //     return NetworkStatus.NO_NETWORK;
  //   }
  //
  //   // 获取netHandle对应网络的能力信息。能力信息包含了网络类型、网络具体能力等网络信息
  //   let netCap = connection.getNetCapabilitiesSync(netHandler);
  //   if (!netCap || !netCap.bearerTypes) {
  //     return (NetworkStatus.NO_NETWORK);
  //   }
  //
  //   // 获取网络类型(bearerTypes)
  //   if (netCap.bearerTypes.includes(connection.NetBearType.BEARER_ETHERNET)) {
  //     return NetworkStatus.BEARER_ETHERNET;
  //   }
  //   if (netCap.bearerTypes.includes(connection.NetBearType.BEARER_WIFI)) {
  //     return NetworkStatus.BEARER_WIFI;
  //   }
  //   if (netCap.bearerTypes.includes(connection.NetBearType.BEARER_CELLULAR)) {
  //     return NetworkStatus.BEARER_CELLULAR;
  //   }
  // /*  if (netCap.bearerTypes.includes(connection.NetBearType.BEARER_VPN)) {
  //     return NetworkStatus.BEARER_VPN;
  //   }*/
  //   return NetworkStatus.NO_NETWORK;
  // }
}