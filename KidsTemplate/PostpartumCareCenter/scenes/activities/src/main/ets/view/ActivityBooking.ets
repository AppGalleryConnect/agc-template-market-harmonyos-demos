import {
  ActivityBookingRecordModel,
  ActivityModel,
  BookingUtil,
  CommonUtil,
  Logger,
  ServiceItem,
} from '@ohos_agcit/postpartum_care_center_utils';
import { ActivityEntryVM } from '../viewmodel/ActivityEntryVM';
import { promptAction } from '@kit.ArkUI';
import { MainEntryVM } from '@ohos_agcit/postpartum_care_center_uicomponents';

const TAG: string = '[ActivityBooking]';

@Builder
export function ActivityBookingBuilder() {
  ActivityBooking();
} // 全局自定义构建函数

@ComponentV2
struct ActivityBooking {
  vm: ActivityEntryVM = ActivityEntryVM.instance;
  mainVm: MainEntryVM = MainEntryVM.instance;
  @Local activity: ActivityModel | null = null;
  @Local activityBookingRecord: ActivityBookingRecordModel | null = null;

  aboutToAppear(): void {
    this.activity = this.vm.navStack.getParamByName('ActivityBooking')[0] as ActivityModel;
    this.activityBookingRecord = ActivityBookingRecordModel.createRec(this.activity);
    Logger.debug('about to enter page ActivityBooking');
    Logger.debug('ActivityBooking' + JSON.stringify(this.activity));
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Text($r('app.string.booking_personal_info'))
            .width('100%')
            .fontSize($r('app.string.font_size_18'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Bold)
            .fontColor('rgba(0,0,0,0.90)')
            .padding({
              left: $r('app.string.padding_16'),
              top: $r('app.string.margin_l'),
              bottom: $r('app.string.margin_xs'),
            })
            .margin({ bottom: $r('app.string.margin_xs') });

          Column() {
            Row() {
              Text($r('app.string.booking_must'))
                .fontSize($r('app.string.font_size_12'))
                .fontFamily('HarmonyHeiTi')
                .fontWeight(FontWeight.Regular)
                .fontColor('rgba(232,64,38,1.00)')
                .width(6)
                .height(16);
              Text($r('app.string.booking_name'))
                .fontSize($r('app.string.font_size_12'))
                .fontFamily('HarmonyHeiTi')
                .fontWeight(FontWeight.Regular)
                .fontColor('rgba(0,0,0,0.40)');
            }
            .width('100%');

            TextInput({
              placeholder: $r('app.string.booking_name_input'),
            })
              .height(48)
              .fontSize($r('app.string.font_size_16'))
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Regular)
              .fontColor('rgba(0,0,0,0.90)')
              .placeholderColor('rgba(0,0,0,0.40)')
              .placeholderFont({
                size: $r('app.string.font_size_16'),
                family: 'HarmonyHeiTi',
                weight: FontWeight.Regular,
              })
              .backgroundColor(Color.White)
              .padding({
                left: $r('app.string.padding_6'),
                top: $r('app.string.padding_14'),
                bottom: $r('app.string.padding_13'),
              })
              .onChange((value: string) => {
                if (this.activityBookingRecord != null) {
                  this.activityBookingRecord.userName = value;
                }
              });

            Divider()
              .margin({ bottom: $r('app.string.margin_ms') })
              .padding({ left: $r('app.string.padding_6'), right: $r('app.string.padding_6') })
              .color('rgba(0,0,0,0.20)')
              .strokeWidth(1);

            Row() {
              Text($r('app.string.booking_must'))
                .fontSize($r('app.string.font_size_12'))
                .fontFamily('HarmonyHeiTi')
                .fontWeight(FontWeight.Regular)
                .fontColor('rgba(232,64,38,1.00)')
                .width(6)
                .height(16);
              Text($r('app.string.booking_telephone'))
                .fontSize($r('app.string.font_size_12'))
                .fontFamily('HarmonyHeiTi')
                .fontWeight(FontWeight.Regular)
                .fontColor('rgba(0,0,0,0.40)');
            }
            .width('100%');

            TextInput({
              text: this.mainVm.userInfo.phone
            })
              .height(48)
              .fontSize($r('app.string.font_size_16'))
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Regular)
              .fontColor('rgba(0,0,0,0.90)')
              .placeholderColor('rgba(0,0,0,0.40)')
              .placeholderFont({
                size: $r('app.string.font_size_16'),
                family: 'HarmonyHeiTi',
                weight: FontWeight.Regular,
              })
              .backgroundColor(Color.White)
              .padding({
                left: $r('app.string.padding_6'),
                top: $r('app.string.padding_14'),
                bottom: $r('app.string.padding_13'),
              })
              .onChange((value: string) => {
                this.mainVm.userInfo.phone = value;
              });

            Divider()
              .margin({ bottom: $r('app.string.margin_ms') })
              .padding({ left: $r('app.string.padding_6'), right: $r('app.string.padding_6') })
              .color('rgba(0,0,0,0.20)')
              .strokeWidth(1);
          }
          .padding({ left: $r('app.string.padding_10'), right: $r('app.string.padding_10') });
        };

        Column() {
          Button({ type: ButtonType.Normal, stateEffect: true }) {
            Text($r('app.string.submit_immediately'))
              .fontSize($r('app.string.font_size_16'))// 设置字号为16
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF');
          }
          .backgroundColor('#333333')
          .padding({
            top: $r('app.string.padding_10'),
            bottom: $r('app.string.padding_9'),
          }) // 设置文字内边距
          .borderRadius($r('app.string.border_radius_20'))
          .width('100%')
          .margin({ top: $r('app.string.margin_xl') })
          .onClick(() => {
            if (!CommonUtil.isStringValid(this.activityBookingRecord?.userName)) {
              promptAction.showToast({ message: '请输入姓名', alignment: Alignment.Center });
              return;
            }
            if (!CommonUtil.isStringValid(this.mainVm.userInfo.phone)){
              promptAction.showToast({ message: '请关联手机号', alignment: Alignment.Center });
              return;
            }
            if (this.activityBookingRecord != null) {
              this.activityBookingRecord.phone=this.mainVm.userInfo.phone;
            }

            if(this.mainVm.getActivityBookingRec().find(rec =>
            rec.phone === this.activityBookingRecord?.phone &&
              rec.activity?.id ===this.activityBookingRecord.activity?.id)){
              promptAction.showToast({
                message: `手机号【${this.activityBookingRecord?.phone}】已预约该活动，请重新选择活动或修改信息`,
                alignment: Alignment.Center,
              });
              return;
            }

            if (this.activityBookingRecord != null) {
              BookingUtil.addActivityBookingRec(this.activityBookingRecord);
              Logger.debug(TAG,BookingUtil.getActivityBookingRec().length.toString());
            }

            this.mainVm.serviceItems[1].linkNextPageDesc = `${BookingUtil.getActivityBookingRec().length}条记录`;

            this.vm.navStack.pushPathByName('ActivityBookingSuccess', this.activityBookingRecord);
          });
        }
        .padding({ left: $r('app.string.padding_16'), right: $r('app.string.padding_16') });
      }
      .height('100%')
      .padding({ top: $r('app.string.padding_8'), bottom: $r('app.string.padding_8') })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceBetween);
    };
  }
}