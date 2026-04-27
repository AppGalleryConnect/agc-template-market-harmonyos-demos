/**
 * @usage: Tab页面控制类,包括音频编辑、作品列表、我的三个Tab页面。
 * 用户可以在底部Tab栏切换不同的功能模块,支持音频编辑首页、作品管理和个人中心。
 * @layout: 页面采用NavDestination包裹Tabs组件,底部为TabBar导航栏,包含三个Tab项。
 * 每个Tab项包含图标和文字,点击切换对应的页面内容。根据当前Tab索引动态调整状态栏颜色。
 * @constraints: Tab页面控制类,包括音频编辑(audio_edit_home)、作品列表(audio_work_list)、我的(person)。
 * 根据用户实际需求仅修改代码中的Tab配置,当前支持调整Tab顺序、修改Tab标题和图标资源。
 * 根据用户需求删除多余的import依赖,仅从audio_edit_home、audio_work_list、person依赖中删除。
 * 作品编辑完成后通过ChangeTabUtilContr.isBackHome标志自动切换到作品列表Tab页。
 * @modifiable: 可修改Tab数量、Tab顺序、Tab标题和图标资源。
 * 可调整状态栏颜色切换逻辑、Tab切换动画效果。可定制TabBar高度和样式。
 * @domain: 音频编辑
 * @zhName: 首页Tab控制器
 * @fileType: tab
 * @isGen: true
 */
import { AutioEditPage } from 'audio_edit_home';
import { WorkListPage } from 'audio_work_list';
import { BarVM, ChangeTabUtilContr, Constants } from 'common';
import { MinePage } from 'person';
import { window } from '@kit.ArkUI';

@Builder
function bookList() {
  Column() {
    WorkListPage()
  }
  .backgroundColor($r('sys.color.background_primary'))
}

@Builder
function person() {
  MinePage()
}

@Builder
function bookshelf() {
  Column() {
    AutioEditPage()
  }
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
  windowStage: window.WindowStage = AppStorage.get('windowStage') as window.WindowStage;
  mainWin: window.Window = this.windowStage?.getMainWindowSync();
  @Builder
  tabBuilder(title: Resource, index: number, selectedImg: Resource, normalImg: Resource, unselected: Resource) {
    Column() {
      Column() {
        Image(this.currentIndexTab === index ? selectedImg : this.currentIndexTab === 2 ? unselected : normalImg)
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain)
        Text(title)
          .margin({ top: 4 })
          .fontSize(10)
          .fontColor(this.currentIndexTab === 2 ? 'rgba(0, 0, 0, 0.85)' : '#89FFFFFF')
      }
      .justifyContent(FlexAlign.Center)
      .height(52)
      .width('100%')
      .onClick(() => {
        this.currentIndexTab = index;
        this.tabsController.changeIndex(this.currentIndexTab);
        if (index < 2) {
          let sysBarProps: window.SystemBarProperties = {
            statusBarContentColor: '#ffffff'
          };
          this.mainWin?.setWindowSystemBarProperties(sysBarProps)
        } else {
          let sysBarProps: window.SystemBarProperties = {
            statusBarContentColor: '#000000'
          };
          this.mainWin?.setWindowSystemBarProperties(sysBarProps)
        }
      })
    }.padding({ bottom: BarVM.instance.aiBarH })
    .backgroundColor(this.currentIndexTab === 2 ? '#FFFFFF' : 'rgba(255,255,255,0.1)')

  }

  @Builder
  tabContentBuilder(text: Resource,
    index: number,
    selectedImg: Resource,
    normalImg: Resource,
    unselected: Resource,
    builder: WrappedBuilder<[string]>) {
    TabContent() {
      Stack() {
        builder.builder('');
      }
      .height('100%')

    }
    .tabBar(this.tabBuilder(text, index, selectedImg, normalImg, unselected))
  }
  build() {
    NavDestination() {
      Tabs({
        index:this.currentIndexTab,
        barPosition: BarPosition.End,
        controller: this.tabsController
      }) {
        this.tabContentBuilder($r('app.string.bookshelf'),
          Constants.TAB_INDEX_ZERO, $r('app.media.shelf_tab_active'), $r('app.media.shelf_tab'),
          $r('app.media.shelf_tab_black'), bookshelfBuilder)
        this.tabContentBuilder($r('app.string.book_case'),
          Constants.TAB_INDEX_ONE, $r('app.media.mall_tab_active'), $r('app.media.mall_tab'),
          $r('app.media.mall_tab_black'),
          bookListBuilder)
        this.tabContentBuilder($r('app.string.person'),
          Constants.TAB_INDEX_TWO, $r('app.media.person_tab_active'), $r('app.media.person_tab'),
          $r('app.media.person_tab'), personBuilder)
      }
      .clip(true)
      .width('100%')
      .barHeight(50 + BarVM.instance.aiBarH)
      .barMode(BarMode.Fixed)
      .animationDuration(0)
      .scrollable(false)
      .onAnimationStart((targetIndex: number) => {
        this.currentIndexTab = targetIndex;
      })
    }
    .onVisibleAreaChange([0, 1], (isExpanding, currentRatio) => {
      if (isExpanding && currentRatio > 0) {
        if(ChangeTabUtilContr.isBackHome){
          setTimeout(()=>{
            this.tabsController.changeIndex(1)
            this.currentIndexTab = 1;
          })
          ChangeTabUtilContr.isBackHome=false
        }

      }
    })
    .hideTitleBar(true)
    .backgroundColor('#0A0D1E')
    .onWillAppear(()=>{
      let sysBarProps: window.SystemBarProperties = {
        statusBarContentColor: '#ffffff'
      };
      this.mainWin?.setWindowSystemBarProperties(sysBarProps)
    })
  }
}
