
export interface ClassSignInReq {
  /**
   * 维度，取值范围为-90到90，仅支持WGS84坐标系
   */
  latitude: number;

  /**
   * 经度，取值范围为-180到180，仅支持WGS84坐标系
   */
  longitude: number;

  /**
   * 签到码
   */
  signCode: string;
}