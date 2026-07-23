import { AppStorageV2 } from '@kit.ArkUI'
import { AiBarHeight, AppStorageKeys, StatusBarHeight } from '@agctemplate/widgets'
import { appRouter, StringUtil } from '@agctemplate/utils'
import { NAV_PAGE_NAME } from '@agctemplate/resources'
import { DramaInfo } from '@agctemplate/server'
import { DramaCoverVM } from '../viewmodels/DramaCoverVM'
import { getRankList, getSearchList } from '../mapper/DramaCoverMapper'
import { getTipInfos } from '../mapper/SearchTipMapper'
import { SearchPanel } from '../components/SearchPanel'
import { SearchTipPanel } from '../components/SearchTipPanel'
import { SearchHistoryPanel } from '../components/SearchHistoryPanel'
import { HotSearchPanel } from '../components/HotSearchPanel'
import { SearchResultPanel } from '../components/SearchResultPanel'
import { SearchRecords } from '../viewmodels/SearchRecordsVM'

const HOT_SEARCH_CATEGORY: string = '热搜榜'

@ComponentV2
struct SearchPage {
  @Local aiBarHeight: AiBarHeight = AppStorageV2.connect(AiBarHeight, AppStorageKeys.AI_BAR_HEIGHT,
    () => new AiBarHeight())!;
  @Local statusBarHeight: StatusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight())!;
  @Local searchText: string = ''
  @Local searchResult: Array<DramaCoverVM> | undefined = undefined
  @Local rankList: Array<DramaCoverVM> | undefined = undefined
  @Local isEdit: boolean = false
  @Local tipInfos: Array<string> = []
  @Local searchRecords: SearchRecords = AppStorageV2.connect(SearchRecords, () => new SearchRecords())!
  @Local currentPageNum: number = 1
  @Local searchCurrentPageNum: number = 1
  textController: TextInputController = new TextInputController()

  async aboutToAppear() {
    // 进入页面先加载热搜榜的数据
    this.rankList = await getRankList(HOT_SEARCH_CATEGORY, this.currentPageNum)
  }

  @Monitor('searchText')
  async onSearchTextChange() {
    this.tipInfos = StringUtil.isBlank(this.searchText) ? [] : await getTipInfos(this.searchText)
  }

  // 真正的搜索操作
  async doSearch(searchText: string, textController: TextInputController) {
    this.searchCurrentPageNum = 1
    this.searchResult = await getSearchList(searchText, this.searchCurrentPageNum)
    this.isEdit = false
    // 需要传进来，直接this获取是undefined
    textController.stopEditing()
    this.searchText = searchText
  }

  @Builder
  titleBuilder() {
    SearchPanel({
      textController: this.textController,
      searchText: this.searchText,
      searchResult: this.searchResult,
      isEdit: this.isEdit,
      inputValueChangedEvent: (value: string) => {
        this.searchText = value
      },
      inputFocusEvent: () => {
        this.searchResult = undefined
        this.isEdit = true
      },
      searchEvent: async (text: string) => {
        this.doSearch(text, this.textController)
      },
      isInput: true,
      clearText: () => {
        this.searchText = ''
      }
    })
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          if (this.searchText && this.isEdit) {
            SearchTipPanel({
              searchText: this.searchText,
              tipInfos: this.tipInfos,
              searchEvent: async (text: string) => {
                this.doSearch(text, this.textController)
              }
            })
              .height('100%')
          } else {
            if (this.searchResult) {
              SearchResultPanel({
                resultList: this.searchResult,
                loadNextPage: async () => {
                  let list = await getSearchList(this.searchText, ++this.searchCurrentPageNum)
                  this.searchResult = this.searchResult?.concat(list)
                },
                onDramaClick: this.onDramaClick
              })
            } else {
              // 只有存在历史搜索记录的时候才显示
              if (this.searchRecords.records && this.searchRecords.records.length > 0) {
                SearchHistoryPanel({
                  searchText: this.searchText,
                  isEdit: this.isEdit,
                  searchRecordClickEvent: (record: string) => {
                    this.searchText = record
                    this.isEdit = true
                  }
                })
              }
              if (this.rankList && this.rankList.length > 0) {
                HotSearchPanel({
                  rankList: this.rankList,
                  onDramaClick: this.onDramaClick
                })
              }
            }
          }
        }
        .width('100%')
        .padding({
          left: 16, right: 16
        })
        .align(Alignment.TopStart)
        .onClick(() => {
          this.textController.stopEditing()
          this.isEdit = false
        })
      }
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .onReachEnd(async () => {
        if (!this.isEdit && this.searchResult) {
          let list = await getSearchList(this.searchText, ++this.searchCurrentPageNum)
          this.searchResult = this.searchResult.concat(list)
        } else {
          let list = await getRankList(HOT_SEARCH_CATEGORY, ++this.currentPageNum)
          this.rankList = this.rankList?.concat(list)
        }
      })
    }
    .title(this.titleBuilder())
    .padding({ top: `${this.getUIContext().px2vp(this.statusBarHeight.value)}vp`, bottom: `${this.getUIContext().px2vp(this.aiBarHeight.value)}vp` })
    .onReady((context:NavDestinationContext)=>{
      const text = context.pathInfo.param as string
      if(text){
        this.doSearch(text, this.textController)
      }
    })
  }

  onDramaClick(option: DramaCoverVM, callback?: (popInfo: PopInfo) => void) {
    appRouter.push({
      builderName: NAV_PAGE_NAME.ShortDramaDetailPage.name,
      params: {
        dramaInfo: new DramaInfo({ id: option.dramaId }),
      }, popCallback: callback
    })
  }
}

@Builder
export function SearchPageBuilder(index: number) {
  SearchPage()
}
