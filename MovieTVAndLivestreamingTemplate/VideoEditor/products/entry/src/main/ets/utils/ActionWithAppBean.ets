import { TValueType } from 'common';

export class ActionWithAppBean {
  /**
   * 与APP层交互
   */
  static readonly ACTION_WITH_APP = 0x1001

  action: string = '';
  data: TValueType = null
}