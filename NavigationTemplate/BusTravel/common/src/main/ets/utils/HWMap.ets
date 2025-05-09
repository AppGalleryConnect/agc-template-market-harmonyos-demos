import { MapComponent, mapCommon, map } from '@kit.MapKit';
import abilityAccessCtrl, { PermissionRequestResult, Permissions } from '@ohos.abilityAccessCtrl';
import { bundleManager, common } from '@kit.AbilityKit';
import { reqPermissionsFromUser, checkPermission } from './requestPermission'
import { geoLocationManager } from '@kit.LocationKit';
import { BusinessError } from '@ohos.base';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { SearchSet } from '../model/commonInterface'
import { text } from '@kit.ArkGraphics2D';

// const context = getContext(this) as common.UIAbilityContext;
const locationPermissions: Array<Permissions> = ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'];

export class Dot {
  public longitude: number = 0
  public latitude: number = 0

  public constructor(lon: number, lat: number) {
    this.longitude = lon
    this.latitude = lat
  }
}


export class HWMap {
  public mapController?: map.MapComponentController;
  private mapEventManager?: map.MapEventManager;
  private busesList: map.Marker[] = []
  public firstLon: number = 116.4
  public firstLat: number = 39.9
  public mapOptions: mapCommon.MapOptions = {
    position: {
      target: {
        latitude: this.firstLat,
        longitude: this.firstLon
      },
      zoom: 12
    }
  }
  private context: common.UIAbilityContext | undefined = undefined

  // private pointAnnotation?: map.PointAnnotation;

  constructor(context: common.UIAbilityContext) {
    this.context = context
  }

  /*
   * 初始化
   * */
  public getMapView(err: BusinessError, mapController: map.MapComponentController, callback: Function) {
    if (!err) {
      console.log('jump succeed=======')
      this.mapController = mapController;
      if (this.mapController) {
        console.log('mapController succeed========')
      }
      // 地图事件管理
      this.mapEventManager = this.mapController.getEventManager();
      let mapLoadCallback = () => {
        let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
        // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
        atManager.requestPermissionsFromUser(this.context, locationPermissions)
          .then((data: PermissionRequestResult) => {
            let grantStatus: Array<number> = data.authResults;
            if (grantStatus[0] === 0) {
              console.log('授权成功')
              this.mapController?.setMyLocationEnabled(true);
              this.mapController?.setMyLocationControlsEnabled(true)

            } else {
              console.log('用户拒绝授权')
            }
          })
          .catch((err: BusinessError) => {
            console.error(`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
          })
      }
      this.mapEventManager.on('mapLoad', mapLoadCallback)
      callback()
    }
  }

  public moveCamera(latitude: number, longitude: number): void {
    let target: mapCommon.LatLng = {
      latitude: latitude,
      longitude: longitude
    };
    let cameraPosition: mapCommon.CameraPosition = {
      target: target,
      zoom: 15
    };
    // 新建CameraUpdate对象
    let cameraUpdate: map.CameraUpdate = map.newCameraPosition(cameraPosition);
    this.mapController?.moveCamera(cameraUpdate)
  }

  public showMap(): void {
    if (this.mapController !== undefined) {
      this.mapController.show();
    }
  }

  public hideMap(): void {
    if (this.mapController !== undefined) {
      this.mapController.hide();
    }
  }

  /*
   * 绘制线段
   * param:
   *dots:要求是坐标数组
   * color：数字格式的颜色
   * */
  public drawLines(dots: mapCommon.LatLng[], requestColor: number = 0xff00ff00) {
    let polylineOption: mapCommon.MapPolylineOptions = {
      points: dots,
      clickable: true,
      startCap: mapCommon.CapStyle.BUTT,
      endCap: mapCommon.CapStyle.BUTT,
      geodesic: false,
      jointType: mapCommon.JointType.BEVEL,
      visible: true,
      width: 15,
      zIndex: 10,
      gradient: false,
      color: requestColor,
      customTexture: $r('app.media.white_arr')
    }
    this.mapController!.addPolyline(polylineOption)
  }

  /*
   * 绘制站点
   * */
  public drawStation(dots: SearchSet, requestIcon: string) {
    let markerOption: mapCommon.PointAnnotationParams = {
      position: {
        latitude: dots.coordY,
        longitude: dots.coordX
      },
      // 定义点注释名称与地图poi名称相同时，是否支持去重
      repeatable: true,
      // 定义点注释的碰撞规则
      collisionRule: mapCommon.CollisionRule.NAME,
      titles: [{
        content: dots.stationName,
        // 定义标题字体颜色
        color: 0xFF000000,
        // 定义标题字体大小
        fontSize: 12,
        // 定义标题描边颜色
        strokeColor: 0xFFFFFFFF,
        // 定义标题描边宽度
        strokeWidth: 2,
        // 定义标题字体样式
        // fontStyle: mapCommon.FontStyle.ITALIC
      }],
      icon: requestIcon,
      showIcon: true,
      // 定义点注释的锚点在水平方向上的位置
      anchorU: 0.5,
      // 定义点注释的锚点在垂直方向上的位置
      anchorV: 1,
      // 定义点注释的显示属性，为true时，在被碰撞后仍能显示
      forceVisible: false,
      // 定义碰撞优先级，数值越大，优先级越低
      priority: 3,
      // 定义点注释展示的最小层级
      minZoom: 12,
      // 定义点注释展示的最大层级
      maxZoom: 20,
      // 定义点注释是否可见
      visible: true,
      // 定义点注释叠加层级属性
      zIndex: 10
    }
    // this.mapController!.addMarker(markerOption)
    this.mapController!.addPointAnnotation(markerOption);
  }


  /*
   * 批量绘制站点
   * */
  public drawStations(dots: SearchSet[], requestIcon: string = 'station_normal.png') {
    for (let i = 0; i < dots.length; i++) {
      this.drawStation(dots[i], requestIcon)
    }
  }


  /*
   * 绘制公交车
   * */
  public async drawBus(dot: mapCommon.LatLng, requestIcon: string) {
    let markerOption: mapCommon.MarkerOptions = {
      position: dot,
      clickable: false,
      visible: true,
      zIndex: 11,
      draggable: false,
      anchorV: 0.5,
      flat: true,
      icon: requestIcon
    }
    let res = await this.mapController!.addMarker(markerOption)
    this.busesList.push(res)
  }


  /*
   * 批量绘制公交
   * */
  public drawBuses(dots: mapCommon.LatLng[], requestIcon: string = 'bus_orange.png') {
    for (let i = 0; i < dots.length; i++) {
      this.drawBus(dots[i], requestIcon)
    }
  }


  /*
   * 定时刷新需要使用清除能力
   * */
  public clearAll() {
    this.mapController?.clear()
  }


  public clearBuses() {
    for (let i = 0; i < this.busesList.length; i++) {
      this.busesList[i].remove()
    }
    this.busesList = []
  }


  public drawAll(lines: mapCommon.LatLng[], stations: SearchSet[], buses: mapCommon.LatLng[]) {
    this.clearAll()
    this.drawLines(lines)
    this.drawStations(stations)
    this.drawBuses(buses)
  }

  public refreshBus(buses: mapCommon.LatLng[]) {
    this.clearBuses()
    this.drawBuses(buses)
  }
}