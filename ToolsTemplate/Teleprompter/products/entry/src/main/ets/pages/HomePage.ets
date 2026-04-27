/**
 * @usage: tab页面控制类，包括提词器、我的
 * @layout:
 * @constraints: tab页面控制类包括提词器（prompt_word）、我的（person）。根据用户实际需求仅修改代码中tabContentBuilder调用的变量，
 * 当前仅支持删除变量中的元素，以及修改index从0开始并保证index顺序，其他元素不允许修改。根据用户需求删除多余的import依赖，
 * 仅从prompt_word、person依赖中删除，Constants依赖需保留。
 * @isGen: true
 * @fileType: tab
 */

import { Constants } from 'common';
import { MinePage } from 'person';
import { PromptWordPage } from 'prompt_word'

@Builder
function person() {
  MinePage()
}

@Builder
function promptWord() {
  PromptWordPage()
}

const promptWordBuilder: WrappedBuilder<[string]> = wrapBuilder(promptWord);
const personBuilder: WrappedBuilder<[string]> = wrapBuilder(person);

@Builder
export function HomePageBuilder() {
  HomePage()
}

@ComponentV2
export struct HomePage {
  @Local currentIndexTab: number = 0;
  tabsController: TabsController = new TabsController();

  @Builder
  tabBuilder(title: Resource, index: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      Image(this.currentIndexTab === index ? selectedImg : normalImg)
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
      Text(title)
        .margin({ top: 6 })
        .fontSize(12)
        .fontColor(this.currentIndexTab === index ? '#0A59F7' : 'rgba(0, 0, 0, 0.40)')
    }
    .height(80)
    .justifyContent(FlexAlign.Start)
    .padding({ top: 3 })
    .width('100%')
    .onClick(() => {
      this.currentIndexTab = index;
      this.tabsController.changeIndex(this.currentIndexTab);
    })

  }

  @Builder
  tabContentBuilder(text: Resource,
    index: number,
    selectedImg: Resource,
    normalImg: Resource,
    builder: WrappedBuilder<[string]>) {
    TabContent() {
      Stack() {
        builder.builder('');
      }
      .height('100%')
    }
    .backgroundColor('#F2F3F5')
    .tabBar(this.tabBuilder(text, index, selectedImg, normalImg))
  }

  build() {
    NavDestination() {
      Tabs({
        barPosition: BarPosition.End,
        controller: this.tabsController
      }) {
        this.tabContentBuilder($r('app.string.prompt_word'),
          Constants.TAB_INDEX_ZERO, $r('app.media.prompt_word_tab_active'), $r('app.media.prompt_word_tab'),
          promptWordBuilder)
        this.tabContentBuilder($r('app.string.person'),
          Constants.TAB_INDEX_ONE, $r('app.media.mine_tab_active'), $r('app.media.mine_tab'), personBuilder)
      }
      .clip(true)
      .width('100%')
      .backgroundColor(Color.White)
      .barHeight(80)
      .barMode(BarMode.Fixed)
      // .padding({ top: 14 })
      .animationDuration(0)
      .scrollable(false)
      .onAnimationStart((targetIndex: number) => {
        this.currentIndexTab = targetIndex;
      })
    }
    .hideTitleBar(true)
  }
}