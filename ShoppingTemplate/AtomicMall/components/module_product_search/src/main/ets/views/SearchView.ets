import { Constants } from '../commons/Constants';
import { HistorySearch } from '../components/HistorySearch';
import { SearchVM } from '../viewmodels/SearchVM';
import { curves, LengthMetrics } from '@kit.ArkUI';
import { HotSearchItem } from '../commons/Types';
import { SearchBar } from '../components/SearchBar';

@ComponentV2
export struct SearchView {
  @Param
  defaultSearch: string = '';
  @Param
  routerStack: NavPathStack = new NavPathStack();
  @Param
  showGuessLike: boolean = true
  @Param
  showHotSearch: boolean = true
  @Event
  handleSearch: (value: string) => void = () => {
  };
  @Local
  animate: boolean = false;
  @Local
  refreshRotateVal: number = 0;
  vm: SearchVM = new SearchVM(this.getUIContext());
  controller: SearchController = new SearchController();

  @Computed
  get keyword() {
    return this.vm.searchWords ? this.vm.searchWords : this.defaultSearch
  }

  aboutToAppear(): void {
    this.vm.initData();
  }

  build() {
    Column() {
      SearchBar({
        placeholder: this.defaultSearch,
        searchWords: this.vm.searchWords,
        clickBack: () => {
          this.routerStack?.pop?.();
        },
        updateSearchWords: (value) => {
          this.vm.searchWords = value;
        },
        submitSearch: () => {
          this.vm.submitSearch(this.keyword, this.handleSearch);
        },
      })
        .padding({ bottom: 8, right: 8 })
        .backgroundColor($r('app.color.background_color_primary'))
      Scroll() {
        if (this.vm.isLoading) {
          LoadingProgress().width(32).height(32);
        } else {
          Column({
            space: 16,
          }) {
            HistorySearch({
              historyList: this.vm.historyList,
              handleClickItem: (value) => {
                this.vm.submitSearch(value, this.handleSearch);
              },
              updateList: (list) => {
                this.vm.updateHistoryList(list);
              },
            });
            if (this.showGuessLike) {
              this.guessLikeBuilder();
            }
            if (this.showHotSearch) {
              this.hotSearchBuilder();
            }

            Blank().height(56)
          };
        }
      }
      .layoutWeight(1)
      .width('100%')
      .align(Alignment.Top)
      .padding(Constants.SPACE_L)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .backgroundColor($r('app.color.background_color_grey'));
  }

  @Builder
  guessLikeBuilder() {
    Column() {
      Row() {
        Text('猜你想搜')
          .fontSize(14)
          .fontColor($r('app.color.font_color_level2'));

        Image($r('app.media.ic_refresh'))
          .width(16)
          .height(16)
          .rotate({ angle: this.refreshRotateVal })
          .onClick(() => {
            this.getUIContext()?.animateTo({ curve: curves.springMotion() }, () => {
              this.animate = !this.animate;
              this.refreshRotateVal = this.animate ? 360 : 0;
            });
            this.vm.getGuessLikeList();
          });
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: Constants.SPACE_L });

      Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
        ForEach(this.vm.guessLikeList, (item: string) => {
          Text(item)
            .fontColor($r('app.color.font_color_level1'))
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('45%')
            .flexShrink(0)
            .onClick(() => {
              this.vm.submitSearch(item, this.handleSearch);
            });
        }, (item: string, index: number) => index + '__' + item);
      }
      .padding({ left: Constants.SPACE_M, right: Constants.SPACE_M });

    };
  }

  @Builder
  hotSearchBuilder() {
    Column() {
      Row() {
        Image($r('app.media.ic_hot_search'))
          .width(24)
          .height(24)
          .margin({ right: Constants.SPACE_XS });
        Text('热搜榜')
          .fontSize(18)
          .fontColor($r('app.color.font_color_level1'))
          .fontWeight(FontWeight.Bold);
      };

      ForEach(this.vm.hotSearchList, (item: HotSearchItem, index: number) => {
        Row() {
          Text() {
            Span(`${index + 1}. `)
              .fontColor(index < 3 ? Constants.THEME_COLOR : $r('app.color.font_color_level1'));
            Span(item.label);
          }
          .fontSize(14)
          .fontColor($r('app.color.font_color_level1'))
          .width('75%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });

          Text('热度 ' + item.hotRate)
            .fontSize(14)
            .fontColor($r('app.color.font_color_level2'));
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: Constants.SPACE_L })
        .onClick(() => {
          this.vm.submitSearch(item.label, this.handleSearch);
        });
      }, (item: HotSearchItem, index: number) => index + '__' + item.label);
    }
    .alignItems(HorizontalAlign.Start)
    .margin({ top: Constants.SPACE_S })
    .width('100%');
  }
}