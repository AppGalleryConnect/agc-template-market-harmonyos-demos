/**
 * 格式化日期
 * @param date
 * @returns
 */
export function formatDate(date: Date): string {
  return `${date.getFullYear()}-${padZero(date.getMonth() + 1)}-${padZero(date.getDate())}`;
}

/**
 * 不足两位补零
 * @param input
 * @returns
 */
export function padZero(input: number): string {
  return input.toString().padStart(2, '0');
}

/**
 * 校验手机号
 * @param phone
 * @returns
 */
export function isPhoneNumberValid(phone: string): boolean {
  const PHONE_REG = /^[1][3-9][0-9]{9}$/;
  return PHONE_REG.test(phone);
}

/**
 * 手机号码中间4位加密处理
 * @param phone
 * @param maskChar
 * @returns
 */
export function encryptPhone(phone: string, maskChar: string = '*'): string {
  if (!phone) {
    return '';
  }
  if (phone.includes('*')) {
    return phone;
  }
  return phone.replace(/(\d{3})(\d{4})(\d{4})/, `$1${maskChar.repeat(4)}$3`);
}