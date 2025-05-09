import { ALL_CITY2, CITY_DATA } from '../viewmodels/CityDetailData';
import { SearchView } from '../components/SearchView';
import { CityView } from '../components/CityView';
import { CommonConstants } from 'commonlib';

@Entry
@Component
struct CitySearch {
  @State changeValue: string = '';
  @State placeholder: string = getContext().resourceManager.getStringSync($r('app.string.placeholder'));
  @State isSearchState: boolean = false;
  @State searchList: string[] = [];
  controller: SearchController = new SearchController();

  build() {
    Column() {
      // Search box.
      Search({ value: this.changeValue, placeholder: this.placeholder, controller: this.controller })
        .searchButton(getContext(this).resourceManager.getStringSync($r('app.string.search_text').id))
        .width(CommonConstants.FULL_PERCENT)
        .margin({ top: $r('app.integer.search_margin_top') })
        .backgroundColor($r('app.color.search_bgc'))
        .placeholderColor($r('sys.color.font_secondary'))
        .placeholderFont({
          size: $r('sys.float.Body_L'),
          weight: CommonConstants.FONT_WEIGHT_400
        })
        .textFont({
          size: $r('sys.float.Body_L'),
          weight: CommonConstants.FONT_WEIGHT_400
        })
        .onSubmit((value: string) => {
          if (value.length === 0) {
            value = this.placeholder;
          }
          this.changeValue = value;
          this.isSearchState = true;
          this.searchCityList(value);
        })
        .onChange((value: string) => {
          this.changeValue = value;
          this.searchCityList(value);
          if (value.length === 0) {
            this.isSearchState = false;
            this.searchList.splice(0, this.searchList.length);
          }
        })

      // City list component.
      CityView({ isSearchState: $isSearchState })
        .margin({ top: $r('app.integer.list_margin_top') })

      // Search component, passing data to the search list.
      SearchView({
        searchList: $searchList,
        isSearchState: $isSearchState
      })
        .width(CommonConstants.FULL_PERCENT)
        .layoutWeight(CommonConstants.LAYOUT_WEIGHT)
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({ left: $r('app.integer.padding_left') })
    .backgroundColor($r('app.color.bgc'))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .height(CommonConstants.FULL_PERCENT)
  }

  // Display logic for searching for a city.
  searchCityList(value: string): void {
    let cityNames: string[] = [];
    ALL_CITY2.forEach(item => {
      if (item.name === value) {
        item.city.forEach(city => {
          cityNames.push(city);
        })
      }
      this.searchList = cityNames;
      return;
    })
    CITY_DATA.forEach(item => {
      item.city.forEach(city => {
        if (city.includes(value)) {
          cityNames.push(city);
        }
      })
    })
    this.searchList = cityNames;
  }
}

// Create the WrappedBuilder object and construct the page during dynamic route jumping.
@Builder
export function getCitySearch(): void {
  CitySearch();
}
