import { FileInfo, FileType } from 'common';
import { DirectorUnSelectCell, PrivateSpaceCell } from 'clouddisk_file_select';

/**
 * @usage: 用于移动文件时选择目标目录场景。提供目录列表展示，支持点击选择目标目录。
 * 关键数据结构：fileList（文件列表数组）、FileInfo（文件信息）、FileType（文件类型枚举，
 * 包含PrivateSpace隐私空间类型）、didSelectAction（选择回调函数，参数为选中的索引）。
 * 包含if逻辑：根据fileType判断使用不同的模板（隐私空间使用PrivateSpaceCell，
 * 普通目录使用DirectorUnSelectCell）。
 * @layout: 垂直列表布局。使用Repeat组件渲染文件列表，根据文件类型显示不同的单元格样式。
 * 列表支持虚拟滚动。
 * @constraints: fileList文件列表不能为空，didSelectAction回调函数必须正确处理选择操作，
 * 列表中只能包含目录类型和隐私空间类型的文件
 * @isGen: true
 * @fileType: component
 * @zhName: 移动目录列表视图组件
 * @component: DirectorUnSelectCell,PrivateSpaceCell
 */
@ComponentV2
export struct MoveDirectorListView {
  @Require @Param fileList: FileInfo[]
  @Event didSelectAction: (index: number) => void = (_: number) => {
  }

  build() {
    // 文件列表
    List() {
      Repeat(this.fileList)
        .each((item: RepeatItem<FileInfo>) => {
          // 隐私空间模板
          ListItem() {
            PrivateSpaceCell({ fileInfo: item.item })
          }
          .onClick(() => {
            this.didSelectAction(item.index)
          })
        })
        .key((item: FileInfo): string => JSON.stringify(item))
        .virtualScroll({ totalCount: this.fileList.length })
        .templateId((item: FileInfo): string => {
          if (item.fileType !== FileType.PrivateSpace) {
            return 'directorTemplate'
          }

          return ''
        })
        .template('directorTemplate', (item: RepeatItem<FileInfo>) => {
          ListItem() {
            DirectorUnSelectCell({ fileInfo: item.item })
          }
          .onClick(() => {
            this.didSelectAction(item.index)
          })
        })
    }
    .padding({ left: 16, right: 16 })
    .cachedCount(2)
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
  }
}