import { call } from '@kit.TelephonyKit';
import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { common, Want } from '@kit.AbilityKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { Passenger, TenantInfo } from 'type';
import Logger from './Logger';

export function copyText(uiContext: UIContext, orderNo: string) {
  try {
    const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, orderNo);
    const systemPasteboard = pasteboard.getSystemPasteboard();
    systemPasteboard.setData(pasteboardData);
    systemPasteboard.getData().then((data) => {
      if (data) {
        uiContext.getPromptAction().showToast({ message: '复制成功' });
      } else {
        uiContext.getPromptAction().showToast({ message: '复制失败' });
      }
    });
  } catch (e) {
    UtilLog.error(`copyText error ${JSON.stringify(e)}`);
  }
}

export function isValidPhoneNo(phone: string) {
  // 手机号不必填
  if (!phone.length) {
    return true;
  }
  const phoneReg = /^1(3|4|5|7|8|9)\d{9}$/;
  return phoneReg.test(phone);
}

export function consult(phoneNo: string) {
  if (canIUse('SystemCapability.Applications.Contacts')) {
    try {
      call.makeCall(phoneNo, (err) => {
        if (err) {
          Logger.error('make call success');
        } else {
          Logger.info('make call success');
        }
      });
    } catch (e) {
      UtilLog.error(`consult with phone error ${JSON.stringify(e)}`);
    }
  }
}

export async function requestAndUploadPic(): Promise<photoAccessHelper.PhotoSelectResult | void> {
  let photoViewPicker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker();
  return photoViewPicker.select({
    MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
    isEditSupported: false,
    maxSelectNumber: 1,
  } as photoAccessHelper.PhotoSelectOptions)
    .then((result: photoAccessHelper.PhotoSelectResult) => {
      return result;
    })
    .catch((err: BusinessError) => {
      console.error(`PhotoViewPicker.select failed with err: ${err.code}, ${err.message}`);
    });
}

export function getCurrentTime() {
  let date = new Date();

  return date.getFullYear() + '-' + String((date.getMonth() + 1)).padStart(2, '0') + '-' +
  String(date.getDate()).padStart(2, '0') + ' ' +
  String(date.getHours()).padStart(2, '0') + ':' +
  String(date.getMinutes()).padStart(2, '0') + ':' + String(date.getSeconds()).padStart(2, '0');
}

export function getPassengerId(): number {
  let hasList = AppStorage.has('psgList');
  let list: string = AppStorage.get('psgList') ?? '';
  return hasList && list.length !== 0 ? (JSON.parse(list) as Passenger[])?.length : 0;
}

export function hasPassenger(guest: string, phone: string) {
  let passengerId = 0;
  let passengers: Passenger[] = JSON.parse(AppStorage.get('psgList') ?? '[]');

  if (passengers && passengers?.length !== 0) {
    let passenger: Passenger | undefined = passengers
      .find((item: Passenger) => ((item.passengerName === guest) &&
        (item.passengerPhone === phone)));
    if (passenger) {
      passengerId = passenger.passengerId;
    } else {
      passengerId = passengers?.length;
    }
  }
  return passengerId;
}

export function checkPsgInfo(guest: string, phone: string) {
  let result = false;
  if (guest.length === 0 || phone.length === 0) {
    result = true;
  }
  return result;
}

export function doRandBySync(): string {
  let data: string = '';
  let rand = cryptoFramework.createRandom();
  let len = 6;
  try {
    let randData = rand.generateRandomSync(len);
    if (randData !== null) {
      for (let i = 0; i < randData.data.length; i++) {
        data += randData.data[i];
      }
    } else {
      Logger.error('[Sync]: get rand result fail!');
    }
  } catch (error) {
    let e: BusinessError = error as BusinessError;
    Logger.error(`do rand failed, ${e.code}, ${e.message}`);
  }
  return data;
}

export function routeToPetal(context: common.UIAbilityContext, name: string) {
  let tenantInfo: TenantInfo | undefined = AppStorage.get('tenantInfo');
  let petalMapWant: Want = {
    bundleName: 'com.huawei.hmos.maps.app',
    uri: 'maps://routes',
    parameters: {
      linkSource: 'com.atomicservice.5765880207855657821',
      destinationLatitude: Number(tenantInfo?.position[1]) ?? 0,
      destinationLongitude: Number(tenantInfo?.position[0]) ?? 0,
      destinationName: name,
    },
  };
  context.startAbility(petalMapWant);
}

export function formatPriceToNumber(price:number) {
  const num = Number(price);
  return Math.round(Number(num.toPrecision(12)) * 100) / 100;
}