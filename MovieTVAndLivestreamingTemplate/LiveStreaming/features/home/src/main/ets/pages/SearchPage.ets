import { AppStorageV2, display } from '@kit.ArkUI'
import { getColor, getString } from '@agctemplate/resources'
import { SearchPanel } from '../components/SearchPanel'
import { SearchTipPanel } from '../components/SearchTipPanel'
import { SearchHistoryPanel } from '../components/SearchHistoryPanel'
import { RecommendPanel } from '../components/RecommendPanel'
import { SearchResultPanel } from '../components/SearchResultPanel'
import { SearchRecords } from '../viewmodels/SearchRecordsVM'
import { RouterMap, RouterModule } from '@agctemplate/router_module'
import { getSearchList, getTipInfos } from '../mapper/SearchTipMapper'
import { PlayController } from '@agctemplate/video_swiper'
import { BarVM, LiveCardModel } from '@agctemplate/widgets'
import { deviceInfo } from '@kit.BasicServicesKit'

@ComponentV2
struct SearchPage {
  @Consumer('searchText') searchText: string = ''
  @Consumer('isSearch') isSearch: boolean = false
  @Local searchResult: Array<LiveCardModel> | undefined = undefined
  @Local rankList: Array<string> | undefined = undefined
  @Consumer('isEdit') isEdit: boolean = false
  @Local isLandscapeTablet: boolean = display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE ||
    display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE_INVERTED &&
      deviceInfo.deviceType === 'tablet';
  @Local tipInfos: Array<string> = []
  @Local searchRecords: SearchRecords = AppStorageV2.connect(SearchRecords, () => new SearchRecords())!
  @Local currentPageNum: number = 1
  @Local searchCurrentPageNum: number = 1
  @Local backToSearch: boolean = false
  @Consumer('isShow') isShow: boolean = true
  textController: TextInputController = new TextInputController()
  scroller: Scroller = new Scroller()

  @Monitor('searchText')
  async onSearchTextChange() {
    this.tipInfos = !this.searchText ? [] : await getTipInfos(this.searchText)
  }

  @Monitor('isSearch')
  startSearch() {
    this.doSearch(this.searchText, this.textController)
    this.isSearch = false
  }

  // 真正的搜索操作
  async doSearch(searchText: string, textController: TextInputController) {
    this.searchCurrentPageNum = 1
    this.searchResult = await getSearchList(searchText, this.searchCurrentPageNum)
    this.isEdit = false
    // 需要传进来，直接this获取是undefined
    textController.stopEditing()
    this.searchText = searchText
    this.backToSearch = true
  }

  build() {
    NavDestination() {
      Column() {
        if (!this.isLandscapeTablet) {
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
            clearText: () => {
              this.searchText = ''
            },
            isInput: true,
            backToSearch: this.backToSearch,
            backSearch: () => {
              this.backSearch()
            }
          })
            .margin({ top: 8, bottom: 12 })
        }


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
              onLiveClick: this.onLiveClick
            })
          } else {
            Scroll(this.scroller) {
              Column() {
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
                RecommendPanel({
                  onLiveClick: () => {
                    this.isShow = false
                    this.onLiveClick('')
                  }
                })
              }
              .onAppear(() => {
                this.backToSearch = false
              })
              .height('120%')
            }
            .edgeEffect(EdgeEffect.Spring)
            .scrollBar(BarState.Off)
          }
        }
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 16,
        right: 16,
        top: this.isLandscapeTablet ? 16 : BarVM.instance.staBarH,
        bottom: this.isLandscapeTablet ? 16 : BarVM.instance.aiBarH
      })
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
    .onBackPressed((): boolean => {
      if (this.backToSearch) {
        this.backSearch()
        return true
      } else {
        return false
      }
    })
  }

  backSearch() {
    this.isEdit = false
    this.searchResult = undefined
    this.backToSearch = false
  }

  onLiveClick(option: string) {
    if (PlayController.onStopPip) {
      PlayController.onStopPip()
    }
    RouterModule.push({
      url: RouterMap.DETAIL_PAGE
    })
  }
}

@Builder
export function SearchPageBuilder() {
  SearchPage()
    .height(552)
}
