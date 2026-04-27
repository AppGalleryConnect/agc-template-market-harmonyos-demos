import { ComponentContent, PromptAction } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';

export interface SpeechRecordParam {
  confirm: () => void;
  cancel: () => void;
}

export class SpeechRecordDialogUtil {
  private uiContext: UIContext;
  private promptAction: PromptAction;
  private node: ComponentContent<SpeechRecordParam> | null = null;

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext;
    this.promptAction = uiContext.getPromptAction();
  }

  public async open(args: SpeechRecordParam): Promise<boolean> {
    if (this.node) {
      return false;
    }
    try {
      this.node = new ComponentContent(this.uiContext, wrapBuilder(speechRecordDialogBuilder), args);
      await this.promptAction.openCustomDialog(this.node, {
        alignment: DialogAlignment.Center,
        onWillDismiss: () => {
        },
        autoCancel: false,
      });
      return true;
    } catch {
      this.node = null;
      return false;
    }
  }

  public close(): void {
    this.promptAction.closeCustomDialog(this.node).catch(() => {
      UtilLog.error('[SpeechRecordDialog]', 'closeCustomDialog failed. ');
    }).finally(() => this.node = null);
  }
}

@Builder
export function speechRecordDialogBuilder(param: SpeechRecordParam) {
  SpeechRecordDialog({
    confirm: param.confirm,
    cancel: param.cancel,
  })
}


@ComponentV2
struct SpeechRecordDialog {
  @Event confirm: () => void;
  @Event cancel: () => void;
  @Local warningDotOpacity: number = 0;
  @Local dotOpacity1: number = 0;
  @Local dotOpacity2: number = 0;
  @Local dotOpacity3: number = 0;

  build() {
    Column() {
      Column() {
        Row() {
          Text('语音识别').fontSize(20).fontColor($r('sys.color.font_primary')).fontWeight(700)
          Button() {
            SymbolGlyph($r('sys.symbol.xmark'))
              .fontSize(16)
              .fontColor([$r('sys.color.icon_secondary')])
          }
          .width(40)
          .height(40)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .onClick(() => {
            this.cancel?.();
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)


        Row() {
          Circle({ width: 8, height: 8 })
            .fill($r('sys.color.warning'))
            .margin({ right: 8 })
            .opacity(this.warningDotOpacity)
            .animation({
              duration: 800,
              delay: 0,
              iterations: -1,
              playMode: PlayMode.Alternate,
              curve: Curve.EaseInOut
            })

          Text('语音录制中')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(400)
            .lineHeight(19)

          // 第一个点
          Text('.')
            .fontSize(20)
            .opacity(this.dotOpacity1)
            .animation({
              duration: 500,
              delay: 0,
              iterations: -1,
              playMode: PlayMode.Alternate,
              curve: Curve.EaseInOut
            })

          // 第二个点
          Text('.')
            .fontSize(20)
            .opacity(this.dotOpacity2)
            .animation({
              duration: 500,
              delay: 250,
              iterations: -1,
              playMode: PlayMode.Alternate,
              curve: Curve.EaseInOut
            })

          // 第三个点
          Text('.')
            .fontSize(20)
            .opacity(this.dotOpacity3)
            .animation({
              duration: 500,
              delay: 500,
              iterations: -1,
              playMode: PlayMode.Alternate,
              curve: Curve.EaseInOut
            })
        }
        .margin({ top: 12 })


        Text('请说出您的姓名，电话和详细地址')
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .lineHeight(21)
          .margin({ top: 16 })

        Row() {
          Button('说完了')
            .width('100%')
            .type(ButtonType.Capsule)
            .shadow(ShadowStyle.OUTER_DEFAULT_XS)
            .backgroundColor($r('sys.color.comp_background_emphasize'))
            .onClick(() => {
              this.confirm();
            })
        }
        .width('100%')
        .padding(12)
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(32)
      .padding({ left: 16, right: 16, top: 12, bottom: 16 })
    }
    .width('100%')
    .constraintSize({ maxWidth: 420 })
    .padding(16)
    .onAppear(() => {
      this.warningDotOpacity = 1;
      this.dotOpacity1 = 1;
      this.dotOpacity2 = 1;
      this.dotOpacity3 = 1;
    })
  }
}