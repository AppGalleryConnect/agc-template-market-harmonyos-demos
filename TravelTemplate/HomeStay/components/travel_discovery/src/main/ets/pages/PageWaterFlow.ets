/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { PullToRefresh, PullToRefreshConfigurator } from '@ohos/pulltorefresh';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { CommonHeader } from 'component';
import { BAR_LIST, BarModel } from '../constant/Index'
import { CommonConstant, PageRouteName } from '../constant/Index';
import { CardDataSource, PostCardModel } from '../model/Index';
import { queryTravelogueList } from '../utils/ApiManage';
import { ContentCard } from '../components/ContentCard';
import { GridRowColSetting } from '../common/GridRowColSetting';
import './PageDetail';
import './PageSearch';
import { QueryTravelogueListRequest } from '../model/IRequest';

@ComponentV2
export struct PageGround {
  @Local isLoading: boolean = false;
  @Local currentIndex: number = 0;
  @Local curPageNum: number = 1;
  @Local list: CardDataSource = new CardDataSource();
  @Local breakpoint: string = 'sm';
  @Param @Require isShowBack: boolean;
  private scroller: Scroller = new Scroller();
  private pullConfig: PullToRefreshConfigurator = new PullToRefreshConfigurator();

  aboutToAppear(): void {
    this.setPullConfig();
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

  queryList(refresh: boolean = true) {
    if (refresh) {
      this.curPageNum = 1;
    }

    const data: QueryTravelogueListRequest = {
      type: BAR_LIST[this.currentIndex].value,
      pageNum: this.curPageNum,
      pageSize: 10,
    };
    return queryTravelogueList(data).then((resp: ESObject) => {
      if (refresh) {
        this.list.clearAllData();
      }
      const list = (resp.data as PostCardModel[]).map(v => new PostCardModel(v));
      if (list.length) {
        this.list.addData(list);
        this.curPageNum += 1;
      }
      return true;
    }).catch(() => {
      ToastDialog.showToast({ message: '请求失败，请联网重试' });
      return false;
    });
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
    .edgeEffect(EdgeEffect.Spring)
    .cachedCount(10)
    .columnsTemplate(GridRowColSetting.getWaterFloColumns(this.breakpoint))
    .columnsGap(12)
    .rowsGap(12)
    .width(CommonConstant.FULL_PERCENT)
    .layoutWeight(1);
  }

  @Builder
  buildList() {
    Column() {
      PullToRefresh({
        refreshConfigurator: this.pullConfig,
        scroller: this.scroller,
        customList: () => {
          this.buildWaterFlow();
        },
        onRefresh: () => {
          return new Promise<string>((resolve, reject) => {
            this.queryList()
              .then((isSuccess: boolean) => {
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
            this.queryList(false)
              .then((isSuccess: boolean) => {
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

    }.layoutWeight(1).backgroundColor($r('app.color.page_bg'))
    .padding({ left: 16, right: 16 });
  }

  @Builder
  buildTabBar() {
    Row() {
      ForEach(BAR_LIST, (item: BarModel, index: number) => {
        Text(item.label)
          .fontColor($r('app.color.grey_level_9'))
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .width('50%')
          .height('100%')
          .borderRadius(20)
          .backgroundColor(this.currentIndex === index ? $r('app.color.white') : Color.Transparent)
          .onClick(() => {
            this.currentIndex = index;
            this.list.clearAllData();
            this.queryList();
          });
      }, (item: BarModel) => item.label.toString());
    }
    .width('100%')
    .height(40)
    .padding(2)
    .margin({ bottom: 12 })
    .borderRadius(20)
    .backgroundColor($r('sys.color.comp_background_tertiary'));
  }

  @Builder
  buildTop() {
    Column() {
      CommonHeader({
        title: '发现',
        icon: $r('app.media.ic_public_input_search'),
        iconClick: () => {
          this.getUIContext().getRouter().pushNamedRoute({ name: PageRouteName.PAGE_SEARCH })
            .catch((err: BusinessError) => {
              UtilLog.error(`pushNameRoute error ${err}`);
            });
        }
      });
      Column() {
        this.buildTabBar();
      }.padding({ left: 16, right: 16 })
    }.backgroundColor($r('app.color.page_bg'))
  }

  build() {
    NavDestination() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({ span: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS }) {
          Column() {
            this.buildTop();
            this.buildList();
          }
          .width(CommonConstant.FULL_PERCENT)
          .height(CommonConstant.FULL_PERCENT);
        }
      }
      .onBreakpointChange((breakpoints: string) => {
        this.breakpoint = breakpoints;
      })
    }.hideTitleBar(true);
  }
}
