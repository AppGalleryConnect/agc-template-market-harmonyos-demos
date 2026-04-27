/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { PullToRefresh, PullToRefreshConfigurator } from '@ohos/pulltorefresh';
import { BAR_LIST, BarModel, CommonConstant } from '../constant/Index';
import { CardDataSource, PostCardModel } from '../model/Index';
import { queryTravelogueList } from '../utils/ApiManage';
import { ContentCard } from '../components/ContentCard';
import { QueryTravelogueListRequest } from '../model/IRequest';

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
  @Param @Require isShowBack: boolean;
  private scroller: Scroller = new Scroller();
  private pullConfig: PullToRefreshConfigurator = new PullToRefreshConfigurator();
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

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
        }
        .width(CommonConstant.FULL_PERCENT);
      });
    }
    .edgeEffect(EdgeEffect.Spring)
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
    }.layoutWeight(1).backgroundColor($r('app.color.page_bg'))
    .padding(6);
  }

  @Builder
  buildTabBar() {
    Row({ space: 16 }) {
      ForEach(BAR_LIST, (item: BarModel, index: number) => {
        Column() {
          Text(item.label)
            .fontColor(this.currentIndex === index ? $r('app.color.grey_level_9') : $r('app.color.grey_level_4'))
            .fontSize(16)
            .fontWeight(this.currentIndex === index ? 500 : 400)
            .lineHeight(20)
            .margin({ bottom: 2 });
          Divider()
            .width(20)
            .strokeWidth(2)
            .opacity(this.currentIndex === index ? 1 : 0);
        }.onClick(() => {
          this.currentIndex = index;
          this.list.clearAllData();
          this.queryList();
        });
      }, (item: BarModel) => item.label.toString());
    }
    .width(CommonConstant.FULL_PERCENT)
    .justifyContent(FlexAlign.Center);
  }

  @Builder
  buildTitle() {
    Row() {
      if (this.isShowBack) {
        Image($r('app.media.ic_public_back'))
          .width(14)
          .height(28)
          .fillColor($r('app.color.grey_level_9'))
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            this.mainPathStack.pop()
          });
        Text($r('app.string.water_flow_title'))
          .fontSize(18)
          .fontColor($r('app.color.grey_level_9'))
          .fontWeight(400)
          .lineHeight(24)
          .margin({ left: 8 });
      }
      Blank();
      Image($r('app.media.ic_public_input_search'))
        .width(22)
        .objectFit(ImageFit.Contain)
        .fillColor($r('app.color.black'))
        .onClick(() => {
          this.mainPathStack.pushPathByName('PageSearch', null);
        });
    }.width(CommonConstant.FULL_PERCENT).padding({ left: 10, right: 10 }).hitTestBehavior(HitTestMode.Transparent);
  }

  @Builder
  buildTop() {
    Stack() {
      this.buildTabBar();
      this.buildTitle();
    }.padding({ top: 8, bottom: 8 }).align(Alignment.Center);
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Start }) {
        Text('游玩攻略').fontSize(18).fontWeight(500).width('100%').textAlign(TextAlign.Center);
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

      Column() {
        this.buildTop();
        this.buildList();
      }
      .width(CommonConstant.FULL_PERCENT)
      .height(CommonConstant.FULL_PERCENT);
    }.hideTitleBar(true);
  }
}
