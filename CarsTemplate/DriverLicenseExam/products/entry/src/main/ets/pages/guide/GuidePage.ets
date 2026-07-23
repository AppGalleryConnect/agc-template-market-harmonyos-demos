import { CommonModel } from '@ohos_agcit/driver_license_exam_commonlib';
import { RouteCommonParam } from '@ohos_agcit/driver_license_exam_datasource';
import { GuideView, GuideService } from '@ohos_agcit/driver_license_exam_guide'
import { Utils } from 'module_city_select'
@Builder
export function GuidePageBuilder() {
  GuidePage();
}

@ComponentV2
export struct GuidePage {
  vm: CommonModel = CommonModel.instance;
  guideService:GuideService = GuideService.instance;

  aboutToAppear(): void {
    Utils.applyLocationPermission().then((city) => {
      if (city) {
        this.guideService.updateCity(city)
      }
    })
  }

  build() {
    NavDestination() {
      GuideView({
        goCitySelectPage:() => {
          const param: RouteCommonParam = {
            fromPage: 'GuidePage',
          }
          this.vm.navStack.replacePathByName('selectCityView', param, true)
        },
        completed:() => {
          this.vm.navStack.replacePathByName('MainEntry', true)
        }
      })
    }
    .height('100%')
    .width('100%')
    .hideTitleBar(true)
    .hideToolBar(true)
  }
}