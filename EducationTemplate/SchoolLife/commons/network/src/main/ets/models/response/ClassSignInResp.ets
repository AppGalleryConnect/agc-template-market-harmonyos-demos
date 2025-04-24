
export enum SignCodeState {
  /**
   * 无效签到码
   */
  INVALID_CODE = 'INVALID_CODE',

  /**
   * 指定课程存在且在课表中，但未到上课时间
   */
  NOT_IN_TIME = 'NOT_IN_TIME',

  /**
   * 签到成功
   */
  SUCCESS = 'SUCCESS',
}

export interface ClassSignInResp {
  signState: SignCodeState; // 签到状态
  courseName: string; // 课程名称
}