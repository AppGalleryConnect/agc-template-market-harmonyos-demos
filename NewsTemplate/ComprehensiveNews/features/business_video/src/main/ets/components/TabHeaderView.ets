import { AppStorageV2 } from '@kit.ArkUI';
import { CommonConstants, WindowModel, TabModel } from 'lib_common';
import { NewsSearchEntry } from 'lib_search';
import { TabNav } from '../models/VideoModel';

@ComponentV2
export struct TabHeaderView {
  // tab页签的数据
  @Param @Require tabNavs: TabNav[]
  // 当前tab下标
  @Param currentTabIndex: number = 1;
  // 当前indicator的下标
  @Param indicatorIndex: number = 1;
  // 是否展示视频头部tab
  @Param showTabHeader: boolean = true;
  // 切换事件
  @Event onChangeTabIndex: (index: number) => void = () => {
  }
  // 返回按钮
  @Local translateX: number = -40
  windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  tabModel: TabModel = AppStorageV2.connect(TabModel, () => new TabModel())!;

  @Monitor('tabModel.showTabBar')
  onChangeShowTabBar(monitor: IMonitor) {
    let isShowCustomTabBar = monitor.value()?.now as boolean
    if (isShowCustomTabBar) {
      this.translateX = -40
    } else {
      this.translateX = 0
    }
  }

  getTextColor(item: TabNav, index: number): ResourceColor {
    if (this.indicatorIndex === index) {
      return item.activeColor
    }
    if (this.indicatorIndex === 0 || this.indicatorIndex === 1) {
      return '#99ffffff'
    }
    return $r('sys.color.font_primary')
  }

  build() {
    Row() {
      Row() {
        Row() {
          Image($r('app.media.ic_left_arrow')).width(9).height(16)
            .offset({ right: 10 })
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.End)
        .onClick(() => {
          this.tabModel.showTabBar = true
        })

        List({ space: CommonConstants.SPACE_L }) {
          ForEach(this.tabNavs, (item: TabNav, index: number) => {
            ListItem() {
              this.tabBuilder(item, index)
            }
          }, (item: TabNav, index: number) => item.id + index)
        }
        .height(56)
        .width('100%')
        .listDirection(Axis.Horizontal)
        .scrollBar(BarState.Off)
        .padding({ left: CommonConstants.PADDING_L, right: CommonConstants.PADDING_L })
        .alignListItem(ListItemAlign.Center)
      }
      .translate({ x: this.translateX })
      .animation({ duration: 200, curve: Curve.EaseInOut })
      .layoutWeight(1)

      NewsSearchEntry({
        name: 'video',
        colorMode: this.indicatorIndex > 1 ? ThemeColorMode.SYSTEM : ThemeColorMode.DARK,
        searBarFgColor: this.indicatorIndex > 1 ? $r('sys.color.font_primary') : '#99FFFFFF',
        searchBarPlaceholderColor: this.indicatorIndex > 1 ? $r('sys.color.font_secondary') : '#99FFFFFF',
        searchBarBgColor: this.indicatorIndex > 1 ? $r('app.color.comment_input_bg') : '#393a3d',
        searchButtonFgColor: this.indicatorIndex > 1 ? $r('sys.color.font_primary') : $r('sys.color.font_on_primary'),
      })
    }
    .width('100%')
    .padding({
      top: this.windowModel.windowTopPadding,
      right: CommonConstants.PADDING_L,
    })
    .animation({ duration: 200 })
    .visibility(this.showTabHeader ? Visibility.Visible : Visibility.Hidden)
  }

  @Builder
  tabBuilder(item: TabNav, index: number) {
    Column() {
      Text(item.name)
        .fontColor(this.getTextColor(item, index))
        .fontSize(16)
        .fontWeight(this.indicatorIndex === index ? 700 : 400)

      Row() {
      }
      .width(16)
      .height(2)
      .borderRadius(1)
      .backgroundColor(this.indicatorIndex === index ? item.activeColor : '')
      .position({ left: CommonConstants.PADDING_S, bottom: CommonConstants.PADDING_S })
    }
    .justifyContent(FlexAlign.Center)
    .height(CommonConstants.FULL_PERCENT)
    .onClick(() => {
      this.onChangeTabIndex && this.onChangeTabIndex(index)
    })
  }
}