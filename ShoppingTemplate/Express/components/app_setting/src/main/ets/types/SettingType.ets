/**
 * 展示形式
 */
export enum DisplayType {
  // 页面
  PAGE = 'page',
  // 半模态
  SHEET = 'sheet',
}

/**
 * 设置种类枚举类型
 */
export enum SettingType {
  // 路由
  ROUTER = 'router',
  // 开关
  SWITCH = 'switch',
  // 选择
  SELECT = 'select',
  // 文本，点击刷新
  TEXT = 'text',
}

/**
 * 已支持的设置项目
 */
export enum SupportedSetting {
  PRIVACY,
  PUSH_SWITCH,
  CLEAR_CACHE,
  LIGHT_DARK_MODE,
  FONT_SIZE,
  CHECK_VERSION,
  ABOUT,
  WEB,
}

/**
 * 已支持的二级设置页
 */
export enum SettingPageEnum {
  // 隐私设置页面
  SETTING_PRIVACY = 'SettingPrivacy',
  // 字体设置页面
  SETTING_FONT = 'SettingFont',
  // 关于页面
  SETTING_ABOUT = 'SettingAbout',
  // 协议H5页面
  SETTING_AGREEMENT = 'SettingH5',
}