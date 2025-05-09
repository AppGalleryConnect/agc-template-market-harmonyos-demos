import { RandomCountdown } from './RandomCountdown'
import { SearchSet } from 'common';
import { getDataFromJSON } from 'common';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { generateRandomNumber } from './BusStationRandom'

@Component
@Preview
export struct RealTimeBusComponent {
  @Prop @Watch('change') busTimer: RandomCountdown;
  @State busInfo: LineSetInfo = new LineSetInfo('', '', '', 116.490437, 39.90536209, 0);
  @State lineName: string = '';
  @State busStationRandom: Array<string> = ['北京南站'];
  @State randomBus: number = 0;
  @State randomBusStopDistance: number = generateRandomNumber(0, 300);
  @StorageLink('stationCount') stationCount: number = 2; // 距离站数 // 值统一
  @StorageLink('countdownMinute') countdownMinute: number = 15;
  @State countdownSecond: number = 0;
  @State endDir: string = '';
  // 站线名 起点站 终点站 经纬度 站点名 seq
  @State busSetItems: Array<SearchSet> = [];

  change() {
    console.log('111111111111111111' + this.busTimer.nearestFirstStation);
  }

  // 换向
  private refreshDirect() {
    if (this.endDir === this.busInfo.endStation) {
      this.endDir = this.busInfo.startStation;
    } else {
      this.endDir = this.busInfo.endStation;
    }
  }

  aboutToAppear(): void {
    // console.log('111111111111111111nearestFirstStation' + this.busTimer.nearestFirstStation);
    this.endDir = this.busInfo.endStation
    this.busSetItems = getDataFromJSON<SearchSet>('Bus_Station.json', this);
    this.lineName = this.busInfo.lineName
  }

  build() {
    Row() {
      Column() {
        Row() {
          Image($r('app.media.ic_buslogo'))
            .height('24lpx')
            .width('24lpx')
            .margin({ right: '12lpx' })

          Text(this.busStationRandom[this.randomBus])
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#e6000000')
        }

        Divider()
          .margin({ top: 9, bottom: 7 })
          .strokeWidth('1px').color($r('sys.color.ohos_id_color_list_separator'))

        Row() {
          Text() {
            Span(this.busInfo.lineName)
          }
          .fontSize(12)
          .fontWeight(FontWeight.Regular)
          .margin({ right: 4 })

          Text() {
            Span('开往 ')
            Span(this.endDir)
              .fontColor('#62B42E')
            Span(' 方向')
          }
          .height('24lpx')
          .width('153lpx')
          .fontSize(12)
        }
        .margin({ bottom: 5 })

        Row() {
          Image($r('app.media.location'))
            .size({ height: '16lpx', width: '16lpx' })
            .margin({ right: '2lpx' })

          Text(this.busStationRandom[this.randomBus])
            .fontSize(10)
            .fontWeight(FontWeight.Regular)

          Image($r('app.media.divider'))
            .size({ height: '16lpx', width: '2lpx' })
            .margin({ left: 6, right: 6 })
          Image($r('app.media.walking'))// .margin({ right: 2 })
            .size({ height: '16lpx', width: '16lpx' })

          Text() {
            Span('约')
            Span(this.randomBusStopDistance.toString())
            Span('米')
          }
          .fontSize(10)
        }
      }
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(12)
      .width('234lpx')
      .height('110lpx')
      .padding(12)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)

      Column() {
        Row() {
          Row() {
          }
          .width(16)
          .height(16)

          Image($r('app.media.signal'))
            .size({ height: '16lpx', width: '16lpx' })
        }
        .justifyContent(FlexAlign.SpaceAround)

        Row() {
          Text() {
            Span(`${this.busTimer.nearestFirstStation}`)
              .fontSize(18)
              .fontColor('#62B42E')
              .fontWeight(FontWeight.Medium)
            Span('站')
              .fontSize(18)
              .fontColor('#62B42E')
              .fontWeight(FontWeight.Medium)
          }
        }

        Text() {
          Span('约')
          Span(`${this.busTimer.nearestFirstMin}`)
          Span('分钟')
        }
        .fontSize('12fp')
        .fontWeight(FontWeight.Regular)
        .margin({ top: 4 })
      }
      .width('80lpx')
      .height('110lpx')
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(12)
      // .shadow({ radius: 6, color: '#50000000', offsetY: 3 })
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .width('321lpx')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}

@Observed
export class LineSetInfo {
  private _lineName: string = ''

  public set lineName(value: string) {
    this._lineName = value
  }

  public get lineName(): string {
    return this._lineName
  }

  private _startStation: string = ''

  public set startStation(value: string) {
    this._startStation = value
  }

  public get startStation(): string {
    return this._startStation
  }

  private _endStation: string = ''

  public set endStation(value: string) {
    this._endStation = value
  }

  public get endStation(): string {
    return this._endStation
  }

  private _lon: number = 0

  public set lon(value: number) {
    this._lon = value
  }

  public get lon(): number {
    return this._lon
  }

  private _lat: number = 0

  public set lat(value: number) {
    this._lat = value
  }

  public get lat(): number {
    return this._lat
  }

  private _orders: number = 0;

  public set orders(value: number) {
    this._orders = value;
  }

  public get orders(): number {
    return this._orders;
  }

  constructor(lineName: string, startStation: string, endStation: string, lon: number, lat: number, orders: number) {
    this._lineName = lineName;
    this._startStation = startStation;
    this._endStation = endStation;
    this._lon = lon;
    this._lat = lat;
    this._orders = orders;
  }
}