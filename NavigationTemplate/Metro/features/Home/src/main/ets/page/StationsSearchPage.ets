import { infrastructure, MainEntryVM, newStation, newStations } from 'commonlib'
import { getColor, searchStation } from '../functions/HomeFunctions';
import { BACKGROUND_COLOR_GRAY } from '../constants/HomeViewConstants'
import { ParamForStationsSearchPage } from '../types/Types';

@Builder
export function StationsSearchPageBuilder(name: string, param: Object){
  StationsSearchPage()
}

@Component
export struct StationsSearchPage {
  vm: MainEntryVM = MainEntryVM.instance;
  lastPageIndex:number = MainEntryVM.instance.navStack.size()-1
  myValue:ParamForStationsSearchPage =
    this.vm.navStack.getParamByIndex(this.lastPageIndex) as ParamForStationsSearchPage
  value:string = this.myValue.value
  image?: PixelMap = this.myValue.image as PixelMap|undefined
  cityName:string|undefined = this.myValue.cityName
  district:string|undefined = this.myValue.district

  build() {
    NavDestination() {
      Column() {
        Column() {
          Row() {
            Text(this.value)
              .fontSize(20)
              .fontColor($r('app.color.stationsInformation_default'))

            if (searchStation(this.value) !== null) {
              ForEach(searchStation(this.value)?.line, (line: string) => {
                Row() {
                  Text(getLine(line))
                    .fontSize(14)
                    .fontColor($r('app.color.background_color_white'))
                }
                .backgroundColor(getColor(line))
                .width(16)
                .height(16)
                .borderRadius(16)
                .margin({ left: 4 })
                .justifyContent(FlexAlign.Center)
              }, (item: string, index: number) => item + index)
            }
          }
          .justifyContent(FlexAlign.Start)
          .margin({ top: 24 })
          .alignItems(VerticalAlign.Center)

          Row(){
            Text(''+this.cityName+this.district)
              .fontColor($r('app.color.font_color_gray'))
              .fontSize(14)
          }
          .margin({top:12})

          Column() {
            Image(this.image)
              .height(200)
              .borderRadius(8)
          }
          .margin({ top: 12 })

          //首末班车标题
          label('首末班车')

          //首末班车栏
          Scroll() {
            Column() {
              ForEach(newStations, (lines: newStation[]) => {
                ForEach(lines, (item: newStation) => {
                  if (item.name === this.value) {
                    Column() {
                      Row() {
                        Row() {
                          Text(item.currentLine)
                            .fontSize(12)
                            .fontColor($r('app.color.background_color_white'))
                        }
                        .borderRadius(10)
                        .backgroundColor(getColor(item.currentLine))
                        .width(40)
                        .height(20)
                        .justifyContent(FlexAlign.Center)

                        Column() {
                          firstTimeAndLastTime(
                            lines[lines.length-1].name,
                            lines[0].firstTime,
                            lines[0].lastTime,
                            0)
                          firstTimeAndLastTime(
                            lines[0].name,
                            lines[lines.length-1].reverseFirstTime,
                            lines[lines.length-1].reverseLastTime,
                            24)

                        }
                        .alignItems(HorizontalAlign.Start)
                        .margin({ left: 12 })
                      }
                      .alignItems(VerticalAlign.Top)
                    }
                    .margin({ top: 16 })
                    .width('100%')
                    .alignItems(HorizontalAlign.Start)
                    .justifyContent(FlexAlign.Start)
                  }
                }, (item: string, index: number) => item + index)
              }, (item: string, index: number) => item + index)
            }
          }
          .height(110)
          .width('100%')


          Divider()
            .width('100%')
            .margin({ top: 16 })

          label('地铁设施')

          Scroll() {
            Column() {
              ForEach(getInfrastructure(this.value), (item: infrastructure) => {
                Row() {
                  Row() {
                    Image(item.image)
                      .size({ width: 24, height: 24 })
                  }

                  Column() {
                    Text(item.name)
                      .fontSize(14)
                      .fontColor($r('app.color.stationsInformation_default'))
                    Text(item.address)
                      .fontSize(12)
                      .margin({ top: 4 })
                      .fontColor($r('app.color.font_color_gray'))
                  }
                  .margin({ left: 8 })
                  .alignItems(HorizontalAlign.Start)
                }
                .margin({ top: 16 })
              }, (item: string, index: number) => item + index)
            }
            .alignItems(HorizontalAlign.Start)
          }
        }
        .width(304)
        .alignItems(HorizontalAlign.Start)
        .height('100%')
      }
      .margin({top:16})
      .width(328)
      .borderRadius(16)
      .height(660)
      .backgroundColor($r('app.color.background_color_white'))
    }
    .title('站点详情')
    .backgroundColor(BACKGROUND_COLOR_GRAY)
  }
}

function getLine(line: string): string {
  return line.replace('号线', '')
}

@Builder
function label(label:string){
  Row() {
    Text(label)
      .fontSize(14)
      .fontColor($r('app.color.stationsInformation_default'))
    Image($r('app.media.ic_public_chevron_down'))
      .width(16)
      .height(16)
  }
  .justifyContent(FlexAlign.SpaceBetween)
  .width('100%')
  .margin({ top: 16 })
}

function getInfrastructure(value:string):infrastructure[]|null{
  if (searchStation(value)!==null) {
    return searchStation(value)?.infrastructure as infrastructure[]
  }
  return null
}

@Builder
function firstTimeAndLastTime(name:string,firstTime:string|undefined,lastTime:string|undefined,margin:number){
  Text('开往' + name)
    .fontSize(14)
    .fontColor($r('app.color.stationsInformation_default'))
    .margin({top:margin})
  Row(){
    Text('首' + firstTime)
      .fontSize(12)
      .fontColor($r('app.color.stationsInformation_default'))
    Text('末' + lastTime)
      .fontColor($r('app.color.stationsInformation_default'))
      .fontSize(12)
      .margin({left:12})
  }
  .margin({top:4})
}
