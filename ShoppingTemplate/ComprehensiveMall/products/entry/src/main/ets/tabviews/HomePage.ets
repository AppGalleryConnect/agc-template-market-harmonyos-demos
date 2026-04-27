import { LoadingStatus } from 'lib_foundation';
import { CommonLoading, CommonSymbol, NavTitleBar } from 'lib_widget';
import { HomePageContent } from '../components/HomePageContent';
import { HomePageVM } from '../viewmodels/HomePageVM';

@ComponentV2
export struct HomePage {
  private vm: HomePageVM = new HomePageVM();
  scroller: Scroller = new Scroller();
  // 定义搜索框的最大高度
  private readonly MAX_SEARCH_HEIGHT: number = 60;
  // 控制搜索框区域的高度
  @Local searchAreaHeight: number = this.MAX_SEARCH_HEIGHT;

  aboutToAppear(): void {
    this.vm.loadHomePage()
  }

  build(): void {
    Column() {
      this.buildHeader()

      Refresh({
        refreshing: $$this.vm.isRefreshing,
        builder: this.buildRefreshingContent,
      }) {
        Scroll(this.scroller) {
          Column() {
            if (this.vm.loadingStatus === LoadingStatus.LOADING) {
              CommonLoading()
            } else if (this.vm.loadingStatus === LoadingStatus.SUCCESS) {
              HomePageContent({
                categoryList: this.vm.categoryList,
                bannerList: this.vm.bannerList,
                scroller: this.scroller,
                handleClickCategory: (id) => {
                  this.vm.jumpToCategoryPage(id);
                },
              })
                .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
            } else {
              Text('当前页面加载失败，请重新发起尝试')
                .fontSize($r('app.float.font_size_14'))
                .margin({ bottom: $r('app.float.space_l') })
                .fontColor($r('sys.color.mask_secondary'));
              Button('重新加载')
                .backgroundColor($r('app.color.theme_color'))
                .onClick(() => {
                  this.vm.loadHomePage()
                });
            }
          }
          .justifyContent(FlexAlign.Center)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        }
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .layoutWeight(1)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .onDidScroll((xOffset: number, yOffset: number) => {
          // 下拉刷新时保持展开
          if (this.scroller.currentOffset().yOffset <= 0) {
            this.searchAreaHeight = this.MAX_SEARCH_HEIGHT;
            return;
          }
          if (this.scroller.currentOffset().yOffset > 100) {
            this.searchAreaHeight = 0
            return;
          }

          let newHeight = this.searchAreaHeight - yOffset;
          if (newHeight < 0) {
            newHeight = 0;
          } else if (newHeight > this.MAX_SEARCH_HEIGHT) {
            newHeight = this.MAX_SEARCH_HEIGHT;
          }
          this.searchAreaHeight = newHeight;
        })
        .onScrollStop(() => {
          // 只有在非刷新状态，且高度处于中间状态时才触发吸附
          if (this.scroller.currentOffset().yOffset > 0) {
            this._snapSearchHeader();
          }
        })
      }
      .layoutWeight(1)
      .onStateChange((state) => {
        this.vm.onRefreshStateChange(state)
      })
      .pullDownRatio(this.vm.loadingStatus === LoadingStatus.SUCCESS ? 1 : 0)
      .backgroundColor($r('app.color.background_color_grey'))
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM]);
    }
    .width($r('app.string.size_percent_full'))
    .height($r('app.string.size_percent_full'))
    .backgroundColor($r('app.color.background_color_grey'))
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .transition(TransitionEffect.OPACITY.animation({ duration: 600 }))
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }

  @Builder
  buildHeader() {
    Column(){
      Row() {
        Text('首页')
          .fontSize($r('sys.float.Title_M'))
          .fontColor($r('app.color.font_color_level1'))
          .fontWeight(FontWeight.Bold)
        Blank()
        if (this.vm.isTablet) {
          this.buildSearchBar()
        } else if (this.searchAreaHeight === 0) {
          CommonSymbol({
            src: $r('sys.symbol.magnifyingglass'),
          })
            .onClick(() => {
              this.vm.jumpToSearchPage(this.getUIContext(), 'search')
            })
            .transition(TransitionEffect.OPACITY.animation({ duration: 600, curve: Curve.Ease }).combine(
              TransitionEffect.move(TransitionEdge.END),
            ))
        }
      }
      .height($r('app.float.nav_header_height'))
      .width('100%')
    }
    .backgroundColor(this.vm.isTablet ? $r('app.color.background_color_transparent') :
      $r('app.color.background_color_primary'))
    .expandSafeArea()
    .padding({
      left: $r('app.float.space_l'),
      right: $r('app.float.space_l'),
    })
    .width('100%')

    if (!this.vm.isTablet) {
      Column() {
        this.buildSearchBar()
      }
      .width('100%')
      .height(this.searchAreaHeight)
      .justifyContent(FlexAlign.Center)
      // 容器整体透明度
      .opacity(this.searchAreaHeight / this.MAX_SEARCH_HEIGHT)
      .visibility(this.searchAreaHeight <= 0 ? Visibility.None : Visibility.Visible)
      .backgroundColor($r('app.color.background_color_primary'))
      .clip(true)
    }
  }

  @Builder
  buildSearchBar() {
    Row() {
      Row() {
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontColor([$r('app.color.font_color_level1')])
          .margin({
            right: $r('app.float.space_l'),
          })
        Swiper() {
          ForEach(this.vm.searchList, (str: string) => {
            Text(str).fontColor($r('app.color.font_color_level2'))
          }, (str: string, index: number) => index + str)
          if (!this.vm.searchList.length) {
            Text('请输入关键字搜索').fontColor($r('app.color.font_color_level2'))
          }
        }
        .indicator(false)
        .loop(true)
        .autoPlay(true)
        .vertical(true)
        .onChange((index) => {
          if (this.vm.searchList.length) {
            this.vm.currentSearchStr = this.vm.searchList[index];
          }
        })
      }
      .height(40)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius(20)
      .layoutWeight(1)
      .padding({
        left: $r('app.float.space_l'),
        right: $r('app.float.space_l'),
      })
      .margin({ right: $r('app.float.space_s') })
      .id('search')
      .onClick(() => {
        this.vm.jumpToSearchPage(this.getUIContext(), 'search')
      })

      CommonSymbol({
        src: $r('sys.symbol.line_viewfinder'),
      })
        .onClick(() => {
          this.vm.jumpToScanPage()
        })
    }
    .width(this.vm.isTablet ? 400 : $r('app.string.size_percent_full'))
    .height(56)
    .backgroundColor(this.vm.isTablet ? $r('app.color.background_color_grey') :
      $r('app.color.background_color_primary'))
    .alignItems(VerticalAlign.Center)
    .padding({
      left: $r('app.float.space_l'),
      right: $r('app.float.space_l'),
    })
  }

  @Builder
  buildRefreshingContent() {
    Stack() {
      if (this.vm.refreshStatus === RefreshStatus.OverDrag) {
        Text('释放可刷新页面')
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.Body_M'))
          .lineHeight(32)
          .halfLeading(true);
      } else if (this.vm.refreshStatus === RefreshStatus.Drag) {
        Text('下拉刷新')
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.Body_M'))
          .lineHeight(32)
          .halfLeading(true);
      }
    }
    .align(Alignment.Center)
    .clip(true)
    .constraintSize({ minHeight: 32 })
    .width('100%')
    .backgroundColor($r('app.color.background_color_grey'))
  }

  private _snapSearchHeader() {
    let targetHeight: number;
    if (this.searchAreaHeight > this.MAX_SEARCH_HEIGHT / 2) {
      targetHeight = this.MAX_SEARCH_HEIGHT; // 恢复展开
    } else {
      targetHeight = 0; // 完全收起
    }
    if (this.searchAreaHeight === targetHeight) {
      return;
    }
    this.getUIContext().animateTo({
      duration: 300,
      curve: Curve.FastOutSlowIn,
    }, () => {
      this.searchAreaHeight = targetHeight;
    })
  }
}


@Builder
export function buildHomePage() {
  HomePage();
}
