import { BusinessError } from '@kit.BasicServicesKit';
import { calendarManager } from '@kit.CalendarKit';
import { serviceNotification } from '@kit.PushKit';
import { i18n, intl } from '@kit.LocalizationKit';
import {
  AppointmentInfo,
  cancelAppointment,
  CommonConstants,
  Logger,
  PopViewUtils,
  updateAppointmentInfo,
  IUpdateAppointmentRequest,
  AppointState,
  SystemSceneUtils,
} from 'utils';
import { DialogCancelAppointmentBuilder, CancelAppointmentParams } from './DialogCancelAppointment';

class FormItemModel {
  label: ResourceStr = '';
  content: ResourceStr = '';
}

const SET_SCHEDULE = 1;
const SET_SUBSCRIBE = 1;

@ComponentV2
struct OperateBtn {
  @Param imgSrc: ResourceStr = '';
  @Param btnText: ResourceStr = '';
  @Param fgColor: ResourceColor = '';

  build() {
    Row({ space: 5 }) {
      Image(this.imgSrc).width(14).height(14)
      Text(this.btnText).fontSize(12).fontColor(this.fgColor)
    }
  }
}

@Extend(Image)
function waterMark() {
  .width(63)
  .height(55)
  .margin({ right: 20 })
}

@ComponentV2
export struct BookCard {
  @Param appointInfo: AppointmentInfo = new AppointmentInfo();
  @Event updateSchedule: (value: number) => void = () => {
  };
  @Event updateSubscribe: (value: number) => void = () => {
  };
  @Event reQueryList: () => void = () => {
  };
  @Local reserveTime: string = '';
  @Param systemLanguage: string = i18n.System.getFirstPreferredLanguage();

  @Monitor('systemLanguage')
  onSysLangChange() {
    this.reserveTime = this.getReserveTime();
  }

  aboutToAppear(): void {
    this.reserveTime = this.getReserveTime();
  }

  @Computed
  get isAddSchedule() {
    return this.appointInfo.setSchedule === SET_SCHEDULE;
  }

  @Computed
  get isSubscribe() {
    return this.appointInfo.setSubscription === SET_SUBSCRIBE;
  }

  @Computed
  get scheduleText() {
    return this.isAddSchedule ? $r('app.string.schedule_added') : $r('app.string.schedule_to_add');
  }

  @Computed
  get scheduleIcon() {
    return this.isAddSchedule ? $r('app.media.icon_schedule_done') :
    $r('app.media.icon_schedule');
  }

  @Computed
  get subscribeText() {
    return this.isSubscribe ? $r('app.string.subscribe_added') : $r('app.string.subscribe_to_add');
  }

  @Computed
  get subscribeIcon() {
    return this.isSubscribe ? $r('app.media.icon_subscribe_done') :
    $r('app.media.icon_subscribe');
  }

  showOperateBar() {
    // 已取消/已完成/已过期不显示，其他均显示
    return !this.showCanceledIcon && !this.showFinishedIcon && !this.showOverTimeIcon();
  }

  @Computed
  get showFinishedIcon() {
    return this.appointInfo.state === AppointState.FINISH;
  }

  @Computed
  get showCanceledIcon() {
    return this.appointInfo.state === AppointState.CANCEL;
  }

  showOverTimeIcon() {
    return this.appointInfo.state === AppointState.OVER_TIME ||
      this.appointInfo.state === AppointState.NEW && this.isOverTime();
  }

  // 是否过期
  isOverTime() {
    return this.appointInfo.reserveTime <= new Date().getTime();
  }

  getReserveTime() {
    const date = new Date(this.appointInfo.reserveTime);
    const monthDayFormat = new intl.DateTimeFormat(this.systemLanguage, { month: 'long', day: 'numeric' });
    const timeFormat = new intl.DateTimeFormat(this.systemLanguage, { timeStyle: 'short', hourCycle: 'h24' });
    return `${monthDayFormat.format(date)} ${timeFormat.format(date)}`;
  }

  updateAppointmentInfo(setSchedule: number, setSubscription: number) {
    const data: IUpdateAppointmentRequest = {
      reserveId: this.appointInfo.id,
      setSchedule: setSchedule,
      setSubscription: setSubscription,
    };
    updateAppointmentInfo(data);
  };

  // 添加日程
  async addEvent() {
    const calendarMgr: calendarManager.CalendarManager | null = await SystemSceneUtils.getCalendarMgr();
    if (!calendarMgr) {
      Logger.warn('cannot get calendarMgr');
      return false;
    }
    const date = new Date(this.appointInfo.reserveTime);
    const event: calendarManager.Event = {
      title: `预约的${this.appointInfo.itemName}`, // 日程标题
      type: calendarManager.EventType.NORMAL,
      startTime: date.getTime(),
      endTime: date.getTime() + 60 * 60 * 1000,
      reminderTime: [30], // 距开始时间提前10分钟提醒
    };

    const calendar = await calendarMgr.getCalendar();
    return calendar.addEvent(event).then((data: number) => {
      Logger.info(`Succeeded in adding event, id -> ${data}`);
      return true;
    }).catch((err: BusinessError) => {
      Logger.error(`Failed to addEvent. Code: ${err.code}, message: ${err.message}`);
      return false;
    });
  };

  openCancelConfirmDialog: () => void = () => {
    if (this.showOverTimeIcon()) {
      this.reQueryList();
      return;
    }
    PopViewUtils.showPopView<CancelAppointmentParams>(wrapBuilder(DialogCancelAppointmentBuilder),
      new CancelAppointmentParams(this.cancelAppoint),
      { alignment: DialogAlignment.Center });
  };
  cancelAppoint: () => void = () => {
    cancelAppointment(this.appointInfo.id).then(() => {
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.toast_appoint_canceled') });
      this.reQueryList();
    })
  }
  // 日程
  onScheduleClick: () => void = async () => {
    if (this.showOverTimeIcon()) {
      this.reQueryList();
      return;
    }
    if (this.isAddSchedule) {
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.toast_schedule_cannot_cancel') });
      return;
    }

    const isSuccess = await this.addEvent();
    if (!isSuccess) {
      return;
    }
    this.getUIContext().getPromptAction().showToast({ message: $r('app.string.toast_schedule_added') });
    const newV = this.isAddSchedule ? 0 : 1;
    this.updateSchedule(newV);
    this.updateAppointmentInfo(newV, this.appointInfo.setSubscription);
  };
  // 推送
  onSubscribeClick: () => void = async () => {
    if (this.showOverTimeIcon()) {
      this.reQueryList();
      return;
    }
    if (this.isSubscribe) {
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.toast_subscribe_cannot_cancel') });
      return;
    }
    const resp = await SystemSceneUtils.requestSubscribeNotification();
    if (resp && resp?.entityResult?.length &&
      resp.entityResult[0]?.resultCode === serviceNotification.ResultCode.ACCEPTED) {
      const newV = this.isSubscribe ? 0 : 1;
      this.updateSubscribe(newV);
      this.updateAppointmentInfo(this.appointInfo.setSchedule, newV);
    }
  };

  @Builder
  FormItem(v: FormItemModel) {
    Row() {
      Text(v.label).fontSize(14).fontColor(this.showOperateBar() ? '#333333' : '#878787').width(100)
      Text(v.content)
        .fontSize(14)
        .fontColor(this.showOperateBar() ? '#333333' : '#878787')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
    }
    .width(CommonConstants.FULL_PERCENT)
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  OperateBar() {
    Column() {
      Divider()
      Row() {
        OperateBtn({
          imgSrc: $r('app.media.icon_cancel'),
          btnText: $r('app.string.btn_cancel_appoint'),
          fgColor: '#878787',
        }).onClick(this.openCancelConfirmDialog)

        Divider().vertical(true).height(20)

        OperateBtn({
          imgSrc: this.scheduleIcon,
          btnText: this.scheduleText,
          fgColor: this.isAddSchedule ? '#434343' : $r('app.color.common_theme_color'),
        }).onClick(this.onScheduleClick)

        Divider().vertical(true).height(20)

        OperateBtn({
          imgSrc: this.subscribeIcon,
          btnText: this.subscribeText,
          fgColor: this.isSubscribe ? '#434343' : $r('app.color.common_theme_color'),
        }).onClick(this.onSubscribeClick)
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding(6)
      .justifyContent(FlexAlign.SpaceBetween)
    }.margin({ top: 10 })
  }

  build() {
    Stack() {
      Column({ space: 4 }) {
        Row({ space: 10 }) {
          Image(this.showOperateBar() ? $r('app.media.icon_circle_red') : $r('app.media.icon_circle_grey'))
            .width(10)
            .height(10)
          Text($r('app.string.text_appoint_time_desc', this.reserveTime))
            .fontSize(18)
            .fontColor(this.showOperateBar() ? '#212121' : '#878787')
            .fontWeight(FontWeight.Medium)
        }.width(CommonConstants.FULL_PERCENT)

        Column({ space: 4 }) {
          this.FormItem({ label: $r('app.string.form_item_project'), content: this.appointInfo.itemName })
          this.FormItem({
            label: $r('app.string.form_item_contact'),
            content: `${this.appointInfo.contactName} ${this.appointInfo.contactPhone}`,
          })
          this.FormItem({
            label: $r('app.string.form_item_nums'),
            content: $r('app.string.form_content_nums', this.appointInfo.numbers.toString()),
          })
          this.FormItem({
            label: $r('app.string.form_item_remark'),
            content: this.appointInfo.remarks || $r('app.string.form_item_remark_empty'),
          })
        }

        if (this.showOperateBar()) {
          this.OperateBar()
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(8)
      .padding(10)

      if (this.showCanceledIcon) {
        Image($r('app.media.icon_canceled')).waterMark()
      }

      if (this.showFinishedIcon) {
        Image($r('app.media.icon_finished')).waterMark()
      }

      if (this.showOverTimeIcon()) {
        Image($r('app.media.ic_overtime')).waterMark()
      }

    }.alignContent(Alignment.End)

  }
}
