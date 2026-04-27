import { FileBaseSelectListView } from 'cloud_file_base'
import { OperationItemView } from 'cloud_operation_item'
import { FileViewSwitchViewModel } from '../viewmodel/FileViewSwitchViewModel'

const SORT_TAG: string = '排序'
const FILTER_TAG: string = '筛选'

/**
 * @usage: 视图切换组件：提供列表/网格视图切换、类型筛选与排序入口。
 * @layout: 工具条（排序/筛选/视图切换）+ 类型筛选水平列表 + 文件选择列表视图 + 底部操作栏（绑定Sheet弹出）。
 * @constraints: 筛选栏、分类栏、排序列表等不可修改
 * @isGen false
 * @fileType: component
 * @domain: 云存储
 * @zhName: 云盘视图切换组件
 * @subPage:
 * @component: FileBaseSelectListView,OperationItemView
 * @image: screenshots/view_switch.jpg
 */
@ComponentV2
export struct FileViewSwitchView {
  @Require @Param vm: FileViewSwitchViewModel

  aboutToAppear(): void {
    this.vm.initializationResponses()
  }

  @Builder
  bottomOperationBar() {
    OperationItemView({ vm: this.vm.operationVM })
  }

  @Builder
  sortPopupBox() {
    Column() {
      ForEach(this.vm.sortList, (item: string, index: number) => {
        Text(item + SORT_TAG)
          .fontSize(14)
          .onClick(() => {
            this.vm.sortFileList(index)
            this.vm.isSortDialogVisible = false
          })
          .fontColor((this.vm.currentSortIndex === index) ? '#2FAFFF' : '#000000')
          .padding({ top: 12, bottom: 12 })
      }, (item: string, idx: number) => JSON.stringify(item) + idx)
    }
    .padding({
      left: 16,
      right: 16,
      top: 12,
      bottom: 12
    })
    .width(180)
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Column() {
      Row() {
        Row() {
          Text(this.vm.sortList[this.vm.currentSortIndex] + SORT_TAG)
            .fontColor('#999EA2')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)

          Image($r('app.media.view_switch_sort_icon'))
            .width(16)
            .height(16)
            .objectFit(ImageFit.Contain)
            .margin({ left: 2 })
        }
        .onClick(() => {
          this.vm.isSortDialogVisible = true
        })
        .bindPopup(this.vm.isSortDialogVisible, {
          enableArrow: false,
          radius: $r('sys.float.corner_radius_level10'),
          offset: { x: 10 },
          builder: this.sortPopupBox,
          onStateChange: (e) => {
            if (!e.isVisible) {
              this.vm.isSortDialogVisible = false
            }
          },
          placement: Placement.Bottom,
          popupColor: Color.White
        })

        Blank()

        // 筛选方式
        Row() {
          Text(FILTER_TAG)
            .fontColor(this.vm.isFilterSelected ? '#444444' : '#999EA2')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)

          Image(this.vm.isFilterSelected ? $r('app.media.view_switch_filter_selected') :
            $r('app.media.view_switch_filter_unselected'))
            .width(16)
            .height(16)
            .objectFit(ImageFit.Contain)
            .margin({ left: 2 })
        }
        .onClick(() => {
          this.vm.isFilterSelected = !this.vm.isFilterSelected
        })

        // 列表样式
        Image(this.vm.isListVisibleGridMode ? $r('app.media.view_switch_list_icon') :
          $r('app.media.view_switch_grid_icon'))
          .margin({ left: 14 })
          .onClick(() => {
            this.vm.isListVisibleGridMode = !this.vm.isListVisibleGridMode
          })
          .objectFit(ImageFit.Contain)
          .width(16)
          .height(16)
      }
      .height(40)
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .padding({ right: 16, left: 16 })

      List({ space: 8 }) {
        ForEach(this.vm.fileTypeTitles, (item: string, index: number) => {
          ListItem() {
            Column() {
              Text(item)
                .fontColor((this.vm.fileTypeIndex === index) ? '#2FAFFF' : '#9DA3AA')
                .fontSize(12)
            }
            .height(22)
            .width(48)
            .borderRadius(8)
            .backgroundColor('#F0F9FF')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {
              if (this.vm.fileTypeIndex === index) {
                return
              }
              this.vm.filterListBySelectedType(index)
            })
          }
        }, (item: string, idx: number) => JSON.stringify(item) + idx)
      }
      .height(38)
      .width('100%')
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .padding({
        left: 16,
        top: 8,
        right: 16,
        bottom: 8
      })
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .visibility(this.vm.isFilterSelected ? Visibility.Visible : Visibility.None)

      FileBaseSelectListView({ vm: this.vm, selectRowBgColor: '#F1F3F5' })
        .layoutWeight(1)
        .width('100%')
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .height('100%')
    .width('100%')
    .bindSheet($$this.vm.isShow, this.bottomOperationBar(),
      {
        showClose: false,
        radius: { topLeft: 0, topRight: 0 },
        height: 40 + 48 * 2,
        enableOutsideInteractive: true,
        preferType: SheetType.BOTTOM,
        maskColor: Color.Transparent
      })
  }
}
