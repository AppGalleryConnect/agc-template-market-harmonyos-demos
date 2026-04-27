/**
 * @usage: 展示指定位置地图，计算步行路线与距离
 * @layout: Stack + MapComponent + 底部地址信息 + 顶部返回
 * @constraints: 需定位权限；地图加载后添加标记；距离计算失败兜底；安全边距
 * @isGen: false
 * @fileType: component
 * @domain: 社交交友
 * @zhName: 聊天位置组件
 * @image: screenshots/chat_location_look.jpeg
 */
import { MapComponent, mapCommon, map, navi } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { geoLocationManager } from '@kit.LocationKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { ChooseLocationUtil } from '../utils/ChooseLocationUtil';
import { ChatBreakpoint } from 'chat_base';

const TAG = 'ChatLocationComponent';

@ComponentV2
export struct ChatLocationComponent {
  @Param latitude: number = 31.8698571539735;
  @Param longitude: number = 118.82523154589367;
  @Param address: string = '';
  @Param addressDetail: string = '';
  @Param onReturnClick: () => void = () => {
  }
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  @Local distance: string | undefined;
  @Local mapOption?: mapCommon.MapOptions
  @Local mapController?: map.MapComponentController
  @Local mapCallBack: AsyncCallback<map.MapComponentController> = (err, mapController) => {
    hilog.info(0x0000, TAG, '%{public}s', 'mapCallBack err: ' + JSON.stringify(err));
    if (mapController !== undefined) {
      mapController.on('mapLoad', () => {
        let markerOptions: mapCommon.MarkerOptions = {
          position: {
            latitude: this.latitude,
            longitude: this.longitude
          },
          icon: $r('app.media.chat_location_marker')
        };
        mapController.addMarker(markerOptions);
      });

      mapController.setMyLocationEnabled(true);
      mapController.setMyLocationControlsEnabled(true);
    }
  }

  @Monitor('latitude')
  async resetLocation() {
    this.mapOption = {
      position: {
        target: {
          latitude: this.latitude,
          longitude: this.longitude
        },
        zoom: 16
      },
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      zoomControlsEnabled: false,
      compassControlsEnabled: false
    }

    let currentLocation = await ChooseLocationUtil.getCurrentLocation();
    this.getWalkingRoutes(currentLocation);
  }

  aboutToAppear() {
    this.resetLocation();
    let context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext
    ChooseLocationUtil.requestLocationPermissionsFromUser(context);
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        MapComponent({
          mapOptions: this.mapOption,
          mapCallback: this.mapCallBack
        })
          .width('100%')
          .layoutWeight(1)

        Column() {
          Text(this.address)
            .fontSize($r('sys.float.Subtitle_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.Black)
            .lineHeight($r('app.float.vp_22'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.addressDetail)
            .fontSize($r('sys.float.Body_S'))
            .fontColor(Color.Black)
            .lineHeight($r('app.float.vp_18'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.distance)
            .fontSize($r('sys.float.Body_S'))
            .fontColor('#7E7E7E')
            .lineHeight($r('app.float.vp_18'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .visibility(this.distance ? Visibility.Visible : Visibility.None)
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .height(78 + this.chatBreakpoint.bottomValue)
        .padding({
          left: this.chatBreakpoint.pagePadding,
          right: this.chatBreakpoint.pagePadding,
          top: 20,
          bottom: 20 + this.chatBreakpoint.bottomValue
        })
        .backgroundColor(Color.White)
      }
      .width('100%')
      .height('100%')

      Row().width('100%').height(94 + this.chatBreakpoint.topValue)
        .linearGradient({
          angle: 0,
          colors: [['#00000000', 0.0], ['#33000000', 1.0]]
        })

      Button() {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_primary')])
          .fontWeight(FontWeight.Normal)
      }
      .width($r('app.float.vp_40'))
      .height($r('app.float.vp_40'))
      .margin({ left: this.chatBreakpoint.pagePadding, top: this.chatBreakpoint.topValue })
      .type(ButtonType.Circle)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        if (this.onReturnClick) {
          this.onReturnClick?.()
        }
      })
    }
    .width('100%')
    .height('100%')

  }

  async getWalkingRoutes(currentLocation: geoLocationManager.Location) {
    try {
      let params: navi.RouteParams = {
        origins: [
          {
            'latitude': currentLocation.latitude,
            'longitude': currentLocation.longitude
          }
        ],
        destination: {
          'latitude': this.latitude,
          'longitude': this.longitude
        },
        language: 'zh_CN'
      };
      const result = await navi.getWalkingRoutes(params);
      hilog.info(0x0000, TAG, '%{public}s', 'get walking routes result = ' + JSON.stringify(result));
      if (result) {
        let route = result.routes[0];
        let step = route.steps[0];
        this.distance = `距离你${step.distanceDescription} ｜ 步行${step.durationDescription}`;
      }
    } catch (error) {
      hilog.error(0x0000, TAG, '%{public}s', 'get walking routes err: ' + JSON.stringify(error));
    }
  }
}
