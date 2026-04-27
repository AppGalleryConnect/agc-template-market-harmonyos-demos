//血糖数据看板页
import WeeklyBloodGlucoseChart from '../cards/WeeklyBloodGlucoseChart';
import MonthlyBloodGlucoseChart from '../cards/MonthlyBloodGlucoseChart';
import ThreeMonthsBloodGlucoseChart from '../cards/ThreeMonthsBloodGlucoseChart';
import { TimeRange } from '../types/BloodGlucoseTypes';
import { BloodGlucoseVM } from '../viewmodel/BloodGlucoseVM';
import { CommonHeader } from '../components/CommonHeader';

/**
 * @usage: 用于展示血糖数据看板的主页面。包含自定义导航栏（返回按钮、标题、菜单按钮）、日期范围选择器、
 * 时间范围切换按钮（近七天/近一个月/近三个月）、血糖图表展示区域、血糖统计区域（最低值和最高值）。主要数据结构包括
 * BloodGlucoseVM（血糖视图模型）。包含if逻辑用于根据时间范围显示不同的血糖图表组件。
 * @layout: 页面采用垂直布局（Column），顶部为自定义导航栏（Stack布局），下方为主要内容区域（Column布局），
 * 包含日期范围选择器（居中对齐）、时间范围切换按钮组（水平排列）、图表展示区域（包含当前血糖值显示和颜色图例）、
 * 统计区域（水平分割显示最低值和最高值）。
 * @constraints:
 * @domain: 健康医疗
 * @isGen: true
 * @fileType: page
 * @zhName: 血糖数据看板页面
 * @subPage: BloodGlucoseHistoryPage
 * @component: WeeklyBloodGlucoseChart,MonthlyBloodGlucoseChart,ThreeMonthsBloodGlucoseChart,TimeRangeButton,
 * CommonHeader
 * @image: screenshot/health/BloodGlucose.jpg
 */
// 血糖数据看板页面
@ComponentV2
export struct BloodGlucosePage {
  private vm: BloodGlucoseVM = BloodGlucoseVM.instance;
  @Local routerModule: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.vm.init();
  }

  handleBack = (): void => {
    this.routerModule.pop('back');
  }
  handleMenu = (): void => {
    this.vm.toggleMenu();
  }
  navigateToHistory = (): void => {
    this.vm.closeMenus();
    this.routerModule.pushPathByName('BloodGlucoseHistoryPage', null);
  }

  build() {
    NavDestination() {
      Column() {
        this.renderCustomHeader()
        Scroll() {
          Column({ space: 12 }) {
            this.renderDateAndRangeA();
            this.renderChartSection();
            this.renderStatisticsSection()
          }
          .justifyContent(FlexAlign.Start)
          .width('100%')
          .padding({
            right: 16,
            left: 16,
            top: 8,
            bottom: 24
          })
        }
        .align(Alignment.Top)
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
      }
      .padding({ top: 24 })
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.comp_background_gray'))
    .onBackPressed(() => {
      this.routerModule.pop('back')
      return true
    })
    .onReady((context) => {
      // 获取参数
      this.routerModule = context.pathStack;
    })
  }

  @Builder
  private renderCustomHeader() {
    CommonHeader({
      title: '血糖',
      onBack: this.handleBack,
      showMenu: this.vm.showMenu,
      onMenuToggle: this.handleMenu,
      menuItems: [{ value: '历史记录', action: this.navigateToHistory }],
      onMenuDisappear: () => { this.vm.showMenu = false; }
    })
  }

  @Builder
  private renderDateAndRangeA() {
    Column({ space: 8 }) {
      Row({ space: 6 }) {
        Text(this.vm.dateRangeText)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Row({ space: 10 }) {
        TimeRangeButton({
          isSelected: this.vm.currentRange === TimeRange.WEEK,
          label: '近七天',
          onTap: () => this.vm.switchTimeRange(TimeRange.WEEK)
        })
        TimeRangeButton({
          isSelected: this.vm.currentRange === TimeRange.MONTH,
          label: '近一个月',
          onTap: () => this.vm.switchTimeRange(TimeRange.MONTH)
        })
        TimeRangeButton({
          label: '近三个月',
          onTap: () => this.vm.switchTimeRange(TimeRange.THREE_MONTHS),
          isSelected: this.vm.currentRange === TimeRange.THREE_MONTHS
        })
      }
      .width('100%')
      .backgroundColor($r('sys.color.background_primary'))
      .borderRadius($r('sys.float.corner_radius_level12'))
      .padding(4)
    }
  }

  @Builder
  private renderChartSection() {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 8 }) {
          Text(this.vm.periodText)
            .fontColor($r('sys.color.mask_secondary'))
            .fontSize($r('sys.float.Body_S'))
          Row({ space: 6 }) {
            Text(this.vm.currentValue.toFixed(1))
              .fontWeight(FontWeight.Bold)
              .fontSize($r('sys.float.Title_S'))
              .fontColor($r('sys.color.font_primary'))
            Text('mmol/L')
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.mask_secondary'))
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Row({ space: 12 }) {
          Row({ space: 4 }) {
            Circle()
              .width(8)
              .fill('#FFA800')
              .height(8)
            Text('偏低')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.mask_secondary'))
          }

          Row({ space: 4 }) {
            Circle()
              .height(8)
              .width(8)
              .fill('#4CAF50')
            Text('正常')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.mask_secondary'))
          }

          Row({ space: 4 }) {
            Circle()
              .width(8)
              .fill('#F44336')
              .height(8)
            Text('偏高')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.mask_secondary'))
          }
        }
      }
      .width('100%')
      .padding({ top: $r('app.float.vp_16'), left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })

      if (this.vm.currentRange === TimeRange.WEEK) {
        WeeklyBloodGlucoseChart({
          values: this.vm.chartValues,
          onValueSelected: this.vm.updateSelectedBloodGlucose,
          currentIndex: -1
        })
          .height(240)
          .width('100%')
          .padding({ left: 0, right: 0, bottom: $r('app.float.vp_16') })
      } else if (this.vm.currentRange === TimeRange.MONTH) {
        MonthlyBloodGlucoseChart({
          values: this.vm.chartValues,
          dateLabels: this.vm.chartLabels,
          onValueSelected: this.vm.updateSelectedBloodGlucose,
          currentIndex: -1
        })
          .width('100%')
          .height(240)
          .padding({ left: 0, right: 0, bottom: $r('app.float.vp_16') })
      } else {
        ThreeMonthsBloodGlucoseChart({
          values: this.vm.chartValues,
          monthLabels: this.vm.chartLabels,
          tooltipLabels: this.vm.chartTooltipLabels,
          currentIndex: this.vm.currentIndex,
          onValueSelected: this.vm.updateSelectedBloodGlucose
        })
          .width('100%')
          .height(240)
          .padding({ left: 0, right: 0, bottom: $r('app.float.vp_16') })
      }
    }
    .width('100%')
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius($r('sys.float.corner_radius_level7'))
  }

  @Builder
  private renderStatisticsSection() {
    Row({ space: 0 }) {
      Column({ space: 8 }) {
        Row({ space: 6 }) {
          Text(this.vm.statistics.minValue.toFixed(1))
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
          Text('mmol/L')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.mask_secondary'))
        }

        Text('最低值')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.mask_secondary'))
      }
      .layoutWeight(1)
      .padding({ top: 20, bottom: 20 })

      Divider()
        .vertical(true)
        .height(60)
        .color($r('sys.color.comp_divider'))
        .strokeWidth('1px')

      Column({ space: 8 }) {
        Row({ space: 6 }) {
          Text(this.vm.statistics.maxValue.toFixed(1))
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
          Text('mmol/L')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.mask_secondary'))
        }

        Text('最高值')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.mask_secondary'))
      }
      .layoutWeight(1)
      .padding({ top: 20, bottom: 20 })
    }
    .width('100%')
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius($r('sys.float.corner_radius_level7'))
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
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .height(40)
    .layoutWeight(1)
    .borderRadius($r('sys.float.corner_radius_level10'))
    .backgroundColor(this.isSelected ? '#2B69FF' : Color.Transparent)
    .onClick(this.onTap)
  }
}


@Builder
export function BloodGlucosePageBuilder() {
  BloodGlucosePage()
}

