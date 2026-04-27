import { PersistenceV2 } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { Constants, getMsgDialogData, MessageReminderDialog, OHDialog, OHDialogModel, TimeUtil } from 'common';
import { PairedDeviceMacList } from 'device';
import { SkipStepModel } from 'person';
import { fiveMinutes, sevenPM, TAB_CONFIG, tenAM, tenPM, threePM } from '../constants/constants';
import { TabSingleItem } from './TabSingleItem';

@Builder
function homeModelDialogBuilder(vm: OHDialogModel) {
  Text(vm.subtitle)
    .fontSize($r('sys.float.Body_M'))
    .fontColor(Color.Black)
    .lineHeight($r('app.float.vp_22'))
    .maxLines(-1)

  Blank().height($r('app.float.vp_26'))
}

@ObservedV2
export class HomeModel {
  @Trace curIndex: number = 0;
  public controller: TabsController = new TabsController();
  public tabList: TabSingleItem[] = TAB_CONFIG;
  private static _instance: HomeModel;
  @Trace macList: PairedDeviceMacList = PersistenceV2.connect(PairedDeviceMacList, () => new PairedDeviceMacList())!;
  private onGotoDeviceTabChange: () => void = () => {
    this.curIndex = 1;
  }

  public static get instance() {
    if (!HomeModel._instance) {
      HomeModel._instance = new HomeModel();
      emitter.on(Constants.onGotoDeviceTabChange, HomeModel._instance .onGotoDeviceTabChange);
    }
    return HomeModel._instance;
  }

  addDeviceDialog() {
    if (this.macList.pairedList.length === 0) {
      let dialogVM = new SkipStepModel();
      dialogVM.title = '设备连接';
      dialogVM.subtitle = '连接后数据会同步APP显示';
      dialogVM.onValueConfirmClick = () => {
        this.curIndex = 1;
      }
      dialogVM.childBuilder = homeModelDialogBuilder
      OHDialog.ShowPopup(dialogVM)
    }
  }

  addHealthRemind() {
    setInterval(() => {
      let time = TimeUtil.getCurTime(TimeUtil.PATTERN_TIME_COLON_WITHOUT_SECOND);
      let hours = time.split(':');
      if (hours.length === 2) {
        let hour = hours[0];
        if (hour === tenAM || hour === threePM) {
          // todo 上午十点，下午三点，弹框提醒喝水
          MessageReminderDialog.ShowMsgReminderPopup(getMsgDialogData()[3]);
        } else if (hour === sevenPM) {
          // todo 下午七点，弹框提醒吃药
          MessageReminderDialog.ShowMsgReminderPopup(getMsgDialogData()[4]);
        } else if (hour === tenPM) {
          // todo 晚上十点，弹框提醒睡觉
          MessageReminderDialog.ShowMsgReminderPopup(getMsgDialogData()[5]);
        }
      }
    }, fiveMinutes);
  }
}