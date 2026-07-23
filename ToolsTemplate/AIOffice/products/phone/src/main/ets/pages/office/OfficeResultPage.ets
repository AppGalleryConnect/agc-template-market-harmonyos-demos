import { HistoryButton } from '../../components/HistoryButton';
import { CopilotController, MessageRole, TextMessage } from '@hw-agconnect/copilot';
import { pasteboard } from '@kit.BasicServicesKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { MarkdownV2 } from '@lidary/markdown';
import { RouterMap, RouterUtils, WindowModel } from 'lib_common';
import { NavHeaderBar } from '../../widget/NavHeaderBar';

export interface PageResultType {
  systemPrompt?: string;
  userPrompt?: string;
  content?: string;
  type: string;
  pageTitle: string,
  title: string
}

@Builder
export function OfficeResultPageBuilder() {
  OfficeResultPage()
}

@ComponentV2
export struct OfficeResultPage {
  @Local chatResult: string = '';
  @Local pageTitle: string = '';
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local controller?: CopilotController;
  @Local isBtnHidden: boolean = false;

  async aboutToAppear(): Promise<void> {
    let params = RouterUtils.getParamByName(RouterMap.OFFICE_RESULT_PAGE) as PageResultType;
    if (params.content) {
      this.chatResult = params.content;
    } else {
      this.controller = new CopilotController({
        llm: {
          baseUrl: 'https://api.deepseek.com/v1',
          model: 'deepseek-chat',
          //TODO: 需要替换成真实的apikey，为了安全起见，建议配置在服务端，可以动态下发
          apiKey: ''
        },
        systemPrompt: params.systemPrompt,
        storeId: params.type
      })
      this.controller.addMessage(new TextMessage({
        role: MessageRole.USER,
        content: params.userPrompt ?? ''
      }))
      this.controller.latestCallback = (content: string) => {
        this.chatResult = content;
      };
    }
    this.pageTitle = params.pageTitle
    if (this.pageTitle === '详情') {
      this.isBtnHidden = true
    }
  }

  aboutToDisappear(): void {
    this.controller?.cancel()
  }

  /**
   * 复制内容到剪贴板
   */
  private async copyToClipboard(): Promise<void> {
    try {
      if (!this.chatResult || this.chatResult.trim() === '') {
        this.getUIContext().getPromptAction().showToast({
          message: '暂无内容可复制',
          duration: 2000
        });
        return;
      }

      const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.chatResult);
      const systemPasteboard = pasteboard.getSystemPasteboard();
      await systemPasteboard.setData(pasteboardData);

      this.getUIContext().getPromptAction().showToast({
        message: '已复制到剪贴板',
        duration: 2000
      });
    } catch (error) {
      console.error('复制失败:', error);
      this.getUIContext().getPromptAction().showToast({
        message: '复制失败',
        duration: 2000
      });
    }
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: this.pageTitle,
          customPadding: {
            left: 0,
            right: 0
          }
        }) {
          HistoryButton({
            onEvent: () => {
              RouterUtils.pushPathByName(RouterMap.OFFICE_HISTORY_PAGE)
            },
            isBtnHidden: this.isBtnHidden
          })
        }

        Scroll() {
          Column() {
            MarkdownV2({
              content: this.chatResult,
              lineSpace: 4,
              fontStyle: {
                fontSize: $r('sys.float.Body_M'),
                fontColor: $r('sys.color.font_primary')
              }
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .constraintSize({ minHeight: `calc(100%)` })
          .padding({
            left: 8,
            top: 14,
            right: 8,
            bottom: 14
          })
          .borderRadius(16)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
        }
        .margin({ bottom: 8 })
        .edgeEffect(EdgeEffect.Spring)
        .align(Alignment.TopStart)
        .scrollBar(BarState.Off)
        .flexShrink(1)
        .flexGrow(1)

        if (!this.controller?.context.isLoading) {
          Text('以上为AI生成内容，仅供参考')
            .fontSize($r('sys.float.Subtitle_S'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .margin({ bottom: 8 })
        }

        Button(this.controller?.context.isLoading ? '停止生成' : '复制')
          .width('100%')
          .height(40)
          .margin({
            bottom: this.windowModel.windowBottomPadding + 12
          })
          .backgroundColor($r('sys.color.comp_background_emphasize'))
          .onClick(() => {
            if (this.controller?.context.isLoading) {
              this.controller.cancel();
            } else {
              this.copyToClipboard();
            }
          })
      }
      .width('100%')
      .height('100%')
      .padding({ top: 8, left: 16, right: 16 })
    }
    .hideTitleBar(true)
  }
}