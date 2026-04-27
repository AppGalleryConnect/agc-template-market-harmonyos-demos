import { TValueType } from 'audio_common'
import { BarVM } from 'common'
import { MusicListView, MusicListViewController, SearchHeader } from 'common_view'
import { LISTMODE } from 'common_view/src/main/ets/components/MusicItem'
import { MusicViewModel } from 'common_view/src/main/ets/viewModel/MusicViewModel'
import { phoneRouterControl } from 'oh_router'
import { MusicLibraryComponent } from '../components/MusicLibraryComponent'
import { HistoryController, SearcyHistoryView } from './SearcyHistoryView'

phoneRouterControl.registerPageBuilder('SearchViewPage', wrapBuilder(SearchViewPageBuilder))

const TAG = 'SearchPage'

@Builder
export function SearchViewPageBuilder(params: TValueType) {
  SearchViewPage({ pageParams: params })
}

@ComponentV2
export struct SearchViewPage {
  @Param pageParams: TValueType = null;
  pageType: string = ''
  @Local listMode: LISTMODE = 'click' //列表操作模式，默认单选模式
  @Local searchVal: string = ''
  @Local isShow: boolean = false //帅选列表是否展示
  musicListViewController = new MusicListViewController()
  historyContrller: HistoryController = new HistoryController()
  @Local selectedMusicList: MusicViewModel[] = [] //选中的音频列表，用于合成功能
  //列表单击事件
  musicItemOnclick = (item: MusicViewModel) => {
  }
  //列表多选事件
  musicItemOnChange = (item: MusicViewModel, checkBoxStatus: boolean) => {
  }
  //搜索提交事件
  onSearchSubmit = (val: string) => {
    this.searchVal = val
    if (!val) {
      return
    }
    //筛选数据
    this.musicListViewController.filterData(val)

    this.historyContrller.addData(val)
    this.isShow = true

  }
  //搜索内容便哈监听
  onSearchChange = (val: string) => {
    this.searchVal = val
    if (!val) {
      this.isShow = false
    }

  }
  historyOnclick = (val: string) => {
    this.onSearchSubmit(val)
  }

  aboutToAppear(): void {
    this.pageType = (this.pageParams as Record<string, string>)?.pageType
    this.listMode = (this.pageParams as Record<string, string>)?.listMode as LISTMODE ?
      (this.pageParams as Record<string, string>)?.listMode as LISTMODE : 'click'
  }

  build() {
    NavDestination() {
      Column() {
        SearchHeader({
          onSearchSubmit: this.onSearchSubmit,
          onSearchChange: this.onSearchChange,
          searchVal: this.searchVal
        })
        Stack() {
          MusicLibraryComponent({
            pageType: this.pageType,
            listMode: this.listMode,
            isSearchPage: true,
            musicListViewController: this.musicListViewController,
            changeSelected: (res: MusicViewModel[]) => {
              this.selectedMusicList = res
            }
          }).visibility(this.isShow ? Visibility.Visible : Visibility.Hidden)
            .width('100%').height('100%')

          SearcyHistoryView({
            historyContrller: this.historyContrller,
            historyOnclick: this.historyOnclick
          })
            .visibility(!this.isShow ? Visibility.Visible : Visibility.Hidden)
            .width('100%').height('100%')
            .padding({ left: 16, right: 16 })
        }.width('100%').layoutWeight(1)
      }.width('100%').height('100%')
      .padding({
        top: BarVM.instance.staBarH
      })
      .backgroundColor('#0A0D1E')
    }.hideTitleBar(true)
  }
}