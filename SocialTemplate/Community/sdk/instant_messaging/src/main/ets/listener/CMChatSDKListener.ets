/**
 * 全局监听类
 */
export interface CMChatSDKListener {
  /**
   * 当前用户被踢下线，此时可以 UI 提示用户，并再次调用 V2TIMManager 的 login() 函数重新登录。
   */
  onKickedOffline?: () => void;
}