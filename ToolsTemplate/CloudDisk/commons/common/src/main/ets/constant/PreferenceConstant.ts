/**
 * @fileType: common
 * @zhName: 偏好设置常量类
 */
export class PreferenceConstant {
  //首次进入启动页隐私协议状态
  static readonly FIRST_LAUNCH: string = 'FirstLaunch';

  //隐私空间开关
  static readonly PRIVATE_SPACE_SWITCH_KEY: string = 'PrivateSpaceSwitchKey'

  //隐私空间密码
  static readonly PRIVATE_SPACE_PASSWORD_KEY: string = 'PrivateSpacePasswordKey'

  // 分享链接提取码开关
  static readonly SHARE_LINK_EXTRACTIONCODE_SWITCH: string = 'ShareLinkExtractionCodeSwitch'
}
