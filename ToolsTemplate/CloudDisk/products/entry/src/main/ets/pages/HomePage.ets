/**
 * @usage: tab页面控制器，包括首页、备份、文件、我的四个主要功能模块
 * @layout: 页面采用底部Tab导航布局，包含四个Tab页签，每个Tab对应不同的功能模块
 * @constraints: tab页面控制类，包括首页（clouddisk_homepage）、备份（clouddisk_backup）、文件（clouddisk_file）、我的（person）。
 * 根据用户实际需求仅修改代码中tabContentBuilder调用的参数，当前仅支持删除变量中的元素，以及修改index，从0开始并保证index顺序，
 * 其他元素不允许修改。根据用户需求删除多余的import依赖，仅从clouddisk_homepage、clouddisk_backup、clouddisk_file、
 * person依赖中删除，Constants依赖需保留
 * @isGen: true
 * @fileType: tab
 * @zhName: 主页面Tab控制器
 * @component: MainPage,Backup,FileManagerPage,MinePage
 */
import { FileManagerPage } from 'clouddisk_file';
import { BarVM, Constants, RouterMap, UserInfo } from 'common';
import { MainPage } from 'clouddisk_homepage';
import { MinePage } from 'person';
import { Backup } from 'clouddisk_backup';
import { PersistenceV2 } from '@kit.ArkUI';
import { phoneRouterControl } from 'oh_router';

@Builder
function backup() {
  Backup()
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
function fileManager() {
  FileManagerPage()
    .backgroundColor($r('sys.color.background_primary'))
}

const mainPageBuilder: WrappedBuilder<[string]> = wrapBuilder(mainPage);
const backupBuilder: WrappedBuilder<[string]> = wrapBuilder(backup);
const personBuilder: WrappedBuilder<[string]> = wrapBuilder(person);
const fileManagertBuilder: WrappedBuilder<[string]> = wrapBuilder(fileManager);

@Builder
export function HomePageBuilder() {
  HomePage()
}

@ComponentV2
export struct HomePage {
  @Provider('currentIndexTab') currentIndexTab: number = 0;
  @Provider('tabController') tabsController: TabsController = new TabsController();
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

  aboutToAppear(): void {
    this.currentIndexTab = this.userInfo.isLogin ? 0 : 3
  }

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
        .fontColor(this.currentIndexTab === index ? '#444444' : '#9DA3AA')
    }
    .justifyContent(FlexAlign.Center)
    .height(52)
    .width('100%')
    .onClick(() => {
      if (!this.userInfo.isLogin) {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.LOGIN_PAGE,
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
        controller: this.tabsController,
        index: this.currentIndexTab
      }) {
        this.tabContentBuilder($r('app.string.home'),
          Constants.TAB_INDEX_ZERO, $r('app.media.home_tab_active'), $r('app.media.home_tab'), mainPageBuilder)
        this.tabContentBuilder($r('app.string.backup'),
          Constants.TAB_INDEX_ONE, $r('app.media.backup_tab_active'), $r('app.media.backup_tab'), backupBuilder)
        this.tabContentBuilder($r('app.string.file'),
          Constants.TAB_INDEX_TWO, $r('app.media.file_tab_active'), $r('app.media.file_tab'), fileManagertBuilder)
        this.tabContentBuilder($r('app.string.mine'),
          Constants.TAB_INDEX_THREE, $r('app.media.mine_tab_active'), $r('app.media.mine_tab'), personBuilder)
      }
      .clip(true)
      .width('100%')
      .backgroundColor('#F3F4F5')
      .barHeight(50)
      .barMode(BarMode.Fixed)
      .padding({ bottom: BarVM.instance.aiBarH })
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