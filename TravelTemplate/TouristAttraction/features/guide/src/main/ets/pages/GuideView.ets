import { Constant, LocationUtil } from 'common';
import { TitleBar } from 'uicomponents';
import { GuideVM } from '../viewmodel/GuideVM';
import { AttractionGuide } from 'attraction_guide';

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
        TitleBar({
          isShowBack: false, title: '导览', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        if (this.vm.attractionsInfo?.attractions.length) {
          AttractionGuide({
            location: [LocationUtil.getLocationInfo().latitude, LocationUtil.getLocationInfo().longitude],
            initAttractionInfo: this.vm.attractionsInfo,
          }).height('90%').gesture(
            LongPressGesture({ repeat: true, duration: 400 })
            // 由于repeat设置为true，长按动作存在时会连续触发，触发间隔为duration（默认值500ms）
              .onAction((event: GestureEvent) => {
                return true;
              })
              .onActionEnd((event: GestureEvent) => {
              }),
          );
        }
      }.height(Constant.FULL_PERCENT);
    }.hideTitleBar(true);
  }
}