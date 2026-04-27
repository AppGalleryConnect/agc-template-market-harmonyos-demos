import { window } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';
import { AnimateCallback, CustomTransition } from './CustomNavigationUtils';
import { LongTakeTransitionType } from '../constants/LongTakeTransitionConstants';
import { ComponentAttrUtils } from './ComponentAttrUtils';
import { LongTakeTransitionParam } from './LongTakeTransitionParam';
import { CustomTransitionOptions, LongTakeTransitionOptions } from './Options';
import { SnapShotImage } from './SnapShotImage';
import { WindowUtils } from './WindowUtils'

const TAG: string = '[ezCustomTransition]';

export class LoneTakeAnimationsTransition {
  static animationCount: number = 0;

  public static init(windowStage: window.WindowStage) {
    WindowUtils.init(windowStage);
  }

  public static generateLongTakeParam(uiContext: UIContext, cardId: string, cornerRadius: number,
    options?: LongTakeTransitionOptions): LongTakeTransitionParam | undefined {
    if (!uiContext || !cardId) {
      UtilLog.error(TAG, 'generateLongTakeParam error, cardId is invalid');
      return undefined;
    }

    try {
      let pixelMap = uiContext.getComponentSnapshot().getSync(cardId);
      UtilLog.info(TAG, `get ${cardId} snapshot sync success!`);
      SnapShotImage.pixelMap = pixelMap;
    } catch (error) {
      UtilLog.error(`getSync ${cardId} failed, errorCode: ` + error.code + '; message: ' + error.message);
      return undefined;
    }

    let cardRectInfo = ComponentAttrUtils.getRectInfoById(uiContext, cardId, cornerRadius);
    UtilLog.info(TAG, 'getRectInfoById value is ' + JSON.stringify(cardRectInfo))
    if (!cardRectInfo) {
      return undefined;
    }
    let transitionParam: LongTakeTransitionParam = new LongTakeTransitionParam(cardRectInfo, options);
    transitionParam.componentId = cardId;
    transitionParam.transitionType = options?.type ?? LongTakeTransitionType.CardLongTake;
    return transitionParam;
  }

  public static customNavContentTransition(from: NavContentInfo, to: NavContentInfo,
    operation: NavigationOperation, options?: CustomTransitionOptions): NavigationAnimatedTransition | undefined {
    if (!from || !to) {
      return undefined;
    }
    from.navDestinationId = from.navDestinationId ?? '-1';
    to.navDestinationId = to.navDestinationId ?? '-1';

    // 针对点击按钮A走自定义转场点击按钮B走默认转场的场景，需要对是否注册了animation进行判断，来决定是否走自定义转场
    let fromParam: AnimateCallback = CustomTransition.getInstance().getAnimateParam(from.navDestinationId);
    let toParam: AnimateCallback = CustomTransition.getInstance().getAnimateParam(to.navDestinationId);

    if (operation === NavigationOperation.PUSH && !toParam.animation) {
      return undefined;
    }

    if (operation === NavigationOperation.POP && !fromParam.animation) {
      return undefined;
    }

    if (operation === NavigationOperation.REPLACE && !fromParam.animation && !toParam.animation) {
      return undefined;
    }

    CustomTransition.getInstance().operation = operation;
    if (CustomTransition.getInstance().interactive) {
      let customAnimation: NavigationAnimatedTransition = {
        onTransitionEnd: () => {
          options?.onTransitionEnd?.();
          CustomTransition.getInstance().proxy = undefined;
        },
        transition: (transitionProxy: NavigationTransitionProxy) => {
          options?.onTransitionStart?.();
          CustomTransition.getInstance().proxy = transitionProxy;
          let targetIndex: string | undefined = operation === NavigationOperation.PUSH ?
            (to.navDestinationId) : (from.navDestinationId);
          if (targetIndex) {
            CustomTransition.getInstance().fireInteractiveAnimation(targetIndex, operation);
          }
        },
        isInteractive: CustomTransition.getInstance().interactive,
      }
      return customAnimation;
    }

    // 一切判断完成后，构造customAnimation给系统侧调用，执行自定义转场动画
    LoneTakeAnimationsTransition.animationCount++;
    let currCount: number = LoneTakeAnimationsTransition.animationCount;
    let customAnimation: NavigationAnimatedTransition = {
      onTransitionEnd: (isSuccess: boolean) => {
        if (currCount === LoneTakeAnimationsTransition.animationCount) {
          LoneTakeAnimationsTransition.animationCount = 0;
          options?.onTransitionEnd?.();
          UtilLog.info(TAG, `current custom transition result is ${isSuccess}`);
        }
      },
      timeout: 1000,
      transition: (transitionProxy: NavigationTransitionProxy) => {
        options?.onTransitionStart?.();
        UtilLog.info(TAG, 'trigger custom transition callback');
        if (fromParam.animation) {
          fromParam.animation(operation === NavigationOperation.PUSH, true, transitionProxy);
        }
        if (toParam.animation) {
          toParam.animation(operation === NavigationOperation.PUSH, false, transitionProxy);
        }
      },
    };
    return customAnimation;
  }
}