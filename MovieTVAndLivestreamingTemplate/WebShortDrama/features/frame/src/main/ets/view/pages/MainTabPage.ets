import { hdsMaterial } from '@kit.UIDesignKit';
import { AppStorageV2, display, window } from '@kit.ArkUI';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { HdsTabs, HdsTabsController } from '@hms.hds.hdsBaseComponent';
import { Tab, TabHeaderInfo } from '../components/tabs/TabItem';
import { TabInfoRegister } from '../../../../../Index';
import { initMainPageContent } from '../model/InitContent';
import {
  AiBarHeight,
  AppStorageKeys,
  BreakPoint,
  BreakPointValue,
  ColorMode,
  FontModel,
  MinorsMode,
  MinorsProtectionUtils,
  StatusBarHeight
} from '@agctemplate/widgets';
import { appRouter, Logger, WindowManager } from '@agctemplate/utils';
import { NetWorkModel, NetworkUtil } from 'video_swiper';

export interface TabInfo {
  tabHeaderInfo: TabHeaderInfo;
  tabContentBuilder: WrappedBuilder<[number]>;
}

const TAG = 'MainTabPage'

@ComponentV2
export struct MainTabPage {
  @Local minorsMode: MinorsMode =
    AppStorageV2.connect(MinorsMode, 'isMinorsMode', () => new MinorsMode(MinorsProtectionUtils.getMinorsMode()))!
  @Local currentBreakpoint: BreakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint(BreakPointValue.SM))!;
  @Local aiBarHeight: AiBarHeight = AppStorageV2.connect(AiBarHeight, AppStorageKeys.AI_BAR_HEIGHT,
    () => new AiBarHeight())!;
  @Local statusBarHeight: StatusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight())!;
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  @Provider('curTabIndex') currentIndex: number = 0;
  @Provider('tabState') tabState: boolean = true;
  @Local isDarkEnable: boolean = !this.minorsMode.isMinorsMode ? true : false; // 默认主页为深色tab
  @Provider('tabShown') tabShown: boolean = true;
  private controller: HdsTabsController = new HdsTabsController();
  private isFirstTimeIn: boolean = true; // 优化首次进入无弹跳效果
  @Local netStatus: NetWorkModel =
    AppStorageV2.connect(NetWorkModel, 'netStatus', () => new NetWorkModel())!
  private netWorkUtil: NetworkUtil = new NetworkUtil()
  @Local currentColorMode: ColorMode = AppStorageV2.connect(ColorMode, 'colorMode', () => new ColorMode('跟随系统'))!
  @Local isLandScape: boolean = display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE ||
    display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE_INVERTED
  callback: Callback<number> = (data: number) => {
    if (display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE ||
      display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE_INVERTED) {
      this.isLandScape = true
    } else {
      this.isLandScape = false
    }
  };

  @Monitor('minorsMode.isMinorsMode')
  onModeChange() {
    initMainPageContent()
  }

  @Monitor('currentColorMode.colorMode')
  onColorModeChange() {
    const actualColorMode = ColorMode.getColorModeByName(this.currentColorMode.modeName);
    this.isDarkEnable = this.currentIndex === 0 && !this.minorsMode.isMinorsMode ? true :
      actualColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ? true : false;

    WindowManager.setWindowSystemBarProperties({
      statusBarContentColor: this.currentIndex === 0 && !this.minorsMode.isMinorsMode ? '#e6ffffff' :
        this.currentColorMode.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ? '#e6ffffff' :
          '#e6000000'
    });

    this.getUIContext()?.getHostContext()?.getApplicationContext()
      .setColorMode(this.isDarkEnable ? ConfigurationConstant.ColorMode.COLOR_MODE_DARK : actualColorMode);
  }

  aboutToAppear(): void {
    WindowManager.setWindowSystemBarProperties({
      statusBarContentColor: !this.minorsMode.isMinorsMode ? '#e6ffffff' : '#e6000000'
    });
    this.getUIContext()?.getHostContext()?.getApplicationContext()
      .setColorMode(!this.minorsMode.isMinorsMode ? ConfigurationConstant.ColorMode.COLOR_MODE_DARK :
        this.currentColorMode.colorMode);
    this.netWorkUtil.onNetSceneChange();
    this.netWorkUtil.onNetworkChange();
    try {
      display.on('change', this.callback);
    } catch (e) {
    }
  }

  aboutToDisappear(): void {
    this.netWorkUtil.unregister()
    try {
      display.off('change', this.callback);
    } catch (e) {
    }
  }

  @Builder
  TabBuilder(item: TabHeaderInfo) {
    Tab({
      isFirstTimeIn: this.isFirstTimeIn,
      tabHeaderInfo: item,
      isSelected: item.index === this.currentIndex,
      isDark: this.isDarkEnable
    })
  }

  build() {
    NavDestination() {
      HdsTabs({
        barPosition: BarPosition.End,
        controller: this.controller,
        index: this.currentIndex!!
      }) {
        ForEach(TabInfoRegister.tabInfos, (tabInfo: TabInfo, index: number) => {
          TabContent() {
            tabInfo.tabContentBuilder.builder(index)
          }
          .tabBar(this.TabBuilder(new TabHeaderInfo(tabInfo.tabHeaderInfo.name, tabInfo.tabHeaderInfo.showSearch,
            tabInfo.tabHeaderInfo.icon, index)))
        }, (tabInfo: TabInfo, index: number) => {
          return index + '_' + JSON.stringify(tabInfo.tabHeaderInfo.name);
        })
      }
      .scrollable(false)
      .barOverlap(true)
      .barHeight(this.tabState ? 56 : 0)
      .barFloatingStyle({
        barWidth: { smallWidth: 328, mediumWidth: 360, largeWidth: 360 },
        barBottomMargin: 28, // 距离屏幕底部的边距
        adaptToHandedness: true,
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.ADAPTIVE, // 启用沉浸光感材质
          materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE // 悬浮页签自定义沉浸光感材质效果
        }
      })
      .onTabBarClick((index: number) => {
        this.isFirstTimeIn = false;
        this.currentIndex = index;
        this.onColorModeChange();
      })
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      appRouter.back(true)
      try {
        window.getLastWindow(this.getUIContext().getHostContext(), (err: BusinessError, win) => {
          const errCode: number = err.code;
          if (errCode) {
            console.error(`Failed to obtain the top window. Cause code: ${err.code}, message: ${err.message}`);
            return;
          }
          win.minimize((err: BusinessError) => {
            const errCode: number = err.code;
            if (errCode) {
              console.error(`Failed to minimize the window. Cause code: ${err.code}, message: ${err.message}`);
              return;
            }
            console.info('Succeeded in minimizing the window.');
          });
          console.info('Succeeded in obtaining the top window. Data: ' + JSON.stringify(win));
        });
      } catch (exception) {
        console.error(`Failed to obtain the top window. Cause code: ${exception.code}, message: ${exception.message}`);
      }
      return true
    })
    .onWillHide(() => {
      Logger.info(TAG, 'onWillHide')
      this.tabShown = false
    })
    .onWillShow(() => {
      Logger.info(TAG, 'onWillShow')
      this.tabShown = true;
    })
  }
}

@Builder
export function MainTabPageBuilder() {
  MainTabPage();
}