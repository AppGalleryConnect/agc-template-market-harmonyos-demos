import {  Want } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { FormCardRouter } from '../type/Types';


const TAG = '[WantUtils]';

/**
 * 应用want处理工具类
 */
export class WantUtils {

  /**
   * 服务卡片事件处理
   * @param want
   */
  public static handleFormCardCall(want: Want) {
    if (want?.parameters?.source === 'FormCard') {
      const formCardRouter: FormCardRouter =
        AppStorageV2.connect(FormCardRouter, () => new FormCardRouter())!;
      formCardRouter.id = new Date().getTime();
      formCardRouter.avId = want?.parameters?.avId as string ?? '';
    }
  }
}