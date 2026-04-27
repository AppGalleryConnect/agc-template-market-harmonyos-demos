import { MySharePageViewModel } from '../viewmodel/MySharePageViewModel';
import { ShareListView } from '../components/ShareListView';
import { CommonModifier } from '@kit.ArkUI';

@Builder
export function MySharePageBuilder(param: Object) {
  MySharePage({vm: param as MySharePageViewModel})
}

/**
 * @usage: 用于展示我的分享页面。提供用户分享文件的管理功能，支持按分享状态筛选查看（全部分享、分享中、分享过期）。
 * 关键数据结构包括MySharePageViewModel（我的分享视图模型，包含fileTypeIndex当前选中索引、fileTypeTitles分类标题数组）、
 * TabsController（标签页控制器）、CommonModifier（通用修饰器，用于设置tabBar样式）。
 * 页面通过Tabs组件实现分类切换，每个TabContent包含ShareListView组件展示对应状态的分享文件列表。
 * @layout: 页面采用Column垂直布局。
 * 主体是Tabs标签页组件包含3个TabContent（全部分享、分享中、分享过期），
 * 每个TabContent内部是ShareListView组件。TabBar采用自定义tabBuilder。
 * @constraints: 分享文件分类标题数组fileTypeTitles固定为3个（全部分享、分享中、分享过期）不可修改；
 * @isGen: true
 * @fileType: page
 * @zhName: 我的分享页面
 * @component: ShareListView
 * @image: screenshots/sharelist.jpg
 */

@ComponentV2
struct MySharePage {
  private navPathStack: NavPathStack = new NavPathStack();
  controller: TabsController = new TabsController();
  @Require @Param vm : MySharePageViewModel
  @Local tabBarModifier: CommonModifier = new CommonModifier();

  aboutToAppear() {
    this.tabBarModifier.margin({ left: 24 }).align(Alignment.Start);
  }

  build() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
    .mode(NavDestinationMode.STANDARD)
    .padding(this.vm.contentPadding)
    .onReady((ctx: NavDestinationContext) => {
      this.navPathStack = ctx.pathStack
    })
  }

  @Builder
  render() {
    Column() {
      this.buildHeader()

      this.content()
    }
  }

  @Builder
  buildHeader() {
    Row() {
      Image($r('app.media.share_back'))
        .width(40)
        .height(40)
        .onClick(() => {
          this.vm.tabListVM[this.vm.fileTypeIndex].selectedIndexes.clear()
          this.navPathStack.pop()
        })

      Text('我的分享')
        .margin({left: 8, right: 8})
        .layoutWeight(1)
        .fontSize(20)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .height(58)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .backgroundColor($r('sys.color.comp_background_primary_contrary'))
  }

  @Builder
  content() {
    // 文件筛选类型列表
    Tabs({
      barPosition: BarPosition.Start,
      controller: this.controller,
      index: this.vm.fileTypeIndex,
      barModifier: this.tabBarModifier
    }) {
      TabContent() {
        Column() {
          ShareListView({ fileListSelectViewVM: this.vm.tabListVM[0], currentIndex: 0 , vm: this.vm})
        }.width('100%').alignItems(HorizontalAlign.Start).layoutWeight(1)
        .margin({ top: 10 })
      }.tabBar(this.tabBuilder(this.vm.fileTypeTitles[0], 0))
      TabContent() {
        Column() {
          ShareListView({ fileListSelectViewVM: this.vm.tabListVM[1], currentIndex: 1 ,  vm: this.vm})
        }.width('100%').alignItems(HorizontalAlign.Start).layoutWeight(1)
        .margin({ top: 10 })
      }.tabBar(this.tabBuilder(this.vm.fileTypeTitles[1], 1))
      TabContent() {
        Column() {
          ShareListView({ fileListSelectViewVM: this.vm.tabListVM[2], currentIndex: 2 ,  vm: this.vm})
        }.width('100%').alignItems(HorizontalAlign.Start).layoutWeight(1)
        .margin({ top: 10 })
      }.tabBar(this.tabBuilder(this.vm.fileTypeTitles[2], 2))
    }
    .barMode(BarMode.Scrollable)
    .backgroundColor($r('sys.color.comp_background_primary_contrary'))
    .layoutWeight(1)
    .barHeight(40)
    .onChange((index: number) => {
      this.vm.isShowList[this.vm.fileTypeIndex] = false
      this.vm.tabListVM[this.vm.fileTypeIndex].selectedIndexes.clear()
      this.vm.fileTypeIndex = index;
    })

  }

  @Builder
  tabBuilder(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize(14)
        .fontColor($r('sys.color.black'))
        .fontWeight(this.vm.fileTypeIndex === index ? 500 : 400)
        .opacity(this.vm.fileTypeIndex === index ? 1 : 0.4)
      Divider()
        .width(12)
        .margin({ top: 7 })
        .strokeWidth(2)
        .color($r('sys.color.comp_background_emphasize'))
        .opacity(this.vm.fileTypeIndex === index ? 1 : 0)
    }
    .padding({ right: 32 })
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      if (this.vm.fileTypeIndex === index) {
        return
      }
      this.vm.isShowList[this.vm.fileTypeIndex] = false
      this.vm.tabListVM[this.vm.fileTypeIndex].selectedIndexes.clear()
      this.vm.fileTypeIndex = index;
    })
  }
}
