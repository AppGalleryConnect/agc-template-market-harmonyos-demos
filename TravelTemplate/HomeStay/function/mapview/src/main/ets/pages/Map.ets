import { map, mapCommon, MapComponent } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';

@Component
export struct CommonMap {
  @Prop latitude: string;
  @Prop longitude: string;
  @Prop name: string;
  @Link isShow: boolean;
  private mapOptions?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private mapEventManager?: map.MapEventManager;

  aboutToAppear(): void {
    let location = {
      target: {
        latitude: Number(this.latitude) ?? 0,
        longitude: Number(this.longitude) ?? 0,
      },
      zoom: 10,
    } as mapCommon.CameraPosition;

    this.mapOptions = {
      position: location,
      myLocationControlsEnabled: true,
      compassControlsEnabled: false,
    };

    let locationButtonClick = () => {
      let cameraUpdate: map.CameraUpdate = map.newCameraPosition(location);
      // 1000ms内移动相机到mark点位置
      this.mapController?.animateCamera(cameraUpdate, 1000);
    };

    // 地图初始化的回调
    this.callback = async (err, mapController) => {
      if (!err) {
        // 获取地图的控制器类，用来操作地图
        this.mapController = mapController;
        this.mapController?.setMyLocationEnabled(true);
        this.mapEventManager = this.mapController.getEventManager();
        this.drawBuilding();
        this.mapController.on('pointAnnotationClick', () => {
          this.isShow = true;
        });

        this.mapEventManager?.on('myLocationButtonClick', locationButtonClick);
      }
    };
  }

  async drawBuilding() {
    let pointAnnotationOptions: mapCommon.PointAnnotationParams = {
      position: {
        latitude: Number(this.latitude) ?? 0,
        longitude: Number(this.longitude) ?? 0,
      },
      repeatable: true,
      collisionRule: mapCommon.CollisionRule.NAME,
      titles: [{
        content: this.name,
        strokeColor: 0xFFFFFFFF,
        strokeWidth: 2,
        fontStyle: mapCommon.FontStyle.BOLD,
      },
      ],
      icon: $r('app.media.point'),
      showIcon: true,
      forceVisible: false,
      minZoom: 2,
      maxZoom: 18,
      visible: true,
      zIndex: 5,
    };
    await this.mapController?.addPointAnnotation(pointAnnotationOptions);
  }

  // 页面每次显示时触发一次，包括路由过程、应用进入前台等场景，仅@Entry装饰的自定义组件生效
  onPageShow(): void {
    // 将地图切换到前台
    if (this.mapController !== undefined) {
      this.mapController.show();
    }
  }

  // 页面每次隐藏时触发一次，包括路由过程、应用进入后台等场景，仅@Entry装饰的自定义组件生效。
  onPageHide(): void {
    // 将地图切换到后台
    if (this.mapController !== undefined) {
      this.mapController.hide();
    }
  }

  build() {
    Column() {
      MapComponent({
        mapOptions: this.mapOptions,
        mapCallback: this.callback,
      })
        .width('100%');
    }.borderRadius(8).clip(true);
  }
}