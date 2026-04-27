//心率数据看板页
import WeeklyHeartRateChart from '../cards/WeeklyHeartRateChart';
import MonthlyHeartRateChart from '../cards/MonthlyHeartRateChart';
import ThreeMonthsHeartRateChart from '../cards/ThreeMonthsHeartRateChart';
import { TimeRange } from '../types/HeartRateTypes';
import { HeartRateVM } from '../viewmodel/HeartRateVM';
import { CommonHeader } from '../components/CommonHeader';

@Builder
export function HeartRatePageBuilder() {
  HeartRatePage()
}

/**
 * @usage: 用于展示心率数据看板的主页面。包含自定义导航栏（返回按钮、标题、菜单按钮）、日期范围选择器、时间范围切换按钮
 * （近七天/近一个月/近三个月）、心率图表展示区域（显示心率范围）、心率统计区域（最高心率、最低心率、静息心率、平均心率四项指标）。
 * 主要数据结构HeartRateVM（心率视图模型）。包含if逻辑用于根据时间范围显示不同的心率图表组件。
 * @layout: 页面采用垂直布局（Column），顶部为自定义导航栏（Stack布局），下方为主要内容（Column布局），包含日期范围选择器（居中对齐）
 * 时间范围切换按钮组（水平排列）、图表展示区域（显示当前心率范围）、统计区域（2x2网格布局显示四项心率指标）。
 * @constraints:
 * @isGen: true
 * @fileType: page
 * @zhName: 心率数据看板页面
 * @subPage: HeartRateHistoryPage
 * @component: WeeklyHeartRateChart,MonthlyHeartRateChart,ThreeMonthsHeartRateChart,TimeRangeButton,CommonHeader
 * @image: screenshot/health/HeartRate.jpg
 */
@ComponentV2
export struct HeartRatePage {
  private vm: HeartRateVM = HeartRateVM.instance;
  @Local routerModule: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.vm.init();
  }

  handleBack = (): void => {
    this.routerModule.pop('back')
  }
  handleMenu = (): void => {
    this.vm.toggleMenu();
  }
  navigateToHistory = (): void => {
    this.vm.closeMenus();
    this.routerModule.pushPathByName('HeartRateHistoryPage', null);
  }

  @Builder
  private renderCustomHeader() {
    CommonHeader({
      title: '心率',
      onBack: this.handleBack,
      showMenu: this.vm.showMenu,
      menuItems: [{ value: '历史记录', action: this.navigateToHistory }],
      onMenuToggle: this.handleMenu,
      onMenuDisappear: () => { this.vm.showMenu = false; }
    })
  }

  @Builder
  private renderDateAndRange() {
    Column({ space: 8 }) {
      Row({ space: 6 }) {
        Text(this.vm.dateRangeText)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')

      Row({ space: 10 }) {
        TimeRangeButton({
          isSelected: this.vm.currentRange === TimeRange.WEEK,
          label: '近七天',
          onTap: () => this.vm.switchTimeRange(TimeRange.WEEK)
        })
        TimeRangeButton({
          label: '近一个月',
          onTap: () => this.vm.switchTimeRange(TimeRange.MONTH),
          isSelected: this.vm.currentRange === TimeRange.MONTH
        })
        TimeRangeButton({
          isSelected: this.vm.currentRange === TimeRange.THREE_MONTHS,
          onTap: () => this.vm.switchTimeRange(TimeRange.THREE_MONTHS),
          label: '近三个月'
        })
      }
      .width('100%')
      .borderRadius($r('sys.float.corner_radius_level12'))
      .padding(4)
      .backgroundColor($r('sys.color.background_primary'))
    }
  }

  @Builder
  private renderChartSection() {
    Column({ space: 12 }) {
      Column({ space: 8 }) {
        Text('心率范围')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.mask_secondary'))
        Row({ space: 6 }) {
          Text(this.vm.currentRangeText)
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
          Text('次/分')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.mask_secondary'))
        }
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .padding({ top: 16, left: 16, right: 16 })

      if (this.vm.currentRange === TimeRange.WEEK) {
        WeeklyHeartRateChart({
          ranges: this.vm.chartRanges,
          currentIndex: 3
        })
          .width('100%')
          .height(240)
          .padding({ left: 16, right: 16, bottom: 16 })
      } else if (this.vm.currentRange === TimeRange.MONTH) {
        MonthlyHeartRateChart({
          ranges: this.vm.chartRanges,
          dateLabels: this.vm.chartLabels,
          groupSizes: this.vm.chartGroupSizes,
          currentIndex: 4
        })
          .width('100%')
          .height(240)
          .padding({ left: 16, right: 16, bottom: 16 })
      } else {
        ThreeMonthsHeartRateChart({
          ranges: this.vm.chartRanges,
          monthLabels: this.vm.chartLabels,
          tooltipLabels: this.vm.chartTooltipLabels,
          rangeText: this.vm.currentRangeText,
          currentIndex: 4
        })
          .width('100%')
          .height(240)
          .padding({ left: 16, right: 16, bottom: 16 })
      }
    }
    .width('100%')
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius($r('sys.float.corner_radius_level7'))
  }

  @Builder
  private renderStatisticsSection() {
    Column({ space: 16 }) {
      Row({ space: 10 }) {
        Row() {
          Image($r('app.media.health_eyes'))
            .width(16)
            .height(16)
            .fillColor(Color.White)
        }
        .width(28)
        .height(28)
        .borderRadius($r('sys.float.corner_radius_level7'))
        .backgroundColor($r('sys.color.comp_background_emphasize'))
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)

        Text(this.vm.currentRange === TimeRange.WEEK ? '本周心率' :
          this.vm.currentRange === TimeRange.MONTH ? '近一个月概览' : '近三个月概览')
          .fontSize($r('sys.float.Subtitle_S'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))

        Blank().layoutWeight(1)
      }
      .alignItems(VerticalAlign.Center)
      .width('100%')

      Row({ space: 16 }) {
        Row({ space: 12 }) {
          Circle()
            .width(6)
            .height(6)
            .borderRadius($r('sys.float.corner_radius_level2'))
            .fill('#FF6B6B')

          Column({ space: 6 }) {
            Text('最高心率')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.mask_secondary'))

            Row({ space: 6 }) {
              Text(this.vm.statistics.avgHigh.toString())
                .fontWeight(FontWeight.Bold)
                .fontColor($r('sys.color.font_primary'))
                .fontSize($r('sys.float.Title_S'))
              Text('次/分')
                .fontColor($r('sys.color.mask_secondary'))
                .fontSize($r('sys.float.Body_S'))
            }
          }
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .alignItems(VerticalAlign.Top)

        Row({ space: 12 }) {
          Circle()
            .borderRadius($r('sys.float.corner_radius_level2'))
            .fill('#FF6B6B')
            .width(6)
            .height(6)

          Column({ space: 6 }) {
            Text('最低心率')
              .fontColor($r('sys.color.mask_secondary'))
              .fontSize($r('sys.float.Body_S'))

            Row({ space: 6 }) {
              Text(this.vm.statistics.avgLow.toString())
                .fontSize($r('sys.float.Title_S'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Bold)
              Text('次/分')
                .fontColor($r('sys.color.mask_secondary'))
                .fontSize($r('sys.float.Body_S'))
            }
          }
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .alignItems(VerticalAlign.Top)
      }
      .width('100%')

      Row({ space: 16 }) {
        Row({ space: 12 }) {
          Circle()
            .width(6)
            .height(6)
            .borderRadius($r('sys.float.corner_radius_level2'))
            .fill('#FF6B6B')

          Column({ space: 6 }) {
            Text('静息心率')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.mask_secondary'))

            Row({ space: 6 }) {
              Text(this.vm.statistics.restingHigh.toString())
                .fontSize($r('sys.float.Title_S'))
                .fontWeight(FontWeight.Bold)
                .fontColor($r('sys.color.font_primary'))
              Text('次/分')
                .fontSize($r('sys.float.Body_S'))
                .fontColor($r('sys.color.mask_secondary'))
            }
          }
          .alignItems(HorizontalAlign.Start)
        }
        .alignItems(VerticalAlign.Top)
        .layoutWeight(1)

        Row({ space: 12 }) {
          Circle()
            .width(6)
            .height(6)
            .borderRadius($r('sys.float.corner_radius_level2'))
            .fill('#FF6B6B')

          Column({ space: 6 }) {
            Text('平均心率')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.mask_secondary'))

            Row({ space: 6 }) {
              Text(this.vm.statistics.restingLow.toString())
                .fontSize($r('sys.float.Title_S'))
                .fontWeight(FontWeight.Bold)
                .fontColor($r('sys.color.font_primary'))
              Text('次/分')
                .fontSize($r('sys.float.Body_S'))
                .fontColor($r('sys.color.mask_secondary'))
            }
          }
          .alignItems(HorizontalAlign.Start)
        }
        .alignItems(VerticalAlign.Top)
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 16,
      bottom: 16
    })
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }

  build() {
    NavDestination() {
      Column() {
        this.renderCustomHeader()
        Scroll() {
          Column({ space: 12 }) {
            this.renderDateAndRange()
            this.renderChartSection()
            this.renderStatisticsSection()
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .padding({
            left: 16,
            right: 16,
            bottom: 24,
            top: 8
          })
        }
        .width('100%')
        .align(Alignment.Top)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .height('100%')
      .padding({ top: 24 })
    }
    .hideTitleBar(true)
    .onReady((context) => {
      // 获取参数
      this.routerModule = context.pathStack;
    })
    .backgroundColor($r('sys.color.comp_background_gray'))
    .onBackPressed(() => {
      this.routerModule.pop('back')
      return true
    })
  }
}

@ComponentV2
struct TimeRangeButton {
  @Param label: string = '';
  @Param isSelected: boolean = false;
  @Param onTap: () => void = () => {
  };

  build() {
    Row() {
      Text(this.label)
        .fontSize($r('sys.float.Body_M'))
        .fontColor(this.isSelected ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .height(40)
    .layoutWeight(1)
    .borderRadius($r('sys.float.corner_radius_level10'))
    .backgroundColor(this.isSelected ? '#2B69FF' : Color.Transparent)
    .onClick(this.onTap)
  }
}


