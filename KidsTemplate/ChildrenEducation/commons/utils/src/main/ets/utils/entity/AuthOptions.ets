import { userAuth } from '@kit.UserAuthenticationKit';

/**
 * 认证参数类
 */
export class AuthOptions {
  /**
   * 挑战值，用来防重放攻击。最大长度为32字节，可传Uint8Array([])。
   */
  challenge?: Uint8Array;
  /**
   * 认证类型列表，用来指定用户认证界面提供的认证方法。
   */
  authType: userAuth.UserAuthType[] =
    [userAuth.UserAuthType.FINGERPRINT, userAuth.UserAuthType.FACE, userAuth.UserAuthType.PIN];
  /**
   * 认证信任等级
   */
  authTrustLevel: userAuth.AuthTrustLevel = userAuth.AuthTrustLevel.ATL3;
  /**
   * 用户认证界面的标题，最大长度为500字符。
   */
  title: string = '请验证身份';
  /**
   * 导航按键的说明文本，最大长度为60字符。仅在单指纹、单人脸场景下支持。
   */
  navigationButtonText?: string;
  /**
   * 默认不显示提示语
   */
  showTip?: boolean = false;
}


/**
 * 查询认证能力是否支持的 返回参数类
 */
export interface StatusResult {
  status: boolean;
  errorCode?: number;
  errorMsg?: string;
}
