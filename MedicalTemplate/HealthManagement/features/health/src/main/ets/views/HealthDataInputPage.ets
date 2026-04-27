import { PersistenceV2 } from '@kit.ArkUI';
import {
  CommonHeader,
  getMsgDialogData,
  MessageReminderDialog,
  UserInfo,
  BarVM,
  TimeUtil,
  OHDialog,
  OHDialogModel
} from 'common'
import { OHPage, phoneRouterControl } from 'oh_router'
import { HealthDataActivityRow } from '../comp/HealthDataActivityRow';
import { HealthDataBMIRow } from '../comp/HealthDataBMIRow';
import { HealthDataInputDialog } from '../comp/HealthDataInputDialog';
import { HealthInfoRow } from '../comp/HealthInfoRow';
import { HealthDataInputDialogModel } from '../viewmodel/HealthDataInputDialogModel';
import { HealthDataInputModel } from '../viewmodel/HealthDataInputModel';
import { WeightDialogModel } from '../viewmodel/WeightDialogModel';
import {
  abnormalDialogDelayTime,
  bloodPressureSystolicMaxNormalValue,
  bloodPressureSystolicMinNormalValue,
  bloodPressureDiastolicMaxNormalValue,
  bloodPressureDiastolicMinNormalValue,
  bloodSugarMaxNormalValue,
  bloodSugarMinNormalValue,
  heartRateMaxNormalValue,
  heartRateMinNormalValue,
  weightRange
} from '../constants/constants';
import { HealthModel } from '../viewmodel/HealthModel';

@Builder
export function HealthDataInputPageBuilder() {
  HealthDataInputPage()
}

/**
 * @usage: 健康数据输入页面，提供用户健康数据的录入和管理功能。支持体重、腰围，臀围，血压、血糖、心率健康指标的输入和BMI计算。
 * 主要数据结构包括HealthDataInputModel（健康数据输入模型）、UserInfo（用户信息）、各种健康数据对话框模型。
 * 包含if逻辑判断健康数据范围和异常提醒。
 * @layout: 页面采用垂直布局（Column），顶部为CommonHeader导航栏，下方为健康数据输入表单。
 * 表单包含多个健康数据行组件，支持弹窗输入和数据验证。
 * @constraints:
 * @domain: 健康医疗
 * @zhName: 健康数据输入页面
 * @isGen: true
 * @fileType: page
 * @subPage:
 * @component: CommonHeader,MessageReminderDialog,OHPage,HealthDataActivityRow,HealthDataBMIRow,HealthDataInputDialog,
 * HealthInfoRow,HMWeightDialog
 * @image: screenshot/health/HealthDataInput.jpg
 */
@ComponentV2
export struct HealthDataInputPage {
  @Local vm: HealthDataInputModel = PersistenceV2.connect(HealthDataInputModel, () => new HealthDataInputModel())!;
  @Local userInfoVM: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  healthModelVM: HealthModel = HealthModel.instance;
  @Local onReturnClick: () => void = () => {
    phoneRouterControl.popPage()
  }

  aboutToAppear(): void {
    this.vm.weight = this.userInfoVM.weight;
    let temp = Math.floor(this.vm.weight);
    if (this.vm.weight - temp > 0) {
      this.vm.weightIndex = weightRange.indexOf(this.vm.weight.toString());
    } else {
      this.vm.weightIndex = weightRange.indexOf(this.vm.weight.toString() + '.0');
    }
    this.bmiCalculator();
  }

  /**
   * bmi计算
   */
  bmiCalculator() {
    if (this.userInfoVM.height === 0 || this.userInfoVM.weight === 0) {
      this.vm.bmiType = 1;
      this.vm.bmiValue = 0;
      return;
    }
    this.vm.bmiValue = this.vm.bmiCalculator(this.userInfoVM.height, this.userInfoVM.weight)
    this.vm.bmiType = this.vm.bmiTypeCalculator(this.vm.bmiValue);

    if (this.userInfoVM.birthday === '' || this.userInfoVM.gender === '') {
      this.vm.bodyFatPercentage = 0;
      this.vm.fatWeight = 0;
      return;
    }
    this.vm.bodyFatPercentage =
      this.vm.getBodyFatPercentage(this.userInfoVM.birthday, this.vm.bmiValue, this.userInfoVM.gender);
    this.vm.fatWeight = (Math.round(this.vm.weight * (this.vm.bodyFatPercentage / 100) * 10)) / 10;
  }

  bloodPreCalculator() {
    const dateStr = TimeUtil.formatDate(new Date().getTime(), TimeUtil.PATTERN_DATE_CN_WITHOUT_YEAR);
    if ((Number(this.vm.bloodPressureDiastolic) > bloodPressureDiastolicMaxNormalValue ||
      Number(this.vm.bloodPressureDiastolic) < bloodPressureDiastolicMinNormalValue) &&
      (Number(this.vm.bloodPressureSystolic) > bloodPressureSystolicMaxNormalValue ||
        Number(this.vm.bloodPressureSystolic) < bloodPressureSystolicMinNormalValue)) {
      this.vm.bloodPressureTime = dateStr + ' 异常高低压'
    } else if ((Number(this.vm.bloodPressureDiastolic) <= bloodPressureDiastolicMaxNormalValue &&
      Number(this.vm.bloodPressureDiastolic) >= bloodPressureDiastolicMinNormalValue) &&
      (Number(this.vm.bloodPressureSystolic) > bloodPressureSystolicMaxNormalValue ||
        Number(this.vm.bloodPressureSystolic) < bloodPressureSystolicMinNormalValue)) {
      this.vm.bloodPressureTime = dateStr + ' 异常高压'
    } else if ((Number(this.vm.bloodPressureDiastolic) > bloodPressureDiastolicMaxNormalValue ||
      Number(this.vm.bloodPressureDiastolic) < bloodPressureDiastolicMinNormalValue) &&
      (Number(this.vm.bloodPressureSystolic) <= bloodPressureSystolicMaxNormalValue &&
        Number(this.vm.bloodPressureSystolic) >= bloodPressureSystolicMinNormalValue)) {
      this.vm.bloodPressureTime = dateStr + ' 异常低压'
    } else {
      this.vm.bloodPressureTime = dateStr + ' 正常高低压'
    }
    this.healthModelVM.initHealthData();
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      CommonHeader({
        title: $r('app.string.health_date_input_name'),
        onReturnClick: this.onReturnClick,
        leftImageRes: $r('app.media.ic_backward2')
      })

      Column() {
        List({ space: 12 }) {
          ListItem() {
            HealthDataActivityRow()
          }

          ListItem() {
            HealthDataBMIRow()
          }

          ListItemGroup() {
            ListItem() {
              HealthInfoRow({
                titleName: $r('app.string.health_bmi_weight'),
                titleValue: this.vm.weight > 0 ? this.vm.weight + '公斤' : '',
                placeholder: $r('app.string.health_bmi_weight_placeholder')
              })
            }
            .onClick(() => {
              let model = new WeightDialogModel();
              model.title = $r('app.string.health_bmi_weight');
              model.changeValue = this.vm.weight.toString();
              model.changeIndex = this.vm.weightIndex;
              model.onValueConfirmClick = (dialogModel: OHDialogModel) => {
                this.vm.weight = Number(dialogModel.changeValue);
                this.userInfoVM.weight = this.vm.weight;
                this.vm.weightIndex = dialogModel.changeIndex;
                this.healthModelVM.initDeviceData();
                this.bmiCalculator();
              }
              model.childBuilder = this.weightDialogBuilder
              OHDialog.ShowPopup(model)
            })

            ListItem() {
              HealthInfoRow({
                titleName: $r('app.string.health_bmi_waistCircumference'),
                titleValue: this.vm.waistCircumference > 0 ? this.vm.waistCircumference + '厘米' : '',
                placeholder: $r('app.string.health_bmi_waistCircumference_placeholder')
              })
            }
            .onClick(() => {
              let model = new HealthDataInputDialogModel();
              model.title = $r('app.string.health_bmi_waistCircumference');
              model.unit = '厘米';
              model.value = this.vm.waistCircumference;
              model.onValueConfirmClick = (dialogModel: HealthDataInputDialogModel) => {
                this.vm.waistCircumference = dialogModel.value;
              }
              HealthDataInputDialog.ShowInputPopup(model);
            })

            ListItem() {
              HealthInfoRow({
                titleName: $r('app.string.health_bmi_hipCircumference'),
                titleValue: this.vm.hipCircumference > 0 ? this.vm.hipCircumference + '厘米' : '',
                placeholder: $r('app.string.health_bmi_hipCircumference_placeholder')
              })
            }
            .onClick(() => {
              let model = new HealthDataInputDialogModel();
              model.title = $r('app.string.health_bmi_hipCircumference');
              model.unit = '厘米';
              model.value = this.vm.hipCircumference;
              model.onValueConfirmClick = (dialogModel: HealthDataInputDialogModel) => {
                this.vm.hipCircumference = dialogModel.value;
              }
              HealthDataInputDialog.ShowInputPopup(model);
            })
          }
          .backgroundColor(Color.White)
          .width('100%')
          .borderRadius($r('sys.float.corner_radius_level7'))
          .clip(true)

          ListItemGroup() {
            ListItem() {
              // 血糖
              HealthInfoRow({
                titleName: $r('app.string.health_bmi_bloodSugar'),
                titleValue: this.vm.bloodSugar > 0 ? this.vm.bloodSugar + 'mmol/L' : '',
                placeholder: $r('app.string.health_bmi_bloodSugar_placeholder')
              })
            }
            .onClick(() => {
              let model = new HealthDataInputDialogModel();
              model.title = $r('app.string.health_bmi_bloodSugar');
              model.unit = 'mmol/L';
              model.value = this.vm.bloodSugar;
              model.onValueConfirmClick = (dialogModel: HealthDataInputDialogModel) => {
                this.vm.bloodSugar = dialogModel.value;
                const dateStr = TimeUtil.formatDate(new Date().getTime(), TimeUtil.PATTERN_DATE_TIME_CN_MONTH);
                this.vm.bloodSugarTime = dateStr + ' 餐后数据'
                this.healthModelVM.initHealthData();
                // todo 录入血糖在正常值范围外，弹框提醒血糖异常
                if (this.vm.bloodSugar > bloodSugarMaxNormalValue ||
                  this.vm.bloodSugar < bloodSugarMinNormalValue) {
                  setTimeout(() => {
                    MessageReminderDialog.ShowMsgReminderPopup(getMsgDialogData()[2]);
                  }, abnormalDialogDelayTime);
                }
              }
              HealthDataInputDialog.ShowInputPopup(model);
            })

            ListItem() {
              HealthInfoRow({
                titleName: $r('app.string.health_bmi_heartRate'),
                titleValue: this.vm.heartRate > 0 ? this.vm.heartRate + '次/分' : '',
                placeholder: $r('app.string.health_bmi_heartRate_placeholder')
              })
            }
            .onClick(() => {
              let model = new HealthDataInputDialogModel();
              model.title = $r('app.string.health_bmi_heartRate');
              model.unit = '次/分';
              model.value = this.vm.heartRate;
              model.onValueConfirmClick = (dialogModel: HealthDataInputDialogModel) => {
                this.vm.heartRate = dialogModel.value;
                let tempHeartRate = Math.floor(dialogModel.value / 10);
                this.vm.heartRateTime = `心率范围${tempHeartRate * 10}-${(tempHeartRate + 1) * 10}次/分钟`
                this.healthModelVM.initHealthData();
                // todo 录入心率在正常值范围外，弹框提醒心率异常
                if (Number(this.vm.heartRate) > heartRateMaxNormalValue ||
                  Number(this.vm.heartRate) < heartRateMinNormalValue) {
                  setTimeout(() => {
                    MessageReminderDialog.ShowMsgReminderPopup(getMsgDialogData()[0]);
                  }, abnormalDialogDelayTime);
                }
              }
              HealthDataInputDialog.ShowInputPopup(model);
            })

            // 血压高压
            ListItem() {
              HealthInfoRow({
                titleName: $r('app.string.health_bmi_bloodPressureSystolic'),
                titleValue: this.vm.bloodPressureSystolic > 0 ? this.vm.bloodPressureSystolic + 'mmHg' : '',
                placeholder: $r('app.string.health_bmi_bloodPressureSystolic_placeholder')
              })
            }
            .onClick(() => {
              let model = new HealthDataInputDialogModel();
              model.title = $r('app.string.health_bmi_bloodPressureSystolic');
              model.unit = 'mmHg';
              model.value = this.vm.bloodPressureSystolic;
              model.onValueConfirmClick = (dialogModel: HealthDataInputDialogModel) => {
                this.vm.bloodPressureSystolic = dialogModel.value;
                this.bloodPreCalculator();
                // todo 录入收缩压在正常值范围外，弹框提醒血压异常
                if (Number(this.vm.bloodPressureSystolic) > bloodPressureSystolicMaxNormalValue ||
                  Number(this.vm.bloodPressureSystolic) < bloodPressureSystolicMinNormalValue) {
                  setTimeout(() => {
                    MessageReminderDialog.ShowMsgReminderPopup(getMsgDialogData()[1]);
                  }, abnormalDialogDelayTime);
                }
              }
              HealthDataInputDialog.ShowInputPopup(model);
            })

            // 血压低压
            ListItem() {
              HealthInfoRow({
                titleName: $r('app.string.health_bmi_bloodPressureDiastolic'),
                titleValue: this.vm.bloodPressureDiastolic > 0 ? this.vm.bloodPressureDiastolic + 'mmHg' : '',
                placeholder: $r('app.string.health_bmi_bloodPressureDiastolic_placeholder')
              })
            }
            .onClick(() => {
              let model = new HealthDataInputDialogModel();
              model.title = $r('app.string.health_bmi_bloodPressureDiastolic');
              model.unit = 'mmHg';
              model.value = this.vm.bloodPressureDiastolic;
              model.onValueConfirmClick = (dialogModel: HealthDataInputDialogModel) => {
                this.vm.bloodPressureDiastolic = dialogModel.value;
                this.bloodPreCalculator();
                // todo 录入舒张压在正常值范围外，弹框提醒血压异常
                if (Number(this.vm.bloodPressureDiastolic) > bloodPressureDiastolicMaxNormalValue ||
                  Number(this.vm.bloodPressureDiastolic) < bloodPressureDiastolicMinNormalValue) {
                  setTimeout(() => {
                    MessageReminderDialog.ShowMsgReminderPopup(getMsgDialogData()[1]);
                  }, abnormalDialogDelayTime);
                }
              }
              HealthDataInputDialog.ShowInputPopup(model);
            })
          }
          .backgroundColor(Color.White)
          .width('100%')
          .borderRadius($r('sys.float.corner_radius_level7'))
          .clip(true)

          ListItem().height(px2vp(BarVM.instance.aiBarH))
        }
        .height('100%')
        .width('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .backgroundColor($r('app.color.color_F1F3F5'))
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      useSafePadding: true
    })
  }

  @Builder
  weightDialogBuilder(weightDialogModel: OHDialogModel) {
    Column(){
      Stack() {
        TextPicker({
          range: weightRange,
          value: weightDialogModel.changeValue,
          selected: weightDialogModel.changeIndex,
        })
          .height('100%')
          .width('100%')
          .canLoop(true)
          .onChange((value: string | string[], index: number | number[]) => {
            weightDialogModel.changeValue = value;
            weightDialogModel.changeIndex = index;
          })

        Text('公斤')
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_emphasize'))
          .fontWeight(FontWeight.Medium)
          .position({ x: '60%', y: '92vp' })
          .hitTestBehavior(HitTestMode.None)
      }
      .height($r('app.float.vp_200'))
      .width('100%')
    }
  }
}
