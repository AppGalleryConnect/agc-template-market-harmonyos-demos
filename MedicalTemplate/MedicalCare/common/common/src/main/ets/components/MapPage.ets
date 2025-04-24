import { map, mapCommon, MapComponent } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { RouterUtil } from '../utils/RouterUtil';
import { LogUtil } from '../utils/LogUtil';
import { common } from '@kit.AbilityKit';

export interface MapParam {
  latitude: number;
  longitude: number;
}

function getRouterParam(): MapParam {
  return RouterUtil.getLatestParam() as MapParam
}

@Builder
export function MapPageBuilder() {
  NavDestination() {
    MapPage()
  }.title('查看位置')
}

@Entry
@Component
struct MapPage {
  @State mapParam: MapParam = {
    latitude: 39.9,
    longitude: 116.4
  }
  private mapOptions?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private mapEventManager?: map.MapEventManager;

  aboutToAppear(): void {
    this.mapParam = getRouterParam();
    this.mapOptions = {
      position: {
        target: {
          latitude: this.mapParam.latitude,
          longitude: this.mapParam.longitude
        },
        zoom: 16
      }
    };

    this.callback = async (err, mapController) => {
      if (!err) {
        this.mapController = mapController;
        this.mapEventManager = this.mapController.getEventManager();

        let markerOptions: mapCommon.MarkerOptions = {
          position: {
            latitude: this.mapParam.latitude,
            longitude: this.mapParam.longitude
          },
          rotation: 0,
          visible: true,
          zIndex: 0,
          alpha: 1,
          anchorU: 0.5,
          anchorV: 1,
          clickable: true,
          draggable: false,
          flat: false
        };
        await this.mapController.addMarker(markerOptions);

        let callback = () => {
          LogUtil.info(`on-mapLoad: ${JSON.stringify(this.mapParam)}`);
        }
        this.mapEventManager.on('mapLoad', callback);
      }
    };
  }

  onPageShow(): void {
    if (this.mapController) {
      this.mapController.show();
    }
  }

  onPageHide(): void {
    if (this.mapController) {
      this.mapController.hide();
    }
  }

  build() {
    Stack() {
      MapComponent({ mapOptions: this.mapOptions, mapCallback: this.callback }).width('100%').height('100%');

      Button('开始导航')
        .height(42)
        .width('70%')
        .onClick(() => {
          const uri =
            `https://www.petalmaps.com/navigation/?&daddr=${this.mapParam.latitude},${this.mapParam.longitude}&type=bus&utm_source=ft`;
          let context = getContext(this) as common.UIAbilityContext
          context.openLink(uri, {
            appLinkingOnly: true
          })
        })
        .margin({ bottom: 36 })
    }
    .height('100%')
    .alignContent(Alignment.Bottom)
  }
}