import { ConfigurationConstant } from '@kit.AbilityKit';

/**
 * 全局设置
 */
@ObservedV2
export class SettingModel {
  // 通知开关
  @Trace pushSwitch: boolean = false;
  // 深色模式
  @Trace darkSwitch: boolean = false;
  // 深浅色模式
  @Trace colorMode: ConfigurationConstant.ColorMode = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
  // 字体大小
  @Trace fontSizeRatio: number = 1;
  // 隐私设置-个性化推荐
  @Trace personalizedPush: boolean = true;
  // 播放与网络设置
  @Trace network: SettingNetworkModel = new SettingNetworkModel();
}

@ObservedV2
export class SettingNetworkModel {
  // 非WLAN网络流量
  @Trace downloadWithoutWlan: number = 0;
  // 非WLAN网络播放提醒
  @Trace remindWithoutWlan: number = 0;
  // 使用移动网络改善内容浏览体验
  @Trace optimizeWith4G: boolean = true;
  // 直播是否启用小窗播放
  @Trace enableLivePiP: boolean = true;
  // 视频自动下滑
  @Trace autoPlayNext: boolean = true;
  // 推荐频道自动播放视频
  @Trace autoPlayTabRecommend: boolean = true;
}