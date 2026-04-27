/**
 * 修改个人信息
 */
export interface ModifyPersonalInfoRequest {
  userIcon?: string;
  userNickName?: string;
  userPhone?: string;
  verifyCode?: string;
}

/**
 * 登录请求
 */
export interface SignInRequest {
  loginChannel?: string;
  uid?: string;
}

/**
 * 获取验证码
 */
export interface SendCodeRequest {
  phone: string;
}

/**
 * 验证短信验证码
 */
export interface VerifyCodeRequest {
  phone: string;
  code: string;
}

/**
 * 验证短信验证码
 */
export interface GetProductExpireTimeRequest {
  productId: string;
  time?: number;
}