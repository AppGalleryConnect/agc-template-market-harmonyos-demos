import { call } from '@kit.TelephonyKit';
import { promptAction } from '@kit.ArkUI';
import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { abilityAccessCtrl, common, Want } from '@kit.AbilityKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import Logger from './Logger';
import { Passenger, TenantInfo } from 'type';

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

export function isValidPhoneNo(phone: string) {
  const phoneReg = /^1(3|4|5|7|8|9)\d{9}$/;
  return phoneReg.test(phone);
}

export function consult(phoneNo: string) {
  if (canIUse('SystemCapability.Applications.Contacts')) {
    call.makeCall(phoneNo, (err) => {
      if (err) {
        Logger.error('make call success');
        promptAction.showToast({ message: '拨打号码失败' });
      } else {
        Logger.info('make call success');
      }
    });
  }
}

export async function requestAndUploadPic(context: common.UIAbilityContext):
  Promise<photoAccessHelper.PhotoSelectResult> {
  let result: Promise<photoAccessHelper.PhotoSelectResult>;
  let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  let requestResult = await atManager.requestPermissionsFromUser(context, ['ohos.permission.READ_MEDIA']);

  if (requestResult.authResults[0] !== -1) {
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    result = photoPicker.select({
      MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
      maxSelectNumber: 1,
    });
    return result;
  }

  return new photoAccessHelper.PhotoSelectResult();
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