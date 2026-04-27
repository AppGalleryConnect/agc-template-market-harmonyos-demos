import { WxExtraInfo } from 'aggregated_payment';
import { OrderInfoUtil } from './OrderInfoUtil';

export class MockApi {
  static isShow: boolean = false;

  static WX_APP_ID: string = 'wx05b3e2e9fc730840';

  static getAliPreOrderInfo() {
    // 支付宝预下单
    return new Promise<string>((resolve, reject) => {
      try {
        OrderInfoUtil.getOrderInfo().then((result) => {
          resolve(result);
        });
      } catch (error) {
        reject('');
      }
    });
  }

  static getWxPreOrderInfo(): WxExtraInfo {
    return{
      partnerId: '2480306091',
      appId: 'wx05b3e2e9fc730840',
      packageValue: 'Sign=WXPay',
      prepayId: 'wx26161523845794ecced251acf2b6860000',
      nonceStr: 'vmall_240926161523_993_2774',
      timeStamp:'1747722044',
      sign : 'rAqsrx5yLfRNBGvlHYuLhUsNK0OPeOLQ5xlvhxFo9guPU4HeNtzRdPaGAXAzXvn7V5chVe8sj3BfvDgwXlCKctCcFIllOgheyZbZ7btFC++9bW0QTijhWo1hZ6LhvjcKQ1zf53RGX7zf7GBu9sheqWPKlWqJJzynBZo8UH5Wow9t/WK5fanNj6ST2U2zPQGxuCH+DBMOKJAhhaalrOXlqj+feEiz1bLAzEmhLzIREgcWJQyZmdI5VO0B8r11ND+o1iBYgoohDUuJc+bd9r6RvmZBSE+HqggWE4p3D0/NzY7mQH+51u0osfOfaTHVLqlUM3IMoXi1vH4a0Qrg1P6c0g==',
      extData: 'extData'
    }
  }

  static getHuaweiOrderInfo() {
    return '{"app_id":"***","merc_no":"***","prepay_id":"xxx","timestamp":"1680259863114","noncestr":"1487b8a60ed9f9ecc0ba759fbec23f4f","sign":"****","auth_id":"***"}';
  }
}

