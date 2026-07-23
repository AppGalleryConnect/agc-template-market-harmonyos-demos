import { CommonConstants, loadingPage } from 'lib_common';
import { NewsModel } from 'lib_news_api';
import { emptyBuilder, NavHeaderBar } from 'lib_widget';
import { EditCheckbox, HeaderRightPart, ToolBarBottom } from '../components/BaseHistoryComment';
import { UniformNewsCard } from '../components/UniformNewsCard';
import { HistoryViewModel } from '../viewmodels/HistoryVM';

@Builder
export function HistoryPageBuilder() {
  HistoryPage()
}

@ComponentV2
struct HistoryPage {
  @Local vm: HistoryViewModel = new HistoryViewModel();

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '历史',
          rightPartBuilder: () => {
            this.rightPartBuilder()
          },
        })
        if (this.vm.loadingModel.loading) {
          loadingPage()
        } else if (this.vm.list.length <= 0) {
          Column() {
            emptyBuilder({
              fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
            })
          }
          .layoutWeight(1)
        } else {
          Column() {
            List({ space: CommonConstants.SPACE_M }) {
              ForEach(this.vm.list, (v: NewsModel) => {
                ListItem() {
                  Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                    if (this.vm.isEditMode) {
                      EditCheckbox({
                        onChange: (value) => {
                          this.vm.onChange(value, v);
                        },
                      })
                    }

                    this.contentItemBuilder(v)
                  }
                }
              }, (v: NewsModel) => v.id)
            }
            .width(CommonConstants.FULL_PERCENT)
            .layoutWeight(1)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
            .lanes(this.vm.lanesMap.getValue(this.vm.breakPointModel.currentBreakpoint), 12)
            .padding({
              left: this.vm.breakPointModel.pagePadding,
              right: this.vm.breakPointModel.pagePadding,
              top: CommonConstants.SPACE_M,
              bottom: CommonConstants.SPACE_M,
            })

            if (this.vm.isEditMode) {
              this.toolBarBuilder()
            }
          }
          .layoutWeight(1)
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .padding({
        bottom: this.vm.windowModel.windowBottomPadding,
      })
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      return this.vm.onBackPressed();
    })
  }

  @Builder
  contentItemBuilder(v: NewsModel) {
    Row() {
      UniformNewsCard({
        newsInfo: v,
        showAuthorInfoTop: true,
        showAuthorInfoBottom: false,
        customStyle: {
          bodyFg: 16 * this.vm.settingInfo.fontSizeRatio,
        },
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      top: CommonConstants.PADDING_M,
      bottom: CommonConstants.PADDING_M,
    })
  }

  @Builder
  rightPartBuilder() {
    HeaderRightPart({ vm: this.vm })
  }

  @Builder
  toolBarBuilder() {
    ToolBarBottom({ vm: this.vm })
  }
}