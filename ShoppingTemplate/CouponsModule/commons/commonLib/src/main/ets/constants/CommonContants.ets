import { emitter } from '@kit.BasicServicesKit';

export class CommonConstants {
  // 域名
  public static readonly BASE_URL = '';
  // 全屏宽度
  public static readonly FULL_WIDTH = '100%';
  // 全屏高度
  public static readonly FULL_HEIGHT = '100%';
}

export class EmitterConstants {
  public static readonly TO_HOME: emitter.InnerEvent = { eventId: 0 }
}
