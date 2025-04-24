import {
  CommonConstants,
  DateUtil,
  DialogUtils,
  GlobalContext,
  rightArrow,
  StringUtil,
} from '@ohos_agcit/children_education_utils';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { JSON } from '@kit.ArkTS';

@Builder
export function TimeCtrlBuilder() {
  TimeCtrl();
}

@ComponentV2
export struct TimeCtrl {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  topRectHeight: number = 0;
  @Local lunchEndTime: string = CommonConstants.EMPTY_STRING;
  @Local nightStartTime: string = CommonConstants.EMPTY_STRING;
  @Local nightEndTime: string = CommonConstants.EMPTY_STRING;
  @Local timeLimit: string = CommonConstants.EMPTY_STRING;
  @Local lunchStartTime: string = CommonConstants.EMPTY_STRING;
  private timeArray: Resource = $r('app.strarray.time_array');
  @Local lunchTimeState: boolean = false;
  @Local nightTimeState: boolean = false;
  private selectTime: Date = new Date()

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        textTitleBuilder('每日播放');
        Row() {
          textCommonBuilder('每日使用时长');
          Blank();
          Text(this.timeLimit)
            .fontSize(14)
            .fontFamily('鸿蒙黑体')
            .fontWeight(FontWeight.Regular)
            .opacity(0.6)
            .padding({
              right: '3%',
            });
          rightArrow();
        }
        .alignItems(VerticalAlign.Center)
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .borderRadius(16)
        .rowExtend(12, 14)
        .height(56)
        .onClick(() => {
          DialogUtils.textPickerDialog(this.timeArray, (sexValue: string) => {
            this.timeLimit = sexValue;
          });
        });

        textTitleBuilder('禁止观看时间');
        Column() {
          Row() {
            textCommonBuilder('晚间休息');
            Blank();
            Toggle({ type: ToggleType.Switch, isOn: this.nightTimeState })
              .selectedColor('#FFD15D')
              .switchPointColor($r('sys.color.comp_background_list_card'))
              .onChange((nightIsOn: boolean) => {
                this.nightTimeState = nightIsOn;
                let startTimeIsNull = StringUtil.isEmpty(this.nightStartTime);
                let endTimeIsNull = StringUtil.isEmpty(this.nightEndTime);
                let b = startTimeIsNull || endTimeIsNull;
                if (nightIsOn && b) {
                  //自定义吐司
                  DialogUtils.showToast('请选择开始和结束时间', {
                    fontColor: Color.Black,
                    backgroundColor: '#99e3dcdc',
                    duration: 1500,
                    alignment: Alignment.Center,
                  });
                }
              });
          }
          .rowExtend(12,12);

          divider();

          Row() {
            textCommonBuilder('开始时间');
            Blank();
            Text(this.nightStartTime).padding({ right: 4 });
            rightArrow()
          }
          .rowExtend(12, 12)
          .onClick(() => {
            TimePickerDialog.show({
              selected: this.selectTime,
              useMilitaryTime: true,
              disappearTextStyle: { color: Color.Black, font: { size: 14, weight: 400 } },
              textStyle: { color: Color.Black, font: { size: 16, weight: 400 } },
              selectedTextStyle: { color: Color.Black, font: { size: 20, weight: 500 } },
              acceptButtonStyle: { fontColor: Color.Black, fontSize: 16, fontWeight: 500 },
              cancelButtonStyle: { fontColor: Color.Black, fontSize: 16, fontWeight: 500 },
              onAccept: (value: TimePickerResult) => {
                this.nightStartTime = this.getMinuteValue(value.hour) + ':' + this.getMinuteValue(value.minute);
              }
            })
          });

          divider();

          Row() {
            textCommonBuilder('结束时间');
            Blank();
            Text(this.nightEndTime).padding({ right: 4 });
            rightArrow()
          }
          .rowExtend(12,12)
          .onClick(() => {
            TimePickerDialog.show({
              selected: this.selectTime,
              useMilitaryTime: true,
              disappearTextStyle: { color: Color.Black, font: { size: 14, weight: 400 } },
              textStyle: { color: Color.Black, font: { size: 16, weight: 400 } },
              selectedTextStyle: { color: Color.Black, font: { size: 20, weight: 500 } },
              acceptButtonStyle: { fontColor: Color.Black, fontSize: 16, fontWeight: 500 },
              cancelButtonStyle: { fontColor: Color.Black, fontSize: 16, fontWeight: 500 },
              onAccept: (value: TimePickerResult) => {
                this.nightEndTime = this.getMinuteValue(value.hour) + ':' + this.getMinuteValue(value.minute);
              }
            })
          });
        }
        .columnExtend();

        Column() {
          Row() {
            textCommonBuilder('午间休息');
            Blank();
            Toggle({ type: ToggleType.Switch, isOn: this.lunchTimeState })
              .selectedColor('#FFD15D')
              .switchPointColor($r('sys.color.comp_background_list_card'))
              .onChange((lunchIsOn: boolean) => {
                this.lunchTimeState = lunchIsOn;
                let startTimeIsNull = StringUtil.isEmpty(this.lunchStartTime);
                let endTimeIsNull = StringUtil.isEmpty(this.lunchEndTime);
                let b = startTimeIsNull || endTimeIsNull;
                if (lunchIsOn && b) {
                  //自定义吐司
                  DialogUtils.showToast('请选择开始和结束时间', {
                    fontColor: Color.Black,
                    backgroundColor: '#99e3dcdc',
                    duration: 1500,
                    alignment: Alignment.Center,
                  });
                }
              });
          }
          .rowExtend(12,12)

          divider();

          Row() {
            textCommonBuilder('开始时间');
            Blank();
            Text(this.lunchStartTime).padding({ right: 4 });
            rightArrow()
          }
          .rowExtend(12,12)
          .onClick(() => {
            TimePickerDialog.show({
              selected: this.selectTime,
              useMilitaryTime: true,
              disappearTextStyle: { color: Color.Black, font: { size: 14, weight: 400 } },
              textStyle: { color: Color.Black, font: { size: 16, weight: 400 } },
              selectedTextStyle: { color: Color.Black, font: { size: 20, weight: 500 } },
              acceptButtonStyle: { fontColor: Color.Black, fontSize: 16, fontWeight: 500 },
              cancelButtonStyle: { fontColor: Color.Black, fontSize: 16, fontWeight: 500 },
              onAccept: (value: TimePickerResult) => {
                this.lunchStartTime = this.getMinuteValue(value.hour) + ':' + this.getMinuteValue(value.minute);
              }
            })
          });

          divider();

          Row() {
            textCommonBuilder('结束时间');
            Blank();
            Text(this.lunchEndTime).padding({ right: 4 });
            rightArrow()
          }
          .rowExtend(12,12)
          .onClick(() => {
            TimePickerDialog.show({
              selected: this.selectTime,
              useMilitaryTime: true,
              disappearTextStyle: { color: Color.Black, font: { size: 14, weight: 400 } },
              textStyle: { color: Color.Black, font: { size: 16, weight: 400 } },
              selectedTextStyle: { color: Color.Black, font: { size: 20, weight: 500 } },
              acceptButtonStyle: { fontColor: Color.Black, fontSize: 16, fontWeight: 500 },
              cancelButtonStyle: { fontColor: Color.Black, fontSize: 16, fontWeight: 500 },
              onAccept: (value: TimePickerResult) => {
                this.lunchEndTime = this.getMinuteValue(value.hour) + ':' + this.getMinuteValue(value.minute);
              }
            })
          });
        }
        .columnExtend();

        Row() {
          Button('保存')
            .width(CommonConstants.FULL_PERCENT)
            .backgroundColor('#FFD15D')
            .fontColor($r('sys.color.black'))
            .fontSize(16)
            .onClick(() => {
              GlobalContext.getContext().setObject(CommonConstants.LUNCH_TIME_STATE, this.lunchTimeState);
              GlobalContext.getContext().setObject(CommonConstants.NIGHT_TIME_STATE, this.nightTimeState);
              if (this.lunchTimeState) {
                GlobalContext.getContext().setObject(CommonConstants.LUNCH_START_TIME, this.lunchStartTime);
                GlobalContext.getContext().setObject(CommonConstants.LUNCH_END_TIME, this.lunchEndTime);
              }
              if (this.nightTimeState) {
                GlobalContext.getContext().setObject(CommonConstants.NIGHT_START_TIME, this.nightStartTime);
                GlobalContext.getContext().setObject(CommonConstants.NIGHT_END_TIME, this.nightEndTime);
              }
              GlobalContext.getContext().setObject(CommonConstants.TIME_LIMIT, this.timeLimit);

              let convertValue = converTimeLimit(this.timeLimit);
              let timeControl: emitter.EventData = {
                data: {
                  'timeLimit': convertValue,
                  'lunchTimeState': this.lunchTimeState,
                  'nightTimeState': this.nightTimeState,
                  'lunchStartTime': this.lunchStartTime,
                  'lunchEndTime': this.lunchEndTime,
                  'nightStartTime': this.nightStartTime,
                  'nightEndTime': this.nightEndTime,
                },
              };
              console.log('开始发送时长控制消息:', JSON.stringify(timeControl));
              emitter.emit(CommonConstants.TIME_CONTROL, timeControl);

              DialogUtils.showToast('保存成功', {
                fontColor: Color.Black,
                backgroundColor: '#99e3dcdc',
                duration: 1500,
                alignment: Alignment.Center,
              });
            });
        }.padding({ top: 170 });
      }
      .padding({ right: 16, left: 16 })
      .height(CommonConstants.FULL_PERCENT)
      .backgroundColor('#F1F3F5')
    }
    .onShown(() => {
      this.timeLimit = GlobalContext.getContext().getObject(CommonConstants.TIME_LIMIT) as string;
      this.lunchStartTime = GlobalContext.getContext().getObject(CommonConstants.LUNCH_START_TIME) as string;
      this.lunchEndTime = GlobalContext.getContext().getObject(CommonConstants.LUNCH_END_TIME) as string;
      this.nightStartTime = GlobalContext.getContext().getObject(CommonConstants.NIGHT_START_TIME) as string;
      this.nightEndTime = GlobalContext.getContext().getObject(CommonConstants.NIGHT_END_TIME) as string;
      this.lunchTimeState = GlobalContext.getContext().getObject(CommonConstants.LUNCH_TIME_STATE) as boolean;
      this.nightTimeState = GlobalContext.getContext().getObject(CommonConstants.NIGHT_TIME_STATE) as boolean;
    })
    .margin({
      top: px2vp(this.topRectHeight),
    })
    .title('时长控制')
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    });
  }

  getMinuteValue(minute: number): string {
    if (minute < 10) {
      return '0' + minute;
    }
    return '' + minute;
  }
}

@Builder
function divider() {
  Divider().width('85%').alignSelf(ItemAlign.Center);
}

@Builder
function textCommonBuilder(text: ResourceStr) {
  Text(text)
    .fontSize(16)
    .fontFamily('鸿蒙黑体')
    .fontWeight(FontWeight.Medium)
    .opacity(0.9);
}

@Builder
function textTitleBuilder(text: ResourceStr) {
  Text(text)
    .fontSize(14)
    .fontFamily('鸿蒙黑体')
    .fontWeight(FontWeight.Regular)
    .opacity(0.6)
    .width(CommonConstants.FULL_PERCENT)
    .padding({ left: 12, top: 16 });
}

@Extend(Column)
function columnExtend() {
  .backgroundColor($r('sys.color.white')).borderRadius(16).height(152).justifyContent(FlexAlign.SpaceEvenly);
}

@Extend(Row)
function rowExtend(left: number, right: number) {
  .width(CommonConstants.FULL_PERCENT).padding({ left: left, right: right });
}


function converTimeLimit(timeLimit: string): number {
  if (timeLimit.endsWith('分钟')) {
    return Number(timeLimit.replace('分钟', ''));
  } else if (timeLimit.endsWith('小时')) {
    return Number(timeLimit.replace('小时', '')) * 60;
  } else {
    return 1440;
  }
}
