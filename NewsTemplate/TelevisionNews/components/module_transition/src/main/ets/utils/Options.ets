import { LongTakeTransitionType } from '../constants/LongTakeTransitionConstants';

export interface LongTakeTransitionOptions {
  type?: LongTakeTransitionType;
  isGestureEnabled?: boolean;

  // 一镜到底跳转目标页动画开始回调
  onEnterTransitionStart?: () => void;

  // 一镜到底跳转目标页动画结束回调
  onEnterTransitionEnd?: () => void;

  // 一镜到底目标页返回动画开始回调
  onBackTransitionStart?: () => void;

  // 一镜到底目标页返回动画结束回调
  onBackTransitionEnd?: () => void;
}

export interface CustomTransitionOptions {
  // 自定义转场动画开始时的回调
  onTransitionStart?: () => void;

  // 自定义转场动画结束时的回调
  onTransitionEnd?: () => void;
}

export interface DelegateGestureInterface {
  fingers?: number;
  direction?: PanDirection;
  distance?: number;
}

export interface LongTakeSessionOptions {
  // 首页卡片需要
  alignTargetId?: string;

  // 返回上一页的逻辑
  pop: () => void;

  // 手势返回开始时
  onBackGestureStart?: () => void;

  // 返回取消时
  onRecoverStart?: () => void;

  // 返回取消时
  onRecoverEnd?: () => void;
}