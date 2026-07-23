import { StoreManager, TextMessage } from '@hw-agconnect/copilot';
import { RouterMap, RouterUtils } from 'lib_common';
import { CopilotHistory } from '../../components/CopilotHistory';
import { NavHeaderBar } from '../../widget/NavHeaderBar';
import { PageResultType } from './OfficeResultPage';

const RESULT_TYPE = ['论文写作', '智能总结']
const SORT_TYPE = ['paper', 'summary']

@Builder
export function OfficeHistoryPageBuilder() {
  OfficeHistoryPage()
}

@ComponentV2
export struct OfficeHistoryPage {
  private controller: TabsController = new TabsController();
  @Local isDeleted: boolean = false;
  @Local curIndex: number = 0;

  aboutToAppear(): void {
    let params = RouterUtils.getParamByName<string>(RouterMap.OFFICE_HISTORY_PAGE);
    this.curIndex = RESULT_TYPE.lastIndexOf(params ?? '') !== -1 ? RESULT_TYPE.lastIndexOf(params ?? '') : 0;
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '历史记录'
        }) {
          this.deleteButton()
        }

        Row({ space: 8 }) {
          ForEach(RESULT_TYPE, (name: string, index: number) => {
            Button(name)
              .height(40)
              .fontColor(index === this.curIndex ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Normal)
              .backgroundColor(index === this.curIndex ? $r('sys.color.comp_background_emphasize') :
              $r('sys.color.comp_background_tertiary'))
              .onClick(() => {
                if (index === this.curIndex) {
                  return
                }
                this.curIndex = index
                this.controller.changeIndex(this.curIndex);
              })
          }, (name: string) => name)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .padding({
          top: 8,
          bottom: 8,
          left: 16,
          right: 16
        })

        Tabs({ index: this.curIndex, barPosition: BarPosition.Start, controller: this.controller }) {
          ForEach(SORT_TYPE, (storeId: string) => {
            TabContent() {
              CopilotHistory({
                isDeleted: this.isDeleted,
                storeId: storeId,
                onClickEvent: async (threadId) => {
                  let storeInfo = await StoreManager.getStore(storeId).loadMessages(threadId);
                  let content = 'load fail'
                  if (storeInfo.messages) {
                    let lastMessage = storeInfo.messages[storeInfo.messages.length - 1];
                    if (lastMessage.isTextMessage()) {
                      content = (lastMessage as TextMessage).content;
                    }
                  }
                  RouterUtils.pushPathByName(RouterMap.OFFICE_RESULT_PAGE, {
                    content: content,
                    pageTitle: '详情'
                  } as PageResultType)
                }
              })
            }
          }, (item: string) => item)
        }
        .layoutWeight(1)
        .barHeight(0)
        .animationDuration(300)
        .padding({ left: 16, right: 16 })
        .onAnimationStart((_index: number, targetIndex: number, _event: TabsAnimationEvent) => {
          // 使用onAnimationStart控制页面与页签的联动，避免出现页面与页签联动延迟
          this.curIndex = targetIndex;
        })
      }
    }.hideTitleBar(true)
  }

  @Builder
  tabBuilder(name: string, index: number) {
    Button(name)
      .height(40)
      .fontColor(this.curIndex === index ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
      .fontSize($r('sys.float.Body_M'))
      .fontWeight(FontWeight.Normal)
      .backgroundColor(this.curIndex === index ? $r('sys.color.comp_background_emphasize') :
      $r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        this.curIndex = index
      })
  }

  @Builder
  deleteButton() {
    Column() {
      SymbolGlyph($r('sys.symbol.trash'))
        .fontSize($r('sys.float.Title_M'))
        .fontColor([$r('sys.color.icon_primary')])
        .padding(8)
        .borderRadius(40)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.isDeleted = !this.isDeleted
        })
    }
  }
}
