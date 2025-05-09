import { JSON, util } from '@kit.ArkTS';
import {
  BreakpointConstants,
  BreakpointType, CommonConstants, Logger,
  NewsData,
  NewsDataSource,
  PreferencesUtil, RouterMap, RouterModule } from 'commonlib';
import { GetMyOrderResp, Good, HttpRequestApi } from 'network';
import { BusinessError } from '@kit.BasicServicesKit';
import { HomePageVM } from '../viewModels/HomePageVM';

const NEWS_TITLE_MAX_LINES: number = 1;
const NEWS_TITLE_TEXT_FONT_WEIGHT: number = 500;
const NEWS_CONTENT_MAX_LINES: number = 2;
const NEWS_TIME_MAX_LINES: number = 1;
const NEWS_RESOLVE_SUCCESS: string = getContext(this).resourceManager.getStringSync($r('app.string.refresh').id);
const NEWS_MOCK_DATA_COUNT: number = 8;
const MOCK_DATA_FILE_ONE_DIR: string = getContext(this).resourceManager.getStringSync($r('app.string.mock1').id);
const MOCK_DATA_FILE_TWO_DIR: string = getContext(this).resourceManager.getStringSync($r('app.string.mock2').id);
const NEWS_REFRESH_TIME: number = 1000;
const swiperImage: Resource[] = [
  $r('app.media.ic_picture'),
  $r('app.media.ic_fengjing_01')
]

@Builder
export function pullToRefreshNewsBuilder() {
  PullToRefreshNews()
}

@ComponentV2
export struct PullToRefreshNews {
  @Local newsData: NewsDataSource = new NewsDataSource();
  @Local firstIndex: number = 0;
  @Local isRefreshing: boolean = false;
  private listScroller: ListScroller = new ListScroller();
  private mockFlag: boolean = true;
  private scroller: Scroller = new Scroller();
  readonly ANIMATION_DURATION: number = 500;
  readonly SWITCH_BUTTON: number = 3;
  @Local changeFontSize: number = 0;
  @Local isLoading: boolean = false;
  @Local isLoadingMore: boolean = false;
  @Local offsetY: number = 0;
  @Local showUpBtn: boolean = false;
  vm: HomePageVM = HomePageVM.instance;

  aboutToAppear() {
    PreferencesUtil.getChangeFontSize().then((value:number) => {
      this.changeFontSize = value;
      Logger.info('setfontsize', 'Get the value of changeFontSize: ' + this.changeFontSize);
    });
    let newsModelMockData: NewsData[] = getNews(MOCK_DATA_FILE_ONE_DIR);
    for (let j = CommonConstants.ZERO; j < NEWS_MOCK_DATA_COUNT; j++) {
      this.newsData.pushData(newsModelMockData[j]);
    }
    this.getOrderInfo();
  }

  getOrderInfo() {
    HttpRequestApi.getGoodInfo('1').then((resp: Good) => {
      if (resp) {
        console.info(`getGoodInfo resp:${JSON.stringify(resp)}.`);
      } else {
        console.error(`getGoodInfo error: ${JSON.stringify(resp)}.`);
      }
    })
      .catch((e: BusinessError) => {
        console.error(`getGoodSpec error: ${JSON.stringify(e)}.`);
      })
  }

  @Builder
  customRefreshComponent() {
    Row() {
      LoadingProgress().color($r('sys.color.icon_secondary')).width(32).height(32)
    }
    .height(32)
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  footer() {
    Row() {
      LoadingProgress().height(32).width(32)
      Text('加载中')
    }.width('100%')
    .height(64)
    .justifyContent(FlexAlign.Center)
    // 当不处于加载中状态时隐藏组件。
    .visibility(this.isLoading ? Visibility.Hidden : (this.isLoadingMore ? Visibility.Visible : Visibility.Hidden))
  }

  build() {
    NavDestination() {
        Column() {
          Stack() {
            Refresh({ refreshing: $$this.isRefreshing, builder: this.customRefreshComponent }) {
              List({ space: 24, scroller: this.listScroller }) {
                ListItem() {
                  this.CustomSwiper()
                }
                .backgroundColor(Color.White)
                .borderRadius(16)
                .onClick(() => {
                  RouterModule.push({ url: RouterMap.NEWS_DETAIL, param: null });
                })
                LazyForEach(this.newsData, (item: NewsData, index: number) => {
                  ListItem() {
                    newsItem({
                      newsTitle: item.newsTitle,
                      newsContent: item.newsContent,
                      newsTime: item.newsTime,
                      newsImage: item.newsImage
                    })
                      .onClick(() => {
                        RouterModule.push({ url: RouterMap.NEWS_DETAIL, param: null });
                      })
                  }
                }, (item: NewsData) => JSON.stringify(item))

                ListItem() {
                  this.footer()
                }
              }
              .width('100%')
              .height('100%')
              .scrollBar(BarState.Off)
              .onScrollIndex((start: number, end: number) => {
                // 当达到列表末尾时，触发新数据加载。
                this.firstIndex = start;
                if (end >= this.newsData.totalCount() - 1) {
                  this.isLoadingMore = true;
                  setTimeout(() => {
                    let newsModelMockData: NewsData[] = getNews(MOCK_DATA_FILE_ONE_DIR);
                    for (let j = CommonConstants.ZERO; j < NEWS_MOCK_DATA_COUNT; j++) {
                      this.newsData.pushData(newsModelMockData[j]);
                    }
                    this.isLoadingMore = false;
                  }, NEWS_REFRESH_TIME);

                }
              })
              .scrollBar(BarState.Off)
              // 开启边缘滑动效果。
              .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
              .onScrollVisibleContentChange((start: VisibleListContentInfo, end: VisibleListContentInfo) => {
                if (this.offsetY !== 0) {
                  this.showUpBtn = start.index > 0
                }
              })
              .onScrollFrameBegin((offset: number, state: ScrollState) => {
                this.offsetY = offset
                return { offsetRemain: offset }
              })
            }
            .layoutWeight(1)
            .onRefreshing(() => {
              return new Promise<string>((resolve, reject) => {
                setTimeout(() => {
                  this.newsData.clear();
                  let newsModelMockData: NewsData[] = [];
                  if (this.mockFlag) {
                    newsModelMockData = getNews(MOCK_DATA_FILE_TWO_DIR);
                  } else {
                    newsModelMockData = getNews(MOCK_DATA_FILE_ONE_DIR);
                  }
                  this.mockFlag = !this.mockFlag;
                  for (let j = CommonConstants.ZERO; j < NEWS_MOCK_DATA_COUNT; j++) {
                    this.newsData.pushData(newsModelMockData[j]);
                  }
                  this.isRefreshing = false
                  resolve(NEWS_RESOLVE_SUCCESS);
                }, NEWS_REFRESH_TIME);
              });

            })
            .pullToRefresh(true)
            .refreshOffset(64)

            Row() {
              Image($r('app.media.ic_public_backtotop'))
                .width(24)
                .height(24)
                .opacity(0.8)
            }
            .onClick(() => {
              if (this.firstIndex >= this.SWITCH_BUTTON) {
                this.listScroller.scrollToIndex(0, true)
                this.offsetY = 0
              }
            })
            .visibility(this.firstIndex >= this.SWITCH_BUTTON ? Visibility.Visible : Visibility.None)
            .justifyContent(FlexAlign.Center)
            .width(48)
            .height(48)
            .backgroundColor('#0A59F7')
            .borderRadius(24)
            .margin({
              right: 32,
              bottom: 60
            })
          }
          .alignContent(Alignment.BottomEnd)
          .layoutWeight(1)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Color.White)
      }
  }

  @Builder
  CustomSwiper() {
    Column(){
      Text('华为发布机场智能运控中心等五大航空解决方案，加速行业智能化,加速行业智能化,引领行业智能化升级。')
        .fontSize(`${16 + this.vm.changeFontSize}`)
        .fontColor($r('app.color.news_title_fontColor'))
        .layoutWeight(CommonConstants.LAYOUT_WEIGHT)
        .maxLines(NEWS_CONTENT_MAX_LINES)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontWeight('medium')
        .padding({ right: 8, left: 12, top: 12 })
        .width('100%')
      Swiper() {
        ForEach(swiperImage, (item: string) => {
          Image(item)
            .aspectRatio(2.25)
            .borderRadius(8)
            .backgroundColor(Color.White)
        }, (item: string) => JSON.stringify(item))
      }
      .borderRadius(8)
      .margin({ right: 12, left: 12, top: 4 })
      .backgroundColor(Color.White)
      Row() {
        Text('xx新闻')
          .fontSize(`${10 + this.vm.changeFontSize}`)
          .fontWeight('regular')
          .fontFamily('鸿蒙黑体')
          .fontColor($r('app.color.news_time_fontColor'))
          .margin({bottom: 6})

        Text('2025年04月12日')
          .fontSize(`${10 + this.vm.changeFontSize}`)
          .fontWeight('regular')
          .fontFamily('鸿蒙黑体')
          .fontColor($r('app.color.news_time_fontColor'))
          .margin({bottom: 6,left: 8})
      }
      .width('100%')
      .margin({left: 24,top: 10})
    }
    .height(`${252 + this.vm.changeFontSize}`)
  }


  aboutToDisappear() {
    this.newsData.clear();
  }
}

@ComponentV2
struct newsItem {
  @Param  newsTitle: string | Resource = '';
  @Param  newsContent: string | Resource = '';
  @Param  newsTime: string | Resource = '';
  @Param  newsImage: string | Resource = '';
  vm: HomePageVM = HomePageVM.instance;

  build() {
    Row() {
      Column() {
        Row() {
          Image($r('app.media.new'))
            .width($r('app.string.news_title_image_width'))
            .height($r('app.string.news_title_image_height'))
            .objectFit(ImageFit.ScaleDown)
          Text(this.newsTitle)
            .fontSize(`${16 + this.vm.changeFontSize}`)
            .fontColor($r('app.color.news_title_fontColor'))
            .layoutWeight(CommonConstants.LAYOUT_WEIGHT)
            .maxLines(NEWS_TITLE_MAX_LINES)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontWeight(NEWS_TITLE_TEXT_FONT_WEIGHT)
        }
        .alignItems(VerticalAlign.Center)
        .height($r('app.string.news_title_row_height'))
        .width($r('app.string.news_List_width'))
        .margin({ top: 2 })
        Row() {
          Text(this.newsContent)
            .fontSize(`${14 + this.vm.changeFontSize}`)
            .lineHeight(`${18 + this.vm.changeFontSize}`)
            .fontColor($r('app.color.news_content_fontColor'))
            .width($r('app.string.news_List_width'))
            .maxLines(NEWS_CONTENT_MAX_LINES)
            .margin({ top: $r('app.string.news_content_margin') })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(CommonConstants.LAYOUT_WEIGHT)
        .alignItems(VerticalAlign.Top)

        Row() {
          Text('xx新闻')
            .fontSize(`${10 + this.vm.changeFontSize}`)
            .fontWeight('regular')
            .fontFamily('鸿蒙黑体')
            .fontColor($r('app.color.news_time_fontColor'))
            .margin({bottom: 6})

          Text(this.newsTime)
            .fontSize(`${10 + this.vm.changeFontSize}`)
            .fontWeight('regular')
            .fontFamily('鸿蒙黑体')
            .fontColor($r('app.color.news_time_fontColor'))
            .margin({bottom: 6,left: 8})
        }
        .margin({top:`${2 * this.vm.changeFontSize}`})
      }
      .margin({ right: $r('app.string.news_column_margin') })
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(CommonConstants.LAYOUT_WEIGHT)

      if (this.newsImage) {
        Image($rawfile(`${this.newsImage}`))
          .height(100)
          .width(100)
          .borderRadius($r('app.float.image_border_radius'))
          .margin({
            top: $r('app.string.image_margin'),
            bottom: $r('app.string.image_margin')
          })
      }
    }
    .padding({
      left: $r('app.string.news_row_padding'),
      right: $r('app.string.news_row_padding')
    })
    .height(`${100 + 2 * this.vm.changeFontSize}`)
  }
}

class JsonNewsList {
  public newsList: NewsData[] = [];
}

class JsonNewsData {
  private jsonFileDir: string = '';

  constructor(jsonFileDir: string) {
    this.jsonFileDir = jsonFileDir;
  }

  getNewsData(): Array<NewsData> {
    let value = getContext().resourceManager.getRawFileContentSync(this.jsonFileDir);
    let textDecoder = util.TextDecoder.create('utf-8', {
      ignoreBOM: true
    });
    let textDecoderResult = textDecoder.decodeWithStream(new Uint8Array(value.buffer));
    let jsonObj: JsonNewsList = JSON.parse(textDecoderResult) as JsonNewsList;
    let newsModelBuckets: NewsData[] = [];
    let newsModelObj = jsonObj.newsList;
    for (let i = CommonConstants.ZERO; i < newsModelObj.length; i++) {
      let contactTemp = new NewsData(newsModelObj[i].newsId, newsModelObj[i].newsTitle,
        newsModelObj[i].newsContent, newsModelObj[i].newsTime, newsModelObj[i].newsImage);
      newsModelBuckets.push(contactTemp);
    }
    return newsModelBuckets;
  }
}

function getNews(mockFileDir: string): Array<NewsData> {
  let jsonObj: JsonNewsData = new JsonNewsData(mockFileDir);
  let newsModelMockData: NewsData[] = jsonObj.getNewsData();
  return newsModelMockData;
}
