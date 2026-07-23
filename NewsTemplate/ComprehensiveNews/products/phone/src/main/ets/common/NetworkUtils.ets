import { NetworkUtil } from 'lib_common';

/**
 * 网络工具类
 */
export class NetworkUtils {
  /**
   * 注册网络监听
   */
  public static initNetwork() {
    let networkInstance = NetworkUtil.getInstance();
    networkInstance.init();
  }

  /**
   * 取消注册网络监听
   */
  public static unRegisterNetwork() {
    let networkInstance = NetworkUtil.getInstance();
    networkInstance.unregister();
  }
}