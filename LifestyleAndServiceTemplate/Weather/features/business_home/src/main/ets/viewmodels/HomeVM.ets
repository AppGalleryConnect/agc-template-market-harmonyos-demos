import { AppStorageV2 } from '@kit.ArkUI';
import { AppStorageMap, GridRowColSetting, LocationInfo, Logger, WindowUtil } from 'lib_foundation';
import { CityManager } from 'module_city_manage';
import { BroadCastUtil, VoiceType } from 'module_voice_broadcast';
import {
  BreakpointModel,
  CardRect,
  DailyWeather,
  HourlyWeather,
  IndicesWeather,
  RainConfig,
  RainEffectResumeState,
  RainEffectResumeUtil,
  RainLevel,
  RealTimeWeather,
  WeatherUtils,
} from 'module_weather_core';
import { WidgetUtil } from '../utils/WidgetUtil';

const TAG = '[HomeVM]';
const TITLE_BAR_HEIGHT: number = 56;
const DEFAULT_TOP_PADDING: number = 536;
const MIDDLE_WINDOW_TOP_PADDING: number = 480;
const LARGE_WINDOW_TOP_PADDING: number = 420;
const SCROLL_RATE_THRESHOLD: number = 0.5;

@ObservedV2
export class HomeVM {
  @Trace rate: number = 0;
  @Trace location: LocationInfo = { name: '北京', code: '110100' };
  @Trace realTimeWeather: RealTimeWeather | undefined;
  @Trace hourlyWeathers: HourlyWeather[] = [];
  @Trace dailyWeathers: DailyWeather[] = [];
  @Trace indicesWeathers: IndicesWeather[][] = [];
  @Trace uiContext: UIContext | null = null
  private static _instance: HomeVM;
  scrollerController: Scroller = new Scroller();
  swiperController: SwiperController = new SwiperController();
  readonly weatherCardSpan: GridColColumnOption = {
    sm: 4,
    md: 8,
    lg: 6,
    xl: 6,
  };
  readonly weatherCardOffset: GridColColumnOption = {
    sm: 0,
    md: 0,
    lg: 0,
    xl: 0,
  };
  readonly largeCardTitleHeight: number = TITLE_BAR_HEIGHT;
  readonly largeHourlyContentHeight: number = 224;
  readonly weatherGridOptions: GridRowOptions = {
    gutter: {
      x: {
        sm: 0,
        md: 0,
        lg: 16,
        xl: 16,
      },
      y: {
        sm: 0,
        md: 0,
        lg: 16,
        xl: 16,
      },
    },
    columns: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS,
    breakpoints: {
      value: GridRowColSetting.BREAK_POINT_VALUE,
      reference: BreakpointsReference.WindowSize,
    },
    direction: GridRowDirection.Row,
  };
  @Trace rainLevel: RainLevel = RainLevel.NONE;
  @Trace cardRects: Map<string, CardRect> = new Map();
  @Trace breakpointModel: BreakpointModel =
    AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Trace scrollHeight: number = 0;
  @Trace largeGridHeight: number = 0;
  private resumeUtils: RainEffectResumeUtil = new RainEffectResumeUtil();
  resumeState: RainEffectResumeState = this.resumeUtils.getState();
  private _locationRequestId: number = 0;

  @Monitor('location')
  private onLocationChange() {
    Logger.debug(TAG, 'onLocationChange, location: ' + this.location.code);
    const requestId = ++this._locationRequestId;
    WidgetUtil.setLocation(this.location, this.uiContext?.getHostContext()!);
    WidgetUtil.updateWeatherInfo(this.uiContext?.getHostContext()!);
    WeatherUtils.getRealTimeWeathers([this.location.code]).then(res => {
      if (requestId !== this._locationRequestId) {
        return;
      }
      this.realTimeWeather = res[0];
      this.rainLevel = RainConfig.getRainLevel(this.realTimeWeather?.desc ?? '');
      AppStorage.setOrCreate(AppStorageMap.REALTIME_WEATHER, this.realTimeWeather);
      Logger.debug(TAG, 'realtime weather: ' + JSON.stringify(this.realTimeWeather));
    });
    WeatherUtils.getHourlyWeathers(this.location.code).then(res => {
      if (requestId !== this._locationRequestId) {
        return;
      }
      this.hourlyWeathers = res;
    });
    WeatherUtils.getDailyWeathers(this.location.code).then(res => {
      if (requestId !== this._locationRequestId) {
        return;
      }
      this.dailyWeathers = res;
    });
    WeatherUtils.getIndicesWeathers(this.location.code, 3).then(res => {
      if (requestId !== this._locationRequestId) {
        return;
      }
      this.indicesWeathers = res;
      AppStorage.setOrCreate(AppStorageMap.INDICES, this.indicesWeathers);
    });
  }

  public static get instance() {
    if (!HomeVM._instance) {
      HomeVM._instance = new HomeVM();
    }
    return HomeVM._instance;
  }

  public async init() {
    this.onLocationChange();
    const res = await CityManager.applyLocationPermission();
    this.location = { name: res.name, code: res.code };
  }

  @Computed
  get isLargeWindow(): boolean {
    return this.breakpointModel.isLargeWindow;
  }

  @Computed
  get topTitleHeight(): number {
    return TITLE_BAR_HEIGHT + WindowUtil.getAvoidArea().top;
  }

  @Computed
  get topPadding(): number {
    if (this.breakpointModel.isMiddleWindow) {
      return MIDDLE_WINDOW_TOP_PADDING;
    }
    return this.isLargeWindow ? LARGE_WINDOW_TOP_PADDING : DEFAULT_TOP_PADDING;
  }

  @Computed
  get largeBottomBlankHeight(): number {
    const height = this.scrollHeight - this.largeGridHeight - this.topTitleHeight;
    return height > 0 ? height : 40;
  }

  @Computed
  get scrollPadding(): number {
    return this.isLargeWindow ? 32 : 0;
  }

  @Computed
  get largeHourlyCardHeight(): number {
    return this.largeCardTitleHeight + this.largeHourlyContentHeight;
  }

  public updateLargeGridHeight(height: number): void {
    this.largeGridHeight = height;
  }

  public updateScrollHeight(height: number): void {
    this.scrollHeight = height;
  }

  public scroll() {
    const temp =
      this.scrollerController.currentOffset().yOffset /
        (this.topPadding - WindowUtil.getAvoidArea().top - TITLE_BAR_HEIGHT);
    if (temp <= 0) {
      this.rate = 0;
    } else if (temp >= 1) {
      this.rate = 1;
    } else {
      this.rate = temp;
    }

    if (this.rate > SCROLL_RATE_THRESHOLD) {
      this.swiperController.changeIndex(1, true);
    } else {
      this.swiperController.changeIndex(0, true);
    }
  }

  /**
   * 播报能力
   * 英文播报更多内容前,自行翻译
   */
  public speak() {
    let text = '';
    const tempRound = this.realTimeWeather!.temp.toFixed();
    if (BroadCastUtil.getCurVoiceType() !== VoiceType.US_FEMALE) {
      text = `实时气温 ${tempRound}摄氏度,
             最高气温 ${this.realTimeWeather!.maxTemp}摄氏度,
             最低气温 ${this.realTimeWeather!.minTemp}摄氏度`;
    } else {
      text = `The real-time temperature is ${tempRound} degrees Celsius,
              the maximum temperature is ${this.realTimeWeather!.maxTemp} degrees Celsius,
              the minimum temperature is ${this.realTimeWeather!.minTemp} degrees Celsius`;
    }
    BroadCastUtil.speak(text);
  }

  /**
   * 监测碰撞区域变化
   */
  onCollisionAreaChange(newArea: Area) {
    const newRects = new Map<string, CardRect>(this.cardRects);
    const rect: CardRect = {
      x: (newArea.globalPosition.x as number),
      y: (newArea.globalPosition.y as number),
      width: newArea.width as number,
      height: newArea.height as number,
    };
    Logger.info(TAG,
      `HomeArea uiNow rect: x=${rect.x}, y=${rect.y}, w=${rect.width}, h=${rect.height}`);
    newRects.set('uiNow', rect);
    this.cardRects = newRects;
  }
}
