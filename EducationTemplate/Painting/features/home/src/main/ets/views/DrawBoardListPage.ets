import { PersistenceV2 } from '@kit.ArkUI';
import { OHPage, phoneRouterControl } from 'oh_router';
import { DrawingHistoryItem, DrawingHistoryList } from '../viewmodel/DrawingHistoryVM';
import { Constants } from 'common';
import { baseToast } from '../comp/ConfirmDialog';
import { DrawingItem } from '../comp/DrawingItem';
import { DrawingListVM } from '../viewmodel/DrawingListVM';

@Builder
export function DrawBoardListPageBuilder() {
  DrawBoardListPage()
}

/**
 * @usage: 我的画本列表页面，展示和管理用户保存的所有画作，支持管理模式（多选删除）和左滑删除，列表为空时显示空状态提示。
 * @layout: 页面采用垂直布局（Column），顶部为标题栏（Row，左侧返回按钮，中间标题和管理按钮横向排列），
 * 中间为画作列表（List 垂直排列）或空状态提示（Column 居中显示），管理模式下底部为操作按钮行（Row，全选和删除按钮各占一半宽度）。
 * @constraints: drawingHistoryList 数据结构不可修改，使用 PersistenceV2 持久化存储。DrawingHistoryItem 类型定义不可更改。
 * 管理模式的 selectedIds 数组用于记录选中项，不可删除。空状态判断逻辑（drawingList.length === 0）不可修改。
 * @isGen: true
 * @fileType: page
 * @zhName: 我的画本列表页面
 * @domain: 绘画
 * @subPage: DrawingBoardPage
 * @image: screenshots/home/drawinglist.jpg
 * @component: DrawingItem
 */
@ComponentV2
struct DrawBoardListPage {
  @Local drawingHistoryList: DrawingHistoryList =
    PersistenceV2.connect(DrawingHistoryList, 'drawingHistoryList', () => new DrawingHistoryList())!;
  drawingListVM: DrawingListVM = new DrawingListVM()

  @Builder
  Header() {
    Row() {
      Image($r('app.media.ic_back'))
        .width(40)
        .height(40)
        .onClick(() => {
          phoneRouterControl.popPage()
        })
      Row() {
        Text($r('app.string.my_sketchbook'))
          .fontColor(Color.Black)
          .textAlign(TextAlign.Start)
          .layoutWeight(1)
          .fontSize($r('sys.float.Title_S'))
        Text(this.drawingListVM.mangerMode ? $r('app.string.cancel_management') : $r('app.string.management'))
          .fontColor(Color.Black)
          .textAlign(TextAlign.End)
          .layoutWeight(1)
          .fontSize($r('sys.float.Body_L'))
          .onClick(() => {
            this.drawingListVM.mangerMode = !this.drawingListVM.mangerMode
          })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceAround)
      .margin({ left: 8 })
    }
    .width(Constants.FULL_SIZE)
    .height(56)
    .alignItems(VerticalAlign.Center)
    .padding({ top: 8, bottom: 8 })

  }

  @Builder
  render() {
    Column() {
      this.Header()
      if (this.drawingHistoryList.drawingList.length === 0) {
        Column() {
          Column() {
            Image($r('app.media.empty_Item'))
              .width(160)
              .height(160)
              .objectFit(ImageFit.Cover)
            Text('暂无画本')
              .fontSize($r('sys.float.Body_S'))
              .fontColor('#99000000')
          }

        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .width(Constants.FULL_SIZE)
      } else {
        List({ scroller: this.drawingListVM.scroller }) {
          ForEach(this.drawingHistoryList.drawingList, (drawing: DrawingHistoryItem, index: number) => {
            DrawingItem({
              drawing: drawing,
              mangerMode: this.drawingListVM.mangerMode,
              idLists: this.drawingListVM.selectedIds,
              deleteItem: (id: string) => {
                this.drawingHistoryList.deleteItemById(id)
              },
              editItem: (id: string) => {
                this.drawingListVM.toggleSelection(id)
              }
            })
          }, (drawing: DrawingHistoryItem) => drawing.id)
        }
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        .width(Constants.FULL_SIZE)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .friction(0.6)

        if (this.drawingListVM.mangerMode) {
          Row() {
            this.mangerBuilder($r('app.media.icon_all_selected'), $r('app.string.all_selected'), () => {
              if (this.drawingListVM.getSelectedCount() < this.drawingHistoryList.getCount()) {
                const ids: string[] =
                  this.drawingHistoryList.drawingList.map((drawing: DrawingHistoryItem) => drawing.id)
                this.drawingListVM.selectAll(ids)
              } else {
                this.drawingListVM.clearSelection()
              }
            })
            this.mangerBuilder($r('app.media.icon_delete'), $r('app.string.delete'), () => {
              const isAll: boolean = this.drawingListVM.getSelectedCount() < this.drawingHistoryList.getCount()
              baseToast.show({
                type: 'dialog',
                cancelColor: $r('sys.color.icon_secondary'),
                confirmColor: $r('app.color.theme_color'),
                message: isAll ? $r('app.string.confirm_delete_picture_book') :
                $r('app.string.confirm_delete_all_picture_books'),
                confirmAction: () => {
                  this.drawingHistoryList.deleteMultipleItemsById(this.drawingListVM.selectedIds)
                  baseToast.hide()
                },
              });
            })
          }
          .height(48)
          .width(Constants.FULL_SIZE)
          .padding({ left: 8, right: 8 })
        }
      }
    }
    .padding({ left: 16, right: 16 })
    .height(Constants.FULL_SIZE)
    .backgroundColor('#CCF1F3F5')
  }

  @Builder
  mangerBuilder(image: ResourceStr, name: ResourceStr, click: () => void) {
    Column() {
      Image(image)
        .width(24)
        .height(24)
        .margin({ bottom: 6 });
      Text(name)
        .width(Constants.FULL_SIZE)
        .textAlign(TextAlign.Center)
        .fontSize($r('sys.float.Caption_M'))
    }
    .height(40)
    .width(Constants.HALF_SIZE)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      click()
    })
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render()
      },
      useSafePadding: false
    })
  }
}

