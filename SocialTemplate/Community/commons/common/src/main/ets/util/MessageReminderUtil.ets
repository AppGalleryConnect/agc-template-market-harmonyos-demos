import { UserInfo } from '../model/UserInfo';
import { PersistenceV2 } from '@kit.ArkUI';
import { vibrator } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AudioUtlis } from './AudioUtlis';

const TAG: string = 'MessageReminderUtil';

let oldMsgId = '' //消息id

export class MessageReminderUtil {
  userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  duration: number = 1000
  id: number = 0

  messageReminderMethod(userId: string, type: number, senderId: string, newMsgId: string) {
    if (this.userInfo.messageNotificationTone && senderId !== this.userInfo.id && newMsgId !== oldMsgId) {
      let playSoundPoolView: AudioUtlis = new AudioUtlis(userId)
      setTimeout(() => {
        playSoundPoolView.PlaySoundPool(); // 延迟执行的释放函数
      }, 90); // 延迟到事件循环空闲时执行

    }
    if (type === 1 && this.userInfo.messageVibrationAlert && senderId !== this.userInfo.id && newMsgId !== oldMsgId) {
      this.vibrateMethod()
    }
    if (type === 2 && this.userInfo.groupMessageNotificationTone && senderId !== this.userInfo.id &&
      newMsgId !== oldMsgId) {
      this.vibrateMethod()
    }
    oldMsgId = newMsgId;
  }

  vibrateMethod() {
    try {
      // 触发马达振动
      vibrator.startVibration({
        type: 'time',
        duration: this.duration,
      }, {
        id: this.id,
        usage: 'notification'
      }, (error: BusinessError) => {
        if (error) {
          return;
        }
      });
    } catch (err) {
      let e: BusinessError = err as BusinessError;
    }
  }
}