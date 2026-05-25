import { common } from '@kit.AbilityKit';
import { call } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';

import { DialPanelContentVM } from '../viewmodels/DialPanelContentVM';
import { DialErrorCode } from '../common/CustomTypes';
import { BusinessErrorFactory } from '../utils/BusinessErrorFactory';
import { WindowListener } from '../utils/WindowListener';

@ComponentV2
export struct DialPanelSheet {

  @Require @Param
  public content: DialPanelContentVM;

  private ctx: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  private listener: WindowListener = new WindowListener(this.ctx);

  public aboutToAppear(): void {
    this.listener.start();
  }

  public aboutToDisappear(): void {
    this.listener.stop();
  }

  public build(): void {
    Column() {
      Row() {
        Text(this.content.title)
          .layoutWeight(1)
          .fontSize($r('sys.float.Title_S'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
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
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => this.content.onWillDismiss(DismissReason.CLOSE_BUTTON))
      }
      .width('100%')
      .height(56)
      .margin({ top: 8 })
      .padding({ left: 16, right: 16 })
      Scroll() {
        Column() {
          /**
           * 电话号码展示
           */
          Column() {
            Text(this.content.phoneNumber)
              .width('100%')
              .textAlign(TextAlign.Center)
              .fontSize($r('sys.float.Title_S'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Bold)
          }
          /**
           * 不推荐使用 layoutWeight(1)，其导致窗口变化时的过渡动画表现不稳定
           *
           * 直接使用 (320 - 标题栏 - 拨号按钮 - 取消按钮) 计算居中布局下的具体高度
           */
          .height(this.content.sheetType === SheetType.BOTTOM ? 'auto' : 320 - 64 - 52 - 52)
          .padding(this.content.sheetType === SheetType.BOTTOM ? { top: 8, bottom: 24 } : {})
          .justifyContent(FlexAlign.Center)
          /**
           * 拨号按钮
           */
          Button() {
            Row() {
              SymbolGlyph($r('sys.symbol.phone_fill'))
                .fontSize(18)
                .fontColor([$r('sys.color.font_on_primary')])
                .margin({ right: 8 })
              Text('一键拨号')
                .fontColor($r('sys.color.font_on_primary'))
                .fontWeight(FontWeight.Regular)
            }
          }
          .width('100%')
          .height(40)
          .type(ButtonType.ROUNDED_RECTANGLE)
          .margin({ bottom: 12 })
          .onClick(() => this.makeCall())
          /**
           * 取消按钮
           */
          Button('取消')
            .width('100%')
            .type(ButtonType.ROUNDED_RECTANGLE)
            .fontColor($r('sys.color.font_primary'))
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .margin({ bottom: this.listener.avoidArea.bottom ? `calc(${this.listener.avoidArea.bottom}px + 4vp)` : 12 })
            .onClick(() => this.content.onWillDismiss(DismissReason.CLOSE_BUTTON))
        }
        .width('100%')
        .height(this.content.sheetType === SheetType.BOTTOM ? 'auto' : 320 - 64)
        .padding({ right: 16, left: 16 })
      }
      /**
       * 模态页面中不推荐使用百分比约束高度，需使用具体 VP 或 PX 值
       */
      .constraintSize(this.content.sheetType === SheetType.BOTTOM ?
        { maxHeight: `calc(${this.listener.windowSize.height}px - ${this.listener.avoidArea.top}px - 8vp - 64vp)` } :
        { maxHeight: `calc(${this.listener.windowSize.height * 0.8}px - 64vp)` }
      )
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .backgroundColor($r('sys.color.comp_background_primary'))
  }

  private makeCall(): void {
    if (canIUse('SystemCapability.Applications.Contacts')) {
      call.makeCall(this.content.phoneNumber)
        .then(() => {
          if (this.content.isAutoClosePanel) {
            this.content.close();
          }
          this.content.onMakeCall(BusinessErrorFactory.create(DialErrorCode.SUCCESS));
        })
        .catch((e: BusinessError<void>) => this.content.onMakeCall(e));
    } else {
      this.content.onMakeCall(BusinessErrorFactory.create(DialErrorCode.SYSCAP_NOT_SUPPORTED));
    }
  }
}
