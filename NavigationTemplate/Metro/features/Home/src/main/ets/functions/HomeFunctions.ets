import { newStation, newStations } from 'commonlib'
import { staticMap } from '@kit.MapKit'

export function searchStation(name: string): newStation | null {
  for (let item of newStations) {
    for (let station of item) {
      if (station.name === name) {
        return station
      }
    }
  }
  return null
}

export function getColor(line: string): Resource {
  switch (line) {
    case '1号线':
      return $r('app.color.background_color_line1')
    case '2号线':
      return $r('app.color.background_color_line2')
    case '3号线':
      return $r('app.color.background_color_line3')
    case '4号线':
      return $r('app.color.background_color_line4')
    case '5号线':
      return $r('app.color.background_color_line5')
    case '10号线':
      return $r('app.color.background_color_line10')
    case 'S1号线':
      return $r('app.color.background_color_lineS1')
    case 'S3号线':
      return $r('app.color.background_color_lineS3')
  }
  return $r('app.color.background_color_white')
}

export function getOption(searchStation:newStation|null):staticMap.StaticMapOptions{
  // 设置静态图标记参数
  let markers: Array<staticMap.StaticMapMarker> = [{
    location: {
      latitude: searchStation === null ? 0 : searchStation.latitude,
      longitude: searchStation === null ? 0 : searchStation.longitude,
    },
    defaultIconSize: staticMap.IconSize.TINY
  }];
  // 拼装静态图参数
  let option: staticMap.StaticMapOptions = {
    location: {
      latitude: searchStation === null ? 0 : searchStation.latitude,
      longitude: searchStation === null ? 0 : searchStation.longitude,
    },
    zoom: 15,
    imageWidth: 304,
    imageHeight: 200,
    scale: 2,
    markers: markers,
  };

  return option
}