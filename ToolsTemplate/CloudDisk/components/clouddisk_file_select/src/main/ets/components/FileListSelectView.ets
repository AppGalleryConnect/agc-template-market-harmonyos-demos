import { FileListSelectViewVM } from '../viewmodel/FileListSelectViewVM';
import { BarVM, FileInfo, FileType } from 'common';
import { PrivateSpaceCell } from './PrivateSpaceCell';
import { FileInfoCell } from './FileInfoCell';
import { FileInfoGridItem } from './FileInfoGridItem';


/**
 * @usage: 用于文件列表选择和管理场景。提供文件选择、全选、取消全选、列表/宫格视图切换功能。
 * 关键数据结构：FileListSelectViewVM（视图模型，包含fileList文件列表、selectedIndexes选中索引集合、
 * isListVisibleGridMode是否宫格模式布尔值、checkIsAllSelected全选判断方法、switchAllSelected切换全选方法、
 * didClickAtIndexAction点击回调、didSelectedAtIndexAction选择回调）、FileInfo（文件信息）、
 * FileType（文件类型枚举，包含PrivateSpace隐私空间类型）。包含if逻辑：根据isListVisibleGridMode判断显示列表或宫格，
 * 根据fileType判断使用不同的模板（隐私空间使用PrivateSpaceCell，普通文件使用FileInfoCell或FileInfoGridItem）。
 * @layout: 垂直布局。顶部为选择栏（左侧显示已选文件数量，右侧显示全选/取消全选按钮，横向排列），
 * 下方为文件列表（列表模式为单列，宫格模式为3列）。列表支持滚动和弹性边缘效果。
 * @constraints: vm.fileList文件列表不能为空，vm.selectedIndexes选中索引集合必须正确维护，
 * vm.didClickAtIndexAction和vm.didSelectedAtIndexAction回调函数必须正确处理点击和选择操作
 * @isGen: true
 * @fileType: component
 * @domain: 云存储
 * @zhName: 文件列表选择视图组件
 * @subPage:
 * @component: PrivateSpaceCell,FileInfoCell,FileInfoGridItem
 * @image: screenshot/screenshot01.jpg,screenshot/screenshot02.jpg
 */
@ComponentV2
export struct FileListSelectView {
  @Require @Param vm: FileListSelectViewVM
  @Param selectRowBgColor: ResourceColor = Color.White

  @Computed
  get checkAllSelected() {
    return this.vm.checkIsAllSelected()
  }

  @Computed
  get checkSelectedCount() {
    return this.vm.selectedIndexes.size
  }

  @Computed
  get checkGridColumns() {
    return this.vm.checkGridColumns()
  }

  build() {
    Column() { // 文件筛选类型列表
      // 选择栏
      Row() {
        Text($r('app.string.selected_file_number', this.checkSelectedCount.toString()))
          .fontSize(12)
          .fontColor('#999EA2')

        Text(this.checkAllSelected ? $r('app.string.cancel_allselected') : $r('app.string.allselected'))
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2FAFFF')
          .onClick(() => {
            this.vm.switchAllSelected()
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .padding({ left: 16, right: 16 })
      .backgroundColor(this.selectRowBgColor)
      .width('100%')
      .height(31)

      // 文件列表
      List() {
        Repeat(this.vm.fileList)
          .each((subFile: RepeatItem<FileInfo>) => {
            // 隐私空间模板
            ListItem() {
              PrivateSpaceCell({ fileInfo: subFile.item })
            }
            .onClick(() => {
              this.vm.didClickAtIndexAction(subFile.index)
            })
          })
          .key((subFile: FileInfo): string => JSON.stringify(subFile) + this.vm.isListVisibleGridMode ? 'grid' : 'list')
          .virtualScroll({ totalCount: this.vm.fileList.length })
          .templateId((item: FileInfo): string => {
            if (this.vm.isListVisibleGridMode) {
              return 'girdTemeplate'
            }

            if (item.fileType !== FileType.PrivateSpace) {
              return 'directorTemplate'
            }

            return ''
          })
          .template('directorTemplate', (subFile: RepeatItem<FileInfo>) => {
            // 普通文件夹模板
            ListItem() {
              FileInfoCell({
                fileInfo: subFile.item,
                checkAction: () => {
                  this.didSelectItem(subFile)
                },
                isSelected: this.vm.selectedIndexes.has(subFile.index),
                vm: this.vm
              })
            }
            .onClick(() => {
              this.vm.didClickAtIndexAction(subFile.index)
            })
          })
          .template('girdTemeplate', (subFile: RepeatItem<FileInfo>) => {
            ListItem() {
              FileInfoGridItem({
                fileInfo: subFile.item, checkAction: () => {
                  this.didSelectItem(subFile)
                }, isSelected: this.vm.selectedIndexes.has(subFile.index)
              })
            }
            .onClick(() => {
              this.vm.didClickAtIndexAction(subFile.index)
            })
          })

      }
      .padding({ left: 16, right: 16, bottom: BarVM.instance.aiBarH })
      .cachedCount(2)
      .width('100%')
      .height('100%')
      .lanes(this.vm.isListVisibleGridMode ? this.checkGridColumns : 1)
      .alignListItem(ListItemAlign.Center)
      .backgroundColor($r('sys.color.background_primary'))
      .edgeEffect(EdgeEffect.Spring, {alwaysEnabled: true})
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST, // 向前滚动父组件优先
        scrollBackward: NestedScrollMode.PARENT_FIRST // 向后滚动父组件优先
      })
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
  }

  // 选中某一项
  private didSelectItem(item: RepeatItem<FileInfo>) {
    if (this.vm.selectedIndexes.has(item.index)) {
      this.vm.selectedIndexes.delete(item.index)
    } else {
      this.vm.selectedIndexes.add(item.index)
    }
    this.vm.didSelectedAtIndexAction(item.index)
  }
}
