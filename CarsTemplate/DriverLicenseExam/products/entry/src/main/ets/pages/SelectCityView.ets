import { CitySearchController, UICitySelect } from 'module_city_select';
import { GuideService } from '@ohos_agcit/driver_license_exam_guide'
import { CommonModel } from '@ohos_agcit/driver_license_exam_commonlib';
import { RouteCommonParam } from '@ohos_agcit/driver_license_exam_datasource';

@Builder
export function SelectCityViewBuilder() {
  SelectCityView();
}


@ComponentV2
struct SelectCityView {

  controller: CitySearchController = new CitySearchController();
  guideService: GuideService = GuideService.instance;
  @Local currentCity: string = this.guideService.getGuideData().city || '北京';
  vm: CommonModel = CommonModel.instance;

  @Local bottomRectHeight: number = 0;
  @Local topRectHeight: number = 0;
  @Local fromPage:string = '';

  aboutToAppear(): void {
    this.bottomRectHeight = AppStorage.get('bottomRectHeight') || 0;
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
    const param: Array<RouteCommonParam> = this.vm.navStack.getParamByName('selectCityView') as Array<RouteCommonParam>;
    if (param?.length) {
      this.fromPage = param[0]?.fromPage || '';
    }
  }

  back(): void {
    if (this.fromPage === 'GuidePage') {
      this.vm.navStack.replacePathByName('guidePage', true);
    } else {
      this.vm.navStack.pop();
    }
  }

  build() {
    NavDestination() {
      Column() {
        UICitySelect({
          currentCity: this.currentCity,
          recentVisitList: ['北京', '上海', '深圳', '广西'],
          controller: this.controller,
          emitUpdateCityLocation: (city: string) => {
            this.currentCity = city;
            this.guideService.updateCity(city);
          },
          goBack: (citySelected?: string) => {
            const message = citySelected ? `选择了${citySelected}并返回` : '直接返回';
            this.getUIContext().getPromptAction().showToast({ message });
            this.back()
          },
          emitUpdateRecentCityList:(city: string) => {
            this.currentCity = city;
            this.guideService.updateCity(city);
          }
        })
      }
      .width('100%')
    }
    .height('100%')
    .width('100%')
    .title('城市选择')
    .onBackPressed(() => {
      this.back();
      return true;
    })
    .padding({
      top:this.getUIContext().px2vp(this.topRectHeight),
      bottom: this.getUIContext().px2vp(this.bottomRectHeight)
    })
  }
}