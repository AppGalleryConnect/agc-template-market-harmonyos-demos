import { map, mapCommon } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { buffer } from '@kit.ArkTS';
import { GeoJSON, Geometry } from '../viewmodel/MapGeoModel';
import { FootPrintItem } from '../viewmodel/FootprintModel';


@ObservedV2
export class LightMapVm {
  @Trace chinaBoundaryPoints: GeoJSON = {
    type: 'FeatureCollection',
    features: []
  }
  @Trace boundaryPoints: mapCommon.LatLng[][] = []
  @Trace provincePoints: mapCommon.LatLng[][] = []
  polygonList: map.MapPolygon[] = []
  markerList: map.Marker[] = []
  mapOptions?: mapCommon.MapOptions;
  mapController?: map.MapComponentController;
  callback?: AsyncCallback<map.MapComponentController>;
  uiContext: UIContext
  context: common.UIAbilityContext
  @Trace handleAreaName: number = 1
  @Trace areaGeoObj: GeoJSON[] = []

  constructor(context: common.UIAbilityContext, uiContext: UIContext) {
    this.context = context
    this.uiContext = uiContext
  }

  initMap(lightItems: FootPrintItem[]) {
    this.mapOptions = {
      position: {
        target: {
          latitude: 31.984410259206815,
          longitude: 105
        },
        zoom: 3.1
      },
      zoomControlsEnabled: false,
      rotateGesturesEnabled: false,
      minZoom: 3,
      bounds: { northeast: { longitude: 135.08, latitude: 53.55 }, southwest: { longitude: 73.67, latitude: 3 } }
    };
    this.callback = async (err, mapController) => {
      if (!err) {
        this.mapController = mapController;
        //地图自定义样式
        this.setMapCustomStyle()
        this.getChinaBoundaryData()
        this.getProvinceBoundaryData()
        this.getLightAreaData(lightItems)
      }
    };
  }

  setMapCustomStyle() {
    let param: mapCommon.CustomMapStyleOptions = {
      styleContent: `[
        {
          "mapFeature": "all",
          "options": "geometry",
          "paint": {
            "color": "#111e27"
          }
        },
        {
          "mapFeature": "all",
          "options": "labels",
          "visibility": false
        },
        {
          "mapFeature": "water",
          "options": "geometry",
          "paint": {
            "color": "#111e27"
          }
        },
        {
          "mapFeature": "water",
          "options": "labels",
          "paint": {
            "color": "#4C6481"
          },
          "visibility": false
        }
      ]`
    };
    this.mapController?.setCustomMapStyle(param);
  }

  getRawFileContentSync(fileName: string) {
    let boundaryPointsStr = ''
    try {
      let value: Uint8Array = this.context?.resourceManager.getRawFileContentSync(fileName);
      boundaryPointsStr = buffer.from(value.buffer).toString();
    } catch (err) {
    }
    return boundaryPointsStr
  }

  getChinaBoundaryData() {
    let boundaryPointsStr = this.getRawFileContentSync('chinaBoundary.json')
    this.chinaBoundaryPoints = JSON.parse(boundaryPointsStr);
    this.boundaryPoints =
      this.multiPolygonToCoordinates(this.chinaBoundaryPoints.features[0].geometry.coordinates as Position[][][])
    this.boundaryPoints.forEach((item: Array<mapCommon.LatLng>) => {
      this.mapController?.addPolyline({
        points: item,
        clickable: false,
        geodesic: false,
        color: 0xFF4c5d66,
        width: 3,
      })
    })
  }

  getProvinceBoundaryData() {
    let boundaryPointsStr = this.getRawFileContentSync('provinceBoundary.json')
    let provinceList: GeoJSON[][] = JSON.parse(boundaryPointsStr).boundary
    provinceList.forEach((item: GeoJSON[]) => {
      let geoObj: GeoJSON = item[0]
      this.provincePoints =
        this.provincePoints.concat(this.geometryToCoordinates(geoObj.features[0].geometry))
    })
    this.provincePoints.forEach((item: mapCommon.LatLng[]) => {
      this.mapController?.addPolygon({
        points: item,
        clickable: false,
        fillColor: 0xFF262f36,
        geodesic: false,
        strokeColor: 0xFF4c5d66,
        strokeWidth: 3,
      })
    })
  }

  getLightAreaData(lightItems: FootPrintItem[]) {
    let boundaryPointsStr = this.getRawFileContentSync('provinceCityData.json')
    let boundaryPoints: GeoJSON[] = JSON.parse(boundaryPointsStr)
    let lightAreas: GeoJSON[] = []
    lightItems.forEach((item: FootPrintItem) => {
      let obj = boundaryPoints.find(boundary => boundary.features[0].properties.name.includes(item.city))
      if (obj) {
        lightAreas.push(obj)
      }
    })
    this.drawLightAreas(lightAreas)
  }

  drawLightAreas(data: GeoJSON[]) {
    data.forEach(async (geoObj: GeoJSON) => {
      let lightAreaList: mapCommon.LatLng[][] = this.geometryToCoordinates(geoObj.features[0].geometry)
      lightAreaList.forEach(async (childItem: mapCommon.LatLng[]) => {
        let polygon = await this.drawLightMap(childItem)
        if (polygon) {
          this.polygonList.push(polygon)
        }
      })
      this.areaGeoObj.push(geoObj)
    })
    ++this.handleAreaName
  }

  async drawLightMap(data: mapCommon.LatLng[]) {
    return await this.mapController?.addPolygon({
      points: data,
      clickable: true,
      fillColor: 0xFF1e5ca9,
      geodesic: false,
      strokeColor: 0xFF7ea8d8,
      strokeWidth: 3,
    })
  }


  cleanMap() {
    this.polygonList.forEach((polygon) => {
      polygon.remove()
    })
    this.polygonList = []
    this.markerList.forEach((marker) => {
      marker.remove()
    })
    this.markerList = []
    this.areaGeoObj = []
  }

  geometryToCoordinates(geometry: Geometry): mapCommon.LatLng[][] {
    if (!geometry || !geometry.coordinates) {
      return [];
    }
    switch (geometry.type) {
      case 'Polygon':
        return this.polygonToCoordinates(geometry.coordinates as Position[][]);
      case 'MultiPolygon':
        return this.multiPolygonToCoordinates(geometry.coordinates as Position[][][]);
      default:
        return [];
    }
  }

  private polygonToCoordinates(coordinates: Position[][]) {
    const polygons: Array<Array<mapCommon.LatLng>> = [];
    coordinates.forEach(polygonGroup => {
      const path = polygonGroup.map((item) => ({ 'longitude': item[0], 'latitude': item[1] } as mapCommon.LatLng));
      polygons.push(path);
    });
    return polygons;
  }

  private multiPolygonToCoordinates(coordinates: Position[][][]) {
    const polygons: Array<Array<mapCommon.LatLng>> = [];
    coordinates.forEach(polygonGroup => {
      polygonGroup.forEach(polygon => {
        const path = polygon.map((item) => ({ 'longitude': item[0], 'latitude': item[1] } as mapCommon.LatLng));
        polygons.push(path);
      });
    });
    return polygons;
  }
}