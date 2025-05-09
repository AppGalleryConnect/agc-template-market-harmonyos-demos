import { MainEntryVM, newStation, stationsName } from 'commonlib';
import { SideTab } from '../components/StationsInformationTabs';
import { getOption, searchStation } from '../functions/HomeFunctions';
import { site, staticMap } from '@kit.MapKit';
import { ParamForStationsSearchPage } from '../types/Types';
import { BaseTitle } from 'componentlib';


@Builder
export function StationsInformationPageBuilder(name: string, param: Object) {
  StationsInformationPage()
}


@ComponentV2
export struct StationsInformationPage {
  vm: MainEntryVM = MainEntryVM.instance;
  @Local cityName:string|undefined = undefined
  @Local district:string|undefined = undefined
  @Local name: string = ''
  @Local image?: PixelMap = undefined;
  @Local searchStation: newStation | null = {
    line: [],
    currentLine:'',
    name: '',
    latitude: 0,
    longitude: 0,
    firstTime: '',
    lastTime: '',
    reverseFirstTime:'',
    reverseLastTime:'',
    infrastructure:[],
    serial: 0
  }

  @Builder
  StationsInformationBuilder() {
    Text('站点信息')
      .fontSize($r('app.float.title_lg_font_size'))
      .fontWeight(FontWeight.Medium)
  }

  build() {
    NavDestination() {
      BaseTitle({
        customTitle: () => {
          this.StationsInformationBuilder()
        },
        showBackBtn: true,
        onBack: () => {
          this.vm.navStack.pop()
        },
      });

      Column() {
        Row() {
          Search({ placeholder: '请输入站点名称' })
            .width(304)
            .margin({ top: 16 })
            .onSubmit(async (value: string) => {
              if (stationsName.has(value)) {
                this.name = value
                this.searchStation = searchStation(value)
                let option: staticMap.StaticMapOptions = getOption(this.searchStation)
                await staticMap.getMapImage(option).then((value) => {
                  this.image = value;
                });
                let params: site.ReverseGeocodeParams = {
                  // 位置经纬度
                  location: {
                    latitude: this.searchStation?.latitude===undefined?
                    0:this.searchStation?.latitude,
                    longitude: this.searchStation?.longitude===undefined?
                    0:this.searchStation?.longitude,
                  },
                  language: 'cn',
                  radius: 200
                };
                const result = await site.reverseGeocode(params).then((data)=>{
                  this.cityName = data.addressComponent.adminLevel2
                  this.district = data.addressComponent.adminLevel3
                })
              }
              let param:ParamForStationsSearchPage = {
                value: value,
                image: this.image,
                cityName: this.cityName,
                district: this.district
              }
              this.vm.navStack.pushPath({name:'StationsSearchPage',param:param})
            })
        }
        .alignItems(VerticalAlign.Bottom)
        .justifyContent(FlexAlign.Center)
        .height(56)
        .width(328)
        .borderRadius({ topLeft: 16, topRight: 16 })
        .backgroundColor($r('app.color.background_color_white'))
        .padding({ bottom: 6 })

        SideTab()
      }
      .margin({ top: 8 })
      .width(328)
      .height(692)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.stationsInformation_background_color'))
    .hideTitleBar(true)
  }
}



