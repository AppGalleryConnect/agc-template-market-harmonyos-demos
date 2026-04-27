import { Constants, TabBarData, TabBarType } from 'lib_common';
import { PhoneConstants } from '../constants/Contants';
import { IndexVM } from '../viewmodel/IndexVM';


@ComponentV2
export struct CustomTabBar {
  @Require @Param item: TabBarData;
  @Param index: number = 0;
  @Consumer() currentIndex: number = TabBarType.HOMEPAGE;
  vm: IndexVM = new IndexVM(this.getUIContext());

  build() {
    Column() {
      Image(this.currentIndex === this.index ? this.item.activeIcon : this.item.icon)
        .width(24)
        .draggable(false)
        .objectFit(ImageFit.Contain)
      Text(this.item.title)
        .fontSize($r('sys.float.Caption_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor(this.index === this.currentIndex ? ($r('sys.color.multi_color_09')) :
          $r('sys.color.font_secondary'))
        .margin({
          top: Constants.PADDING_XS,
        })
    }
    .width(this.tabItemWidth)
    .height(this.tabItemHeight)
    .justifyContent(FlexAlign.Center)
    .padding({
      left: Constants.PADDING_XS,
      right: Constants.PADDING_XS,
    })
  }

  @Computed
  get tabItemWidth(): Length {
    return Constants.FULL_PERCENT;
  }

  @Computed
  get tabItemHeight(): Length {
    if (this.vm.isTabVertical) {
      return PhoneConstants.LEFT_TAB_BAR_ITEM_HEIGHT;
    }
    return PhoneConstants.BOTTOM_TAB_BAR_HEIGHT;
  }
}