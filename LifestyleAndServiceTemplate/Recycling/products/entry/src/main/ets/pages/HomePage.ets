import { BarVM, Constants } from 'common';
import { MinePage } from 'person';
import { MainPage } from 'homepage';

/**
 * @usage: tab 页面控制类，包括首页（MainPage）和我的（MinePage）两个 tab 页签。提供 tab 切换、页面导航功能。
 * @layout: 页面采用 Tabs 组件布局，底部为 TabBar，包含首页和我的两个 tab 按钮。每个 tab 按钮包含图标和文字，选中状态会高亮显示。
 * @constraints: tab 页面控制类包括首页（homepage）和我的（person）。根据用户实际需求仅修改代码中 tabContentBuilder 调用，当前仅支持删除
 * tab 项，以及修改 Constants.TAB_INDEX 常量值，从 0 开始并保证顺序。根据用户需求删除多余的 import 依赖，仅从 homepage、person 依赖中删
 * 除，common 依赖需保留。
 * @isGen: true
 * @fileType: tab
 * @zhName: Tab 页面控制器
 */

@Builder
function bookList() {
  Column() {
    Text('书城页面')
  }
  .backgroundColor($r('sys.color.background_primary'))
}

@Builder
function person() {
  MinePage()
}

@Builder
function bookshelf() {
  MainPage()
}

@Builder
function bookSort() {
  Column({ space: 20 }) {
    Text('分类页面')
  }
  .backgroundColor($r('sys.color.background_primary'))
}

const bookshelfBuilder: WrappedBuilder<[string]> = wrapBuilder(bookshelf);
const bookListBuilder: WrappedBuilder<[string]> = wrapBuilder(bookList);
const personBuilder: WrappedBuilder<[string]> = wrapBuilder(person);
const bookSortBuilder: WrappedBuilder<[string]> = wrapBuilder(bookSort);

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
        .margin({ top: 4 })
        .fontSize(10)
        .fontColor(this.currentIndexTab === index ? $r('app.color.font_overdue') : '#E6000000')
    }
    .justifyContent(FlexAlign.Center)
    .height(52)
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
    .backgroundColor(Color.White)
    .tabBar(this.tabBuilder(text, index, selectedImg, normalImg))
  }

  build() {
    NavDestination() {
      Tabs({
        barPosition: BarPosition.End,
        controller: this.tabsController
      }) {
        this.tabContentBuilder($r('app.string.main_page'),
          Constants.TAB_INDEX_ZERO, $r('app.media.home_page_active'), $r('app.media.ic_home_inactive'), bookshelfBuilder)

        this.tabContentBuilder($r('app.string.person'),
          Constants.TAB_INDEX_ONE, $r('app.media.ic_mine_selected'), $r('app.media.ic_mine_unselected'), personBuilder)
      }
      .clip(true)
      .width('100%')
      .backgroundColor('#F3F4F5')
      .barHeight(50)
      .barMode(BarMode.Fixed)
      .animationDuration(0)
      .scrollable(false)
      .onAnimationStart((targetIndex: number) => {
        this.currentIndexTab = targetIndex;
      })
      .padding({
        bottom: BarVM.instance.aiBarH
      })
    }
    .hideTitleBar(true)
  }
}
