import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import Decimal from '@arkts.math.Decimal';
import { geoLocationManager } from '@kit.LocationKit';
import { map, mapCommon } from '@kit.MapKit';

export function copyString(param: string = '') {
  let pasteData: pasteboard.PasteData =
    pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, param)
  let systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
  systemPasteboard.setData(pasteData)
    .then(() => {
      console.info('succeeded in setting PasteData. ')
      promptAction.showToast({
        message: $r('app.string.copy_success'),
        duration: 2000,
      });
    })
    .catch((err: BusinessError) => {
      console.error(`faild to set PasteData, ${JSON.stringify(err)}`)
    })
}

export function getAnonymousTel(userTel: string = '') {
  if (userTel.length >= 8) {
    return `${userTel.substring(0, userTel.length - 8)}****${userTel.substring(userTel.length - 4)}`
  } else {
    return '****';
  }
}

export function getFmtDistWithLocation(myLocation: geoLocationManager.Location, toLocation: string): string {
  return getDistance(getDistanceWithLocation(myLocation, toLocation));
}

export function getDistanceWithLocation(myLocation: geoLocationManager.Location, toLocation: string): number {
  let locationArr = toLocation.split(',')
  if (locationArr?.length === 2) {
    let fromLatLng: mapCommon.LatLng = {
      latitude: myLocation.latitude,
      longitude: myLocation.longitude,
    };

    let toLatLng: mapCommon.LatLng = {
      latitude: Number(locationArr[0]),
      longitude: Number(locationArr[1]),
    };
    return map.calculateDistance(fromLatLng, toLatLng);
  } else {
    return 0
  }
}

export function getDistanceByLocation(fromLatLng: mapCommon.LatLng, toLatLng: mapCommon.LatLng): string {
  return getDistance(map.calculateDistance(fromLatLng, toLatLng));
}

export function getDistance(distance: number = 0) {
  if (distance > 1000) {
    return `${new Decimal(distance).div(1000).toFixed(2)}KM`
  } else {
    return `${new Decimal(distance).toFixed(2)}M`;
  }
}

export function getTime(date: Date): string {
  let hours = `0${date.getHours()}`.slice(-2)
  let minutes = `0${date.getMinutes()}`.slice(-2)
  return `${hours}:${minutes}`
}

export function getSecond(date: Date): string {
  let hours = `0${date.getHours()}`.slice(-2)
  let minutes = `0${date.getMinutes()}`.slice(-2)
  let seconds = `0${date.getSeconds()}`.slice(-2)
  return `${hours}:${minutes}:${seconds}`
}

export function getDate(date: Date): string {
  let year = date.getFullYear()
  let month = `0${date.getMonth() + 1}`.slice(-2)
  let day = `0${date.getDate()}`.slice(-2)
  return `${year}-${month}-${day}`
}

export function getFullDate(date: Date): string {
  return `${getDate(date)} ${getSecond(date)}`
}