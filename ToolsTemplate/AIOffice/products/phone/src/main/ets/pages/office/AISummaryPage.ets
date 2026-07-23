import { GlobalContext, RouterMap, RouterUtils, WindowModel } from 'lib_common';
import { HistoryButton } from '../../components/HistoryButton';
import { PageResultType } from './OfficeResultPage';
import { AppStorageV2 } from '@kit.ArkUI';
import { NavHeaderBar } from '../../widget/NavHeaderBar';

const LANGUAGE = ['中文', '英文']

@Builder
export function AISummaryPageBuilder() {
  AISummaryPage()
}

@ComponentV2
export struct AISummaryPage {
  @Local content: string = '';
  @Local language: string = '中文';
  @Local other: string = '';
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '智能总结'
        }) {
          HistoryButton({
            onEvent: () => {
              RouterUtils.pushPathByName(RouterMap.OFFICE_HISTORY_PAGE, '智能总结')
            }
          })
        }

        Scroll() {
          Column() {
            Text('文本内容')
              .fontSize($r('sys.float.Subtitle_L'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 12 })

            TextArea({ placeholder: '请粘贴或输入文本内容', text: $$this.content })
              .placeholderColor($r('sys.color.font_secondary'))
              .placeholderFont({
                size: $r('sys.float.Body_L'),
                weight: FontWeight.Regular,
              })
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Regular)
              .borderRadius(8)
              .padding({ left: 12 })
              .constraintSize({ minHeight: 240 })
              .margin({ bottom: 16 })

            Text('选择语言')
              .fontSize($r('sys.float.Subtitle_L'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 12 })

            Row({ space: 8 }) {
              ForEach(LANGUAGE, (item: string) => {
                Button() {
                  Text(item)
                    .fontSize($r('sys.float.Body_M'))
                    .fontWeight(FontWeight.Normal)
                    .fontColor(this.language === item ? $r('sys.color.font_on_primary') :
                    $r('sys.color.font_primary'))
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .maxLines(1)
                }
                .width(72)
                .height(28)
                .borderRadius(14)
                .padding({
                  top: 4,
                  bottom: 4,
                  right: 8,
                  left: 8
                })
                .backgroundColor(this.language === item ? $r('sys.color.icon_emphasize') :
                $r('sys.color.comp_background_tertiary'))
                .onClick(() => {
                  this.language = item;
                })
              }, (item: string): string => item)
            }
            .margin({ bottom: 16 })

            Text('其他要求')
              .fontSize($r('sys.float.Subtitle_L'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 12 })
            TextArea({ placeholder: '请输入您的其他要求，若无可不填', text: $$this.other })
              .placeholderColor($r('sys.color.font_secondary'))
              .placeholderFont({
                size: $r('sys.float.Body_L'),
                weight: FontWeight.Regular,
              })
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Regular)
              .borderRadius(8)
              .padding({ left: 12 })
              .constraintSize({ minHeight: 120 })
              .margin({ bottom: 16 })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .edgeEffect(EdgeEffect.Spring)
        .align(Alignment.TopStart)
        .scrollBar(BarState.Off)
        .flexShrink(1)
        .flexGrow(1)
        .expandSafeArea([SafeAreaType.KEYBOARD])
        .padding({ top: 8, left: 16, right: 16 })

        Column() {
          Button('开始生成')
            .width('100%')
            .height(40)
            .backgroundColor($r('sys.color.comp_background_emphasize'))
            .onClick(() => {
              if(!this.content){
                GlobalContext.getUIContext().getPromptAction().showToast({ message: '文本内容不能为空！' });
                return;
              }
              let systemPrompt = '你是一个写作专家，需要根据用户的需求生成论文或总结，内容需要严谨';
              let userPrompt =
                `帮我生成一篇总结，需要总结的内容是${this.content} 。使用${this.language}，其他要求：${this.other}`
              RouterUtils.pushPathByName(RouterMap.OFFICE_RESULT_PAGE, {
                systemPrompt: systemPrompt,
                userPrompt: userPrompt,
                type: 'summary',
                pageTitle: '智能总结',
              } as PageResultType)
            })
        }
        .margin({
          bottom: this.windowModel.windowBottomPadding + 12
        })
        .padding({ left: 16, right: 16, top: 8 })
      }
      .height('100%')
    }
    .hideTitleBar(true)
  }
}