export interface Source {
  source: string;
}

export interface TenantInfo {
  /*主键ID */
  id: number;
  appName: string;

  /*标签列表 */
  labelList: string[];

  /*banner图片url */
  banner: string | Resource;

  /*联系电话 */
  phone: string;

  /*地址 */
  address: string;

  /*坐标 */
  position: string[];

  /*介绍 */
  introduction: string;
}

export enum LoginErrorCode {
  ERROR_CODE_NETWORK_ERROR = 1001502005,
  ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED = 1005300001,
  ERROR_CODE_LOGIN_OUT = 1001502001,
  ERROR_CODE_NOT_SUPPORTED = 1001500003,
  ERROR_CODE_NOT_REQUIRED_SCOPE_OR_PERMISSION = 1001502014
}

export interface PersonalPopInfo {
  type: number,
  avatar: ResourceStr,
  nickname: string,
}