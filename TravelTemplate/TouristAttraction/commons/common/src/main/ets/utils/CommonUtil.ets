import { pasteboard } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';

export function padWithZeros(num: number) {
  if (num) {
    return num.toString().padStart(2, '0');
  }
  return '00';
}

export function copyText(orderNo: string) {
  const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, orderNo);
  const systemPasteboard = pasteboard.getSystemPasteboard();
  systemPasteboard.setData(pasteboardData);
  systemPasteboard.getData().then((data) => {
    if (data) {
      promptAction.showToast({ message: '复制成功' });
    } else {
      promptAction.showToast({ message: '复制失败' });
    }
  });
}

export function verifyPhoneNo(phone: string) {
  const phoneReg = /^1(3|4|5|7|8|9)\d{9}$/;
  return phoneReg.test(phone);
}

export function verifyCardNo(cardNo: string) {
  const cardNoReg = /^[1-9]\d{5}(18|19|20)\d{2}((0[1-9])|(1[0-2]))(([0-2][1-9])|10|20|30|31)\d{3}[0-9Xx]$/;
  return cardNoReg.test(cardNo);
}