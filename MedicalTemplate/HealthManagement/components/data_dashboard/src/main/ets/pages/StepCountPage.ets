//步数数据看板页
import { WeeklyBarChart } from '../cards/WeeklyBarChart';
import MonthlyBarChart from '../cards/MonthlyBarChart';
import ThreeMonthsBarChart from '../cards/ThreeMonthsBarChart';
import { TimeRange } from '../types/StepTypes';
import { StepCountVM } from '../viewmodel/StepCountVM';
import { CommonHeader } from '../components/CommonHeader';

/**
 * @usage: 用于展示步数数据看板的主页面。包含自定义导航栏（返回按钮、标题、菜单按钮）、日期范围选择器、
 * 时间范围切换按钮（近七天/近一个月/近三个月）、步数图表展示区域、统计概览卡片和消耗距离卡片。主要数据结构包括StepCountVM（步数视图模型）
 * TimeRange（时间范围枚举）。包含if逻辑用于根据时间范围显示不同的图表组件。
 * @layout: 页面采用垂直布局（Column），顶部为自定义导航栏（Stack布局，包含返回按钮、标题、菜单按钮），下方为主要内容区域（Column布局）
 * 包含日期范围选择器（居中对齐）、时间范围切换按钮组（水平排列）、图表展示区域、统计概览卡片（水平分割显示总步数和平均步数）、
 * 消耗距离卡片（水平分割显示卡路里和距离）。
 * @constraints: 如果用户需求不需要历史记录，可以在renderCustomHeader这个Builder中取消菜单bindMenu的内容。
 * @domain: 健康医疗
 * @isGen: true
 * @fileType: page
 * @zhName: 步数数据看板页面
 * @subPage: StepHistoryPage
 * @component: WeeklyBarChart,MonthlyBarChart,ThreeMonthsBarChart,TimeRangeButton,StepStatisticsCard,
 * CaloriesDistanceCard
 * @image: screenshot/health/StepCount.jpg
 */
//步数数据看板页面
@ComponentV2
export struct StepCountPage {
  private vm: StepCountVM = StepCountVM.instance;
  @Local routerModule: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.vm.init();
  }

  handleBack = (): void => {
    this.routerModule.pop('back');
  }
  navigateToHistory = (): void => {
    this.vm.closeMenus();
    this.routerModule.pushPathByName('StepHistoryPage', null);
  }

  build() {
    NavDestination() {
      Column() {
        this.renderCustomHeader()
        Scroll() {
          Column({ space: 12 }) {
            this.renderDateAndRange();
            this.renderChartSection();
            StepStatisticsCard({
              title: this.vm.currentRange === TimeRange.WEEK ? '本周概览' :
                this.vm.currentRange === TimeRange.MONTH ? '近一个月概览' : '近三个月概览',
              totalSteps: this.vm.statistics.total,
              averageSteps: this.vm.statistics.average
            })
            CaloriesDistanceCard({
              calories: this.vm.statistics.calories,
              distance: this.vm.statistics.distance
            })
          }
          .padding({
            top: 8,
            left: 16,
            right: 16,
            bottom: 24
          })
          .justifyContent(FlexAlign.Start)
          .width('100%')
        }
        .width('100%')
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .layoutWeight(1)
      }
      .padding({ top: 24 })
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
    }
    .onReady((context) => {
      // 获取参数
      this.routerModule = context.pathStack;
    })
    .backgroundColor($r('sys.color.comp_background_gray'))
    .onBackPressed(() => {
      this.routerModule.pop('back')
      return true
    })
    .hideTitleBar(true)
  }

  @Builder
  private renderCustomHeader() {
    CommonHeader({
      title: '步数',
      onBack: this.handleBack,
      onMenuDisappear: this.vm.closeMenus,
      menuItems: [{ value: '历史记录', action: this.navigateToHistory }],
      showMenu: this.vm.showMenu,
      onMenuToggle: this.vm.toggleMenu,
    })
  }

  @Builder
  private renderDateAndRange() {
    Column({ space: 8 }) {
      Row({ space: 6 }) {
        Text(this.vm.dateRangeText)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Row({ space: 8 }) {
        TimeRangeButton({
          label: '近七天',
          isSelected: this.vm.currentRange === TimeRange.WEEK,
          onTap: () => this.vm.switchTimeRange(TimeRange.WEEK)
        })
        TimeRangeButton({
          label: '近一个月',
          isSelected: this.vm.currentRange === TimeRange.MONTH,
          onTap: () => this.vm.switchTimeRange(TimeRange.MONTH)
        })
        TimeRangeButton({
          label: '近三个月',
          isSelected: this.vm.currentRange === TimeRange.THREE_MONTHS,
          onTap: () => this.vm.switchTimeRange(TimeRange.THREE_MONTHS)
        })
      }
      .width('100%')
      .padding(4)
      .backgroundColor($r('sys.color.background_primary'))
      .borderRadius($r('sys.float.corner_radius_level12'))
    }
  }

  @Builder
  private renderChartSection() {
    Column({ space: 12 }) {
      Column({ space: 8 }) {
        Text(this.vm.periodText)
          .fontColor($r('sys.color.mask_secondary'))
          .fontSize($r('sys.float.Body_S'))

        Row({ space: 6 }) {
          Text(this.vm.currentSteps.toString())
            .fontSize($r('sys.float.Title_S'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Bold)
          Text('步')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.mask_secondary'))
        }
      }
      .alignItems(HorizontalAlign.Start)
      .padding({
        top: 16,
        left: 16,
        right: 16,
        bottom: 0
      })
      .width('100%')

      if (this.vm.currentRange === TimeRange.WEEK) {
        WeeklyBarChart({
          dateLabels: this.vm.chartLabels,
          weeklySteps: this.vm.chartSteps,
          onValueSelected: this.vm.updateSelectedData
        })
          .width('100%')
          .height(240)
          .padding({ left: 16, bottom: 16, right: 16 })
      } else if (this.vm.currentRange === TimeRange.MONTH) {
        MonthlyBarChart({
          onValueSelected: this.vm.updateSelectedData,
          monthlySteps: this.vm.chartSteps,
          dateLabels: this.vm.chartLabels
        })
          .width('100%')
          .height(240)
          .padding({ left: 16, right: 16, bottom: 16 })
      } else {
        ThreeMonthsBarChart({
          threeMonthsSteps: this.vm.chartSteps,
          monthLabels: this.vm.chartLabels,
          onValueSelected: this.vm.updateSelectedData
        })
          .height(240)
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 16 })
      }
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


//统计概览卡片组件
@ComponentV2
struct StepStatisticsCard {
  @Param title: string = '本周概览';
  @Param totalSteps: number = 0;
  @Param averageSteps: number = 0;

  build() {
    Column({ space: 16 }) {
      Row({ space: 12 }) {
        Row() {
          Image($r('app.media.health_eyes'))
            .width(16)
            .height(16)
        }
        .width(24)
        .height(24)
        .borderRadius($r('sys.float.corner_radius_level7'))
        .backgroundColor($r('sys.color.comp_background_emphasize'))
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)

        Text(this.title)
          .fontSize($r('sys.float.Subtitle_S'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))

        Blank().layoutWeight(1)
      }
      .alignItems(VerticalAlign.Center)
      .width('100%')

      Row({ space: 16 }) {
        Column({ space: 6 }) {
          Row({ space: 6 }) {
            Circle()
              .width(6)
              .height(6)
              .borderRadius($r('sys.float.corner_radius_level2'))
              .fill('#0A59F7')
            Text('总步数')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_tertiary'))
          }

          Row({ space: 6 }) {
            Text(this.totalSteps.toString())
              .fontSize($r('sys.float.Title_S'))
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
              .margin({ left: 12 })
            Text('步')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.mask_secondary'))
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Divider()
          .vertical(true)
          .height(40)
          .color($r('sys.color.comp_divider'))

        Column({ space: 6 }) {
          Row({ space: 6 }) {
            Circle()
              .width(6)
              .height(6)
              .borderRadius($r('sys.float.corner_radius_level2'))
              .fill('#0A59F7')
            Text('平均步数')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_tertiary'))
          }

          Row({ space: 6 }) {
            Text(this.averageSteps.toString())
              .fontSize($r('sys.float.Title_S'))
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
              .margin({ left: 12 })
            Text('步')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.mask_secondary'))
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
    }
    .padding({
      bottom: $r('app.float.vp_16'),
      top: $r('app.float.vp_16'),
      left: $r('app.float.vp_16'),
      right: $r('app.float.vp_16')
    })
    .width('100%')
    .borderRadius($r('sys.float.corner_radius_level8'))
    .backgroundColor($r('sys.color.background_primary'))
  }
}

//消耗和距离卡片组件
@ComponentV2
struct CaloriesDistanceCard {
  @Param calories: number = 0;
  @Param distance: number = 0;

  build() {
    Row({ space: 16 }) {
      Column({ space: 6 }) {
        Row({ space: 6 }) {
          Text(this.calories.toString())
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
          Text('千卡')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.mask_secondary'))
        }

        Text('消耗')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.mask_secondary'))
      }
      .layoutWeight(1)

      Divider()
        .vertical(true)
        .height(56)
        .color($r('sys.color.comp_divider'))

      Column({ space: 6 }) {
        Row({ space: 6 }) {
          Text(this.distance.toFixed(2))
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
          Text('公里')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.mask_secondary'))
        }

        Text('距离')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.mask_secondary'))
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding({
      top: 16,
      bottom: 16,
      left: 16,
      right: 16
    })
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }
}

@Builder
export function StepCountPageBuilder() {
  StepCountPage()
}

