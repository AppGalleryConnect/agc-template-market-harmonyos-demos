import { AsyncCallback } from '@kit.BasicServicesKit';
import { map, mapCommon, MapComponent } from '@kit.MapKit';
import { geoLocationManager } from '@kit.LocationKit';
import { Constants } from '../constants/Common';
import { MapLocation } from '../models/ParamsModel';

@ComponentV2
export struct HwMapComp {
  @Param mapHeight: Length = Constants.FULL_SIZE;
  @Param @Require locations: Array<MapLocation>
  @Param showMyLocation: boolean = true
  @Param mapBorderRadius: number = 0
  @Param selectStore: MapLocation = new MapLocation()
  @Local mapController?: map.MapComponentController | undefined = undefined;
  private marker: Map<string, map.Marker> = new Map<string, map.Marker>()
  private mapOption?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private style: mapCommon.MyLocationStyle = {
    anchorU: 0.5,
    anchorV: 0.5,
    radiusFillColor: 0xff00FFFFFF,
    displayType: mapCommon.MyLocationDisplayType.FOLLOW,
  };

  @Computed
  get selectLocation(): MapLocation {
    if (this.selectStore) {
      return this.selectStore
    } else {
      return this.locations[0]
    }
  }

  aboutToAppear(): void {
    this.mapOption = {
      position: {
        target: {
          latitude: this.selectLocation.latitude,
          longitude: this.selectLocation.longitude,
        },
        zoom: 15,
      },
    };

    this.callback = async (err, mapController) => {
      if (!err) {
        this.mapController = mapController;
        this.mapController.on('mapLoad', () => {
          console.info('mapLoad success');
        });
        this.abilityEnabled();
        mapController.setMyLocationStyle(this.style);
        this.updateMakers()
      }
    };
  }

  @Monitor('selectStore.id')
  cameraChange(monitor: IMonitor) {
    if (monitor.value()?.now) {
      this.moveCamera(this.selectLocation)
    }
  }

  @Monitor('locations')
  infoChange(monitor: IMonitor) {
    if (monitor.value()?.now) {
      this.updateMakers()
    }
  }

  updateMakers() {
    this.mapController?.clear()
    this.marker?.clear()
    this.locations.forEach(location => {
      this.addMarker(location)
    })
    if (this.selectLocation) {
      this.moveCamera(this.selectLocation)
    }
  }

  async addMarker(location: MapLocation) {
    // Marker初始化参数
    let markerOptions: mapCommon.MarkerOptions = {
      position: {
        latitude: location.latitude,
        longitude: location.longitude,
      },
      rotation: 0,
      visible: true,
      zIndex: 0,
      alpha: 1,
      anchorU: 0.5,
      anchorV: 1,
      clickable: true,
      draggable: true,
      flat: false,
      icon: location.icon || 'ic_store_location.png',
    };
    // 创建Marker
    let marker = await this.mapController?.addMarker(markerOptions);
    if (marker) {
      // 设置信息窗的标题
      marker.setTitle(location.title);
      this.marker.set(location.id, marker)
    }
  }

  moveCamera(location: MapLocation) {
    this.mapController?.animateCameraStatus(map.newLatLng({
      latitude: location.latitude,
      longitude: location.longitude,
    }, 15), 200).then(() => {
      this.marker?.get(location.id)?.setInfoWindowVisible(true)
    });
  }

  aboutToDisappear(): void {
    if (this.mapController) {
      this.mapController.hide();
    }
  }

  async abilityEnabled(): Promise<void> {
    if (this.showMyLocation) {
      this.mapController?.setMyLocationEnabled(true);
      this.mapController?.setMyLocationControlsEnabled(true);
    }
    this.mapController?.setZoomControlsEnabled(false);
  }

  getLocation(mapController?: map.MapComponentController): Promise<geoLocationManager.Location> {
    let promise = geoLocationManager.getCurrentLocation();
    console.info('getCurrentLocation' + JSON.stringify(promise));
    promise.then(async (location: geoLocationManager.Location) => {
      mapController?.setMyLocation(location);
      console.info('getCurrentLocation' + JSON.stringify(location));
      return location;
    }).catch((error: Error) => {
      console.error('getCurrentLocation failed', 'getCurrentLocation error: ' + JSON.stringify(error));
    });
    return promise;
  }

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      MapComponent({
        mapOptions: this.mapOption,
        mapCallback: this.callback,
      })
    }.height(this.mapHeight).borderRadius(this.mapBorderRadius).clip(true)
  }
}