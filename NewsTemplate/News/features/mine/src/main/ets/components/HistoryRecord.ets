import { JSON, util } from '@kit.ArkTS';
import { BreakpointConstants, BreakpointType, CommonConstants, NewsData,
  NewsDataSource,
  RouterMap, RouterModule } from 'commonlib';
import { MainPageVM } from '../viewModels/MainPageVM';

const NEWS_TITLE_MAX_LINES: number = 1;
const NEWS_TITLE_TEXT_FONT_WEIGHT: number = 500;
const NEWS_CONTENT_MAX_LINES: number = 2;
const NEWS_TIME_MAX_LINES: number = 1;
const NEWS_RESOLVE_SUCCESS: string = getContext(this).resourceManager.getStringSync($r('app.string.refresh').id);
const NEWS_MOCK_DATA_COUNT: number = 8;
const MOCK_DATA_FILE_ONE_DIR: string = getContext(this).resourceManager.getStringSync($r('app.string.mock1').id);
const MOCK_DATA_FILE_TWO_DIR: string = getContext(this).resourceManager.getStringSync($r('app.string.mock2').id);
const NEWS_REFRESH_TIME: number = 1000;

@Builder
export function historyRecordBuilder() {
  HistoryRecord();
}

@ComponentV2
export struct HistoryRecord {
  vm: MainPageVM = MainPageVM.instance;
  @Local newsData: NewsDataSource = new NewsDataSource();
  @Local firstIndex: number = 0;
  private mockFlag: boolean = true;
  private listScroller: ListScroller = new ListScroller();
  readonly ANIMATION_DURATION: number = 500;
  readonly SWITCH_BUTTON: number = 3;
  @Local navTitle: string = '';
  @Local isRefreshing: boolean = false;
  @Local isLoading: boolean = false;
  @Local isLoadingMore: boolean = false;
  @Local offsetY: number = 0;
  @Local showUpBtn: boolean = false;

  aboutToAppear() {
    let newsModelMockData: NewsData[] = getNews(MOCK_DATA_FILE_ONE_DIR);
    for (let j = CommonConstants.ZERO; j < NEWS_MOCK_DATA_COUNT; j++) {
      this.newsData.pushData(newsModelMockData[j]);
    }
  }

  build() {
    NavDestination() {
        Column() {
          Stack() {
            Refresh({ refreshing: $$this.isRefreshing }) {
              List({ space: 24, scroller: this.listScroller }) {
                LazyForEach(this.newsData, (item: NewsData, index: number) => {
                  ListItem() {
                    newsItem({
                      newsTitle: item.newsTitle,
                      newsTime: item.newsTime,
                      newsImage: item.newsImage,
                      newsContent: item.newsContent
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
              .height('100%')
              .width('100%')
              .scrollBar(BarState.Off)
              .onScrollIndex((start: number, end: number) => {
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
                .width(24).height(24).opacity(0.8)
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
            .margin({
              right: 32,
              bottom: 10
            })
            .backgroundColor('#0A59F7')
            .borderRadius(24)
          }
          .alignContent(Alignment.BottomEnd)
          .layoutWeight(1)
        }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.White)
    }
    .title(this.navTitle)
    .onReady(() => {
      let params: string | undefined = RouterModule.getNavParam({
        url: RouterMap.HISTORY_RECORD,
      });
      if(params){
        this.navTitle = params;
      }
    });
  }

  @Builder
  footer() {
    Row() {
      LoadingProgress()
        .height(32)
        .width(32)
      Text('加载中')
    }
    .width('100%')
    .height(64)
    .justifyContent(FlexAlign.Center)
    // 当不处于加载中状态时隐藏组件。
    .visibility(this.isLoading ? Visibility.Hidden : (this.isLoadingMore ? Visibility.Visible : Visibility.Hidden))
  }

  aboutToDisappear() {
    this.newsData.clear();
  }
}

@ComponentV2
struct newsItem {
  @Param newsTitle: string | Resource = '';
  @Param newsContent: string | Resource = '';
  @Param newsTime: string | Resource = '';
  @Param newsImage: string | Resource = '';
  vm: MainPageVM = MainPageVM.instance;

  build() {
    Row() {
      Column() {
        Row() {
          Image($r('app.media.new'))
            .width(40)
            .height(16)
            .objectFit(ImageFit.ScaleDown)
          Text(this.newsTitle)
            .fontSize(`${16 + this.vm.changeFontSize}`)
            .fontColor('#000000')
            .layoutWeight(CommonConstants.LAYOUT_WEIGHT)
            .maxLines(NEWS_TITLE_MAX_LINES)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontWeight(NEWS_TITLE_TEXT_FONT_WEIGHT)
        }
        .alignItems(VerticalAlign.Center)
        .height(20)
        .width('100%')
        .margin({ top: 10 })

        Row() {
          Text(this.newsContent)
            .fontSize(`${14 + this.vm.changeFontSize}`)
            .lineHeight((`${18 + this.vm.changeFontSize}`))
            .fontColor('#000000')
            .width('100%')
            .maxLines(NEWS_CONTENT_MAX_LINES)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .margin({ top: 10 })
        .layoutWeight(CommonConstants.LAYOUT_WEIGHT)

        Row() {
          Text('xx新闻')
            .fontSize(`${10 + this.vm.changeFontSize}`)
            .fontWeight('regular')
            .fontFamily('鸿蒙黑体')
            .fontColor('#FF989898')
            .margin({bottom: 6})

          Text(this.newsTime)
            .fontSize(`${10 + this.vm.changeFontSize}`)
            .fontWeight('regular')
            .fontFamily('鸿蒙黑体')
            .fontColor('#FF989898')
            .margin({bottom: 6,left: 8})
        }
        .margin({top:`${2 * this.vm.changeFontSize}`})
      }
      .margin({ right: 12 })
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(CommonConstants.LAYOUT_WEIGHT)

      if (this.newsImage) {
        Image($rawfile(`${this.newsImage}`))
          .height(110)
          .width(110)
          .borderRadius(8)
          .margin({
            top: 12,
            bottom: 12
          })
      }
    }
    .padding({
      left: 12,
      right: 12
    })
    .height(`${110 + 2 * this.vm.changeFontSize}`)
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
    let textDecoderResult = textDecoder.decodeToString(new Uint8Array(value.buffer));
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

