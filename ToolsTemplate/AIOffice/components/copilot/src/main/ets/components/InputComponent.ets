import { requestPermission } from '../utils/RequestPermission';
import { CopilotChatOptions } from './CopilotChatOptions';
import { common } from '@kit.AbilityKit';
import { SpeechRecognizer } from '../utils/SpeechRecognizer';
import { window } from '@kit.ArkUI';

@Preview
@ComponentV2
export struct InputComponents {
  @Param isProgress: boolean = false;
  @Param options: CopilotChatOptions = {};
  @Param scroller: Scroller = new Scroller();
  @Event onSend: (input: string) => void;
  @Event onStop: () => void;
  @Local inputString: string = '';
  @Local historyString: string = '';
  @Local recordingString: string = '';
  @Local isRecording: boolean = false;
  @Local keyboardHeight: number = 0;
  @Local isRecognizerEnable: boolean = false;
  private speechRecognizer: SpeechRecognizer = new SpeechRecognizer();

  @Computed
  get isInputButtonEnable(): boolean {
    if (this.inputString.trim().length > 0) {
      return true;
    } else {
      return this.isProgress;
    }
  }

  async aboutToAppear(): Promise<void> {
    this.isRecognizerEnable = await this.speechRecognizer.initEngine();
    try {
      window.getLastWindow(this.getUIContext().getHostContext()).then(currentWindow => {
        currentWindow.on('keyboardHeightChange', (data: number) => {
          this.keyboardHeight = this.getUIContext().px2vp(data);
          if (this.keyboardHeight === 0) {
            this.stopRecord();
          }
        })
      }).catch((error: Error) => {
        console.error('[InputComponent] getLastWindow error: ' + JSON.stringify(error));
      })
    } catch (error) {
      console.error('[InputComponent] aboutToAppear error: ' + JSON.stringify(error));
    }
  }

  aboutToDisappear(): void {
    this.speechRecognizer.shutdown();
  }

  build() {
    RelativeContainer() {
      TextInput({
        placeholder: this.options.labels?.placeholder,
        text: this.inputString
      })
        .onEditChange((isEditing: boolean) => {
          if (this.scroller.isAtEnd()) {
            setTimeout(() => {
              animateToImmediately({ duration: isEditing ? 300 : 0 }, () => {
                this.scroller.scrollEdge(Edge.Bottom);
              })
            }, 200);
          }
        })
        .fontColor('sys.color.font_primary')
        .backgroundColor('#00000000')
        .id('input_textarea')
        .onChange((value: string) => {
          if (this.isRecording && value !== this.inputString) {
            this.stopRecord();
          }
          this.inputString = value;
        })
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          start: { anchor: '__container__', align: HorizontalAlign.Start },
          end: { anchor: '__actions__', align: HorizontalAlign.Start }
        })
        .height('100%')
      Row({ space: 4 }) {
        SymbolGlyph(this.isProgress ? $r('sys.symbol.stop_circle') : $r('sys.symbol.arrow_up_circle_fill'))
          .fontSize($r('sys.float.Title_M'))
          .fontColor([this.isInputButtonEnable ? (this.isProgress ? '#E84026' : '#2576F4') : '#ffa4c6ff'])
          .width(32)
          .height(32)
          .enabled(this.isInputButtonEnable)
          .onClick(() => {
            if (this.isProgress) {
              this.onStop();
            } else {
              if (this.isRecording) {
                this.stopRecord();
              }
              this.onSend(this.inputString.trim());
              this.getUIContext().getFocusController().clearFocus();
            }
            this.inputString = '';
          })
        if (this.isRecognizerEnable) {
          SymbolGlyph($r('sys.symbol.mic_fill'))
            .fontSize($r('sys.float.Title_M'))
            .fontColor([this.isRecording ? '#E84026' : $r('sys.color.icon_primary')])
            .width(32)
            .height(32)
            .onClick(() => {
              this.isRecording ? this.stopRecord() : this.startRecord();
            })
        }
      }
      .id('__actions__')
      .alignRules({
        center: { anchor: '__container__', align: VerticalAlign.Center },
        end: { anchor: '__container__', align: HorizontalAlign.End }
      })
      .padding({
        right: 4
      })
    }
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .borderRadius(8)
    .height(40)
  }

  stopRecord() {
    this.speechRecognizer.stop();
    this.isRecording = false;
  }

  async startRecord() {
    try {
      let result = await requestPermission(['ohos.permission.MICROPHONE'], getContext() as common.UIAbilityContext);
      if (result !== 0) {
        this.getUIContext().getPromptAction().showToast({
          message: result === 2 ? '未正确配置权限' : '麦克风权限未开启，请前往“设置”>"应用和元服务"中开启权限'
        })
        return;
      }
      this.getUIContext().getFocusController().requestFocus('input_textarea');
      this.historyString = this.inputString;
      this.isRecording = true;
      this.speechRecognizer.start((result, isFinish, error) => {
        if (!result?.isLast && result?.result) {
          this.recordingString = result?.result;
          this.inputString = this.historyString + this.recordingString;
        }
        if (result?.isFinal && result.result.length > 0) {
          this.recordingString = result.result;
          this.inputString = this.historyString + this.recordingString;
          this.historyString = this.inputString;
        }

        if (isFinish) {
          this.isRecording = false;
        }
      });
    } catch (e) {
    }
  }
}