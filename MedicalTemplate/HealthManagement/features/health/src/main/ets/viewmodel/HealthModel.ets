import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { BaseViewModel, BreakpointModel, TimeUtil } from 'common';
import { healthCard } from '../constants/constants';
import { BreakpointNameEnum } from 'common/src/main/ets/constant/GridRowColSetting';
import { HealthCardModel } from './HealthCardModel';
import { HealthDataInputModel } from './HealthDataInputModel';
import { PairedDeviceMacList } from 'device';

@ObservedV2
export class HealthModel extends BaseViewModel {
  @Trace activityHeat = 260; // 活动热量
  @Trace exerciseDuration = 20; // 锻炼时长
  @Trace travelDistance = 2.5; // 运动距离
  standardActivityHeat = 500; // 标准活动热量
  standardExerciseDuration = 60; // 标准锻炼时长
  standardTravelDistance = 5; // 标准运动距离
  @Trace stepCount = 2739; //今日步数
  @Trace isReportData = false; // 健康报告是否有数据
  @Trace breakPointModel: BreakpointModel =
    AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Trace cardList = healthCard;
  @Trace dataVM = new HealthCardModel();
  @Trace reportVM = new HealthCardModel();
  @Trace sleepVM = new HealthCardModel();
  @Trace bloodPreVM = new HealthCardModel();
  @Trace heartRateVM = new HealthCardModel();
  @Trace bloodSugarVM = new HealthCardModel();
  @Trace inputVM: HealthDataInputModel =
    PersistenceV2.connect(HealthDataInputModel, () => new HealthDataInputModel())!;
  @Trace macList: PairedDeviceMacList =
    PersistenceV2.connect(PairedDeviceMacList, () => new PairedDeviceMacList())!;
  private static _instance: HealthModel;

  public static get instance() {
    if (!HealthModel._instance) {
      HealthModel._instance = new HealthModel();
      HealthModel._instance.initHealthData();
      HealthModel._instance.initDeviceData();
    }
    return HealthModel._instance;
  }

  initDeviceData() {
    this.dataVM.img = $r('app.media.health_data_icon');
    this.dataVM.title = '健康数据';
    this.dataVM.type = 1;
    this.dataVM.icon = '';
    this.dataVM.timeStatus = TimeUtil.formatDate(new Date().getTime(), TimeUtil.PATTERN_DATE_TIME_CN_MONTH);

    this.reportVM.img = $r('app.media.health_report_icon');
    this.reportVM.title = '健康报告';
    this.reportVM.type = 2;
    this.reportVM.icon = '';
    this.reportVM.timeStatus = TimeUtil.formatDate(new Date().getTime(), TimeUtil.PATTERN_DATE_CN_WITHOUT_YEAR);


    this.sleepVM.img = $r('app.media.health_sleep_icon');
    this.sleepVM.title = '睡眠';
    this.sleepVM.type = 3;
    this.sleepVM.icon = $r('app.media.sleep_icon');

    if (this.macList.pairedList.length > 0) {
      this.dataVM.value = '良好';
      this.dataVM.desc = '今天身体状态';

      if (this.userInfo.weight > 0 && this.userInfo.height > 0) {
        this.reportVM.value = '良好';
        this.reportVM.desc = '今天身体状态';
      } else {
        this.reportVM.desc = '暂无数据';
      }

      this.sleepVM.value = '';
      this.sleepVM.desc = '7时35分';
      this.sleepVM.timeStatus = '目标 8小时 ｜良好';

      this.activityHeat = 260;
      this.exerciseDuration = 20;
      this.travelDistance = 2.5;
      this.stepCount = 2739;

    } else {
      this.dataVM.value = '';
      this.dataVM.desc = '暂无数据';
      this.reportVM.value = '';
      this.reportVM.desc = '暂无数据';
      this.sleepVM.value = '';
      this.sleepVM.desc = '暂无数据';
      this.sleepVM.timeStatus = TimeUtil.formatDate(new Date().getTime(), TimeUtil.PATTERN_DATE_CN_WITHOUT_YEAR);

      this.activityHeat = 0;
      this.exerciseDuration = 0;
      this.travelDistance = 0;
      this.stepCount = 0;
    }
  }

  initHealthData() {
    this.bloodPreVM.img = $r('app.media.health_blood_pre_icon');
    this.bloodPreVM.title = '血压';
    this.bloodPreVM.type = 4;
    this.bloodPreVM.icon = $r('app.media.blood_pre_icon');

    this.heartRateVM.img = $r('app.media.health_heart_rate_icon');
    this.heartRateVM.title = '心率';
    this.heartRateVM.type = 5;
    this.heartRateVM.icon = $r('app.media.heart_rate_icon');

    this.bloodSugarVM.img = $r('app.media.health_blood_sugar_icon');
    this.bloodSugarVM.title = '血糖';
    this.bloodSugarVM.type = 6;
    this.bloodSugarVM.icon = $r('app.media.blood_sugar_icon');

    if (this.macList.pairedList.length > 0) {
      this.bloodPreVM.value = this.inputVM.bloodPressureSystolic > 0 ?
      this.inputVM.bloodPressureSystolic.toString() : '--';
      this.bloodPreVM.diastolicValue = this.inputVM.bloodPressureDiastolic > 0 ?
      this.inputVM.bloodPressureDiastolic.toString() : '--';
      this.bloodPreVM.desc = 'mmHg';
      this.bloodPreVM.timeStatus = this.inputVM.bloodPressureTime;

      this.heartRateVM.value = this.inputVM.heartRate > 0 ? this.inputVM.heartRate.toString() : '--'
      this.heartRateVM.desc = '次/分';
      this.heartRateVM.timeStatus = this.inputVM.heartRateTime;

      this.bloodSugarVM.value = this.inputVM.bloodSugar > 0 ? this.inputVM.bloodSugar.toString() : '--';
      this.bloodSugarVM.desc = 'mmol/L';
      this.bloodSugarVM.timeStatus = this.inputVM.bloodSugarTime;
    } else {
      this.bloodPreVM.value = '';
      this.bloodPreVM.desc = '暂无数据';
      this.bloodPreVM.timeStatus = TimeUtil.formatDate(new Date().getTime(), TimeUtil.PATTERN_DATE_CN_WITHOUT_YEAR);
      this.heartRateVM.value = '';
      this.heartRateVM.desc = '暂无数据';
      this.heartRateVM.timeStatus = TimeUtil.formatDate(new Date().getTime(), TimeUtil.PATTERN_DATE_CN_WITHOUT_YEAR);
      this.bloodSugarVM.value = '';
      this.bloodSugarVM.desc = '暂无数据';
      this.bloodSugarVM.timeStatus = TimeUtil.formatDate(new Date().getTime(), TimeUtil.PATTERN_DATE_CN_WITHOUT_YEAR);
    }
  }

  @Computed
  get getFoldShow(): boolean {
    if (this.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM) {
      return false;
    } else {
      return true;
    }
  }
}