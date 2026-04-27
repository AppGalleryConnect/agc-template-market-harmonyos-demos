import { common } from '@kit.AbilityKit';
import { KeyboardAvoidMode } from '@kit.ArkUI';
import { Logger } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';

const TAG = '[BlockReasonDialog]'

export interface IBlockReasonDialogParams {
  keywords?: string[];
  onBlockKeyword?: (keyword: string) => void;
  onSubmitFeedback?: (feedback: string) => void;
}

export class BlockReasonDialogParams implements IBlockReasonDialogParams {
  keywords: string[] = [];
  onBlockKeyword: (keyword: string) => void = () => {
  };
  onSubmitFeedback: (feedback: string) => void = () => {
  };

  constructor(item: IBlockReasonDialogParams) {
    if (item.keywords) {
      this.keywords = item.keywords;
    }
    if (item.onBlockKeyword) {
      this.onBlockKeyword = item.onBlockKeyword;
    }
    if (item.onSubmitFeedback) {
      this.onSubmitFeedback = item.onSubmitFeedback;
    }
  }
}

/**
 * 屏蔽弹窗内容
 */
@ComponentV2
export struct BlockReasonView {
  @Require @Param params: BlockReasonDialogParams;
  @Event changeSheetHeight: (height: number) => void = () => {
  };
  // 用于存储用户输入的反馈内容
  @Local private feedbackText: string = '';
  private pageStack: NavPathStack = new NavPathStack();
  private uiAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToAppear(): void {
    this.addKeyboardListener();
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.NONE);
  }

  aboutToDisappear(): void {
    this.cancelKeyboardListener();
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET);
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '屏蔽',
          showBackBtn: true,
          headerBarHeight: 40,
          customPadding: {
            top: 0,
            bottom: 8,
            left: 0,
            right: 0,
          },
          onBack: () => {
            this.pageStack.pop();
          },
        })

        Column() {
          ForEach(this.params.keywords, (keyword: string) => {
            Column() {
              Row() {
                Text(`不想看:  ${keyword}`)
                  .fontSize(16)
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(FontWeight.Medium)
              }
              .width('100%')
              .height(48)
              .onClick(() => {
                this.params.onBlockKeyword(keyword);
              })

              if (keyword !== this.params.keywords[this.params.keywords.length - 1]) {
                Divider()
              }
            }
          }, (keyword: string) => keyword)
        }
        .width('100%')

        TextInput({ placeholder: '输入想要屏蔽的关键词', text: this.feedbackText })
          .width('100%')
          .height(40)
          .fontColor($r('sys.color.font_primary'))
          .backgroundColor($r('sys.color.background_primary'))
          .margin({
            top: 16,
            bottom: 16,
          })
          .onChange((value: string) => {
            this.feedbackText = value;
          })
          .onSubmit(() => {
            Logger.info(TAG, `Submit feedback: ${this.feedbackText}`);
            this.params.onSubmitFeedback(this.feedbackText);
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.common_sheet_bg'))
    .onReady((context) => {
      this.pageStack = context.pathStack;
    })
  }

  addKeyboardListener() {
    try {
      const windowClass = this.uiAbilityContext.windowStage.getMainWindowSync();
      windowClass.on('keyboardHeightChange', this.onKeyBoardCB);
      windowClass
    } catch (e) {
      Logger.error(TAG, 'on keyboardHeightChange fail, error: ' + JSON.stringify(e));
    }
  }

  cancelKeyboardListener() {
    try {
      const windowClass = this.uiAbilityContext.windowStage.getMainWindowSync();
      windowClass.off('keyboardHeightChange', this.onKeyBoardCB);
    } catch (e) {
      Logger.error(TAG, 'off keyboardHeightChange fail, error: ' + JSON.stringify(e));
    }
  }

  onKeyBoardCB: (height: number) => void = (height: number) => {
    const keyboardH = this.getUIContext().px2vp(height);
    this.changeSheetHeight(keyboardH);
  };
}