export class CommonUtil {
  static padWithZeros(num: number) {
    if (num) {
      return num.toString().padStart(2, '0');
    }
    return '00';
  }

  static verifyPhoneNo(phone: string) {
    const phoneReg = /^1(3|4|5|7|8|9)\d{9}$/;
    return phoneReg.test(phone);
  }

  static verifyCardNo(cardNo: string) {
    const cardNoReg = /^[1-9]\d{5}(18|19|20)\d{2}((0[1-9])|(1[0-2]))(([0-2][1-9])|10|20|30|31)\d{3}[0-9Xx]$/;
    return cardNoReg.test(cardNo);
  }
}