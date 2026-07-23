import { AttractionGuide } from 'attraction_guide';
import { Constant, LocationUtil } from 'common';
import { GuideVM } from '../viewmodel/GuideVM';

@Builder
export function GuideBuilder() {
  GuideView();
}

@ComponentV2
export struct GuideView {
  vm: GuideVM = GuideVM.instance;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.vm.getAttractionList();
  }

  build() {
    NavDestination() {
      Column() {
        if (this.vm.attractionsInfo?.attractions.length) {
          AttractionGuide({
            location: [LocationUtil.getLocationInfo().latitude, LocationUtil.getLocationInfo().longitude],
            initAttractionInfo: this.vm.attractionsInfo,
          })
        }
      }.height(Constant.FULL_PERCENT);
    }.hideTitleBar(true);
  }
}