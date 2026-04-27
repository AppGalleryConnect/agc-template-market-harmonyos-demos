/**
 * 手机号码的校验工具类
 */
export class PhoneValidatorUtil {
  // 主要运营商号段（2025年常用）
  private static readonly MOBILE_SEGMENTS: string[] = [
    // 移动
    '134', '135', '136', '137', '138', '139', '147', '148', '150', '151', '152',
    '157', '158', '159', '165', '172', '178', '182', '183', '184', '187', '188', '198',
    // 联通
    '130', '131', '132', '145', '146', '155', '156', '166', '167', '171', '175', '176', '185', '186',
    // 电信
    '133', '149', '153', '173', '177', '180', '181', '189', '191', '199',
    // 虚拟运营商
    '170', '171'
  ];

  /**
   * 判断是否为合法的中国大陆手机号
   * @param phone 手机号码字符串
   * @returns 是否合法
   */
  public static isValidPhoneNumber(phone: string): boolean {
    // 1. 基本检查
    if (!phone || phone.length !== 11) {
      return false;
    }

    // 2. 必须是纯数字
    if (!/^\d+$/.test(phone)) {
      return false;
    }

    // 3. 必须1开头
    if (!phone.startsWith('1')) {
      return false;
    }

    // 4. 检查运营商号段（前3位）
    const prefix3 = phone.substring(0, 3);

    // 检查是否为有效号段
    for (const segment of PhoneValidatorUtil.MOBILE_SEGMENTS) {
      if (phone.startsWith(segment)) {
        return true;
      }
    }

    return false;
  }
}