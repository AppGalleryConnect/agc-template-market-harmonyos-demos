import { ConfigurationConstant } from '@kit.AbilityKit';
import { ColorModeName } from '../constants/ColorModeEnum';

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
  // 模式名称
  @Trace colorModeName: ColorModeName = ColorModeName.FOLLOW_SYSTEM;
  // 字体大小
  @Trace fontSizeRatio: number = 1;
  // 隐私设置-个性化推荐
  @Trace personalizedPush: boolean = true;
  // 播放与网络设置
  @Trace network: SettingNetworkModel = new SettingNetworkModel();

  getNameByColorMode(colorMode: ConfigurationConstant.ColorMode): ColorModeName {
    if (colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET) {
      return ColorModeName.FOLLOW_SYSTEM
    } else if (colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
      return ColorModeName.DARK
    } else if (colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) {
      return ColorModeName.LIGHT
    }
    return ColorModeName.FOLLOW_SYSTEM
  }

  getColorModeByName(modeName: ColorModeName): ConfigurationConstant.ColorMode {
    const modeMap: Record<ColorModeName, ConfigurationConstant.ColorMode> = {
      [ColorModeName.FOLLOW_SYSTEM]: ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET,
      [ColorModeName.DARK]: ConfigurationConstant.ColorMode.COLOR_MODE_DARK,
      [ColorModeName.LIGHT]: ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
    }
    return modeMap[modeName] ?? ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET
  }
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
  // 退出广播，开启小窗播放
  @Trace enableAudioSub: boolean = true

}