@ObservedV2
export class NetworkModel {
  private static instance?: NetworkModel
  // 是否有网络
  @Trace hasNet: boolean = true
  // 是否是移动蜂窝网络
  @Trace isCellular: boolean = false;
  // 是否是WiFi网络
  @Trace isWiFi: boolean = false
  // 无网络时，是否已经提示
  @Trace hasOfflineTip: boolean = false;
  // 是否可以使用移动流量
  @Trace canUseMobileData: boolean = false
  // 使用流量播放时，是否已经提示
  @Trace hasUseMobileDataTip: boolean = false;
  // 当前网络是否可用
  @Trace isNetworkAvailable: boolean = true;
  // 网络地址
  @Trace netAddress: string[] = [];

  public static getInstance(): NetworkModel {
    if (!NetworkModel.instance) {
      NetworkModel.instance = new NetworkModel()
    }
    return NetworkModel.instance
  }
}