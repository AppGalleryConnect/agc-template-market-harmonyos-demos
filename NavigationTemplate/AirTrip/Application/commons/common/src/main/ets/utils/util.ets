import { mapCommon, map, site } from '@kit.MapKit'
import { geoLocationManager } from '@kit.LocationKit';
import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { call } from '@kit.TelephonyKit';
import { DayFormat } from './DayFormat';
import { Decimal } from '@kit.ArkTS';
import { promptAction } from '@kit.ArkUI';

export const getDayLabel = (date: Date) : string=> {
  let today: Date = new Date()
  let tY = today.getFullYear()
  let tM = today.getMonth()
  let tD = today.getDate()
  // 获取星期几 (0-6, 0 是周日，1 是周一，依此类推)
  const dayOfWeek = date.getDay();
  const diffDays = Math.floor((date.getTime() - new Date(tY, tM, tD).getTime()) / (1000 * 60 * 60 * 24)); // 计算两个日期的天数差
  if (diffDays === 0) {
    return '今天';
  } else if (diffDays === 1) {
    return '明天';
  }
  // 如果日期不在今天、明天、后天范围内，返回周几
  const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
  return weekDays[dayOfWeek];
}

// 转换经纬度坐标
export const convertCoordinate = (wgs84Position: mapCommon.LatLng): mapCommon.LatLng => {
  let gcj02Position: mapCommon.LatLng =
    map.convertCoordinateSync(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02, wgs84Position);

  return gcj02Position
}

// 根据经纬度获取城市信息
export const getAddressInfo = async (): Promise<string> => {
  let requestInfo: geoLocationManager.CurrentLocationRequest = {
    'priority': geoLocationManager.LocationRequestPriority.FIRST_FIX,
    'scenario': geoLocationManager.LocationRequestScenario.UNSET,
  };
  let cityName: string = ''
  let location: geoLocationManager.Location = await geoLocationManager.getCurrentLocation(requestInfo)
  if (location) {
    let wgs84Position: mapCommon.LatLng = {
      latitude: location.latitude,
      longitude: location.longitude
    };
    // 转换经纬度坐标
    let gcj02Position: mapCommon.LatLng = convertCoordinate(wgs84Position)
    let params: site.NearbySearchParams = {
      location: gcj02Position,
      pageSize: 1,
      language: 'zh',
    }
    const result = await site.nearbySearch(params);
    if (result.sites?.length) {
      cityName = result.sites[0].addressComponent?.city?.cityName?.replace('市', '') ?? ''
    }
  }
  return new Promise((resolve) => {
    resolve(cityName)
  })
}

// 校验手机号码是否有效
export function checkPhoneValid(phone: string): boolean {
  const chinaMobileRegex = /^1[3-9]\d{9}$/
  return chinaMobileRegex.test(phone)
}

// 格式化日期 MM-DD
export function formatMMDD(time: string): string {
  return `${new DayFormat(new Date(time)).format('MM-DD')}`
}

// 手机号脱敏
export function maskPhone(phone: string): string {
  return phone.toString().replace(/(\d{3})\d{4}(\d{4})/, '$1****$2');
}

// 证件号码脱敏
export function maskCertificate(certificate:string, type:string = 'idCard') {
  if (!certificate) {
    return ''
  }

  const str = certificate.toString();
  const len = str.length;

  switch(type) {
    case 'idCard': // 身份证
    case 'Hukou': // 户口簿
      if (len === 18) {
        return str.substring(0, 6) + '*'.repeat(8) + str.substring(14);
      }
      if (len === 15) {
        return str.substring(0, 6) + '*'.repeat(6) + str.substring(12);
      }
      break;
    case 'passport': // 护照
      if (len <= 5) {
        return str.charAt(0) + '*'.repeat(len - 1);
      }
      return str.charAt(0) + '*'.repeat(3) + str.substring(len - 4);

    case 'hkMacau': // 港澳通行证
      if (len <= 5) {
        return str.charAt(0) + '*'.repeat(len - 1);
      }
      return str.charAt(0) + '*'.repeat(4) + str.substring(len - 4);

    case 'taiwan': // 台胞证
      if (len <= 4) {
        return str.substring(0, 1) + '*'.repeat(len - 1);
      }
      return str.substring(0, 2) + '*'.repeat(4) + str.substring(len - 2);
  }

  return str; // 默认不处理
}

// 随机生成航行时间
export function generateRandomFlightTime(minHours = 1, maxHours = 12): string {
  // 随机生成小时数
  const hours = Math.floor(Number(Decimal.random()) * (maxHours - minHours + 1)) + minHours;
  // 随机生成分钟数（0-59）
  const minutes = Math.floor(Number(Decimal.random()) * 60);

  return `${hours}小时${minutes.toString().padStart(2, '0')}分钟`;
}

// 复制操作
export function pasteText(text: string) {
  // 获取系统剪贴板对象
  let systemPasteboard = pasteboard.getSystemPasteboard();
  // 创建一条纯文本类型的剪贴板内容对象
  let pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
  let textRecord: pasteboard.PasteDataRecord = pasteboard.createRecord(pasteboard.MIMETYPE_TEXT_PLAIN, text);
  let pasteText = pasteData.getPrimaryText()
  if (pasteText) {
    pasteData.replaceRecord(0, textRecord);
  } else {
    pasteData.addRecord(textRecord);
  }
  // 将数据写入系统剪贴板
  systemPasteboard.setData(pasteData).then(()=>{
    promptAction.showToast({
      message: '复制成功'
    })
  })
}

/*
 * 拉起拨号盘进行拨号
 * */
export function callTel(phone: string): void {
  call.makeCall(phone ?? '0564-252525663', (err: BusinessError) => {
    if (err) {
      console.error(`Failed to make call. Code is ${err.code}, Message is ${err.message}`);
      return;
    }
    console.info('Succeeded in making call.');
  })
}

// 判断位置服务是否已经使能
export function checkLocationEnabled(): boolean {
  return geoLocationManager.isLocationEnabled();
}