import { phoneRouterControl } from 'oh_router';
import { BarVM, RouterMap } from 'common';
import { SearchImgType } from '../common/model';
import { SearchClassificationPageBuilder } from '../../../../Index';
import { SearchPageVM } from '../viewmodel/SearchPageVM';
import { FileSearch } from 'clouddisk_file_search';
import { FileOperationType, OperationSelect, OperationSelectVM } from 'clouddisk_file_operation';
import { FileTransferSearchView } from '../components/FileTransferSearchView';
import { PersistenceV2 } from '@kit.ArkUI';
import { SearchPageHistoryVM } from '../viewmodel/SearchHistoryVM';

/**
 * @usage: 用于展示文件搜索页面。提供文件搜索功能，支持按文件类型快速筛选（文档、图片、视频、音频、其他）和搜索历史记录管理。
 * 关键数据结构包括SearchPageVM（搜索页面视图模型，包含searchHistoryList搜索历史列表、showHistory显示历史标志、
 * selectVM文件选择视图模型、searchQuery搜索查询方法）、OperationSelectVM（文件操作视图模型）、
 * SearchImgType（搜索图标类型，包含img图标和text文字）、searchList（搜索类型列表数组）。
 * 包含if逻辑：根据showHistory判断显示搜索历史或搜索结果。
 * @layout: 页面采用NavDestination布局。顶部Column包含FileSearch搜索组件（showBack为false）和imageBuilder五个图标行
 * @isGen: true
 * @fileType: page
 * @domain: 云存储,
 * @zhName: 文件搜索页面
 * @subPage: SearchClassificationPage
 * @component: FileSearch,FileTransferSearchView,OperationSelect
 * @image: screenshot/Home/search.jpg
 */

@Builder
export function SearchPageBuilder() {
  SearchPage()
}

@ComponentV2
export struct SearchPage {
  vm: SearchPageVM = new SearchPageVM()
  @Local searchPageHistoryVM: SearchPageHistoryVM =
    PersistenceV2.connect(SearchPageHistoryVM, () => new SearchPageHistoryVM())!;
  logTag: string = 'SearchPage';
  @Event query: (content: string) => Promise<void> = () => Promise.resolve();
  @Event goBack: () => void = () => {
  };
  @Local searchList: SearchImgType[] =
    [{ img: $r('app.media.ic_search_document'), text: '文档' }, { img: $r('app.media.ic__search_img'), text: '图片' },
      { img: $r('app.media.ic_search_video'), text: '视频' }, { img: $r('app.media.ic_search_audio'), text: '音频' },
      { img: $r('app.media.ic__search_other'), text: '其他' }];
  operationVM: OperationSelectVM = new OperationSelectVM([
    FileOperationType.Download,
    FileOperationType.Delete,
    FileOperationType.Share,
    FileOperationType.Rename,
    FileOperationType.Move,
    FileOperationType.MoveToPrivateSpace,
    FileOperationType.Collect
  ])

  searchQuery(data: string) {
    this.vm.showHistory = false
    if (!data) {
      this.vm.selectVM.fileList = this.vm.fileList
      return
    }
    this.searchPageHistoryVM.searchHistoryList = [...this.searchPageHistoryVM.searchHistoryList, data]
    if (this.searchPageHistoryVM.searchHistoryList.length > this.vm.searchHistoryLength) {
      this.searchPageHistoryVM.searchHistoryList.shift(); // 删除第一个元素
    }

    this.vm.selectVM.fileList = this.fuzzySearchObjectArray(this.vm.fileList, data, item => item.name)
  }

  fuzzySearchObjectArray<FileInfo>(
    items: FileInfo[],
    searchTerm: string,
    keySelector: (item: FileInfo) => string
  ): FileInfo[] {
    if (!searchTerm.trim()) {
      return items;
    }
    const term = searchTerm.toLowerCase();
    return items.filter(item =>
    keySelector(item).toLowerCase().includes(term)
    );
  }

  deleteHistoryItem(data: number) {
    this.searchPageHistoryVM.searchHistoryList.splice(data, 1)
  }

  handleIconClick(data: string) {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.SEARCH_CLASSIFICATION_PAGE,
      builder: wrapBuilder(SearchClassificationPageBuilder),
      param: data
    })
  }

  build() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
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
          showBack: false,
          pageParam: '',
          searchQuery: (x: string) => {
            this.searchQuery(x)
          },
          popPage: () => {
            phoneRouterControl.popPage()
          },
        })

        // 五个图标
        this.imageBuilder()
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: BarVM.instance.staBarH,
        bottom: BarVM.instance.aiBarH
      })
      .borderRadius({ bottomLeft: 16, bottomRight: 16 })
      .backgroundColor($r('sys.color.background_primary'))

      if (this.vm.showHistory) {
        this.searchHistory()
      } else {
        this.content()
      }
    }

    .backgroundColor($r('sys.color.background_secondary'))
    .width('100%')
    .height('100%')
  }

  @Builder
  imageBuilder() {
    Row() {
      ForEach(this.searchList, (item: SearchImgType, index: number) => {
        Column({ space: 8 }) {
          // 图标
          Row() {
            Image(item.img)
              .width(40)
              .height(40)
              .objectFit(ImageFit.Contain)
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)

          // 文字
          Text(item.text)
            .fontSize(12)
            .fontColor('#444444')
        }
        .onClick(() => {
          this.handleIconClick(item.text)
        })
      }, (item: SearchImgType, idx: number) => JSON.stringify(item) + idx)
    }
    .margin({ top: 8 })
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  searchHistory() {
    Column() {
      Text('搜索历史').fontSize(12).fontColor('#9E9E9E').margin({ top: 12, bottom: 8, left: 16 })
      Column() {
        ForEach(this.searchPageHistoryVM.searchHistoryList, (item: string, index: number) => {
          Row() {
            Text(item)
              .fontSize(12)
              .fontColor('##444444')

            Image($r('app.media.ic_delete'))
              .width(20)
              .height(20)
              .objectFit(ImageFit.Contain)
              .onClick(() => {
                this.deleteHistoryItem(index)
              })
          }
          .padding({ left: 16, right: 16 })
          .height(44)
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
        }, (item: string, idx: number) => JSON.stringify(item) + idx)
      }.width('100%')
      .backgroundColor($r('sys.color.background_primary'))
    }.width('100%')
    .alignItems(HorizontalAlign.Start)
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
          .opacity(0.2)
        FileTransferSearchView({
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