export class SafetyRuleConstants {
  // 用户是否修改了安全规则,
  // true: 默认关联账户要求，未修改
  // false：不关联账户要求，AGC云存储权限修改为(if true)，具体参考ReadMe中的修改安全规则步骤：
  // agc.cloud.storage[
  //   match:/{bucket}/{path=**}
  // {
  //    allow read, write:if true;
  // }
  // ]
  public static readonly MODIFY_SAFETY_RULE = false;
}