/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { PullToRefresh, PullToRefreshConfigurator } from '@ohos/pulltorefresh';
import { Constant } from 'module_base';
import { ContentCard } from '../components/ContentCard';
import { BreakpointNameEnum, BreakpointType, GridRowColSetting } from '../constant/GridRowColSetting';
import { BAR_LIST, BarModel, CommonConstant } from '../constant/Index';
import { CardDataSource, PostCardModel } from '../model/Index';
import { QueryTravelogueListRequest } from '../model/IRequest';
import { queryTravelogueList } from '../utils/ApiManage';

@Builder
export function PageGroundBuilder() {
  PageGround({ isShowBack: false });
}

@ComponentV2
export struct PageGround {
  @Local isLoading: boolean = false;
  @Local currentIndex: number = 0;
  @Local curPageNum: number = 1;
  @Local list: CardDataSource = new CardDataSource();
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Local breakpoint: string = '';
  @Param @Require isShowBack: boolean;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  private scroller: Scroller = new Scroller();
  private pullConfig: PullToRefreshConfigurator = new PullToRefreshConfigurator();

  aboutToAppear(): void {
    this.setPullConfig();
    this.queryList();
  }

  getResourceString(name: string) {
    return this.getUIContext().getHostContext()!.resourceManager.getStringByName(name);
  }

  queryList(refresh: boolean = true) {
    if (refresh) {
      this.curPageNum = 1;
    }

    const data: QueryTravelogueListRequest = {
      type: BAR_LIST[this.currentIndex].value, pageNum: this.curPageNum, pageSize: 10,
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
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.query_fail') });
      return false;
    });
  }

  async setPullConfig() {
    this.pullConfig
      .setHasRefresh(true)// 是否具有下拉刷新功能
      .setHasLoadMore(true)// 是否具有上拉加载功能
      .setRefreshTextSize(14)// 下拉加载完毕后提示文本的字体大小
      .setLoadImgHeight(16)
      .setLoadTextSize(14)// 上拉文本的字体大小
      .setLoadTextPullUp1(await this.getResourceString('app.string.pull_load_text'))// 上拉1阶段文本
      .setLoadTextPullUp2(await this.getResourceString('app.string.pull_load_release'))// 上拉2阶段文本
      .setLoadTextLoading(await this.getResourceString('app.string.pull_loading'))// 上拉加载更多中时的文本
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
        }.width(CommonConstant.FULL_PERCENT);
      });
    }
    .edgeEffect(EdgeEffect.Spring)
    .cachedCount(10)
    .columnsTemplate(new BreakpointType({
      [BreakpointNameEnum.SM]: '1fr '.repeat(2),
      [BreakpointNameEnum.MD]: '1fr '.repeat(3),
      [BreakpointNameEnum.LG]: '1fr '.repeat(5),
      [BreakpointNameEnum.XL]: '1fr '.repeat(5),
    }).getValue(this.breakpoint))
    .columnsGap(GridRowColSetting.getGutter(this.breakpoint))
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
                  resolve(this.getResourceString('app.string.refresh_success'));
                } else {
                  resolve(this.getResourceString('app.string.refresh_fail'));
                }
              });
          });
        },
        onLoadMore: () => {
          return new Promise<string>((resolve, reject) => {
            this.queryList(false)
              .then((isSuccess: boolean) => {
                if (isSuccess) {
                  resolve(this.getResourceString('app.string.load_success'));
                } else {
                  resolve(this.getResourceString('app.string.load_fail'));
                }
              });
          });
        },
        customLoad: null,
        customRefresh: null,
      });
    }.layoutWeight(1);
  }

  @Builder
  buildTabBar() {
    Row({ space: GridRowColSetting.getGutter(this.breakpoint) }) {
      ForEach(BAR_LIST, (item: BarModel, index: number) => {
        Row() {
          Text(item.label)
            .fontColor(this.currentIndex === index ? $r('sys.color.font_on_primary') : $r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Subtitle_M'))
            .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Regular);
        }
        .height(36)
        .borderRadius(20)
        .padding({ left: 16, right: 16 })
        .backgroundColor(
          this.currentIndex === index ? $r('sys.color.multi_color_04') : $r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.currentIndex = index;
          this.list.clearAllData();
          this.queryList();
        });
      }, (item: BarModel) => item.label.toString());
    }.width(CommonConstant.FULL_PERCENT).padding({ top: 10, bottom: 10 });
  }

  build() {
    NavDestination() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({ span: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS }) {
          Column() {
            Row({ space: 8 }) {
              SymbolGlyph($r('sys.symbol.chevron_backward'))
                .width(40)
                .height(40)
                .fontSize(24)
                .fontColor([$r('sys.color.icon_primary')])
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .borderRadius(1000)
                .padding(8)
                .onClick(() => {
                  this.mainPathStack.pop();
                });
              Text('游玩攻略')
                .fontSize($r('sys.float.Title_S'))
                .fontWeight(FontWeight.Bold)
                .fontColor($r('sys.color.font_primary'))
                .textAlign(TextAlign.Start);
            }.margin({ top: this.windowTopHeight }).width('100%').padding({ top: 8, bottom: 8 });

            Column() {
              this.buildTabBar();
              this.buildList();
            }.layoutWeight(1);
          }.width(CommonConstant.FULL_PERCENT).margin({
            top: 8,
            left: GridRowColSetting.getPageMargin(this.breakpoint),
            right: GridRowColSetting.getPageMargin(this.breakpoint),
          }).constraintSize({ maxWidth: Constant.FULL_PERCENT });
        };
      }.onBreakpointChange((bp) => {
        this.breakpoint = bp;
      });
    }.hideTitleBar(true).backgroundColor($r('sys.color.background_secondary'));
  }
}
