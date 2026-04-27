//健康报告页面
import { phoneRouterControl } from 'oh_router';
import { UnitConverter, RouterMap, BreakpointModel, BarVM } from 'common';
import { HealthReportModel } from '../viewmodel/HealthReportModel';
import { HealthMetricItem, MenuItemType } from '../types/HealthReportTypes';
import { HealthHistoryPageBuilder } from './HealthHistoryPage';
import { WeeklyReportPageBuilder } from './WeeklyReportPage';
import { MonthlyReportPageBuilder } from './MonthlyReportPage';
import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointNameEnum } from 'common/src/main/ets/constant/GridRowColSetting';

@Builder
export function HealthReportPageBuilder() {
  HealthReportPage()
}

/**
 * @usage： 健康报告页面，用于展示用户的健康数据分析报告，支持查看不同时间段的健康指标趋势和分析。
 * 主要数据结构为HealthReportModel（健康报告模型）、HealthMetricItem（健康指标项目）。
 * 包含if逻辑用于报告类型切换和菜单显示。
 * @layout： 页面采用垂直布局（Column），顶部为导航栏和菜单按钮，下方为报告内容展示区域，支持不同报告类型的切换显示，菜单采用弹出式布局。
 * @constraints:
 * @domain: 健康医疗
 * @isGen: true
 * @fileType: page
 * @zhName: 健康报告页面
 * @subPage: WeeklyReportPage,MonthlyReportPage,HealthHistoryDetailPage
 */
//健康报告页面
@ComponentV2
export struct HealthReportPage {
  private vm: HealthReportModel = HealthReportModel.instance;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  @Computed
  get getFoldShow(): boolean {
    if (this.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM) {
      return false;
    } else {
      return true;
    }
  }

  handleBack = (): void => {
    phoneRouterControl.popPage();
  }
  handleMenu = (): void => {
    this.vm.toggleReportMenu();
  }

  private getMenuItems(): MenuItemType[] {
    const items: MenuItemType[] = this.vm.getReportMenuItems().map(item => {
      const menuItem: MenuItemType = {
        value: item.label,
        action: () => {
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

  private getBMITypeMargin(): string {
    const bmi = this.vm.reportData.bmi;
    if (bmi < 18.5) {
      return '0%';
    } else if (bmi < 24) {
      return '25%';
    } else if (bmi < 28) {
      return '50%';
    } else {
      return '75%';
    }
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
          .width(40)
          .aspectRatio(1)
          .margin({ top: 22, right: 16 })
          .onClick(this.handleMenu)
          .bindMenu(this.vm.showReportMenu, this.getMenuItems(), {
            placement: Placement.BottomRight,
            onDisappear: () => {
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
            Column({ space: 2 }) {
              Row({ space: 0 }) {
                Text('您的身体健康评分：')
                  .fontSize($r('sys.float.Body_M'))
                  .fontColor(Color.White)
                Text(this.vm.reportData.score.toString())
                  .fontSize($r('sys.float.Title_M'))
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
                  .margin({ left: 0 })
                Text('分')
                  .fontSize($r('sys.float.Body_M'))
                  .fontColor(Color.White)
                  .margin({ left: 1 })
              }
              .alignItems(VerticalAlign.Bottom)
              .margin({ bottom: 2 })

              Text() {
                Span('超过了')
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor('rgba(255,255,255,0.9)')
                Span(this.vm.reportData.percentile.toString())
                  .fontSize($r('sys.float.Title_M'))
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
                Span('%的同龄人')
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor('rgba(255,255,255,0.9)')
              }
              .width('100%')
              .textAlign(TextAlign.Start)
              .margin({ top: 2, bottom: 2 })

              Text(this.vm.reportData.reportDate)
                .width('100%')
                .textAlign(TextAlign.Start)
                .fontSize($r('sys.float.Body_S'))
                .fontColor('rgba(255,255,255,0.9)')
                .margin({ top: 6 })
            }
            .width('60%')
          }
          .alignSelf(ItemAlign.Start)
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .height(220)
          .alignItems(HorizontalAlign.Start)
          .padding({
            top: 0,
            left: 24,
            bottom: 50,
            right: 24
          })
        }
        .width('100%')
        .height(220)

        Image($r('app.media.banner_person'))
          .width(180)
          .position({ x: '50%', y: '-5%' })
          .zIndex(2)
          .height(240)
          .objectFit(ImageFit.Contain)
      }
      .width('100%')

      Row({ space: 0 }) {
        Column({ space: 6 }) {
          Text(this.vm.reportData.weight.toFixed(1))
            .fontSize($r('sys.float.Title_M'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.black'))
          Text('体重(公斤)')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
        }
        .layoutWeight(1)

        Divider()
          .vertical(true)
          .height(42)
          .color($r('sys.color.comp_divider'))
          .strokeWidth('1px')

        Column({ space: 6 }) {
          Text(this.vm.reportData.height.toString())
            .fontSize($r('sys.float.Title_M'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.black'))
          Text('身高(厘米)')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
        }
        .layoutWeight(1)

        Divider()
          .vertical(true)
          .height(42)
          .color($r('sys.color.comp_divider'))
          .strokeWidth('1px')

        Column({ space: 6 }) {
          Text(this.vm.reportData.age.toString())
            .fontSize($r('sys.float.Title_M'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.black'))
          Text('年龄')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
        }
        .layoutWeight(1)
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
  private renderMetricsGrid() {
    Grid() {
      ForEach(this.vm.getHealthMetrics(), (item: HealthMetricItem) => {
        GridItem() {
          Column({ space: 8 }) {
            Row({ space: 8 }) {
              Row()
                .width(32)
                .height(32)
                .backgroundColor(item.backgroundColor)
                .borderRadius($r('sys.float.corner_radius_level7'))
                .backgroundImage(item.icon)
                .backgroundImageSize(ImageSize.Contain)

              Text(item.label)
                .fontSize($r('sys.float.Body_L'))
                .fontColor($r('sys.color.black'))
                .fontWeight(FontWeight.Medium)
                .fontFamily('HarmonyOS Sans SC')
            }
            .width('100%')

            Text() {
              Span(item.value)
                .fontSize(28)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.black'))
                .fontFamily('HarmonyOS Sans SC')

              if (item.unit) {
                Span(item.unit)
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor($r('sys.color.font_secondary'))
                  .fontFamily('HarmonyOS Sans SC')
              }
            }
            .fontFamily('HarmonyOS Sans SC')
            .baselineOffset(0)
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
      })
    }
    .columnsTemplate('1fr 1fr')
    .rowsTemplate('1fr 1fr 1fr')
    .columnsGap(12)
    .rowsGap(12)
    .width('100%')
    .height(360)
  }

  @Builder
  private renderAdviceCard() {
    Column({ space: 20 }) {
      Text('控制建议')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.black'))
        .fontFamily('HarmonyOS Sans SC')
        .width('100%')

      Column({ space: 8 }) {
        RelativeContainer() {
          Row()
            .width('100%')
            .height(13)
            .borderRadius($r('sys.float.corner_radius_level2'))
            .backgroundColor($r('sys.color.comp_divider'))
            .id('bottomId')
            .alignRules({
              left: { anchor: '__container__', align: HorizontalAlign.Start },
              bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
            })

          Row()
            .width('25%')
            .height(13)
            .borderRadius($r('sys.float.corner_radius_level2'))
            .backgroundColor('#FF8533')
            .margin({ left: this.getBMITypeMargin() })
            .id('lightId')
            .alignRules({
              left: { anchor: '__container__', align: HorizontalAlign.Start },
              bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
            })

          Text(this.vm.reportData.bmi.toFixed(1))
            .fontColor($r('sys.color.black'))
            .fontSize(27)
            .fontWeight(FontWeight.Bold)
            .fontFamily('HarmonyOS Sans SC Medium')
            .id('valueId')
            .alignRules({
              middle: { anchor: 'lightId', align: HorizontalAlign.Center },
              top: { anchor: '__container__', align: VerticalAlign.Top }
            })

          Image($r('app.media.health_bmi_triangle'))
            .width(12)
            .height(11)
            .fillColor('#FF8533')
            .id('iconId')
            .alignRules({
              middle: { anchor: 'valueId', align: HorizontalAlign.Center },
              top: { anchor: 'valueId', align: VerticalAlign.Bottom }
            })
        }
        .width('100%')
        .height(50)

        Row() {
          Text($r('app.string.health_bmi_type_underweight'))
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Body_S'))
            .fontFamily('HarmonyOS Sans SC')
            .width('25%')
            .textAlign(TextAlign.Center)

          Text($r('app.string.health_bmi_type_normal'))
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Body_S'))
            .fontFamily('HarmonyOS Sans SC')
            .width('25%')
            .textAlign(TextAlign.Center)

          Text($r('app.string.health_bmi_type_overweight'))
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Body_S'))
            .fontFamily('HarmonyOS Sans SC')
            .width('25%')
            .textAlign(TextAlign.Center)

          Text($r('app.string.health_bmi_type_obesity'))
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Body_S'))
            .fontFamily('HarmonyOS Sans SC')
            .width('25%')
            .textAlign(TextAlign.Center)
        }
        .width('100%')
      }
      .width('100%')

      Text(this.vm.reportData.bmiAdvice)
        .fontSize($r('sys.float.Body_M'))
        .fontColor('#666666')
        .fontFamily('HarmonyOS Sans SC')
        .lineHeight(22)
        .width('100%')
    }
    .width('100%')
    .padding({
      left: 20,
      right: 20,
      top: 20,
      bottom: 20
    })
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius($r('sys.float.corner_radius_level7'))
  }

  build() {
    NavDestination() {
      Column() {
        this.renderCustomHeader()
        Scroll() {
          Column({ space: 16 }) {
            this.renderHeroCard()
            this.renderMetricsGrid()
            this.renderAdviceCard()
          }
          .width('100%')
          .padding({
            left: 16,
            right: 16,
            top: 0,
            bottom: 24
          })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.comp_background_gray'))
    }
    .hideTitleBar(true)
  }
}

