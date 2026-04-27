import { BusinessError } from '@kit.BasicServicesKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { notificationManager } from '@kit.NotificationKit';
import { MyMessageList, MessageItem, MessageType } from 'common_travel_guide';


@ObservedV2
export class MessageVM {
  @Trace messageList: MyMessageList = AppStorageV2.connect(MyMessageList, () => new MyMessageList())!
  @Trace orderMessageList: MessageItem[] = []
  @Trace sysMessageList: MessageItem[] = []
  @Trace showPushTip: boolean = true

  initData(){
    this.sysMessageList = this.messageList.list.filter(item => item.type === MessageType.SYSTEM)
    this.orderMessageList = this.messageList.list.filter(item => item.type === MessageType.ORDER)
  }

  requestEnableNotification(context: common.UIAbilityContext) {
    if (canIUse('SystemCapability.Notification.NotificationSettings')) {
      notificationManager.openNotificationSettings(context).then(() => {
        this.showPushTip = false
      }).catch((err: BusinessError) => {
      });
    }
  }
}