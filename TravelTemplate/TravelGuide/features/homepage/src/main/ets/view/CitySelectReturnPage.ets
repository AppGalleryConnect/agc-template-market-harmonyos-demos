import { City, CITY_LIST_SAMPLE, CitySelect, CitySelectController, HOT_CITY_LIST_SAMPLE } from 'city_select';
import { BarVM, TValueType } from 'common';
import { OHPage } from 'oh_router';
import { PlanePageVM } from '../viewmodel/PlaneTicketVM';

@Builder
export function CitySelectReturnPageBuilder(params: TValueType) {
  CitySelectPage({
    pageParam: params
  })
}


@ComponentV2
struct CitySelectPage {
  @Param pageParam: TValueType = null
  vm: PlanePageVM = this.pageParam as PlanePageVM
  @Local returnCity: City = {
    name: this.vm.returnCity,
    code: this.getCityCodeByName(this.vm.returnCity) as string,
  };
  controller: CitySelectController = new CitySelectController();

  onBackPress(): boolean | void {
    return this.controller.onBackPressed();
  }

  aboutToDisappear(): void {
    this.vm.returnCity = this.returnCity.name
    this.vm.returnCity1 = this.returnCity.name
  }

  getCityCodeByName(cityName: string): string | undefined {
    const city = CITY_LIST_SAMPLE.find(city => city.name === cityName);
    return city?.code;
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.CityBuilder()
      },
    })
  }

  @Builder
  CityBuilder() {
    NavDestination() {
      Column() {
        CitySelect({
          select: ((city) => {
            // 选择城市
            this.returnCity = city
          }),
          cancel: () => {
          },
          handleCurrentCity: (city) => {},
          cityList: CITY_LIST_SAMPLE,
          hotCityList: HOT_CITY_LIST_SAMPLE,
          controller: this.controller,
        })
      }
      .width('100%')
    }
    .padding({
      top: BarVM.instance.staBarH,
      bottom: BarVM.instance.aiBarH
    })
    .width('100%')
    .title(`城市选择：${this.returnCity.name}`)
  }
}
