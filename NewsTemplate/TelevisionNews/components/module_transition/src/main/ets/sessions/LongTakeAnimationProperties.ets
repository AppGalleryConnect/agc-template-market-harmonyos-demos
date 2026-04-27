import { UtilLog } from '@hw-agconnect/util-log';
import { LongTakeTransitionConstants, LongTakeTransitionType } from '../constants/LongTakeTransitionConstants';
import { LongTakeTransitionParam } from '../utils/LongTakeTransitionParam';
import { RectInfoPx } from '../utils/ComponentAttrUtils';
import { WindowUtils } from '../utils/WindowUtils';
import { CustomTransition } from '../utils/CustomNavigationUtils';
import { LongTakeSessionOptions } from '../utils/Options';

const TAG: string = '[LongTakeSession]';

const INIT_BG_COLOR = '#00000000';

const DEFAULT_FINAL_BG_COLOR = '#33000000';

const DEFAULT_SCREEN_RADIUS = 9;

// 自定义一镜到底转场动画进行封装
@ObservedV2
export class LongTakeAnimationProperties {
  @Trace navDestinationBgColor: ResourceColor = INIT_BG_COLOR;
  @Trace snapShotOpacity: number = 0;
  @Trace postPageOpacity: number = 1;
  @Trace translateX: number = 0;
  @Trace translateY: number = 0;
  @Trace scaleValue: number = 1;
  @Trace clipWidth: Dimension = '100%';
  @Trace clipHeight: Dimension = '100%';
  @Trace radius: number = 0;
  @Trace positionXValue: number = 0;
  @Trace positionYValue: number = 0;
  @Trace navDestSize: SizeOptions = { width: '100%', height: '100%' };
  @Trace snapShotSize: SizeOptions = { width: '100%', height: '100%' };
  @Trace snapShotPositionX: number = 0;
  @Trace snapShotPositionY: number = 0;
  @Trace options: LongTakeSessionOptions | undefined = undefined;
  @Trace type: LongTakeTransitionType = LongTakeTransitionType.CardLongTake;
  @Trace finalBgColor: ResourceColor = DEFAULT_FINAL_BG_COLOR;
  @Trace animationCount: number = 0;
  @Trace initScale: number = 1;
  @Trace initTranslateX: number = 0;
  @Trace initTranslateY: number = 0;
  @Trace initClipWidth: Dimension = 0;
  @Trace initClipHeight: Dimension = 0;
  @Trace initPositionValueX: number = 0;
  @Trace initPositionValueY: number = 0;
  @Trace cardItemInfoPx: RectInfoPx = new RectInfoPx();
  @Trace postPageSharedComponentId: string | undefined = undefined;
  @Trace navDestinationId: string = '';
  @Trace navPathStack: NavPathStack = new NavPathStack();
  @Trace transitionParam: LongTakeTransitionParam = new LongTakeTransitionParam(new RectInfoPx());
  @Trace uiContext: UIContext | undefined = undefined;

  private initParams(): void {
    try {
      this.uiContext = WindowUtils.window.getUIContext();
      let postNode = this.uiContext.getFrameNodeById(this.postPageSharedComponentId);
      let stackNode =
        this.uiContext.getFrameNodeById(this.getNavDestinationId() + LongTakeTransitionConstants.POST_PAGE_STACK_ID);
      let snapShotStackNode =
        this.uiContext.getFrameNodeById(this.getNavDestinationId() +
        LongTakeTransitionConstants.POST_PAGE_SNAPSHOT_STACK_ID);

      let isWindowLayoutFullScreen: boolean = WindowUtils.window.getImmersiveModeEnabledState();

      let stackPositionVp = stackNode?.getPositionToWindowWithTransform();
      let stackSizePx = stackNode?.getMeasuredSize();
      let stackCenterXPx = this.uiContext.vp2px(stackPositionVp?.x) + (stackSizePx?.width!) / 2;

      if (!this.postPageSharedComponentId || !postNode || !snapShotStackNode || !stackSizePx) {
        if (!stackSizePx?.width || !stackSizePx?.height) {
          return;
        }

        let initScaleX = this.cardItemInfoPx.width / stackSizePx?.width!;
        let initScaleY = this.cardItemInfoPx.height / stackSizePx?.height!;

        this.initPositionValueY = (stackPositionVp?.y! !== 0) ? 0
          : (isWindowLayoutFullScreen ? 0 : -this.uiContext.px2vp(WindowUtils.topAvoidAreaHeightPx));

        if (initScaleX >= initScaleY) {
          this.initScale = initScaleX;
          this.initTranslateX =
            this.uiContext.px2vp(this.cardItemInfoPx.left + this.cardItemInfoPx.width / 2 - stackCenterXPx);
          this.initClipWidth = this.uiContext.px2vp(stackSizePx?.width);
          this.initClipHeight = this.uiContext.px2vp((this.cardItemInfoPx.height) / this.initScale);
          this.snapShotSize = { width: this.uiContext.px2vp(stackSizePx?.width) };
          this.initTranslateY = this.uiContext.px2vp(this.cardItemInfoPx.top -
            ((this.uiContext.vp2px(this.initClipHeight) - this.uiContext.vp2px(this.initClipHeight) * this.initScale) /
              2)) -
            stackPositionVp?.y!;
        } else {
          this.initScale = initScaleY;
          this.initTranslateY =
            this.uiContext.px2vp(this.cardItemInfoPx.top - (stackSizePx?.height! * (1 - this.initScale) / 2)) -
              stackPositionVp?.y!;
          this.initClipHeight = this.uiContext.px2vp(stackSizePx?.height);
          this.initClipWidth = this.uiContext.px2vp((this.cardItemInfoPx.width) / this.initScale);
          this.initTranslateX =
            this.uiContext.px2vp(this.cardItemInfoPx.left + this.cardItemInfoPx.width / 2 - stackCenterXPx);
          this.snapShotSize = { height: this.uiContext.px2vp(stackSizePx?.height) };
        }
      } else {
        let snapShotStackPositionToWindowVp = snapShotStackNode?.getPositionToWindowWithTransform();
        let postNodePositionXVp = postNode.getPositionToWindowWithTransform().x;
        let postNodePositionYVp = postNode.getPositionToWindowWithTransform().y;
        let postNodeWidthPx = postNode.getMeasuredSize().width;
        let postNodeHeightPx = postNode.getMeasuredSize().height;
        UtilLog.info(TAG,
          'the size is ' + postNodeWidthPx + ' and ' + postNodeHeightPx + ' and ' +
          this.uiContext.vp2px(postNodePositionXVp) +
            ' and ' + this.uiContext.vp2px(postNodePositionYVp));

        this.initScale = this.cardItemInfoPx.width / postNodeWidthPx;
        this.initClipHeight = this.uiContext.px2vp(this.cardItemInfoPx.height / this.initScale);

        if (postNodeHeightPx === 0 || this.transitionParam.options?.type === LongTakeTransitionType.ImageLongTake) {
          postNodeHeightPx = postNodeHeightPx ?? this.cardItemInfoPx.height / this.initScale;
          this.initPositionValueX = -postNodePositionXVp + stackPositionVp?.x!;
          this.snapShotPositionY =
            postNodePositionYVp + this.uiContext.px2vp(postNodeHeightPx) / 2 - this.initClipHeight / 2 -
              snapShotStackPositionToWindowVp?.y!;
          this.initPositionValueY =
            -(postNodePositionYVp + this.uiContext.px2vp(postNodeHeightPx) / 2 - this.initClipHeight / 2 -
              stackPositionVp?.y!);
          this.snapShotPositionX = postNodePositionXVp - snapShotStackPositionToWindowVp?.x!;
          this.initTranslateY =
            this.uiContext.px2vp(this.cardItemInfoPx.top) - (this.initClipHeight * (1 - this.initScale) / 2) -
              stackPositionVp?.y!;
        } else if (!this.transitionParam.options?.type ||
          this.transitionParam.options?.type === LongTakeTransitionType.CardLongTake) {
          this.initPositionValueX = -postNodePositionXVp + stackPositionVp?.x!;
          this.initPositionValueY = -postNodePositionYVp + stackPositionVp?.y!;
          this.snapShotPositionY = postNodePositionYVp - snapShotStackPositionToWindowVp?.y!;
          this.snapShotPositionX = postNodePositionXVp - snapShotStackPositionToWindowVp?.x!;
          this.initTranslateY =
            this.uiContext.px2vp(this.cardItemInfoPx.top -
              this.uiContext.vp2px(this.initClipHeight) * (1 - this.initScale) / 2) -
              stackPositionVp?.y!;
        }

        this.initClipWidth = this.uiContext.px2vp(postNodeWidthPx);
        this.snapShotSize = { width: this.uiContext.px2vp(postNodeWidthPx) };
        this.initTranslateX =
          this.uiContext.px2vp(this.cardItemInfoPx.left + this.cardItemInfoPx.width / 2 - stackCenterXPx);
      }
      UtilLog.info(TAG,
        'the value is initScale: ' + this.initScale + ' initTranslateX ' + this.initTranslateX + ' initClipWidth ' +
        this.initClipWidth + ' initClipHeight ' + this.initClipHeight + ' initTranslateY ' + this.initTranslateY +
          ' initPositionValue ' + this.initPositionValueY);
    } catch (error) {
      UtilLog.error(TAG, 'initParams fail, error: ' + JSON.stringify(error));
      return;
    }
  }

  public doAnimation(isPush: boolean, isExit: boolean, transitionProxy: NavigationTransitionProxy): void {
    if (isPush && !isExit) {
      this.doEnterAnimation(transitionProxy);
    } else if (!isPush && isExit) {
      this.doBackAnimation(transitionProxy);
    }
  }

  public doEnterAnimation(transitionProxy?: NavigationTransitionProxy): void {
    this.initParams();
    this.scaleValue = this.initScale;
    this.translateX = this.initTranslateX;
    this.clipWidth = this.initClipWidth;
    this.clipHeight = this.initClipHeight;
    this.translateY = this.initTranslateY;
    this.positionYValue = this.initPositionValueY;
    this.positionXValue = this.initPositionValueX;
    this.radius = (this.cardItemInfoPx.cornerRadius ?? 0) / this.initScale;
    this.transitionParam.options?.onEnterTransitionStart?.();
    this.snapShotOpacity = 1;
    this.postPageOpacity = 0;

    let animationCount = ++this.animationCount;

    // 开始做动画效果
    this.uiContext?.animateTo({
      duration: 250,
      curve: Curve.EaseInOut,
      onFinish: () => {
        if (animationCount === this.animationCount) {
          this.radius = 0;
          this.animationCount = 0;
          this.transitionParam.options?.onEnterTransitionEnd?.();
        }
        if (transitionProxy) {
          transitionProxy.finishTransition();
        }
      },
    }, () => {
      this.translateX = 0;
      this.scaleValue = 1.0;
      this.translateY = 0;
      this.clipWidth = '100%';
      this.clipHeight = '100%';
      this.positionYValue = 0;
      this.positionXValue = 0;
      this.navDestinationBgColor = this.finalBgColor;
      this.radius = DEFAULT_SCREEN_RADIUS;
    })

    this.uiContext?.animateTo({
      delay: 50,
      duration: 75,
      curve: Curve.Sharp,
    }, () => {
      this.snapShotOpacity = 0;
    })

    this.uiContext?.animateTo({
      duration: 100,
      curve: Curve.Sharp,
    }, () => {
      this.postPageOpacity = 1.0;
    })
  }

  public doBackAnimation(transitionProxy?: NavigationTransitionProxy, isChanged?: boolean): void {
    if (this.animationCount === 0) {
      this.radius = DEFAULT_SCREEN_RADIUS;
    }
    ++this.animationCount;
    this.transitionParam.options?.onBackTransitionStart?.();

    if (isChanged) {
      this.uiContext?.animateTo({
        duration: 250,
        curve: Curve.EaseOut,
        onFinish: () => {
          this.transitionParam.options?.onBackTransitionEnd?.();
          if (transitionProxy) {
            transitionProxy.finishTransition();
          }
        },
      }, () => {
        this.scaleValue = 0.05;
        this.translateX = 0;
        this.translateY = 0;
        this.radius = (this.cardItemInfoPx.cornerRadius ?? 0) / this.initScale;
        this.navDestinationBgColor = INIT_BG_COLOR;
      })

      this.uiContext?.animateTo({
        duration: 250,
        curve: Curve.EaseOut,
      }, () => {
        this.snapShotOpacity = 0;
      })

      this.uiContext?.animateTo({
        duration: 250,
        curve: Curve.EaseInOut,
      }, () => {
        this.postPageOpacity = 0;
      })
    } else {
      this.uiContext?.animateTo({
        duration: 250,
        curve: Curve.EaseInOut,
        onFinish: () => {
          this.transitionParam.options?.onBackTransitionEnd?.();
          if (transitionProxy) {
            transitionProxy.finishTransition();
          }
        },
      }, () => {
        this.scaleValue = this.initScale;
        this.translateX = this.initTranslateX;
        this.clipWidth = this.initClipWidth;
        this.clipHeight = this.initClipHeight;
        this.translateY = this.initTranslateY;
        this.radius = (this.cardItemInfoPx.cornerRadius ?? 0) / this.initScale;
        this.positionXValue = this.initPositionValueX;
        this.positionYValue = this.initPositionValueY;
        this.navDestinationBgColor = INIT_BG_COLOR;
      })

      this.uiContext?.animateTo({
        delay: 80,
        duration: 150,
        curve: Curve.Friction,
      }, () => {
        this.snapShotOpacity = 1;
      })

      this.uiContext?.animateTo({
        delay: 130,
        duration: 100,
        curve: Curve.Friction,
      }, () => {
        this.postPageOpacity = 0;
      })
    }
  }

  public setNewSize(newSize: SizeOptions) {
    this.navDestSize = newSize;
  }

  public getNavDestinationId(): string {
    return this.navDestinationId;
  }

  public getPathStack(): NavPathStack {
    return this.navPathStack;
  }

  public getTransitionParam(): LongTakeTransitionParam {
    return this.transitionParam;
  }

  public init(context: NavDestinationContext, param: LongTakeTransitionParam, options: LongTakeSessionOptions): void {
    this.navPathStack = context?.pathStack;
    if (!context || !param || !context.navDestinationId || !param.componentRectInfo || !options) {
      UtilLog.info(TAG, 'init param is invalid!');
      return;
    }
    if (param.componentRectInfo.width === 0 || param.componentRectInfo.height === 0) {
      return;
    }

    try {
      // 先初始化一些转场信息
      this.transitionParam = param;
      this.cardItemInfoPx = param.componentRectInfo;
      this.postPageSharedComponentId = options.alignTargetId;
      this.options = options;
      this.navDestinationId = context.navDestinationId;
      this.type = param.options?.type ?? LongTakeTransitionType.CardLongTake;
      this.finalBgColor = this.type ? Color.Black : DEFAULT_FINAL_BG_COLOR;

      CustomTransition.getInstance().registerNavParam(context.navDestinationId,
        (isPush: boolean, isExit: boolean, transitionProxy: NavigationTransitionProxy) => {
          this.doAnimation(isPush, isExit, transitionProxy);
        }, undefined);
      return;
    } catch (e) {
      UtilLog.info(TAG, 'initLongTakeTransition error ' + e);
      return;
    }
  }
}