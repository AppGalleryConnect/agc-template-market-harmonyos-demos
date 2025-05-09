import { BusLineInfo, busLine, BusFromCurrent } from '../components/BusLine'
import { MapComponent, mapCommon, map, site } from '@kit.MapKit';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import {
  Logger,
  Common,
  BreakpointConstants,
  LocationUtil,
  DeviceScreen,
  BreakpointType,
  HWMap,
  SearchSet,
  LineSet,
  RouterModule
} from 'common';
import { MapConstants } from '../constants/MapConstants';
import { abilityAccessCtrl, common, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { BusLineView } from '../components/BusLineView'
import { getDataFromJSON } from 'common';
import { LineSetInfo } from '../components/BusInfo';
import { RandomCountdown } from '../components/RandomCountdown'
import { RouterDetailParam } from '../viewmodels/RouterParams';
import { RouteEntryVM } from 'common';


@Builder
export function RouteDetailBuilder() {
  RouteDetail()
}

const context = getContext(this) as common.UIAbilityContext;

@Component
export struct RouteDetail {
  @Prop @Watch('change') busTimer: RandomCountdown
  vm: RouteEntryVM = RouteEntryVM.instance;
  @State line: Array<string> = [] // 查询路线
  // 线路
  @State lineDots: mapCommon.LatLng[] = []
  // 站点
  @State stationLocation: SearchSet[] = []
  // 当前该路线的公交车
  @State busLocation: mapCommon.LatLng[] = [{ longitude: 118.79, latitude: 31.974 }]
  @State busLine: Array<number> = [1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10, 13]
  @State nearToMe: number = 3
  // 站线名
  @State longLineName: string = ''
  @State busLineInfo: BusLineInfo = new BusLineInfo(this.longLineName, '下行', '6：00', '22：00', 2, 3, this.line, [])
  @State showLon: number = 0
  @State showLat: number = 0
  hwMap = new HWMap(context)
  // hwMap = new HWMap(context)
  @StorageLink('currentBreakpoint') @Watch('getHeight') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_MD;
  @StorageLink('searchInput') searchInput: string = '';
  @StorageLink('isSearch') isSearch: boolean = false;
  @StorageLink('sites') sites: Array<site.Site> | undefined = [];
  @StorageLink('isShowBack') isShowBack: boolean = false;
  @StorageLink('isOnShowRoute') isOnShowRoute: boolean = false;
  @State mapController?: map.MapComponentController | undefined = undefined;
  @State isShow: boolean = true;
  @State columnMaxHeight: number = 0;
  @State columnHeight: number = Common.HEIGHT_MIDDLE;
  @State tempColumnHeight: number = Common.HEIGHT_MIDDLE;
  @State isChangeHeight: boolean = false;
  @State isLeft: boolean = true;
  @State left: number = Common.LEFT_MD;
  @State tempLeft: number = Common.LEFT_MD;
  // @State busTimer: RandomCountdown = new RandomCountdown('')
  private panOptionHeight: PanGestureOptions = new PanGestureOptions({
    direction: PanDirection.Up | PanDirection.Down
  });
  private panOptionPosition: PanGestureOptions = new PanGestureOptions({
    direction: PanDirection.Left | PanDirection.Right,
    distance: 10
  });
  private smMaxHeight: number = DeviceScreen.getDeviceHeight() - 8 - (px2vp(AppStorage.get('topRectHeight') as number));
  // 站线名 起点站 终点站 经纬度 站点名 seq
  @State busSetItems: Array<SearchSet> = []
  // 线路名 起点站 终点站 经纬度 orders
  @State lineSetItems: Array<LineSet> = []
  @State currentEveryStation: Array<SearchSet> = [] // 当前站点
  @State currentEveryLine: Array<LineSet> = [] // 当前路线

  initDataSource() {
    this.busSetItems = getDataFromJSON<SearchSet>('Bus_Station.json', this);
    this.lineSetItems = getDataFromJSON<LineSet>('Bus_Line.json', this);
  }

  // 根据线路名找出当前路线的所有的站点名
  getCurrentEveryStation() {
    for (let i = 0; i < this.busSetItems.length; i++) {
      if (this.busSetItems[i].lineName === this.longLineName) {
        this.currentEveryStation.push(this.busSetItems[i])
        this.line.push(this.busSetItems[i].stationName)
        this.stationLocation.push(this.busSetItems[i])
        if (this.busSetItems[i].stationName === this.busSetItems[i].endStation) {
          break
        }
      }
    }
  }

  // 根据路线名找出当前的路线经纬度
  getCurrentEveryLine() {
    for (let i = 0; i < this.lineSetItems.length; i++) {
      if (this.lineSetItems[i].lineName === this.longLineName) {
        this.currentEveryLine.push(this.lineSetItems[i])
        this.lineDots.push({
          longitude: this.lineSetItems[i].lon,
          latitude: this.lineSetItems[i].lat
        })

      }
    }
  }

  drawAll() {
    this.hwMap.drawAll(this.lineDots, this.stationLocation, this.busLocation)
  }

  getHeight() {
    this.columnMaxHeight = new BreakpointType(this.smMaxHeight, Common.HEIGHT_MD).getValue(this.currentBreakpoint);
    AppStorage.setOrCreate('columnMaxHeight', this.columnMaxHeight);
    if (this.tempColumnHeight === this.smMaxHeight && this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD) {
      this.tempColumnHeight = Common.HEIGHT_MD;
    }
    if (this.tempColumnHeight === Common.HEIGHT_MD && this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM) {
      this.tempColumnHeight = this.smMaxHeight;
    }
  }

  aboutToAppear(): void {

    let params = RouterModule.stack.getParamByName('RouteDetail') as Array<RouterDetailParam>;
    this.longLineName = params[params.length-1].lineName
    this.busLineInfo.busNumber = params[params.length-1].lineName
    this.busTimer = params[params.length-1].busTimer
    console.log(`longLineName================:${JSON.stringify(this.longLineName)}`);

    this.busLineInfo.nearestThreeBuses[0] =
      new BusFromCurrent(this.busTimer.nearestFirstStation, this.busTimer.nearestFirstDis,
        this.busTimer.nearestFirstMin)
    this.busLineInfo.nearestThreeBuses[1] =
      new BusFromCurrent(this.busTimer.nearestSecondStation, this.busTimer.nearestSecondDis,
        this.busTimer.nearestSecondMin)
    this.busLineInfo.nearestThreeBuses[2] =
      new BusFromCurrent(this.busTimer.nearestThirdStation, this.busTimer.nearestThirdDis,
        this.busTimer.nearestThirdMin)
    this.getHeight();

    this.initDataSource()
    console.log('============' + JSON.stringify(this.busSetItems))
    this.getCurrentEveryStation()
    this.getCurrentEveryLine()
    console.log('============busLineInfo' + JSON.stringify(this.busLineInfo))

    this.showLon = this.stationLocation[0].coordX
    this.showLat = this.stationLocation[0].coordY
    this.hwMap.firstLon = this.stationLocation[0].coordX
    this.hwMap.firstLat = this.stationLocation[0].coordY
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {

        Column() {
          MapComponent({
            mapOptions: this.hwMap.mapOptions,
            mapCallback: (err: BusinessError, mapController: map.MapComponentController) => {
              this.hwMap.getMapView(err, mapController, () => {
                this.drawAll()
                this.hwMap.moveCamera(this.showLat, this.showLon)
              });
              setInterval(() => {
                this.hwMap.refreshBus(this.busLocation)
              }, 1000)
            }
          })
            .height(780 - this.tempColumnHeight)

          Stack({ alignContent: Alignment.Top }) {
            Row()
              .backgroundColor('#62B42E')
              .height(this.tempColumnHeight)
              .width('100%')
              .borderRadius({ topLeft: '20lpx', topRight: '20lpx' })

            Column() {
              Row() {
                Divider()
                  .strokeWidth('1px').color($r('sys.color.ohos_id_color_list_separator'))
                  .width('48lpx')
                  .lineCap(LineCapStyle.Round)
                  .padding({ bottom: '16lpx' })
              }
              .height('26lpx')
              .width(Common.FULL_WIDTH)
              .justifyContent(FlexAlign.Center)

              busLine({ busLineInfo: this.busLineInfo })
              BusLineView({ busStationName: this.line, busIndex: this.busLine, nearToMe: this.nearToMe })
            }
            .gesture(
              PanGesture(this.panOptionHeight)
                .onActionUpdate((event?: GestureEvent) => {
                  if (event) {
                    let height = this.columnHeight - event.offsetY;
                    this.tempColumnHeight = height;
                    if (this.tempColumnHeight < Common.HEIGHT_LOW) {
                      this.tempColumnHeight = Common.HEIGHT_LOW;
                    }
                    if (this.tempColumnHeight > this.columnMaxHeight) {
                      this.tempColumnHeight = this.columnMaxHeight;
                    }
                  }
                })
                .onActionEnd(() => {
                  if (this.tempColumnHeight >
                    (this.columnMaxHeight - Common.HEIGHT_MIDDLE) / 2 + Common.HEIGHT_MIDDLE) {
                    this.columnHeight = this.columnMaxHeight;
                    this.isShowBack = false;
                  } else if (this.tempColumnHeight <
                    (Common.HEIGHT_MIDDLE - Common.HEIGHT_LOW) / 2 + Common.HEIGHT_LOW) {
                    this.columnHeight = Common.HEIGHT_LOW;
                    this.isShowBack = true;
                  } else {
                    this.columnHeight = Common.HEIGHT_MIDDLE;
                    this.isShowBack = true;
                  }
                  this.tempColumnHeight = this.columnHeight;
                })
            )
          }
          .height(this.tempColumnHeight)
          .width('100%')
          .expandSafeArea((this.tempColumnHeight === this.columnMaxHeight ? [SafeAreaType.KEYBOARD] : []),
            (this.tempColumnHeight === this.columnMaxHeight ? [SafeAreaEdge.BOTTOM] : []))
          .backgroundColor($r('app.color.background_color_white'))
          .visibility(this.isShow ? Visibility.Visible : Visibility.None)
          .borderRadius({
            topLeft: '15lpx',
            topRight: '15lpx',
            bottomLeft: new BreakpointType('0lpx',
              '15lpx').getValue(this.currentBreakpoint),
            bottomRight: new BreakpointType('0lpx',
              '15lpx').getValue(this.currentBreakpoint)
          })
          .gesture(
            PanGesture(this.panOptionPosition)
              .onActionUpdate((event?: GestureEvent) => {
                if (event) {
                  let position = this.left + event.offsetX;
                  this.tempLeft = position;
                  if (this.tempLeft < Common.LEFT_MD) {
                    this.tempLeft = Common.LEFT_MD;
                  }
                  if (this.tempLeft > Common.RIGHT_MD) {
                    this.tempLeft = Common.RIGHT_MD;
                  }
                }
              })
              .onActionEnd(() => {
                if (this.tempLeft < Common.CHANGE) {
                  this.left = Common.LEFT_MD;
                } else {
                  this.left = Common.RIGHT_MD;
                }
                this.tempLeft = this.left;
              })
          )
        }

        Image($r('app.media.icon_back'))
          .width(45)
          .height(45)
          .margin({ left: 12, top: 12 })
          .onClick(() => {
            this.vm.pop()
          })
      }
    }
    .hideTitleBar(true)
  }

  change(changedPropertyName: string) {
    console.log('111111111111111111' + this.busTimer.nearestFirstStation)
  }
}