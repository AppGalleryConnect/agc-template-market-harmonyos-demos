@ObservedV2
export class VideoNetworkModel {
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
}

@ObservedV2
export class VideoNetworkSetting {
  // 非WLAN网络流量
  @Trace downloadWithoutWlan: number = 0;
  // 非WLAN网络播放提醒
  @Trace remindWithoutWlan: number = 0;
  // 使用移动网络改善内容浏览体验
  @Trace optimizeWith4G: boolean = true;
  // 视频自动下滑
  @Trace autoPlayNext: boolean = true;
  // 推荐频道自动播放视频
  @Trace autoPlayTabRecommend: boolean = true;
  // 直播是否启用小窗播放
  @Trace enableLivePiP: boolean = true;
}

/**
 * 非WLAN网络流量枚举
 */
export enum DownloadWithoutWlanEnum {
  downloadBigPic = 0,
  downloadSmart,
  downloadDisable,
}