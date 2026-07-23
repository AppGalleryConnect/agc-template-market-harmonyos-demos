import { common } from '@kit.AbilityKit';
import { CommonConstants, RouterMap, RouterModule } from 'lib_foundation';
import { ThemeController } from 'module_theme';
import { RainEffect, UIDays, UIHours, UIIndices, UINow } from 'module_weather_core';
import { SystemSceneUtils } from 'module_city_manage';
import {
  CARD_BORDER_RADIUS,
  DAILY_ITEM_WIDTH,
  DIVIDER_HEIGHT,
  HOURLY_ITEM_WIDTH,
  INDICES_COLUMNS_MD,
  INDICES_COLUMNS_SM,
  INDICES_ITEM_SPACE_LG,
  INDICES_ITEM_SPACE_SM,
  LARGE_HEADER_MARGIN,
  MASK_MAX_OPACITY,
  MOBILE_REALTIME_CARD_HEIGHT,
  SPEAKER_BTN_SIZE,
  SPEAKER_ICON_SIZE,
} from '../constants/HomeConstants';
import { TopLocation } from '../components/TopLocation';
import { HomeVM } from '../viewmodels/HomeVM';

@ComponentV2
export struct Home {
  vm: HomeVM = HomeVM.instance;

  aboutToAppear(): void {
    this.vm.uiContext = this.getUIContext()
    SystemSceneUtils.context = this.getUIContext().getHostContext() as common.UIAbilityContext
    this.vm.init();
  }

  build() {
    Column() {
      Image(ThemeController.themePic)
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)
        .objectFit(ImageFit.Cover)
        .position({ top: 0 })
        .opacity(1 - this.vm.rate)

      Column()
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)
        .backgroundColor(ThemeController.themeColor)
        .opacity(this.vm.rate * MASK_MAX_OPACITY)
        .position({ top: 0 })

      TopLocation().position({ top: 0 }).zIndex(1)

      RainEffect({
        rainLevel: this.vm.rainLevel,
        cardRects: this.vm.cardRects,
        resumeVersion: this.vm.resumeState.version,
        themeColor: ThemeController.themeColor,
      })

      Scroll(this.vm.scrollerController) {
        Column() {
          this.weatherContentBuilder()
        }
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Fade)
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .padding({ left: this.vm.scrollPadding, right: this.vm.scrollPadding })
      .onScrollFrameBegin((offset) => {
        this.vm.scroll();
        return { offsetRemain: offset };
      })
      .onAreaChange((_oldArea: Area, newArea: Area) => {
        this.vm.updateScrollHeight(Number(newArea.height));
      })
    }
    .backgroundColor(ThemeController.themeColor)
  }

  @Builder
  weatherContentBuilder() {
    Column() {
      GridRow(this.vm.weatherGridOptions) {
        this.realTimeWeatherBuilder()
        this.hourlyWeatherBuilder()
        this.dailyWeatherBuilder()
        this.indicesWeatherBuilder()
      }
      .onAreaChange((_oldArea: Area, newArea: Area) => {
        this.vm.onCollisionAreaChange(newArea);
        if (this.vm.isLargeWindow) {
          this.vm.updateLargeGridHeight(Number(newArea.height));
        }
      })

      if (this.vm.isLargeWindow) {
        Blank()
          .height(this.vm.largeBottomBlankHeight)
      } else {
        Blank().layoutWeight(1).width(CommonConstants.FULL_PERCENT)
      }
    }
    .margin({ top: this.vm.topPadding })
    .backgroundColor(this.vm.isLargeWindow ? Color.Transparent : $r('sys.color.background_primary'))
    .borderRadius(this.vm.isLargeWindow ? 0 : { topLeft: CARD_BORDER_RADIUS, topRight: CARD_BORDER_RADIUS })
    .clip(true)
  }

  @Builder
  realTimeWeatherBuilder() {
    if (this.vm.realTimeWeather) {
      GridCol({ span: this.vm.weatherCardSpan, offset: this.vm.weatherCardOffset }) {
        UINow({
          weather: this.vm.realTimeWeather,
          customHeight: this.vm.isLargeWindow ? this.vm.largeHourlyCardHeight : MOBILE_REALTIME_CARD_HEIGHT,
          headerMargin: this.vm.isLargeWindow ? LARGE_HEADER_MARGIN : {},
        }) {
          this.speakerBuilder()
        }

        if (!this.vm.isLargeWindow) {
          this.mobileDividerBuilder()
        }
      }
      .borderRadius(this.vm.isLargeWindow ? CARD_BORDER_RADIUS : 0)
      .clip(this.vm.isLargeWindow)
    }
  }

  @Builder
  hourlyWeatherBuilder() {
    if (this.vm.hourlyWeathers.length) {
      GridCol({ span: this.vm.weatherCardSpan, offset: this.vm.weatherCardOffset }) {
        UIHours({
          weathers: this.vm.hourlyWeathers,
          itemWidth: HOURLY_ITEM_WIDTH,
          customHeight: this.vm.largeHourlyContentHeight,
        })

        if (!this.vm.isLargeWindow) {
          this.mobileDividerBuilder()
        }
      }
      .borderRadius(this.vm.isLargeWindow ? CARD_BORDER_RADIUS : 0)
      .clip(this.vm.isLargeWindow)
    }
  }

  @Builder
  dailyWeatherBuilder() {
    if (this.vm.dailyWeathers.length) {
      GridCol({ span: this.vm.weatherCardSpan, offset: this.vm.weatherCardOffset }) {
        UIDays({
          weathers: this.vm.dailyWeathers,
          itemWidth: DAILY_ITEM_WIDTH,
        })

        if (!this.vm.isLargeWindow) {
          this.mobileDividerBuilder()
        }
      }
      .borderRadius(this.vm.isLargeWindow ? CARD_BORDER_RADIUS : 0)
      .clip(this.vm.isLargeWindow)
    }
  }

  @Builder
  indicesWeatherBuilder() {
    if (this.vm.indicesWeathers.length) {
      GridCol({ span: this.vm.weatherCardSpan, offset: this.vm.weatherCardOffset }) {
        UIIndices({
          weathers: this.vm.indicesWeathers[0],
          itemSpace: this.vm.isLargeWindow ? INDICES_ITEM_SPACE_LG : INDICES_ITEM_SPACE_SM,
          columnsNum: this.vm.breakpointModel.isMiddleWindow ? INDICES_COLUMNS_MD : INDICES_COLUMNS_SM,
          click: (weather) => {
            RouterModule.push({ url: RouterMap.INDICES, param: weather.type });
          },
        })
      }
      .borderRadius(this.vm.isLargeWindow ? CARD_BORDER_RADIUS : 0)
      .clip(this.vm.isLargeWindow)
    }
  }

  @Builder
  speakerBuilder() {
    Row() {
      Image($r('app.media.ic_speaker')).width(SPEAKER_ICON_SIZE)
    }
    .width(SPEAKER_BTN_SIZE)
    .height(SPEAKER_BTN_SIZE)
    .onClick(() => {
      this.vm.speak()
    })
  }

  @Builder
  mobileDividerBuilder() {
    Blank().width(CommonConstants.FULL_PERCENT).height(DIVIDER_HEIGHT)
      .backgroundColor($r('sys.color.background_secondary'))
  }
}
