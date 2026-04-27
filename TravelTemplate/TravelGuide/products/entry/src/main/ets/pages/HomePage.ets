/**
 * @usage: tab页面控制器，包括首页、行程、消息、个人中心四个tab页签
 * @layout: 页面整体采用Tabs布局，底部为TabBar，上方为TabContent内容区域
 * @constraints: tab页面控制类包括首页（homepage）、行程（journey）、消息（message）、个人中心（person）。
 * 根据用户实际需求仅修改代码中tabContentBuilder调用，当前仅支持删除tab页签以及修改tab顺序。Constants.TAB_INDEX_ZERO到
 * TAB_INDEX_THREE分别对应四个tab页签索引
 * @isGen: true
 * @fileType: tab
 * @zhName: 主页Tab控制器
 * @domain: 旅游
 */
import { PersistenceV2 } from '@kit.ArkUI';
import { BarVM, Constants, RouterMap, UserInfo } from 'common';
import { MessagePageBuilder } from 'message';
import { MinePage } from 'person';
import { MainPage } from 'homepage';
import { MyJourneyPageBuilder } from 'journey';
import { phoneRouterControl } from 'oh_router';
import { LoginPageBuilder } from 'person/src/main/ets/views/LoginPage';

@Builder
function bookList() {
  MyJourneyPageBuilder()
}

@Builder
function person() {
  MinePage()
}

@Builder
function mainPage() {
  MainPage()
}

@Builder
function bookSort() {
  MessagePageBuilder()
}

const mainPageBuilder: WrappedBuilder<[string]> = wrapBuilder(mainPage);
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
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
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
        .fontColor(this.currentIndexTab === index ? $r('app.color.font_overdue') : '#9DA3AA')
    }
    .justifyContent(FlexAlign.Center)
    .height(52)
    .width('100%')
    .onClick(() => {
      if(index === Constants.TAB_INDEX_ONE && !this.userInfo?.isLogin){
        phoneRouterControl.jumpPage({
          pageName: RouterMap.LOGIN_PAGE,
          builder: wrapBuilder(LoginPageBuilder)
        })
        return
      }
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
        this.tabContentBuilder($r('app.string.bookshelf'),
          Constants.TAB_INDEX_ZERO, $r('app.media.shelf_tab_active'), $r('app.media.shelf_tab'), mainPageBuilder)
        this.tabContentBuilder($r('app.string.book_case'),
          Constants.TAB_INDEX_ONE, $r('app.media.mall_tab_active'), $r('app.media.mall_tab'), bookListBuilder)
        this.tabContentBuilder($r('app.string.book_sort'),
          Constants.TAB_INDEX_TWO, $r('app.media.sort_tab_active'), $r('app.media.sort_tab'), bookSortBuilder)
        this.tabContentBuilder($r('app.string.person'),
          Constants.TAB_INDEX_THREE, $r('app.media.person_tab_active'), $r('app.media.person_tab'), personBuilder)
      }
      .clip(true)
      .width('100%')
      .backgroundColor('#F3F4F5')
      .padding({ bottom: BarVM.instance.aiBarH })
      .barHeight(50)
      .barMode(BarMode.Fixed)
      .animationDuration(0)
      .scrollable(false)
      .onAnimationStart((targetIndex: number) => {
        if(targetIndex === Constants.TAB_INDEX_ONE && !this.userInfo?.isLogin){
          return
        }
        this.currentIndexTab = targetIndex;
      })
    }
    .hideTitleBar(true)
  }
}
