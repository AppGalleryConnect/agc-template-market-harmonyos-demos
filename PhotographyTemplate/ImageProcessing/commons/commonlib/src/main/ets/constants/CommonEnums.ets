export enum RouterMap {
  // app隐私
  PRIVACY_POLICY_PAGE = 'PrivacyPolicyPage',
  // app隐私声明
  PRIVACY_STATEMENT_PAGE = 'PrivacyStatementPage',
  // 广告页
  SPLASH_PAGE = 'SplashPage',
  // 主页
  MAIN_ENTRY = 'MainEntry',
  // 登录
  LOGIN_PAGE = 'LoginPage',

  // -----------------------------------------------------首页
  // 图片选择页
  PHOTO_PICKER_PAGE = 'PhotoPickerPage',
  // 图片美化页
  PICTURE_BEAUTIFICATION = 'PictureBeautification',
  // 图片分享页
  SHARE_IMAGE_PAGE = 'ShareImagePage',
  // 图片拼图页
  COLLAGE_PAGE = 'CollagePage',
  // 下载
  IMAGE_DOWNLOAD = 'ImageDownloadPage',
  // 滤镜相机
  LUT_CAMERA_PAGE = 'LutCameraPage',

  // -----------------------------------------------------我的
  // 个人信息页
  PERSONAL_INFO_PAGE = 'PersonalInfoPage',
  // 设置
  SETTING_PAGE = 'SettingPage',
  // 关于
  ABOUT_PAGE = 'AboutPage',
  // 服务条款
  TERMS_PAGE = 'TermsPage',
  //开通会员
  OPENVIP_PAGE = 'OpenVipPage',
  // 会员页面
  VIP_PAGE = 'VipPage',
}

/**
 * AppStorage应用临时缓存映射表
 */
export enum AppStorageMap {
  TOKEN = 'Token',
}

// url命名
export enum URL_MAP {
  // 用户登录
  USER_LOGIN = '/image-processing/user/login',
  // 用户登出
  USER_LOGOUT = '/image-processing/user/logout',
  // 读取用户信息
  GET_USER_INFO = '/image-processing/user/info',
  // 更新用户信息
  UPDATE_USER_INFO = '/image-processing/user/info/update',
}

// 图片的操作类型
export enum OperateType {
  NONE = 'none', // 无操作
  FILTER = 'filter', // 滤镜
  CROP = 'crop', // 调整：裁剪 和 旋转
  STICKER = 'sticker', // 贴纸
  TEXT = 'text', // 添加文案
  MOSAIC = 'mosaic', // 马赛克
  SCRAWL = 'scrawl', // 涂鸦
  WATERMARK = 'watermark', // 水印
}