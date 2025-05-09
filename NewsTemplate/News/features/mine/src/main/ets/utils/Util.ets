// 手机号脱敏
export function maskPhone(phone: string): string {
  return phone.toString().replace(/(\d{3})\d{4}(\d{4})/, '$1****$2');
}