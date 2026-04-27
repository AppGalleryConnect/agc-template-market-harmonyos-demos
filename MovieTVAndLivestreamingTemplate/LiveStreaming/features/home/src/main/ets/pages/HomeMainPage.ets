import { scanBarcode, scanCore } from '@kit.ScanKit';
import { jumpDetailPage } from '@agctemplate/detail'
import { getMedia } from '@agctemplate/resources'
import { RouterMap, RouterModule } from '@agctemplate/router_module';
import { BigCard, CommonCard } from '../components/LiveCards'
import { BarVM, cardsData, LiveCard, LiveCardModel } from '@agctemplate/widgets'
import { Callback } from '@kit.BasicServicesKit';
import { AppStorageV2, display } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import { SearchPageBuilder } from './SearchPage';
import { SearchRecords } from '../viewmodels/SearchRecordsVM';

interface ScanInfo {
  articleId: string
}

export class TabStyle {
  static readonly BAR_HEIGHT = 48;
  static readonly ANIMATION_DURATION = 0;
  static readonly ICON_SIZE = 24;
}

@ComponentV2
export struct HomeMainPage {
  @Local searchRecords: SearchRecords = AppStorageV2.connect(SearchRecords, () => new SearchRecords())!
  @Local watchRecords: LiveCardModel = AppStorageV2.connect(LiveCardModel, () => new LiveCardModel(cardsData[0]))!
  @Provider('searchText') searchText: string = ''
  @Provider('isSearch') isSearch: boolean = false
  @Provider('isEdit') isEdit: boolean = false
  @Local curIndex: number = 0;
  private bigScroller: Scroller = new Scroller();
  private timer: number | null = null;
  @Provider('isShow') isShow: boolean = false
  @Local gridPadding: number = display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_FOLDED ? 0 : 16
  @Local isLandscapeTablet: boolean = display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE ||
    display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE_INVERTED &&
      deviceInfo.deviceType === 'tablet';
  @Local bottomSpace: number = 0
  callback: Callback<display.FoldStatus> = (data: display.FoldStatus) => {
    if (data === display.FoldStatus.FOLD_STATUS_FOLDED) {
      this.gridPadding = 0
    } else if (data === display.FoldStatus.FOLD_STATUS_EXPANDED) {
      this.gridPadding = 16
    }
    console.info('Listening enabled. Data: ' + JSON.stringify(data));
  };
  callback2: Callback<number> = (data: number) => {
    console.info(data.toString())
    if (display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE ||
      display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE_INVERTED &&
        deviceInfo.deviceType === 'tablet') {
      this.isLandscapeTablet = true
    } else {
      this.isLandscapeTablet = false
    }
  };
  private uiContext: UIContext = this.getUIContext();
  aboutToAppear() {
    this.startAutoPlay();
    try {
      display.on('foldStatusChange', this.callback);
      display.on('change', this.callback2);
    } catch (e) {
    }
  }

  // 生命周期：页面消失时停止自动轮播
  aboutToDisappear() {
    this.stopAutoPlay();
    try {
      display.off('change', this.callback2)
    } catch (e) {
    }
  }

  // 启动自动轮播
  startAutoPlay() {
    this.stopAutoPlay();
    this.timer = setInterval(() => {
      this.nextSlide();
    }, 3000);
  }

  // 停止自动轮播
  stopAutoPlay() {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = null;
    }
  }

  // 切换到下一张
  nextSlide() {
    let nextIndex = (this.curIndex + 1) % 3;
    this.uiContext.animateTo({ duration: 100 }, () => {
      this.bigScroller.scrollTo({ xOffset: 252 * nextIndex, yOffset: 0 });
    })
    this.curIndex = nextIndex;
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Text('直播')
            .width(232)
            .margin({ top: 12, bottom: 12 })
            .fontSize(24)
            .fontWeight(700)
            .fontColor($r('sys.color.font_primary'))
            .textAlign(TextAlign.Start)

          Blank()
          if (this.isLandscapeTablet) {
            Row() {
              Search({ value: $$this.searchText, placeholder: '搜索主播和游戏' })
                .width('100%')
                .margin({ right: 8 })
                .caretStyle({ width: 1.5, color: '#EE5D1A' })
                .onClick(() => {
                  this.isShow = true
                })
                .onSubmit((value: string) => {
                  if (value.trim() !== '') {
                    this.searchRecords.records.unshift(value.trim())
                  }
                  this.isSearch = true
                })
                .onEditChange((status: boolean) => {
                  if (status) {
                    this.isEdit = true
                  } else {
                    this.isEdit = false
                  }
                })
            }
            .width(400)
            .bindPopup(this.isShow, {
              builder: SearchPageBuilder,
              enableArrow: false,
              width: 400,
              placement: Placement.Bottom,
              onStateChange: (e) => {
                if (!e.isVisible) {
                  this.isShow = false;
                }
              }
            })

          } else {
            Button({ type: ButtonType.Circle }) {
              SymbolGlyph($r('sys.symbol.magnifyingglass'))
                .fontSize(24)
                .fontColor([$r('sys.color.icon_primary')])
            }
            .width(40)
            .height(40)
            .margin(8)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .onClick(() => {
              RouterModule.push({ url: RouterMap.SEARCH_PAGE })
            })
          }


          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.line_viewfinder'))
              .fontSize(24)
              .fontColor([$r('sys.color.icon_primary')])
          }
          .width(40)
          .height(40)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .onClick(() => {
            try {
              scanBarcode.startScanForResult(this.uiContext.getHostContext(), {
                scanTypes: [scanCore.ScanType.ALL],
                enableMultiMode: true,
                enableAlbum: true
              }).then((result: scanBarcode.ScanResult) => {
                RouterModule.stack.pushPathByName(RouterMap.DETAIL_PAGE,
                  (JSON.parse(result.originalValue) as ScanInfo).articleId)
              })
            } catch (e) {
            }
          })
        }
        .width('100%')
        .height(56)
        .padding({ right: 16, left: 16 })
        .margin({ top: this.isLandscapeTablet ? 0 : 12, bottom: 12 })

        Scroll(this.bigScroller) {
          Row({ space: 8 }) {
            ForEach([1, 2, 3], (i: number, index: number) => {
              BigCard({
                liveData: {
                  cover: getMedia(`app.media.cover_${i}`),
                  title: i === 1 ? '花瓣杯5V5总决赛' : i === 2 ? '来晚了，监狱跑刀' : '弹唱网友点歌',
                  watching: i === 1 ? 4225000 : i === 2 ? 7878787 : 666666,
                  status: i.toString()
                } as LiveCard
              })
                .onClick(() => {
                  jumpDetailPage('')
                })
            },(item: number, index: number) => { return index + '__' + JSON.stringify(item); })
          }
          .margin({ left: 16, right: 16 })
          .width('100%')
        }
        .onScrollStop(() => {
          if (this.bigScroller.currentOffset().xOffset > 126 && this.bigScroller.currentOffset().xOffset <= 378) {
            this.bigScroller.scrollTo({ xOffset: 252, yOffset: 0 });
            this.curIndex = 1;
          } else if (this.bigScroller.currentOffset().xOffset > 378) {
            this.bigScroller.scrollTo({ xOffset: 504, yOffset: 0 });
            this.curIndex = 2;
          } else {
            this.bigScroller.scrollTo({ xOffset: 0, yOffset: 0 });
            this.curIndex = 0;
          }
          this.stopAutoPlay();
        })
        .margin({ bottom: 8 })
        .width(deviceInfo.deviceType === 'tablet' ? 1102 : 748)
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)

        Row() {
          Text('在线主播')
            .margin({ left: 16, top: 16, bottom: this.isLandscapeTablet ? 8 : 16 })
            .height(24)
            .fontSize(18)
            .fontWeight(700)
            .fontColor($r('sys.color.font_primary'))
            .textAlign(TextAlign.Start)
        }
        .width('100%')


        Grid() {
          ForEach(cardsData, (card: LiveCard) => {
            GridItem() {
              CommonCard({ liveData: card })
            }
            .onClick(() => {
              this.watchRecords.id = card.id;
              jumpDetailPage('')
            })
          },(item: LiveCard, index: number) => { return index + '__' + JSON.stringify(item); })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .width('100%')
        .columnsTemplate('repeat(auto-stretch, 160)')
        .rowsGap(8)
        .columnsGap(8)
        .margin({ left: 16, right: 16 })
        .scrollBar(BarState.Off)
        .padding({ left: this.gridPadding, right: this.gridPadding, bottom: this.bottomSpace })
        .onScrollStart(() => {
          this.bottomSpace = 0
        })
        .onReachEnd(() => {
          this.bottomSpace =
            this.isLandscapeTablet ? 133 + this.getUIContext().px2vp(BarVM.instance.aiBarHeight.value) :
              TabStyle.BAR_HEIGHT + this.getUIContext().px2vp(BarVM.instance.aiBarHeight.value)
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_secondary'))
      .padding({
        top: BarVM.instance.staBarH
      })
    }.hideTitleBar(true)
  }
}

@Builder
export function HomeMainPageBuilder() {
  HomeMainPage()
}