import { ControlInfo, RunMode, WindDirection, WindMode, WindSpeed } from '../model/Index';
import {  ScheduledUtil } from '../util/Index';


const TAG = '[BaseLayoutVM]';

@ObservedV2
export class BaseLayoutVM {
  // 定时弹框
  @Trace isScheduledShow: boolean = false;
  // 名称弹框
  @Trace isNameShow: boolean = false;
  @Trace bakName: string = '';
  // 定时信息
  @Trace scheduledStr: string = '';
  // 风速图标
  @Trace windSpeedIcon: ResourceStr = $r('app.media.icon_auto');
  // 风向图标
  @Trace windDirectionIcon: ResourceStr = $r('app.media.icon_auto');
  // 运行模式文字
  @Trace runModeStr: string = '';
  // 运行模式图标
  @Trace runModeIcon: ResourceStr = $r('app.media.icon_auto');
  // 扫风图标
  @Trace windModeIcon: ResourceStr = $r('app.media.icon_auto');
  // 标志高度是否小于设计UX高度
  @Trace isLowHeight:boolean = false
  private static _instance: BaseLayoutVM;

  public static get instance() {
    if (!BaseLayoutVM._instance) {
      BaseLayoutVM._instance = new BaseLayoutVM();
    }
    return BaseLayoutVM._instance;
  }


  // 切换模式
  changeMode(data: RunMode) {
    switch (data) {
      case RunMode.AUTO:
        return RunMode.HOT;
      case RunMode.HOT:
        return RunMode.COLD;
      case RunMode.COLD:
        return RunMode.WIND;
      case RunMode.WIND:
        return RunMode.DRY;
      default:
        return RunMode.AUTO;
    }
  }

  // 切换风速
  changeWindSpeed(data: WindSpeed) {
    switch (data) {
      case WindSpeed.AUTO:
        return WindSpeed.SLOW;
      case WindSpeed.SLOW:
        return WindSpeed.MIDDLE;
      case WindSpeed.MIDDLE:
        return WindSpeed.FAST;
      default:
        return WindSpeed.AUTO;
    }
  }

  changeWindMode(data: WindMode) {
    switch (data) {
      case WindMode.AUTO:
        return WindMode.MANUAL;
      default:
        return WindMode.AUTO;
    }
  }


  // 切换风向
  changeWindDirection(data: WindDirection) {
    switch (data) {
      case WindDirection.UP:
        return WindDirection.CENTER;
      case WindDirection.CENTER:
        return WindDirection.BOTTOM;
      case WindDirection.BOTTOM:
        return WindDirection.AUTO;
      default:
        return WindDirection.UP;
    }
  }

  upDateView(data: ControlInfo) {
    switch (data.runMode) {
      case RunMode.AUTO:
        this.runModeStr = '自动';
        this.runModeIcon = $r('app.media.icon_auto');
        break;
      case RunMode.HOT:
        this.runModeStr = '制热';
        this.runModeIcon = $r('app.media.icon_heat');
        break;
      case RunMode.COLD:
        this.runModeStr = '制冷';
        this.runModeIcon = $r('app.media.icon_cold');
        break;
      case RunMode.WIND:
        this.runModeStr = '送风';
        this.runModeIcon = $r('app.media.icon_blow');
        break;
      default :
        this.runModeStr = '除湿';
        this.runModeIcon = $r('app.media.icon_dehumidification');
    }

    switch (data.windSpeed) {
      case WindSpeed.AUTO:
        this.windSpeedIcon = $r('app.media.icon_auto');
        break;

      case WindSpeed.SLOW:
        this.windSpeedIcon = $r('app.media.icon_wind_speed1');
        break;

      case WindSpeed.MIDDLE:
        this.windSpeedIcon = $r('app.media.icon_wind_speed2');
        break;

      default:
        this.windSpeedIcon = $r('app.media.icon_wind_speed3');
    }

    switch (data.windDirection) {
      case WindDirection.AUTO:
        this.windDirectionIcon = $r('app.media.icon_auto');
        break;
      case WindDirection.UP:
        this.windDirectionIcon = $r('app.media.icon_sweeping_up');
        break;
      case WindDirection.CENTER:
        this.windDirectionIcon = $r('app.media.icon_sweeping_medium');
        break;
      default:
        this.windDirectionIcon = $r('app.media.icon_sweeping_down');
    }

    // 扫风图标
    switch (data.windMode) {
      case WindMode.AUTO:
        this.windModeIcon = $r('app.media.icon_auto');
        break;
      default:
        this.windModeIcon = $r('app.media.icon_wind_sweeping');
    }

    if (data.isScheduled) {
      this.scheduledStr = `定时${ScheduledUtil.getTimeAfterMilliseconds(new Date(data.startTime), data.interval)}关闭`;
    } else {
      this.scheduledStr = '';
    }


  }
}