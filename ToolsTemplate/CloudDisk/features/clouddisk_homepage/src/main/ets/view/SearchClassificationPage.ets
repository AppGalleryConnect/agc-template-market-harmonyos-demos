import { BarVM, TValueType } from 'common';
import { phoneRouterControl } from 'oh_router';
import { SearchClassificationPageVM } from '../viewmodel/SearchClassificationPageVM';
import { FileSearch } from 'clouddisk_file_search';
import { FileOperationType, OperationSelect, OperationSelectVM } from 'clouddisk_file_operation';
import { FileTransferSearchClassificationView } from '../components/FileTransferSearchClassificationView';

/**
 * @usage: 用于展示文件分类搜索页面。提供按文件类型（文档、图片、视频、音频、其他）进行搜索和筛选的功能，
 * 支持按文件格式二次筛选（如文档类型可筛选WPS、WORD、PDF等）。关键数据结构包括SearchClassificationPageVM（搜索分类视图模型，
 * 包含searchFileList搜索文件列表、selectVM文件选择视图模型、searchQuery搜索查询方法）、OperationSelectVM（文件操作视图模型）、
 * optionList（选项列表数组）、currentIndex（当前选中索引）。
 * @layout: 页面采用NavDestination布局。顶部Column包含FileSearch搜索组件（showBack为true）和option格式筛选行
 * FileTransferSearchClassificationView文件列表视图（占满剩余空间）。
 * @constraints: 文件类型映射关系固定（文档3、图片1、视频2、音频4、其他5）不可修改；
 * 文件操作类型列表固定为Download、Delete、Share、Rename、Move、MoveToPrivateSpace、Collect。
 * @isGen: true
 * @fileType: page
 * @domain: 云存储,
 * @zhName: 文件分类搜索页面
 * @component: FileSearch,FileTransferSearchClassificationView,OperationSelect
 * @image: screenshot/Home/search_classification.jpg
 */

@Builder
export function SearchClassificationPageBuilder(params: TValueType) {
  SearchClassificationPage({
    pageParam: params
  })
}

@ComponentV2
export struct SearchClassificationPage {
  @Param pageParam: TValueType = null
  vm: SearchClassificationPageVM = new SearchClassificationPageVM()
  @Local searchText: string = '';
  @Local optionList: Array<string> = []
  @Local currentIndex: number = 0
  operationVM: OperationSelectVM = new OperationSelectVM([
    FileOperationType.Download,
    FileOperationType.Delete,
    FileOperationType.Share,
    FileOperationType.Rename,
    FileOperationType.Move,
    FileOperationType.MoveToPrivateSpace,
    FileOperationType.Collect
  ])

  aboutToAppear(): void {
    this.optionList = this.getOptionList()
    this.vm.searchFileList = this.vm.fileList.filter(item => item.fileType === this.getOptionType())
    this.vm.selectVM.fileList = this.vm.searchFileList
  }

  getOptionList(): Array<string> {
    switch (this.pageParam) {
      case '文档':
        return ['全部', 'WPS', 'WORD', 'PDF'];
      case '图片':
        return ['全部', 'JPG', 'PNG', 'GIF'];
      case '视频':
        return ['全部', 'MP4', 'AVI', 'WMV'];
      case '音频':
        return ['全部', 'MP3', 'WMA', 'FLAC'];
      case '其他':
        return ['全部'];
      default:
        return [];
    }
  }

  getOptionType(): number | null {
    switch (this.pageParam) {
      case '文档':
        return 3;
      case '图片':
        return 1;
      case '视频':
        return 2;
      case '音频':
        return 4;
      case '其他':
        return 5;
      default:
        return null;
    }
  }

  build() {
    NavDestination() {
      this.render()
    }.hideTitleBar(true)
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
  }

  @Builder
  dealWithFileSheet() {
    OperationSelect({ vm: this.operationVM })
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      Column() {
        // 搜索
        FileSearch({
          showBack: true,
          pageParam: this.pageParam as string,
          searchQuery: (x: string) => {
            this.vm.searchQuery(x)
          },
          popPage: () => {
            phoneRouterControl.popPage()
          },
        })
        this.option()
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: BarVM.instance.staBarH,
        bottom: 8
      })
      .borderRadius({ bottomLeft: 16, bottomRight: 16 })
      .backgroundColor($r('sys.color.background_primary'))

      this.content()
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .width('100%')
    .height('100%')
  }

  @Builder
  option() {
    Row({ space: 8 }) {
      ForEach(this.optionList, (item: string, index: number) => {
        Text(item)
          .fontColor(this.currentIndex === index ? '#2FAFFF' : '#9DA3AA')
          .fontSize(12)
          .height(30)
          .width(48)
          .textAlign(TextAlign.Center)
          .backgroundColor(this.currentIndex === index ? '#F0F9FF' : '#F6F8FA')
          .borderRadius(10)
          .onClick(() => {
            this.currentIndex = index
            if (this.currentIndex > 0) {
              this.vm.selectVM.fileList = this.vm.fileList.filter(ite => ite.name.toUpperCase().slice(-3) === item)
            } else {
              this.vm.selectVM.fileList = this.vm.searchFileList
            }
          })
      }, (item: string, idx: number) => JSON.stringify(item) + idx)
    }.width('100%').alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Start)
  }

  @Builder
  content() {
    Column() {
      Text(`搜索结果（${this.vm.selectVM.fileList.length}）`)
        .fontSize(14)
        .fontColor('#000000')
        .fontWeight(500)
        .margin({ top: 16, bottom: 8, left: 16 })
      if (this.vm.selectVM.fileList.length > 0) {
        Divider()
          .strokeWidth('1px')
          .color($r('sys.color.comp_divider'))
        FileTransferSearchClassificationView({
          vm: this.vm
        }).layoutWeight(1)
      } else {
        Column() {
          Image($r('app.media.ic_nodata')).width(120).height(120)
          Text('暂无文件')
            .fontColor('rgba(0, 0, 0, 0.4)')
            .fontSize($r('app.float.fontsize_12'))
            .lineHeight(14)
            .margin({ top: 18 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .backgroundColor($r('sys.color.comp_background_tertiary'))
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
    .margin({ top: 10 })
    .backgroundColor($r('sys.color.background_primary'))
  }
}