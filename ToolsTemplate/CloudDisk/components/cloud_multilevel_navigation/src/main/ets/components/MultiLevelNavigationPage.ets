import { FileBaseInfo, FileBaseSelectListView } from 'cloud_file_base';
import { OperationItemView } from 'cloud_operation_item';
import { MultiLevelNavigationPageViewModel } from '../viewmodel/MultiLevelNavigationPageViewModel';

const MULTILEVEL_SORT_TAG: string = '排序'
const MULTILEVEL_FILTER_TAG: string = '筛选'

/**
 * @usage: 多级目录导航页面：面包屑导航、类型筛选与排序，展示当前层级文件。
 * @layout: 顶部导航栏 + 面包屑 + 工具条（排序/筛选/视图切换）+ 文件列表 + 底部操作栏（绑定Sheet弹出）。
 * @constraints: 导航栏、筛选栏、分类栏、排序列表等不可修改
 * @isGen: false
 * @fileType: component
 * @domain: 云存储
 * @zhName: 云盘多级导航页面
 * @subPage:
 * @component: FileBaseSelectListView,OperationItemView
 * @image: screenshots/view_switch.jpg
 */
@ComponentV2
struct MultiLevelNavigationPage {
  private navPathStack: NavPathStack = new NavPathStack();
  @Require @Param vm: MultiLevelNavigationPageViewModel

  aboutToAppear(): void {
    this.vm.initializationResponses()
  }

  build() {
    NavDestination() {
      Column() {
        this.buildHeader()

        this.buildMultiLevelNav()

        this.buildSortTypes()

        this.buildFilterList()

        FileBaseSelectListView({ vm: this.vm, selectRowBgColor: '#F1F3F5' })
          .width('100%')
          .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .bindSheet($$this.vm.isShow, this.bottomOperationView(),
        {
          showClose: false,
          height: 40 + 48 * 2,
          enableOutsideInteractive: true,
          maskColor: Color.Transparent,
          radius: { topLeft: 0, topRight: 0 },
          preferType: SheetType.BOTTOM
        })
    }
    .hideTitleBar(true)
    .mode(NavDestinationMode.STANDARD)
    .padding(this.vm.contentPadding)
    .onReady((ctx: NavDestinationContext) => {
      this.navPathStack = ctx.pathStack
    })
  }

  @Builder
  buildHeader() {
    Row() {
      Image($r('app.media.multilevel_back'))
        .width(40)
        .height(40)
        .onClick(() => {
          this.navPathStack.pop()
        })

      Text('')
        .margin({ left: 8, right: 8 })
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
  }

  @Builder
  buildMultiLevelNav() {
    List() {
      ListItem() {
        Row() {
          Text($r('app.string.multilevel_myclouddisk'))
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .textAlign(TextAlign.Start)
            .margin({ right: 6 })
            .wordBreak(WordBreak.BREAK_ALL)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .constraintSize({ maxWidth: '30%' })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .onClick(() => {
              this.navPathStack.pop()
            })
          Image($r('app.media.multilevel_right_icon'))
            .objectFit(ImageFit.Cover)
            .width(14)
            .height(14)
        }.margin({ right: 5 })
      }

      ForEach(this.vm.levelDirectorList, (baseInfo: FileBaseInfo, index: number) => {
        ListItem() {
          Row() {
            Text(baseInfo.name)
              .fontColor(this.vm!.levelDirectorList.length - 1 === index ? '#4B5CC4' :
                $r('sys.color.font_primary'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(this.vm!.levelDirectorList.length - 1 === index ? FontWeight.Medium :
                FontWeight.Regular)
              .textAlign(TextAlign.Start)
              .margin({ right: 6 })
              .wordBreak(WordBreak.BREAK_ALL)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .constraintSize({ maxWidth: '30%' })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .onClick(() => {
                this.vm.changeToPrelevelDirector(index)
              })

            if (this.vm!.levelDirectorList.length - 1 !== index) {
              Image($r('app.media.multilevel_right_icon'))
                .objectFit(ImageFit.Cover)
                .width(14)
                .height(14)
            }
          }.margin({ right: 5 })
        }
      }, (item: FileBaseInfo, idx: number) => JSON.stringify(item) + idx);
    }
    .padding({ top: 12, left: 16, right: 16 })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
    .height(40)
    .width('100%')
  }

  @Builder
  buildSortTypes() {
    Row() {
      // 排序方式
      Row() {
        Text(this.vm.sortList[this.vm.sortIndex] + MULTILEVEL_SORT_TAG)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#999EA2')
        Image($r('app.media.multilevel_sort_icon'))
          .width(16)
          .height(16)
          .objectFit(ImageFit.Contain)
          .margin({ left: 2 })
      }
      .onClick(() => {
        this.vm.sortListIsVisible = true
      })
      .bindPopup(this.vm.sortListIsVisible, {
        builder: this.sortPopupBox,
        placement: Placement.Bottom,
        popupColor: Color.White,
        enableArrow: false,
        radius: $r('sys.float.corner_radius_level10'),
        offset: { x: 10 },
        onStateChange: (e) => {
          if (!e.isVisible) {
            this.vm.sortListIsVisible = false
          }
        }
      })

      Blank()

      // 筛选方式
      Row() {
        Text(MULTILEVEL_FILTER_TAG)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.vm.isFilterSelected ? '#444444' : '#999EA2')
        Image(this.vm.isFilterSelected ? $r('app.media.multilevel_filter_selected') :
          $r('app.media.multilevel_filter_unselected'))
          .width(16)
          .height(16)
          .objectFit(ImageFit.Contain)
          .margin({ left: 2 })
      }
      .onClick(() => {
        this.vm.isFilterSelected = !this.vm.isFilterSelected
      })

      // 列表样式
      Image(this.vm.isListVisibleGridMode ? $r('app.media.multilevel_list_icon') :
        $r('app.media.multilevel_grid_icon'))
        .width(16)
        .height(16)
        .objectFit(ImageFit.Contain)
        .margin({ left: 14 })
        .onClick(() => {
          this.vm.isListVisibleGridMode = !this.vm.isListVisibleGridMode
        })
    }
    .height(40)
    .width('100%')
    .padding({ left: 16, right: 16 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  buildFilterList() {
    // 文件筛选类型列表
    List({ space: 8 }) {
      ForEach(this.vm.filterTitles, (item: string, index: number) => {
        ListItem() {
          Column() {
            Text(item)
              .fontSize(12)
              .fontColor((this.vm.filterIndex === index) ? '#2FAFFF' : '#9DA3AA')
          }
          .width(48)
          .height(22)
          .borderRadius(8)
          .backgroundColor('#F0F9FF')
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            if (this.vm.filterIndex === index) {
              return
            }

            this.vm.filterListBySelectedType(index)
          })
        }
      }, (item: string, idx: number) => JSON.stringify(item) + idx)
    }
    .width('100%')
    .height(38)
    .padding({
      left: 16,
      right: 16,
      top: 8,
      bottom: 8
    })
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
    .visibility(this.vm.isFilterSelected ? Visibility.Visible : Visibility.None)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
  }

  @Builder
  bottomOperationView() {
    OperationItemView({ vm: this.vm.operationVM })
  }

  @Builder
  sortPopupBox() {
    Column() {
      ForEach(this.vm.sortList, (item: string, index: number) => {
        Text(item + MULTILEVEL_SORT_TAG)
          .fontSize(14)
          .fontColor((this.vm.sortIndex === index) ? '#2FAFFF' : '#000000')
          .padding({ top: 12, bottom: 12 })
          .onClick(() => {
            this.vm.sortFileList(index)
            this.vm.sortListIsVisible = false
          })
      }, (item: string, idx: number) => JSON.stringify(item) + idx)
    }
    .width(180)
    .alignItems(HorizontalAlign.Start)
    .padding({
      top: 12,
      bottom: 12,
      left: 16,
      right: 16
    })
  }
}

@Builder
export function MultiLevelNavigationPageBuilder(param: Object) {
  MultiLevelNavigationPage({ vm: param as MultiLevelNavigationPageViewModel })
}
