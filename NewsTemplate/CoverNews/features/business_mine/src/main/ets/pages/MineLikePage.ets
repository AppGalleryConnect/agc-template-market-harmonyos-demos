import { CommonConstants, emptyBuilder, loadingPage, NewsItem } from 'lib_common';
import { EditCheckbox } from '../components/EditCheckbox';
import { NewsCard } from '../components/NewsCard';
import { ToolBarBottom } from '../components/ToolBarBottom';
import { MineLikePageVM } from '../viewmodels/MineLikePageVM';

@Builder
export function MineLikePageBuilder() {
  MineLikePage()
}

@ComponentV2
struct MineLikePage {
  private vm: MineLikePageVM = new MineLikePageVM();

  build() {
    NavDestination() {
      Column() {
        if (this.vm.loadingModel.loading) {
          loadingPage()
        } else if (this.vm.list.length <= 0) {
          Column() {
            emptyBuilder()
          }
        } else {
          Column() {
            this.toolBarTop()
            this.refreshContent()
            if (this.vm.isEditMode) {
              ToolBarBottom({ vm: this.vm })
            }
          }
          .layoutWeight(1)
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .title('我的点赞')
    .backgroundColor($r('sys.color.background_secondary'))
    .onBackPressed(() => {
      return this.vm.onBackPressed();
    })
  }

  @Builder
  toolBarTop() {
    Row() {
      Button() {
        if (this.vm.isEditMode) {
          Text('取消')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
        } else {
          Text('批量管理')
            .fontSize($r('sys.float.Body_L'))
            .fontColor(this.vm.allowEnterEdit ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Medium)
        }
      }
      .enabled(this.vm.allowEnterEdit)
      .backgroundColor(Color.Transparent)
      .padding(0)
      .onClick(() => {
        if (this.vm.isEditMode) {
          this.vm.quitEdit();
        } else {
          this.vm.enterEdit();
        }
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(40)
    .justifyContent(FlexAlign.End)
    .padding({
      left: this.vm.breakPointModel.pagePadding,
      right: this.vm.breakPointModel.pagePadding,
    })
  }

  @Builder
  refreshContent() {
    if (this.vm.isEditMode) {
      Column() {
        this.listContent()
      }
      .layoutWeight(1)
    } else {
      Refresh({ refreshing: $$this.vm.isRefreshing }) {
        this.listContent()
      }
      .layoutWeight(1)
      .onRefreshing(() => {
        this.vm.refresh();
      })
    }
  }

  @Builder
  listContent() {
    List({ space: CommonConstants.SPACE_M, scroller: this.vm.scroller }) {
      Repeat(this.vm.list)
        .virtualScroll()
        .key((item: NewsItem) => item.id)
        .each((item: RepeatItem<NewsItem>) => {
          ListItem() {
            Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
              if (this.vm.isEditMode) {
                EditCheckbox({
                  onChange: (value) => {
                    this.vm.onChange(value, item.item);
                  },
                })
              }

              NewsCard({ newsInfo: item.item, allowClick: !this.vm.isEditMode })
            }
          }
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
    .height(CommonConstants.FULL_PERCENT)
    .scrollBar(BarState.Off)
    .lanes(this.vm.lanesMap.getValue(this.vm.breakPointModel.currentBreakpoint), 12)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .padding({
      left: this.vm.breakPointModel.pagePadding,
      right: this.vm.breakPointModel.pagePadding,
      bottom: CommonConstants.SPACE_M,
    })
  }

  @Builder
  deleteSwipeActionBuilder(v: NewsItem) {
    Button() {
      SymbolGlyph($r('sys.symbol.trash_fill'))
        .fontColor([$r('sys.color.font_on_primary')])
        .fontWeight(FontWeight.Normal)
        .fontSize(24)
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
}