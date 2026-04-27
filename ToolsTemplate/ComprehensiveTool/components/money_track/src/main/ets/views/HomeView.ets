import { BillConstants } from '../commons/Constants';
import { BalanceChangeType, HomeSheetType, RouterMap, SummaryType } from '../commons/Enums';
import { BillCardItem, DailyBillGroup } from '../commons/Types';
import { MoneyTrackHeader } from '../components/base/CommonHeader';
import { CommonMonthPicker } from '../components/base/CommonMonthPicker';
import { BillCard } from '../components/BillCard';
import { BillSummaryCard } from '../components/BillSummaryCard';
import { ChartSummary } from '../components/charts/ChartSummary';
import { TypeFilterSheet } from '../components/TypeFilterSheet';
import { BillManageUtil } from '../utils/BillManageUtil';
import { contextUtil } from '../utils/ContextUtil';
import { EventBus, EventKey } from '../utils/EventBus';
import { HomeVM } from '../viewmodels/HomeVM';

@Builder
export function buildHomeView() {
  HomeView()
}

@Entry
@ComponentV2
export struct HomeView {
  @Local
  stack: NavPathStack = new NavPathStack()
  @Local
  showSheet: boolean = false;
  @Local
  isRefreshing: boolean = false;
  vm: HomeVM = new HomeVM();

  aboutToAppear(): void {
    contextUtil.setUiContext(this.getUIContext())
  }

  build() {
    NavDestination() {
      Column() {
        MoneyTrackHeader({ title: '记账', stack: this.stack }) {
          Row() {
            SymbolGlyph($r('sys.symbol.plus'))
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor([BillConstants.FONT_COLOR_LEVEL1])
          }
          .justifyContent(FlexAlign.Center)
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor(BillConstants.BACKGROUND_COLOR_GREY_2)
          .onClick(() => {
            BillManageUtil.manageBill(undefined, undefined, () => {
              EventBus.instance.emit(EventKey.GLOBAL_REFRESH_EVENT);
            });
          })
        }

        Refresh({ refreshing: $$this.isRefreshing }) {
          Column() {
            // 筛选栏
            this.filterBarBuilder();
            // 收支概况
            BillSummaryCard({
              totalExpense: this.vm.chartData.totalExpense,
              totalIncome: this.vm.chartData.totalIncome,
            })
              .margin({ bottom: $r('app.string.space_m') })
            // 账单列表
            if (this.vm.summaryType === SummaryType.LIST) {
              this.billListBuilder();
            } else {
              ChartSummary({
                vm: this.vm,
              })
            }

          }
          .width($r('app.string.width_percent_full'))
          .alignItems(HorizontalAlign.Start)
          .padding({
            left: $r('app.string.space_l'),
            right: $r('app.string.space_l'),
          });
        }
        .layoutWeight(1)
        .onRefreshing(() => {
          this.vm.refreshBill().then(() => {
            this.isRefreshing = false;
          });
        });
      }
      .bindSheet($$this.showSheet, this.filterSheetBuilder(), {
        height: this.vm.sheet.sheetHeight,
        preferType: SheetType.BOTTOM,
        title: { title: this.vm.sheet.title },
      })
      .height($r('app.string.height_percent_full'))
      .width($r('app.string.width_percent_full'))
      .alignItems(HorizontalAlign.Start)
      .backgroundColor($r('app.color.system_color_background_auxiliary'))
      .backgroundImageSize(ImageSize.Contain)
      .justifyContent(FlexAlign.Start)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
    }
    .onReady(async (context) => {
      this.stack = context.pathStack;
      await this.vm.initData(context.pathStack, this.getUIContext());
    })
    .hideTitleBar(true)

  }

  @Builder
  filterSheetBuilder() {
    if (this.vm.sheet.type === HomeSheetType.DATE) {
      CommonMonthPicker({
        initMonth: this.vm.listData.date,
        handleConfirm: (dateStr: string) => {
          this.vm.changeMonth(dateStr);
          this.showSheet = false;
        },
        handleCancel: () => {
          this.showSheet = false;
        },
      });
    } else if (this.vm.sheet.type === HomeSheetType.TYPE) {
      TypeFilterSheet({
        initResource: this.vm.checkedResource,
        resource: this.vm.resource,
        handleCancel: () => {
          this.showSheet = false;
        },
        handleConfirm: (type: BalanceChangeType, key: number) => {
          this.vm.changeResource(type, key);
          this.showSheet = false;
        },
      });
    }
  }

  @Builder
  filterBarBuilder() {
    Row() {
      Row() {
        Text(this.vm.listData.dateLabel)
          .fontColor($r('app.color.font_color_level1'))
          .fontWeight(FontWeight.Medium);
        Image($r('app.media.ic_arrow_bottom'))
          .width(24);
      }
      .selectorStyle()
      .onClick(() => {
        this.showSheet = true;
        this.vm.openSheet(HomeSheetType.DATE);
      });

      Row() {
        Select([
          { value: '明细' },
          { value: '统计图表' }])
          .font({ size: $r('sys.float.Body_L'), weight: 500 })
          .fontColor($r('sys.color.font_primary'))
          .backgroundColor(Color.Transparent)
          .selected(this.vm.summaryType === SummaryType.LIST ? 0 : 1)
          .value(this.vm.summaryLabel)
          .selectedOptionFont({ size: $r('sys.float.Body_L'), weight: 400 })
          .selectedOptionFontColor($r('sys.color.font_primary'))
          .selectedOptionBgColor($r('app.color.button_color_background'))
          .optionFont({ size: $r('sys.float.Body_L'), weight: 400 })
          .optionWidth(100)
          .padding(0)
          .height(28)
          .onSelect((index: number) => {
            this.vm.summaryType = index === 0 ? SummaryType.LIST : SummaryType.CHART;
          })
      }
      .selectorStyle()
      .padding({
        left: $r('app.string.space_s'),
        right: $r('app.string.space_s'),
        top: $r('app.string.space_s'),
        bottom: $r('app.string.space_s'),
      })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width($r('app.string.width_percent_full'))
    .height(40)
    .margin({ bottom: $r('app.string.space_m') });
  }

  @Builder
  billListBuilder() {
    Row() {
      Text(this.vm.resourceLabel)
        .fontColor($r('app.color.font_color_level1'))
        .fontWeight(FontWeight.Medium);
      Image($r('app.media.ic_arrow_bottom'))
        .width(24);
    }
    .selectorStyle()
    .margin({ bottom: $r('app.string.space_m') })
    .onClick(() => {
      this.vm.openSheet(HomeSheetType.TYPE);
      this.showSheet = true;
    })

    List() {
      ForEach(this.vm.listData.list, (item: DailyBillGroup) => {
        ListItem() {
          BillCard({
            card: item,
            handleDelete: (id: number) => {
              this.vm.deleteBill(id, this.getUIContext());
            },
            handleClickItem: (bill: BillCardItem) => {
              this.stack.pushPath({
                name: RouterMap.HOME_BILL_DETAIL,
                param: bill,
                onPop: async () => {
                  this.vm.refreshBill();
                },
              });
            },
          });
        };
      }, (item: DailyBillGroup) => JSON.stringify(item));
      if (!this.vm.listData.list?.length) {
        // 占位空卡片
        BillCard();
      }
      ListItem() {
        Text('下拉获取最新账单~')
          .fontSize($r('app.string.font_size_12'))
          .fontColor($r('app.color.font_color_level2'))
          .margin({
            top: $r('app.string.space_m'),
            bottom: $r('app.string.space_l'),
          })
          .width($r('app.string.width_percent_full'))
          .textAlign(TextAlign.Center);
      };
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off);
  }
}

@Extend(Row)
function selectorStyle() {
  .backgroundColor($r('sys.color.comp_background_tertiary'))
  .padding({
    left: $r('app.string.space_l'),
    right: $r('app.string.space_s'),
    top: $r('app.string.space_s'),
    bottom: $r('app.string.space_s'),
  })
  .borderRadius($r('app.string.border_radius_capsule'))
  .justifyContent(FlexAlign.Start)
}