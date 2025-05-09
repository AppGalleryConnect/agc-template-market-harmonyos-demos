import { newStation, newStations, linesName, MainEntryVM } from 'commonlib';
import { getColor, getOption, searchStation } from '../functions/HomeFunctions';
import { site, staticMap } from '@kit.MapKit';
import { ParamForStationsSearchPage } from '../types/Types';

@Component
struct ClassifyItem {
  @State getMyColor: Resource = $r('app.color.background_color_white')
  @Prop isSelected: boolean = false;
  classifyName?: string | Resource;
  onClickAction = (): void => {
  }

  build() {
    Text(this.classifyName)
      .fontSize(14)
      .fontColor(this.isSelected ? $r('app.color.orange') :
      $r('app.color.stationsInformation_default'))
      .borderWidth(this.isSelected ? { left: 2 } : 0)
      .borderColor($r('app.color.orange'))
      .fontWeight(this.isSelected ? FontWeight.Medium : FontWeight.Normal)
      .textAlign(TextAlign.Center)
      .backgroundColor(this.isSelected ? '#FFFFFF' : '')
      .width('100%')
      .height(44)
      .onClick(this.onClickAction)
  }
}

@ComponentV2
export struct SideTab {
  vm: MainEntryVM = MainEntryVM.instance;
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
  @Local cityName:string|undefined = undefined
  @Local district:string|undefined = undefined
  @Local currentClassify: number = 0;
  private classifyScroller: Scroller = new Scroller();
  private scroller: Scroller = new Scroller();
  @Local name: string = ''
  @Local image?: PixelMap = undefined;

  classifyChangeAction(index: number, isClassify: boolean): void {
    if (this.currentClassify !== index) {
      this.currentClassify = index;
      if (isClassify) {
        this.scroller.scrollToIndex(index);
      } else {
        this.classifyScroller.scrollToIndex(index);
      }
    }
  }

  build() {
    Row() {
      List({ scroller: this.classifyScroller }) {
        ForEach(linesName, (item: string, index?: number) => {
          ListItem() {
            ClassifyItem({
              classifyName: item,
              isSelected: this.currentClassify === index,
              onClickAction: () => {
                if (index !== undefined) {
                  this.classifyChangeAction(index, true);
                }
              }
            })
          }
        }, (item: string, index: number) => item + index)
      }
      .height('110%')
      .width('27.8%')
      .backgroundColor($r('app.color.stationsInformation_background_color'))
      .scrollBar(BarState.Off)
      .margin({ top: 70 })

      Scroll() {
        Column() {
          ForEach(newStations, (item: newStation[], index: number) => {
            ForEach(item, (item: newStation) => {
              if (this.currentClassify === index) {
                Row() {
                  Row() {
                    Text(item.name)
                      .fontSize(14)
                      .margin({ left: 16 })
                      .onClick(async ()=>{
                        this.name = item.name
                        this.searchStation = searchStation(this.name)
                        let option: staticMap.StaticMapOptions = getOption(item)
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
                        }
                        const result = await site.reverseGeocode(params).then((data)=>{
                          this.cityName = data.addressComponent.adminLevel2
                          this.district = data.addressComponent.adminLevel3
                        })
                        let param:ParamForStationsSearchPage = {
                          value: this.name,
                          image: this.image,
                          cityName: this.cityName,
                          district: this.district
                        }
                        this.vm.navStack.pushPath({name:'StationsSearchPage',param:param})
                      })
                  }
                  .height(44)

                  Row() {
                    ForEach(item.line, (lineName: string) => {
                      if (lineName !== linesName[this.currentClassify]) {
                        Row() {
                          Text(lineName)
                            .fontSize(12)
                            .fontColor($r('app.color.background_color_white'))
                        }
                        .margin({ left: 4 })
                        .justifyContent(FlexAlign.Center)
                        .borderRadius(10)
                        .backgroundColor(getColor(lineName))
                        .width(40)
                        .height(20)
                      }
                    }, (item: string, index: number) => item + index)
                  }
                  .margin({ right: 12 })
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
              }
            }, (item: string, index: number) => item + index)
          }, (item: string, index: number) => item + index)
        }
        .alignItems(HorizontalAlign.Start)
        .width('72.2%')
      }
      .padding({ bottom: 70 })
    }
    .backgroundColor('#FFFFFF')
  }

}
