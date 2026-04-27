import { PullToRefresh, PullToRefreshConfigurator } from '@ohos/pulltorefresh';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { application, common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { QueryTravelogueListType } from '../constant/Index';
import { CommonConstant } from '../constant/Index';
import { CardDataSource, HistoryList, PostCardModel } from '../model/Index';
import { queryTravelogueList } from '../utils/ApiManage';
import { ContentCard } from '../components/ContentCard';
import { QueryTravelogueListRequest } from '../model/IRequest';
import { trimStart } from '../utils/Index';

@Builder
export function PageSearchBuilder() {
  PageSearch();
}

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
  private searchController: SearchController = new SearchController();
  private scroller: Scroller = new Scroller();
  private pullConfig: PullToRefreshConfigurator = new PullToRefreshConfigurator();
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  onBackPress(): boolean | void {
    if (this.withSearchResp) {
      this.withSearchResp = false;
      this.searchValue = '';
      return true;
    }
    return false;
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
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.query_fail') });
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

  getResourceString(res: Resource) {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    let moduleName: string = 'library';
    application.createModuleContext(context, moduleName)
      .then((data: common.Context) => {
        console.info(`CreateModuleContext success, data: ${JSON.stringify(data)}`);
        if (data !== null) {
          this.getUIContext().getPromptAction().showToast({
            message: ('get Context success'),
          });
        }

        try {
          let str = data.resourceManager.getStringSync(res.id);
          return str
        } catch (error) {
          return ''
        }
      })
      .catch((err: BusinessError) => {
        return ''
      });
    return ''
  }

  setPullConfig() {
    this.pullConfig
      .setHasRefresh(true)// 是否具有下拉刷新功能
      .setHasLoadMore(true)// 是否具有上拉加载功能
      .setRefreshTextSize(14)// 下拉加载完毕后提示文本的字体大小
      .setLoadImgHeight(16)
      .setLoadTextSize(14)// 上拉文本的字体大小
      .setLoadTextPullUp1(this.getResourceString($r('app.string.pull_load_text')))// 上拉1阶段文本
      .setLoadTextPullUp2(this.getResourceString($r('app.string.pull_load_release')))// 上拉2阶段文本
      .setLoadTextLoading(this.getResourceString($r('app.string.pull_loading')))// 上拉加载更多中时的文本
      .setRefreshCompleteTextHoldTime(500); //上拉刷新后停留的时间, 默认一秒, 建议设置500
  }

  @Builder
  buildTitle() {
    Row({ space: 8 }) {
      Search({
        value: $$this.searchValue,
        placeholder: $r('app.string.search_input_placeholder'),
        controller: this.searchController,
      })
        .backgroundColor($r('app.color.search_input_bg'))
        .layoutWeight(1)
        .onChange(() => {
          this.searchValue = trimStart(this.searchValue);
        })
        .onSubmit(() => {
          this.queryList();
        });
      Text($r('app.string.btn_search'))
        .fontSize(15)
        .fontColor($r('app.color.grey_level_4'))
        .fontWeight(400)
        .lineHeight(20)
        .onClick(() => {
          this.queryList();
        });
    }.width(CommonConstant.FULL_PERCENT).padding({ left: 14, right: 10 });
  }

  @Builder
  buildTag(label: string) {
    Button() {
      Text(label)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(400)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Center);
    }
    .type(ButtonType.Capsule)
    .borderRadius(23)
    .borderWidth(1)
    .borderColor($r('app.color.grey_level_4'))
    .backgroundColor($r('app.color.search_tag_bg'))
    .hoverEffect(HoverEffect.Highlight)
    .padding({
      left: 10,
      right: 10,
      top: 5,
      bottom: 5,
    })
    .constraintSize({ maxWidth: 160 })
    .onClick(() => {
      this.searchValue = label;
      this.queryList();
    });
  }

  @Builder
  buildHistory() {
    Column({ space: 10 }) {
      Text($r('app.string.search_history'))
        .fontSize(12)
        .fontColor($r('app.color.grey_level_9'))
        .fontWeight(500);
      if (this.historyList.historyList.length) {
        Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(12), cross: LengthMetrics.vp(10) } }) {
          ForEach(this.historyList.historyList.slice(0, 10), (item: string) => {
            this.buildTag(item);
          }, (item: string) => item);
        };
      } else {
        Text($r('app.string.comment_history_empty'))
          .fontSize(20)
          .fontColor($r('app.color.grey_level_6'))
          .margin({ top: 200 })
          .alignSelf(ItemAlign.Center);
      }

    }.width(CommonConstant.FULL_PERCENT).padding(14).alignItems(HorizontalAlign.Start);
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
        LoadingProgress().size({ width: 72, height: 72 }).margin({ top: 200 });
      } else {
        Text($r('app.string.search_list_empty'))
          .fontSize(20)
          .fontColor($r('app.color.grey_level_6'))
          .margin({ top: 200 });
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
        Stack({ alignContent: Alignment.Start }) {
          Text('攻略搜索').fontSize(18).fontWeight(500).width('100%').textAlign(TextAlign.Center);
          Image($r('app.media.left_arrow'))
            .size({ height: 24, width: 24 })
            .onClick(() => {
              this.mainPathStack.pop()
            });
        }
        .margin({ top: this.windowTopHeight })
        .width('100%')
        .padding({
          left: 12,
          top: 16,
          right: 12,
          bottom: 12,
        });

        this.buildTitle();
        if (!this.withSearchResp && !this.searchValue) {
          this.buildHistory();
        }
        if (this.withSearchResp) {
          this.buildList();
        }
      }
      .height(CommonConstant.FULL_PERCENT)
      .width(CommonConstant.FULL_PERCENT);
    }.hideTitleBar(true).onReady(() => {
      this.setPullConfig();
    });
  }
}
