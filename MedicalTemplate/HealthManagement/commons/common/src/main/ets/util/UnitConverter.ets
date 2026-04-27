import { UIContext } from '@ohos.arkui.UIContext';
import { TCLogger } from '../basic/TCLogger';
import { WindowUtils } from './WindowUtils';

const TAG: string = 'UnitConverter';

export class UnitConverter {
  static vp2px(value: number, context?: UIContext): number {
    if (!context) {
      context = WindowUtils.getContext()
    }

    if (!context) {
      TCLogger.info(TAG, `set context,or init WindowUtils`)
      return 0;
    }

    return context.vp2px(value);
  }

  static px2vp(value: number, context?: UIContext): number {
    if (!context) {
      context = WindowUtils.getContext()
    }

    if (!context) {
      TCLogger.info(TAG, `set context,or init WindowUtils`)
      return 0;
    }

    return context.px2vp(value);
  }

  static fp2px(value: number, context?: UIContext): number {
    if (!context) {
      context = WindowUtils.getContext()
    }

    if (!context) {
      TCLogger.info(TAG, `set context,or init WindowUtils`)
      return 0;
    }

    return context.fp2px(value);
  }

  static px2fp(value: number, context?: UIContext): number {
    if (!context) {
      context = WindowUtils.getContext()
    }

    if (!context) {
      TCLogger.info(TAG, `set context,or init WindowUtils`)
      return 0;
    }

    return context.px2fp(value);
  }

  static lpx2px(value: number, context?: UIContext): number {
    if (!context) {
      context = WindowUtils.getContext()
    }

    if (!context) {
      TCLogger.info(TAG, `set context,or init WindowUtils`)
      return 0;
    }

    return context.lpx2px(value);
  }

  static px2lpx(value: number, context?: UIContext): number {
    if (!context) {
      context = WindowUtils.getContext()
    }

    if (!context) {
      TCLogger.info(TAG, `set context,or init WindowUtils`)
      return 0;
    }

    return context.px2lpx(value);
  }
}