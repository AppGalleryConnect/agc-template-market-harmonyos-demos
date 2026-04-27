import { common } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';
import { mapCommon, MapComponent } from '@kit.MapKit'
import { FootPrintItem } from '../viewmodel/FootprintModel';
import { LightMapVm } from '../viewmodel/LightMapVM';

/**
 * @usage: 点亮地图组件，根据用户足迹数据在地图上高亮显示已去过的省份区域
 * @layout: 单行布局，包含MapComponent地图组件，高度占65%
 * @isGen: true
 * @fileType: component
 * @zhName: 点亮地图组件
 * @domain: 旅游
 */
@ComponentV2
export struct LightMap {
  @Param lightItems: FootPrintItem[] = []
  uiContext: UIContext = this.getUIContext();
  context: common.UIAbilityContext = this.uiContext.getHostContext() as common.UIAbilityContext;
  vm: LightMapVm = new LightMapVm(this.context, this.uiContext)

  @Monitor('lightItems')
  lightItemsChange() {
    if (this.lightItems.length) {
      this.vm.cleanMap()
      this.vm.getLightAreaData(this.lightItems)
    }
  }

  @Monitor('vm.handleAreaName')
  AreaNameChange() {
    this.vm.areaGeoObj.forEach(item => {
      this.drawAreaName(item.features[0].properties.name, item.features[0].properties.center)
    })
  }

  aboutToAppear(): void {
    this.vm.initMap(this.lightItems)
  }

  async drawAreaName(name: string, center: number[]) {
    let pixmap: image.PixelMap = await this.uiContext.getComponentSnapshot().createFromBuilder(() => {
      this.textBuilder(name)
    })
    let markerOptions: mapCommon.MarkerOptions = {
      position: {
        latitude: center[1],
        longitude: center[0]
      },
      visible: true,
      anchorU: 0.5,
      anchorV: 1,
      clickable: true,
      icon: pixmap
    };
    let marker = await this.vm.mapController?.addMarker(markerOptions);
    if (marker) {
      this.vm.markerList.push(marker)
    }
  }

  @Builder
  textBuilder(text: string) {
    Column() {
      Text(text)
        .fontSize(12)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
    }
    .id('aaa')
  }

  build() {
    Row() {
      MapComponent({
        mapOptions: this.vm.mapOptions,
        mapCallback: this.vm.callback
      })
    }.width('100%')
    .height('65%')
  }
}