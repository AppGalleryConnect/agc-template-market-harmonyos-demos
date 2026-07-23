import { PullToRefresh, PullToRefreshConfigurator } from '@ohos/pulltorefresh';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { UtilLog } from '@hw-agconnect/util-log';
import { SearchApis, SearchItem } from 'search';
import { QueryTravelogueListType } from '../constant/Index';
import { CommonConstant, PageRouteName } from '../constant/Index';
import { CardDataSource, HistoryList, PostCardModel } from '../model/Index';
import { queryTravelogueList } from '../utils/ApiManage';
import { ContentCard } from '../components/ContentCard';
import { QueryTravelogueListRequest } from '../model/IRequest';
import { trimStart } from '../utils/Index';

@Entry({ routeName: PageRouteName.PAGE_SEARCH })
@ComponentV2
export struct PageSearch {
  @Local curPageNum: number = 1;
  @Local searchValue: string = '';
  @Local historyList: HistoryList = AppStorageV2.connect(HistoryList, 'HistoryList', () => new HistoryList())!;
  @Local list: CardDataSource = new CardDataSource();
  @Local withSearchResp: boolean = false;
  @Local listNum: number = 0;
  @Local isLoading: boolean = false;
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Local hotSearchList: SearchItem[] = [];
  private searchController: SearchController = new SearchController();
  private scroller: Scroller = new Scroller();
  private pullConfig: PullToRefreshConfigurator = new PullToRefreshConfigurator();

  aboutToAppear(): void {
    this.setPullConfig();
    this.loadSearchData();
  }

  onBackPress(): boolean | void {
    if (this.withSearchResp) {
      this.withSearchResp = false;
      this.searchValue = '';
      return true;
    }
    return false;
  }

  loadSearchData() {
    SearchApis.getHotSearchList()
      .then((result) => {
        this.hotSearchList = result;
      })
      .catch(() => {});
  }

  callInterface(refresh: boolean = true) {
    this.isLoading = true;
    if (refresh) {
      this.curPageNum = 1;
    }
    const data: QueryTravelogueListRequest = {
      type: QueryTravelogueListType.ALL,
      title: this.searchValue,
      pageNum: this.curPageNum,
      pageSize: 20,
    };
    return queryTravelogueList(data).then((resp: ESObject) => {
      this.isLoading = false;
      if (refresh) {
        this.list.clearAllData();
        this.listNum = this.list.totalCount();
      }
      const list = (resp.data as PostCardModel[]).map(v => new PostCardModel(v));
      if (list.length) {
        this.list.addData(list);
        this.listNum = this.list.totalCount();
        this.curPageNum += 1;
      }
      return true;
    }).catch(() => {
      this.isLoading = false;
      this.list.clearAllData();
      this.listNum = this.list.totalCount();
      ToastDialog.showToast({ message: '请求失败，请联网重试' });
      return false;
    });
  }

  queryList() {
    if (!this.searchValue) {
      return;
    }
    this.searchController.stopEditing();
    this.withSearchResp = true;
    const existIndex = this.historyList.historyList.findIndex(v => v === this.searchValue);
    if (existIndex !== -1) {
      this.historyList.historyList.splice(existIndex, 1);
    }
    this.historyList.historyList.splice(0, 0, this.searchValue);
    this.callInterface();
  }

  queryByKeyword(keyword: string) {
    this.searchValue = keyword;
    this.queryList();
  }

  getResourceString(res: Resource) {
    try {
      return this.getUIContext().getHostContext()!.resourceManager.getStringSync(res.id);
    } catch (err) {
      UtilLog.error(`getStringSync error ${err}`);
      return undefined;
    }
  }

  setPullConfig() {
    this.pullConfig
      .setHasRefresh(true)
      .setHasLoadMore(true)
      .setRefreshTextSize(14)
      .setLoadImgHeight(16)
      .setLoadTextSize(14)
      .setLoadTextPullUp1(this.getResourceString($r('app.string.pull_load_text')))
      .setLoadTextPullUp2(this.getResourceString($r('app.string.pull_load_release')))
      .setLoadTextLoading(this.getResourceString($r('app.string.pull_loading')))
      .setRefreshCompleteTextHoldTime(500);
  }

  @Builder
  buildSearchBar() {
    Row({ space: 8 }) {
      Row() {
        Image($r('app.media.ic_public_back'))
          .width(14)
          .fillColor($r('app.color.grey_level_6'))
          .objectFit(ImageFit.Contain)
      }
      .width(40)
      .height(40)
      .borderRadius(20)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        if (this.withSearchResp) {
          this.withSearchResp = false;
          this.searchValue = '';
        } else {
          this.getUIContext().getRouter().back();
        }
      });

      Search({
        value: $$this.searchValue,
        placeholder: '',
        controller: this.searchController,
      })
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .layoutWeight(1)
        .placeholderFont({
          size: $r('sys.float.Body_L'),
          weight: FontWeight.Regular,
          family: 'HarmonyHeiTi'
        })
        .placeholderColor($r('sys.color.font_secondary'))
        .textFont({
          size: $r('sys.float.Body_L'),
          weight: FontWeight.Medium,
          family: 'HarmonyHeiTi',
        })
        .cancelButton({
          style: CancelButtonStyle.INPUT,
        })
        .caretStyle({ color: $r('sys.color.font_emphasize') })
        .onChange(() => {
          this.searchValue = trimStart(this.searchValue);
        })
        .onSubmit(() => {
          this.queryList();
        });
    }
    .width(CommonConstant.FULL_PERCENT)
    .padding({ left: 14, right: 10 });
  }

  @Builder
  buildHistoryTag(label: string) {
    Button() {
      Text(label)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .fontFamily('HarmonyHeiTi')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Center);
    }
    .type(ButtonType.Capsule)
    .borderRadius(14)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .hoverEffect(HoverEffect.Highlight)
    .padding({
      left: 12,
      right: 12,
      top: 4,
      bottom: 4,
    })
    .constraintSize({ maxWidth: 160 })
    .onClick(() => {
      this.queryByKeyword(label);
    });
  }

  @Builder
  buildHistorySection() {
    Column({ space: 10 }) {
      Row() {
        Text('历史搜索')
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Regular)
          .fontFamily('HarmonyHeiTi');

        Row({ space: 4 }) {
          SymbolGlyph($r('sys.symbol.trash'))
            .fontSize(16)
            .fontColor([$r('sys.color.font_secondary')]);
          Text('清空')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .fontFamily('HarmonyHeiTi');
        }
        .onClick(() => {
          SearchApis.deleteHistoryList();
          this.historyList.historyList.splice(0, this.historyList.historyList.length);
        });
      }
      .width(CommonConstant.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Bottom);

      if (this.historyList.historyList.length) {
        Flex({
          wrap: FlexWrap.Wrap,
          space: { main: LengthMetrics.vp(12), cross: LengthMetrics.vp(12) }
        }) {
          ForEach(this.historyList.historyList.slice(0, 10), (item: string) => {
            this.buildHistoryTag(item);
          }, (item: string) => item);
        }
      }
    }
    .width(CommonConstant.FULL_PERCENT)
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  buildHotSearchItem(item: SearchItem, index: number) {
    Row({ space: 12 }) {
      Text(`${index + 1}.`)
        .fontSize(14)
        .fontWeight(index < 3 ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(index < 3 ? $r('sys.color.warning') : $r('sys.color.font_secondary'));

      Text(item.title)
        .fontSize(14)
        .fontColor($r('sys.color.font_primary'))
        .fontFamily('HarmonyHeiTi')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1);
    }
    .width(CommonConstant.FULL_PERCENT)
    .padding({ left: 0, right: 0, top: 8, bottom: 8 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.queryByKeyword(item.title);
    });
  }

  @Builder
  buildHotSearchSection() {
    Column({ space: 16 }) {
      Row({ space: 4 }) {
        Image($r('app.media.ic_public_hot'))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain);

        Text('热搜榜')
          .fontSize(18)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold)
          .fontFamily('HarmonyHeiTi');
      }
      .alignItems(VerticalAlign.Center);

      ForEach(this.hotSearchList, (item: SearchItem, index: number) => {
        this.buildHotSearchItem(item, index);
      }, (item: SearchItem) => JSON.stringify(item.title));
    }
    .width(CommonConstant.FULL_PERCENT)
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  buildWaterFlow() {
    WaterFlow({ scroller: this.scroller }) {
      LazyForEach(this.list, (item: PostCardModel) => {
        FlowItem() {
          ContentCard({
            data: item,
          });
        }
        .width(CommonConstant.FULL_PERCENT);
      });
    }
    .cachedCount(10)
    .columnsTemplate('1fr 1fr')
    .columnsGap(6)
    .rowsGap(6)
    .width(CommonConstant.FULL_PERCENT)
    .layoutWeight(1);
  }

  @Builder
  buildList() {
    Column() {
      if (this.listNum) {
        PullToRefresh({
          refreshConfigurator: this.pullConfig,
          scroller: this.scroller,
          customList: () => {
            this.buildWaterFlow();
          },
          onRefresh: () => {
            return new Promise<string>((resolve, reject) => {
              this.callInterface().then((isSuccess: boolean) => {
                if (isSuccess) {
                  resolve(this.getResourceString($r('app.string.refresh_success')));
                } else {
                  resolve(this.getResourceString($r('app.string.refresh_fail')));
                }
              });
            });
          },
          onLoadMore: () => {
            return new Promise<string>((resolve, reject) => {
              this.callInterface(false).then((isSuccess: boolean) => {
                if (isSuccess) {
                  resolve(this.getResourceString($r('app.string.load_success')));
                } else {
                  resolve(this.getResourceString($r('app.string.load_fail')));
                }
              });
            });
          },
          customLoad: null,
          customRefresh: null,
        });
      } else if (this.isLoading) {
        LoadingProgress().size({ width: 72, height: 72 });
      } else {
        Column({ space: 12 }) {
          Image($r('app.media.SearchNoResult'))
            .width(120)
            .height(120)
            .objectFit(ImageFit.Contain);

          Text('暂无搜索结果')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .fontFamily('HarmonyHeiTi');
        }
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
        .width(CommonConstant.FULL_PERCENT);
      }
    }
    .width(CommonConstant.FULL_PERCENT)
    .layoutWeight(1)
    .backgroundColor($r('app.color.page_bg'))
    .padding(6);
  }

  build() {
    NavDestination() {
      Column() {
        this.buildSearchBar();
        if (!this.withSearchResp && !this.searchValue) {
          Scroll() {
            Column() {
              this.buildHistorySection();
              this.buildHotSearchSection();
            }
          }
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
          .layoutWeight(1);
        }
        if (this.withSearchResp) {
          this.buildList();
        }
      }
      .padding({ top: this.windowTopHeight })
      .height(CommonConstant.FULL_PERCENT)
      .width(CommonConstant.FULL_PERCENT)
      .backgroundColor($r('sys.color.background_primary'));
    }.hideTitleBar(true);
  }
}
