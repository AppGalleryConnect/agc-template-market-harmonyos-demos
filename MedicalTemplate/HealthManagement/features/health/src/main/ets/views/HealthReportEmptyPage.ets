//健康报告页面 - 无数据版本
import { phoneRouterControl } from 'oh_router';
import { BarVM, BreakpointModel, RouterMap, UnitConverter } from 'common';
import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointNameEnum } from 'common/src/main/ets/constant/GridRowColSetting';
import { MenuItemType } from '../types/HealthReportTypes';
import { HealthHistoryPageBuilder } from './HealthHistoryPage';
import { WeeklyReportPageBuilder } from './WeeklyReportPage';
import { MonthlyReportPageBuilder } from './MonthlyReportPage';
import { HealthReportModel } from '../viewmodel/HealthReportModel';

@Builder
export function HealthReportEmptyPageBuilder() {
  HealthReportEmptyPage()
}

@ComponentV2
export struct HealthReportEmptyPage {
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  private vm: HealthReportModel = HealthReportModel.instance;
  handleMenu = (): void => {
    this.vm.toggleReportMenu();
  }
  handleBack = (): void => {
    phoneRouterControl.popPage();
  }

  @Computed
  get getFoldShow(): boolean {
    if (this.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM) {
      return false;
    } else {
      return true;
    }
  }

  private getMenuItems(): MenuItemType[] {
    const items: MenuItemType[] = this.vm.getReportMenuItems().map(item => {
      // 在无数据页面，周度报告和月度报告应该禁用
      const isDisabled = item.value === 'weekly' || item.value === 'monthly';

      const menuItem: MenuItemType = {
        value: item.label,
        disabled: isDisabled,
        action: () => {
          // 如果禁用，不执行任何操作
          if (isDisabled) {
            return;
          }
          this.vm.closeReportMenu();
          if (item.value === 'history') {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.HEALTH_HISTORY_PAGE,
              builder: wrapBuilder(HealthHistoryPageBuilder)
            });
          } else if (item.value === 'weekly') {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.WEEKLY_REPORT_PAGE,
              builder: wrapBuilder(WeeklyReportPageBuilder)
            });
          } else if (item.value === 'monthly') {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.MONTHLY_REPORT_PAGE,
              builder: wrapBuilder(MonthlyReportPageBuilder)
            });
          }
        }
      };
      return menuItem;
    });
    return items;
  }

  @Builder
  private renderCustomMenu() {
    Column() {
      ForEach(this.getMenuItems(), (item: MenuItemType, index: number) => {
        Row() {
          Text(item.value)
            .fontSize($r('sys.float.Body_L'))
            .fontColor(item.disabled ? $r('sys.color.font_secondary') : $r('sys.color.font_primary'))
            .layoutWeight(1)
        }
        .width('100%')
        .height(44)
        .padding({ left: 16, right: 16 })
        .backgroundColor(item.disabled ? Color.Transparent : $r('sys.color.comp_background_primary'))
        .onClick(() => {
          if (!item.disabled) {
            item.action();
          }
        })
        .enabled(!item.disabled)

        if (index < this.getMenuItems().length - 1) {
          Divider()
            .color($r('sys.color.comp_divider'))
            .strokeWidth('1px')
            .margin({ left: 16, right: 16 })
        }
      }, (item: MenuItemType) => item.value)
    }
    .width(160)
    .borderRadius($r('sys.float.corner_radius_level10'))
    .backgroundColor($r('sys.color.comp_background_primary'))
    .padding({ top: 8, bottom: 8 })
    .shadow({
      radius: $r('sys.float.corner_radius_level1'),
      color: $r('sys.color.comp_background_gray'),
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder
  private renderCustomHeader() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Row() {
        Image($r('app.media.ic_backward2'))
          .width(40)
          .aspectRatio(1)
          .margin({ left: 16, top: 24, right: 8 })
          .onClick(this.handleBack)

        Text('健康报告')
          .size({ height: 27 })
          .margin({ left: 16, top: 24 })
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(700)
          .fontColor($r('sys.color.font_primary'))

        Blank().layoutWeight(1)

        Image($r('app.media.ic_title_menu'))
          .width(33)
          .aspectRatio(1)
          .margin({ top: 22, right: 16 })
          .onClick(this.handleMenu)
          .bindPopup(this.vm.showReportMenu, {
            builder: () => {
              this.renderCustomMenu()
            },
            placement: Placement.BottomRight,
            enableArrow: false,
            autoCancel: true,
            onWillDismiss: () => {
              this.vm.closeReportMenu();
            }
          })
      }
      .height(UnitConverter.px2vp(BarVM.instance.statusBarHeight.value) + 48)
      .width('100%')
      .margin({ top: 12 })
      .backgroundColor($r('sys.color.background_secondary'))
    }
  }

  @Builder
  private renderStatItem(value: string, label: string) {
    Column({ space: 6 }) {
      Text(value)
        .fontSize($r('sys.float.Title_M'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.black'))
      Text(label)
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.font_secondary'))
    }
    .layoutWeight(1)
  }

  @Builder
  private renderHeroCard() {
    Column({ space: 0 }) {
      Stack() {
        Stack() {
          Image($r('app.media.banner_backgrounds'))
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Contain)
            .borderRadius($r('sys.float.corner_radius_level12'))
            .clip(true)

          Column({ space: 6 }) {
            Text('目前暂无数据')
              .fontSize($r('sys.float.Body_L'))
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .alignSelf(ItemAlign.Start)
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Center)
          .height(220)
          .padding({
            right: 24,
            left: 24,
            top: 0,
            bottom: 55
          })
        }
        .height(220)
        .width('100%')

        Image($r('app.media.banner_person'))
          .width(180)
          .height(240)
          .objectFit(ImageFit.Contain)
          .position({ x: '50%', y: '-5%' })
          .zIndex(2)

      }
      .width('100%')

      Row({ space: 0 }) {
        this.renderStatItem('--', '体重(斤)')

        Divider()
          .vertical(true)
          .height(42)
          .color($r('sys.color.comp_divider'))
          .strokeWidth('1px')

        this.renderStatItem('--', '身高(厘米)')

        Divider()
          .vertical(true)
          .height(42)
          .color($r('sys.color.comp_divider'))
          .strokeWidth('1px')

        this.renderStatItem('--', '年龄')
      }
      .width('100%')
      .margin({ top: -85 })
      .padding({
        left: 24,
        right: 24,
        top: 20,
        bottom: 24
      })
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .shadow({
        radius: $r('sys.float.corner_radius_level1'),
        color: $r('sys.color.comp_background_gray'),
        offsetX: 0,
        offsetY: 1
      })
      .borderRadius({
        topLeft: $r('sys.float.corner_radius_level7'),
        topRight: $r('sys.float.corner_radius_level7'),
        bottomLeft: $r('sys.float.corner_radius_level8'),
        bottomRight: $r('sys.float.corner_radius_level8')
      })
    }
    .width('100%')
  }

  @Builder
  private renderMetricItem(icon: ResourceStr, title: string) {
    GridItem() {
      Column({ space: 8 }) {
        Row({ space: 8 }) {
          Row()
            .width(32)
            .height(32)
            .backgroundColor($r('sys.color.background_secondary'))
            .borderRadius($r('sys.float.corner_radius_level7'))
            .backgroundImage(icon)
            .backgroundImageSize(ImageSize.Contain)

          Text(title)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.black'))
            .fontWeight(FontWeight.Medium)
            .fontFamily('HarmonyOS Sans SC')
        }
        .width('100%')

        Text('暂无数据')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
          .fontFamily('HarmonyOS Sans SC')
      }
      .width('100%')
      .height(110)
      .padding({
        top: 16,
        bottom: 16,
        left: 16,
        right: 16
      })
      .backgroundColor($r('sys.color.background_primary'))
      .borderRadius($r('sys.float.corner_radius_level7'))
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceBetween)
    }
  }

  @Builder
  private renderMetricsGrid() {
    Grid() {
      this.renderMetricItem($r('app.media.health_bmi'), 'BMI')
      this.renderMetricItem($r('app.media.health_bmi_fatPercentage'), '体脂率')
      this.renderMetricItem($r('app.media.health_bmi_fatWeight'), '脂肪重量')
      this.renderMetricItem($r('app.media.health_bmi_heart'), '心率')
      this.renderMetricItem($r('app.media.health_bmi_bloodpressure'), '血压')
      this.renderMetricItem($r('app.media.health_bmi_bloodglucose'), '血糖')
    }
    .columnsTemplate('1fr 1fr')
    .rowsTemplate('1fr 1fr 1fr')
    .columnsGap(12)
    .rowsGap(12)
    .width('100%')
    .height(360)
  }

  build() {
    NavDestination() {
      Column() {
        this.renderCustomHeader()
        Scroll() {
          Column({ space: 16 }) {
            this.renderHeroCard()
            this.renderMetricsGrid()
          }
          .justifyContent(FlexAlign.Start)
          .width('100%')
          .padding({
            left: 16,
            right: 16,
            top: 0,
            bottom: 24
          })
        }
        .width('100%')
        .align(Alignment.Top)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.comp_background_gray'))
      .justifyContent(FlexAlign.Start)
    }
    .hideTitleBar(true)
  }
}

