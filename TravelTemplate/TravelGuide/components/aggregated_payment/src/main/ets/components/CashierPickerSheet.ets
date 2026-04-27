import { window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

import { CashierPickerContentVM } from '../viewmodels/CashierPickerContentVM';
import { PaymentType, WidthBreakpoint, HeightBreakpoint } from '../common/CustomTypes';

@ComponentV2
export struct CashierPickerSheet {

  @Require @Param
  public content: CashierPickerContentVM;

  @Local
  private heightBreakpoint: HeightBreakpoint = HeightBreakpoint.SM;

  @Local
  private widthBreakpoint: WidthBreakpoint = WidthBreakpoint.SM;

  @Computed
  private get isCenterLayout(): boolean {
    if (this.heightBreakpoint === HeightBreakpoint.XS) {
      return false;
    }
    return this.widthBreakpoint !== WidthBreakpoint.XS && this.widthBreakpoint !== WidthBreakpoint.SM;
  }

  @Computed
  private get sheetWidth(): Length {
    if (this.widthBreakpoint === WidthBreakpoint.XS || this.widthBreakpoint === WidthBreakpoint.SM) {
      return '100%';
    } else {
      return '480vp';
    }
  }

  private mainWindow: window.Window | null = null;

  private updateHeightBreakpoint: Callback<Size> = (size: Size) => {
    const ratio: number = size.height / size.width;
    if (ratio < 0.5) {
      this.heightBreakpoint = HeightBreakpoint.XS;
    } else {
      this.heightBreakpoint = HeightBreakpoint.SM;
    }
  };

  public aboutToAppear(): void {
    const ctx: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
    if (ctx) {
      this.mainWindow = ctx.windowStage.getMainWindowSync();
      const properties: window.WindowProperties = this.mainWindow.getWindowProperties();
      this.updateHeightBreakpoint({
        width: properties.windowRect.width,
        height: properties.windowRect.height
      });
    }
    this.mainWindow?.on('windowSizeChange', this.updateHeightBreakpoint);
  }

  public aboutToDisappear(): void {
    this.mainWindow?.off('windowSizeChange', this.updateHeightBreakpoint);
  }

  public build(): void {
    Stack({ alignContent: this.isCenterLayout ? Alignment.Center : Alignment.Bottom }) {
      if (this.content.isOpen) {
        /**
         * 宽度断点监听触发组件
         */
        GridRow({ breakpoints: { value: [ '320vp', '600vp', '840vp' ] } })
          .onBreakpointChange((breakpoints: string) => {
            if (breakpoints === WidthBreakpoint.XS) {
              this.widthBreakpoint = WidthBreakpoint.XS;
            } else if (breakpoints === WidthBreakpoint.SM) {
              this.widthBreakpoint = WidthBreakpoint.SM;
            } else if (breakpoints === WidthBreakpoint.MD) {
              this.widthBreakpoint = WidthBreakpoint.MD;
            } else {
              this.widthBreakpoint = WidthBreakpoint.LG;
            }
          })
        /**
         * 模态窗遮罩蒙层，以透明度渐变方式转场，被点击时回调 willDismiss()，交互类型为 TOUCH_OUTSIDE
         */
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor($r('sys.color.ohos_id_color_mask_thin'))
          .onClick(() => this.content.willDismiss(DismissReason.TOUCH_OUTSIDE))
          .transition(TransitionEffect.asymmetric(
            TransitionEffect.OPACITY.animation({
              duration: this.content.durationForAppear,
              curve: Curve.FastOutSlowIn
            }),
            TransitionEffect.OPACITY.animation({
              duration: this.content.durationForDisappear,
              curve: Curve.FastOutSlowIn
            })
          ))
          .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        Column() {
          /**
           * 标题栏，当前仅用于承载关闭按钮，被点击时回调 willDismiss()，交互类型为 CLOSE_BUTTON
           */
          Row() {
            Button() {
              SymbolGlyph($r('sys.symbol.xmark'))
                .fontSize(18)
                .fontColor([$r('sys.color.icon_primary')])
                .fontWeight(FontWeight.Normal)
                .renderingStrategy(SymbolRenderingStrategy.SINGLE)
            }
            .width(40)
            .height(40)
            .type(ButtonType.Circle)
            .margin({ right: 16 })
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .onClick(() => this.content.willDismiss(DismissReason.CLOSE_BUTTON))
          }
          .width('100%')
          .margin({ top: 16 })
          .justifyContent(FlexAlign.End)
          .alignItems(VerticalAlign.Top)
          /**
           * 收银台选择列表，内容超出容器时支持滚动
           */
          Scroll() {
            Column() {
              if (this.content.tradeSummary) {
                Text(this.content.tradeSummary)
                  .width('80%')
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor($r('sys.color.mask_secondary'))
                  .fontWeight(FontWeight.Regular)
                  .maxLines(1)
                  .textAlign(TextAlign.Center)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ top: 8 })
              }
              Text() {
                Span('¥')
                  .fontSize($r('sys.float.Title_M'))
                Span((this.content.amount / 100).toFixed(2))
                  .fontSize($r('sys.float.Display_S'))
              }
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Bold)
              .margin({ top: 8 })
              Column() {
                this.buildPaymentItem($r('app.media.huawei_pay_logo'), '华为支付', PaymentType.HUAWEI)
                this.buildPaymentItem($r('app.media.alipay_logo'), '支付宝', PaymentType.ALIPAY)
                this.buildPaymentItem($r('app.media.wechat_pay_logo'), '微信支付', PaymentType.WECHAT)
              }
              .width('100%')
              .margin({ top: 16 })
              .borderRadius(16)
              .backgroundColor($r('sys.color.comp_background_primary'))
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
            .margin({ bottom: 12 })
            .justifyContent(FlexAlign.Start)
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          /**
           * 智慧多窗适配，滚动区高度随自身内容动态变化，尽可能直接呈现全部内容
           *
           * 滚动区最大高度：
           * 1. 居中类模态窗 -> 当前窗口高度(90%) - 模态窗标题栏高度 - 付款按钮区域高度 + 1px像素延伸
           * 2. 底部类模态窗 -> 当前窗口高度(100%) - 模态窗标题栏高度 - 付款按钮区域高度 - 8vp避让 + 1px像素延伸
           *
           * 像素取整：延伸 1px，影响可忽略不记，但其可以在某些特定缩放场景中起到向上取整的作用，保证 SafeAreaEdge.BOTTOM 生效
           */
          .constraintSize(
            this.isCenterLayout ?
              { maxHeight: 'calc(90% - 56vp - 56vp + 1px)' } :
              { maxHeight: 'calc(100% - 56vp - 56vp - 8vp + 1px)' }
          )
          .edgeEffect(EdgeEffect.Spring)
          .scrollBar(BarState.Off)
          Row() {
            Button('确认付款')
              .width('100%')
              .height(40)
              .type(ButtonType.ROUNDED_RECTANGLE)
              .onClick(() => this.content.payment(this.content.selectType))
          }
          .width('100%')
          .padding({ bottom: 16, left: 16, right: 16 })
        }
        .width(this.sheetWidth)
        .borderRadius(this.isCenterLayout ? 32 : { topLeft: 32, topRight: 32 })
        .backgroundColor($r('sys.color.background_secondary'))
        .transition(TransitionEffect.asymmetric(
          TransitionEffect.move(TransitionEdge.BOTTOM).animation({
            duration: this.content.durationForAppear,
            curve: Curve.FastOutSlowIn
          }),
          TransitionEffect.move(TransitionEdge.BOTTOM).animation({
            duration: this.content.durationForDisappear,
            curve: Curve.FastOutSlowIn
          })
        ))
        .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM])
      }
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(this.content.isOpen ? HitTestMode.Default : HitTestMode.Block)
  }

  @Builder
  private buildPaymentItem(icon: ResourceStr, label: string, type: PaymentType) {
    Row() {
      Row() {
        Image(icon)
          .width(48)
          .height(48)
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .margin({ right: 16 })
        Text(label)
          .fontSize($r('sys.float.Subtitle_M'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
      }
      Checkbox()
        .select(this.content.selectType === type)
        .hitTestBehavior(HitTestMode.None)
    }
    .width('100%')
    .height(72)
    .padding({ left: 12, right: 14 })
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => this.content.selectType = type)
  }
}
