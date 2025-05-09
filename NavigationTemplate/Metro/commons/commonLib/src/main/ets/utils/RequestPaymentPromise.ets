import { paymentService } from '@kit.PaymentKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

export function requestPaymentPromise(context: common.UIAbilityContext) {
  // use your own orderStr
  const orderStr = '{"app_id":"***","merc_no":"***","prepay_id":"xxx","timestamp":"1680259863114","noncestr":"1487b8a60ed9f9ecc0ba759fbec23f4f","sign":"****","auth_id":"***"}';
  paymentService.requestPayment(context, '{}')
    .then(() => {
      // pay success
      console.info('succeeded in paying');
    })
    .catch((error: BusinessError) => {
      // failed to pay
      console.error(`failed to pay, error.code: ${error.code}, error.message: ${error.message}`);
    });
}