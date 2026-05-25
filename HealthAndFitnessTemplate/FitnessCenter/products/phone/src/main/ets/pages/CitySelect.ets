import { CITY_LIST_SAMPLE, CitySelect, HOT_CITY_LIST_SAMPLE, CitySelectController, City } from 'city_select';
import { emitter } from '@kit.BasicServicesKit';
import  EventData  from '@ohos.events.emitter';
import { Logger } from 'external_interactions';

const TAG = '[CitySelect]';

@ComponentV2
export struct CitySelectPage {
  @Local currentCity: City = {
    name: '南京市',
    code: '320100',
  };
  @Param @Once pathStack: NavPathStack = new NavPathStack()
  controller: CitySelectController = new CitySelectController();

  onBackPress(): boolean | void {
    return this.controller.onBackPressed();
  }

  build() {
    NavDestination() {
      Column() {
        CitySelect({
          select: ((city) => {
            // 选择城市
            this.currentCity = city
            AppStorage.setOrCreate<string>('currentCity', this.currentCity.name)
            let data: EventData.EventData = {
              data: {
                'currentCity': this.currentCity.name
              }
            }
            try {
              emitter.emit('currentCity', data)
            } catch (e) {
              Logger.error(TAG, `emitter emit failed. error: ${JSON.stringify(e)}`)
            }
            this.pathStack.pop()
          }),
          cancel: () => {
            // 取消选择
          },
          cityList: CITY_LIST_SAMPLE,
          hotCityList: HOT_CITY_LIST_SAMPLE,
          controller: this.controller,
        })
      }
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .width('100%')
    }
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx?.pathStack
    })
    .height('100%')
    .width('100%')
    .title('城市选择')
    .padding({ bottom: 30, top: 40 })
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
