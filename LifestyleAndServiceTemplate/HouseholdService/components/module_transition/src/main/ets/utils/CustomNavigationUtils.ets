import { componentSnapshot } from '@kit.ArkUI';
import { SnapShotImage } from './SnapShotImage';
import { LongTakeTransitionParam } from './LongTakeTransitionParam';

const TAG = 'CustomTransition';

export interface AnimateCallback {
  animation: ((isPush: boolean, isExit: boolean,
    transitionProxy: NavigationTransitionProxy) => void | undefined) | undefined;
  interactive: ((operation: NavigationOperation) => void | undefined) | undefined;
}

const customTransitionMap: Map<string, AnimateCallback> = new Map();

export class CustomTransition {
  static delegate = new CustomTransition();
  interactive: boolean = false;
  proxy: NavigationTransitionProxy | undefined = undefined;
  operation: NavigationOperation = NavigationOperation.PUSH;

  static getInstance() {
    return CustomTransition.delegate;
  }

  /* 添加自定义一镜到底转场的流程，主要做卡片截图及pushPath的操作
   * 如果截图成功，则将截图保存在SnapShotImage中
   * 且extraParam的useCustomTransition字段为true，下一页根据该字段判断是否需要注册自定义转场一镜到底动画
   * snapShotId: 需要进行截图的组件id，转场过程中先显示该截图
   * extraParam: 需要传入的一镜到底相关的参数
   * addParamAndPushPath：业务侧添加参数并跳转下一页的逻辑，业务侧需要将extraParam添加到跳转时传的param中
   */
  transitionBySnapShot(componentId: string, extraParam: LongTakeTransitionParam,
    addParamAndPushPath: Function): void {
    if (!componentId || !extraParam || !extraParam.componentRectInfo) {
      addParamAndPushPath(extraParam);
      return;
    }
    // 这里通过extraParam.clickedComponentId获取被点击组件的截图
    try {
      let pixelMap = componentSnapshot.getSync(componentId);
      console.info(TAG, `get ${componentId} snapshot sync success!`);
      SnapShotImage.pixelMap = pixelMap;
    } catch (error) {
      console.error(`getSync ${componentId} errorCode: ` + error.code + ' message: ' + error.message);
    }
    addParamAndPushPath(extraParam);
    return;
  }

  /* 注册某个页面的动画回调
   * name: 注册页面的唯一id
   * startCallback：用来设置动画开始时页面的状态
   * onFinish：用来执行动画结束后页面的其他操作
   * interactiveCallback: 注册的可交互转场的动效
   * timeout：转场结束的超时时间
   */
  registerNavParam(name: string,
    startCallback: ((operation: boolean, isExit: boolean,
      transitionProxy: NavigationTransitionProxy) => void) | undefined,
    interactiveCallback: ((operation: NavigationOperation) => void) | undefined): void {
    if (customTransitionMap.has(name)) {
      let param = customTransitionMap.get(name);
      if (param !== undefined) {
        param.animation = startCallback;
        param.interactive = interactiveCallback;
        return;
      }
    }
    let params: AnimateCallback = { animation: startCallback, interactive: interactiveCallback };
    customTransitionMap.set(name, params);
  }

  unRegisterNavParam(name: string): void {
    customTransitionMap.delete(name);
  }

  fireInteractiveAnimation(id: string, operation: NavigationOperation) {
    let animation = customTransitionMap.get(id)?.interactive;
    if (!animation) {
      return;
    }
    animation(operation);
  }

  updateProgress(progress: number) {
    if (!this.proxy?.updateTransition) {
      return;
    }
    this.proxy?.updateTransition(progress);
  }

  cancelTransition() {
    if (this.proxy?.cancelTransition) {
      this.proxy.cancelTransition();
    }
  }

  finishTransition() {
    this.proxy?.finishTransition();
  }

  getAnimateParam(name: string): AnimateCallback {
    let result: AnimateCallback = {
      animation: customTransitionMap.get(name)?.animation,
      interactive: customTransitionMap.get(name)?.interactive,
    };
    return result;
  }
}