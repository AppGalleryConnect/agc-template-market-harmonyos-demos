import { FileBaseCheckViewModel } from '../viewmodel/FileBaseCheckViewModel';
import { FileBaseInfo, FileBaseType } from '../model/FileBaseInfo';
import { FileBasePrivateSpaceCell } from './FileBasePrivateSpaceCell';
import { FileBaseCheckCell } from './FileBaseCheckCell';
import { FileBaseGridItem } from './FileBaseGridItem';


/**
 * @usage: 文件选择列表视图：支持单选/全选、列表/网格展示、隐私空间特殊展示。
 * @layout: 顶部状态行 + 主体可虚拟滚动的文件列表（List/Grid 动态切换），占满父容器。
 * @constraints: 选中数量、全选反选栏固定显示
 * @isGen: false
 * @fileType: component
 * @domain: 云存储
 * @zhName: 云盘文件基础组件-选择列表视图
 * @subPage:
 * @component: FileBasePrivateSpaceCell,FileBaseCheckCell,FileBaseGridItem
 */
@ComponentV2
export struct FileBaseSelectListView {
  @Require @Param vm: FileBaseCheckViewModel
  @Param selectRowBgColor: ResourceColor = Color.White

  // 是否全选
  @Computed
  get checkAllSelected() {
    return this.vm.checkIsAllSelected()
  }

  // 选中数量
  @Computed
  get checkSelectedCount() {
    return this.vm.selectedIndexes.size
  }

  // 网格列数
  @Computed
  get checkGridColumns() {
    return this.vm.checkGridColumns()
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.base_selected_file_number', this.checkSelectedCount.toString()))
          .fontSize(12)
          .fontColor('#999EA2')

        Text(this.checkAllSelected ? $r('app.string.base_cancel_allselected') : $r('app.string.base_allselected'))
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
          .each((subFile: RepeatItem<FileBaseInfo>) => {
            // 隐私空间模板
            ListItem() {
              FileBasePrivateSpaceCell({ fileInfo: subFile.item })
            }
            .onClick(() => {
              this.vm.didClickAtIndexAction(subFile.index)
            })
          })
          .key((subFile: FileBaseInfo): string => JSON.stringify(subFile) + this.vm.isListVisibleGridMode ? 'grid' :
            'list')
          .virtualScroll({ totalCount: this.vm.fileList.length })
          .templateId((item: FileBaseInfo): string => {
            if (this.vm.isListVisibleGridMode) {
              return 'girdTemeplate'
            }

            if (item.fileType !== FileBaseType.PRIVATESPACE) {
              return 'directorTemplate'
            }

            return ''
          })
          .template('directorTemplate', (subFile: RepeatItem<FileBaseInfo>) => {
            // 普通文件夹模板
            ListItem() {
              FileBaseCheckCell({
                fileInfo: subFile.item,
                vm: this.vm,
                isSelected: this.vm.selectedIndexes.has(subFile.index),
                checkAction: () => {
                  this.didSelectItem(subFile)
                },
                backupDateTime : ''
              })
            }
            .onClick(() => {
              this.vm.didClickAtIndexAction(subFile.index)
            })
          })
          .template('girdTemeplate', (subFile: RepeatItem<FileBaseInfo>) => {
            ListItem() {
              FileBaseGridItem({
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
      .padding({ left: 16, right: 16 })
      .width('100%')
      .height('100%')
      .alignListItem(ListItemAlign.Center)
      .backgroundColor($r('sys.color.background_primary'))
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .cachedCount(2)
      .lanes(this.vm.isListVisibleGridMode ? this.checkGridColumns : 1)
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
  }

  // 选中某一项
  private didSelectItem(item: RepeatItem<FileBaseInfo>) {
    if (this.vm.selectedIndexes.has(item.index)) {
      // 已存在，删除
      this.vm.selectedIndexes.delete(item.index)
    } else {
      // 不存在，添加
      this.vm.selectedIndexes.add(item.index)
    }
    this.vm.didSelectedAtIndexAction(item.index)
  }
}
