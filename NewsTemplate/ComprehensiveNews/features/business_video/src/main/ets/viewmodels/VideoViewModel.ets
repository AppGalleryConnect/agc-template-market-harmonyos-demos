import { emitter } from '@kit.BasicServicesKit';
import { ConfigurationConstant } from '@kit.AbilityKit';
import {
  BaseViewModel,
  EventEnum,
  ShortcutKey,
  SystemBarOperation,
  TabBarType,
  VideoType
} from 'lib_common';
import { TabNav } from '../models/VideoModel';

@ObservedV2
export class VideoViewModel extends BaseViewModel {
  // 当前tab下标
  @Trace currentTabIndex: number = VideoType.CHOICE;
  // 当前indicator的下标
  @Trace indicatorIndex: number = VideoType.CHOICE;
  // 返回按钮偏移
  @Trace translateX: number = -8
  // 是否展示头部tab
  @Trace showTabHeader: boolean = true
  @Trace tabNavs: TabNav[] = [
    new TabNav('follow', '关注'),
    new TabNav('featured', '精选'),
    new TabNav('recommend', '推荐', $r('app.color.color_tab_blue')),
    new TabNav('livestream', '直播', $r('app.color.color_tab_blue')),
    new TabNav('livestream', '电视', $r('app.color.color_tab_blue')),
    new TabNav('livestream', '广播', $r('app.color.color_tab_blue')),
  ]
  tabController: TabsController = new TabsController();

  // 监听底部tab的显隐，是否展示头部的箭头
  @Monitor('tabModel.showTabBar')
  onChangeShowTabBar(monitor: IMonitor) {
    let isShowCustomTabBar = monitor.value()?.now as boolean
    if (isShowCustomTabBar) {
      this.translateX = -10
    } else {
      this.translateX = 30
    }
  }

  // 设置状态栏样式
  @Monitor('indicatorIndex', 'tabModel.selectedIndex')
  onIndexChanged() {
    // 夜间模式适配
    let color = this.settingInfo.darkSwitch ? '#ffffff' : '#ff090909';
    if (this.tabModel.selectedIndex === TabBarType.VIDEO) {
      if (this.indicatorIndex > VideoType.CHOICE) {
        this.setWindowSystemBarContentColor(color)
      } else {
        this.setWindowSystemBarContentColor('#ffffff')
      }
    } else {
      this.setWindowSystemBarContentColor(color)
    }
    this.setHdsTabColor();
  }

  setHdsTabColor() {
    const actualColorMode = this.settingInfo.getColorModeByName(this.settingInfo.colorModeName);
    const darkBar = this.tabModel.selectedIndex === 1 &&
      [VideoType.FOLLOW, VideoType.CHOICE].includes(this.tabModel.videoCurrentTabIndex);
    const isDarkEnable =
      darkBar || this.settingInfo.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ? true : false;
    this.contextModel.globalContext.getApplicationContext()
      .setColorMode(isDarkEnable ? ConfigurationConstant.ColorMode.COLOR_MODE_DARK : actualColorMode);
  }

  private changeShowTabHeader: (eventData: emitter.EventData) => void = (eventData) => {
    this.showTabHeader = eventData.data!.showTabHeader;
  }

  onTabHeaderShowChange() {
    emitter.on(EventEnum.SHOW_TAB_HEADER, this.changeShowTabHeader);
  }

  offTabHeaderShowChange() {
    emitter.off(EventEnum.SHOW_TAB_HEADER, this.changeShowTabHeader);
  }

  private changeVideoTabIndex: (eventData: emitter.EventData) => void = (eventData) => {
    switch (eventData?.data?.pageName) {
      case ShortcutKey.TV:
        this.onChangeTabIndex(VideoType.TELEVISION);
        break;
      case ShortcutKey.AUDIO:
        this.onChangeTabIndex(VideoType.BROADCAST);
        break;
    }
  }

  onTabIndexChange() {
    emitter.on(EventEnum.VIDEO_TAB_CHANGE, this.changeVideoTabIndex);
  }

  offTabIndexChange() {
    emitter.off(EventEnum.VIDEO_TAB_CHANGE, this.changeVideoTabIndex);
  }

  onChangeTabIndex(index: number) {
    this.indicatorIndex = index;
    this.currentTabIndex = index;
    this.tabModel.videoCurrentTabIndex = index;
  }

  handleTabAnimationStart(_index: number, targetIndex: number) {
    this.indicatorIndex = targetIndex;
    this.tabModel.videoCurrentTabIndex = targetIndex;
  }

  setWindowSystemBarContentColor(color: string) {
    SystemBarOperation.setWindowSystemBarProp({
      statusBarContentColor: color,
    })
  }
}