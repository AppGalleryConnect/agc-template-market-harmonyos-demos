import { CommonConstants, loadingPage } from 'lib_common';
import { NewsModel } from 'lib_news_api';
import { emptyBuilder, NavHeaderBar } from 'lib_widget';
import { EditCheckbox, HeaderRightPart, ToolBarBottom } from '../components/BaseHistoryComment';
import { LiveReservationCard } from '../components/LiveReservationCard';
import { LiveReservationListVM } from '../viewmodels/LiveReservationListVM';

@Builder
export function LiveReservationPageBuilder() {
  LiveReservationPage()
}

@ComponentV2
struct LiveReservationPage {
  @Local vm: LiveReservationListVM = new LiveReservationListVM();

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '我的预约',
        rightPartBuilder: () => {
          this.rightPartBuilder()
        },
      })
      Column() {
        if (this.vm.loadingModel.loading) {
          loadingPage()
        } else if (this.vm.list.length <= 0) {
          Column() {
            emptyBuilder({
              text: '暂无预约',
              fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
            })
          }
          .layoutWeight(1)
        } else {
          Column() {
            Refresh({ refreshing: $$this.vm.isRefresh }) {
              List({ space: CommonConstants.SPACE_M, scroller: this.vm.scroller }) {
                Repeat(this.vm.list)
                  .virtualScroll()
                  .key((item: NewsModel) => item.id)
                  .each((item: RepeatItem<NewsModel>) => {
                    ListItem() {
                      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                        if (this.vm.isEditMode) {
                          EditCheckbox({
                            onChange: (value) => {
                              this.vm.onChange(value, item.item);
                            },
                          })
                        }

                        LiveReservationCard({
                          reservationInfo: item.item,
                          refreshCard: this.vm.refreshCard,
                          refreshList: () => {
                            this.vm.refresh();
                          },
                        })
                          .hitTestBehavior(this.vm.isEditMode ? HitTestMode.Block : HitTestMode.Default)
                      }
                    }
                    .clip(true)
                    .swipeAction(this.vm.isEditMode ? {} : {
                      end: {
                        builder: this.deleteSwipeActionBuilder(item.item),
                        onAction: () => {
                          this.vm.deleteSingleConfirm(item.item);
                        },
                      },
                    })
                  })
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
            }
            .layoutWeight(1)
            .onRefreshing(() => {
              this.vm.refresh();
            })

            if (this.vm.isEditMode) {
              this.toolBarBuilder()
            }
          }
          .layoutWeight(1)
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .layoutWeight(1)
      .padding({
        bottom: this.vm.windowModel.windowBottomPadding,
      })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .onBackPressed(() => {
      return this.vm.onBackPressed();
    })
  }

  @Builder
  deleteSwipeActionBuilder(v: NewsModel) {
    Button() {
      SymbolGlyph($r('sys.symbol.trash_fill'))
        .fontColor([$r('sys.color.font_on_primary')])
        .fontWeight(FontWeight.Normal)
        .fontSize($r('app.float.normal_img_size'))
    }
    .width(40)
    .height(40)
    .type(ButtonType.Circle)
    .backgroundColor($r('sys.color.warning'))
    .margin({ left: CommonConstants.PADDING_L })
    .onClick(() => {
      this.vm.deleteSingleConfirm(v);
    })
  }

  @Builder
  rightPartBuilder() {
    HeaderRightPart({ vm: this.vm, isTextButton: true })
  }

  @Builder
  toolBarBuilder() {
    ToolBarBottom({ vm: this.vm })
  }
}