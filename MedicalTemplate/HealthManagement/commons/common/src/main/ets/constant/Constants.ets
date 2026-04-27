import emitter from '@ohos.events.emitter';
import { MsgDialogModel } from '../model/MsgDialogModel';

// 泛型类型
export type TValueType = string | boolean | number | null | Array<TValueType> | Object | Object[] | (() => void)

export class Constants {
  public static readonly FULL_SIZE = '100%';

  public static readonly onForegroundChange: emitter.InnerEvent = {
    eventId: 868
  }

  public static readonly onPairDeviceChange: emitter.InnerEvent = {
    eventId: 779
  }

  public static readonly onHealthDataChange: emitter.InnerEvent = {
    eventId: 800
  }

  public static readonly onBackgroundChange: emitter.InnerEvent = {
    eventId: 686
  }

  public static readonly onEnableBluetoothChange: emitter.InnerEvent = {
    eventId: 810
  }

  public static readonly onBluetoothScanningChange: emitter.InnerEvent = {
    eventId: 811
  }

  public static readonly onGotoDeviceTabChange: emitter.InnerEvent = {
    eventId: 812
  }

  public static readonly TAB_INDEX_ZERO: number = 0;
  public static readonly TAB_INDEX_ONE: number = 1;
  public static readonly TAB_INDEX_TWO: number = 2;
  public static readonly TAB_INDEX_THREE: number = 3;

}

export function getMsgDialogData(): MsgDialogModel[] {
  return [
    {
      img: $r('app.media.health_heart_rate_icon'),
      title: '心率异常',
      subtitle: '血氧饱和度降至88%，严重缺氧风险！请立即吸氧（如有设备），保持呼吸通畅，尽快联系急救人员！',
      time: '1分钟前'
    },
    {
      img: $r('app.media.health_blood_pre_icon'),
      title: '血压异常',
      subtitle: '收缩压≥180mmHg或舒张压≥110mmHg，高血压危象风险！请立即平躺休息，避免活动，拨打120急救电话！',
      time: '1分钟前'
    },
    {
      img: $r('app.media.health_blood_sugar_icon'),
      title: '高血糖预警',
      subtitle: '餐后2小时血糖12.8mmol/L，连续2次测量均偏高。请避免高糖、高油食物，遵医嘱调整用药，记录今日饮食供医生参考。',
      time: '1分钟前'
    },
    {
      img: $r('app.media.health_water_clock_icon'),
      title: '喝水提醒',
      subtitle: '忙了这么久，别忘记给自己倒杯水，润润喉，也放松放松。',
      time: '9分钟前'
    },
    {
      img: $r('app.media.health_medication_reminder_icon'),
      title: '用药提醒',
      subtitle: '该吃药啦！今日19:00需服用【降压药】，1片/1次，饭后30分钟服用，记得搭配一杯温水～。',
      time: '9分钟前'
    },
    {
      img: $r('app.media.health_sleep_icon'),
      title: '睡眠提醒',
      subtitle: '根据世界卫生组织建议，成年人每晚应保证7 - 9小时睡眠 ，以维持良好的身心健康。' +
        '现在距离您的最佳入睡时间仅剩15分钟，请关闭电子设备，调整卧室光线，准备进入睡眠状态 ，祝您拥有优质睡眠。',
      time: '9分钟前'
    }
  ]
}

