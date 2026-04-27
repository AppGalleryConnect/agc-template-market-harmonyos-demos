import { ValueType } from '@kit.ArkData';
import { RouterMap, RouterUtils } from 'lib_common';

export class AvRouter {
  private uiContext: UIContext

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext
  }

  /*
   * 跳转视频详情
   * cardData 数据源
   * */
  public pushToAvDetails(cardData: Record<string, ValueType>) {
    let params: Record<string, ValueType  | undefined> = {
      'avId': cardData.id,
      'isCreateSubWindow': cardData.isCreateSubWindow,
    }
    RouterUtils.pushPathByName(RouterMap.VIDEO_PROGRAM_DETAILS, params)
  }
}