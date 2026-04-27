//睡眠数据看板页
import { WeeklySleepChart } from '../cards/WeeklySleepChart';
import { MonthlySleepChart } from '../cards/MonthlySleepChart';
import { ThreeMonthsSleepChart } from '../cards/ThreeMonthsSleepChart';
import { TimeRange as SleepTimeRange } from '../types/SleepTypes';
import { SleepVM } from '../viewmodel/SleepVM';
import { CommonHeader } from '../components/CommonHeader';

@Builder
export function SleepPageBuilder() {
  SleepPage()
}

/**
 * @usage: 用于展示睡眠数据看板的主页面。包含自定义导航栏（返回按钮、标题、菜单按钮）、日期范围选择器、时间范围切换按钮
 * （近七天/近一个月/近三个月）、睡眠图表展示区域、睡眠质量评估、睡眠统计区域（四种睡眠阶段的平均时长）。
 * 主要数据结构为SleepVM(睡眠视图模型)。包含if逻辑用于根据时间范围显示不同的睡眠图表组件和时长显示格式。
 * @layout: 页面采用垂直布局（Column），顶部为自定义导航栏（Stack布局），下方为可滚动的主要内容区域（Scroll+Column布局），
 * 包含日期范围选择器（居中对齐）、时间范围切换按钮组（水平排列）、图表展示区域（包含当前睡眠时长显示和睡眠阶段颜色图例）、
 * 睡眠质量评估区域、统计区域（2x2网格布局显示四种睡眠阶段的平均时长）。
 * @constraints:
 * @domain: 健康医疗
 * @isGen: true
 * @fileType: page
 * @zhName: 睡眠数据看板页面
 * @subPage: SleepHistoryPage
 * @component: WeeklySleepChart,MonthlySleepChart,ThreeMonthsSleepChart,TimeRangeButton,CommonHeader
 * @image: screenshot/health/Sleep.jpg
 */
@ComponentV2
export struct SleepPage {
  private vm: SleepVM = SleepVM.instance;
  @Local routerModule: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    SleepVM.resetInstance();
    this.vm = SleepVM.instance;
    this.vm.init()
  }

  handleBack = (): void => {
    this.routerModule.pop('back');
  }
  navigateToHistory = (): void => {
    this.vm.closeMenus();
    this.routerModule.pushPathByName('SleepHistoryPage', null);
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
            top: $r('app.float.vp_8'),
            left: $r('app.float.vp_16'),
            bottom: $r('app.float.vp_24'),
            right: $r('app.float.vp_16')
          })
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .width('100%')
      }
      .justifyContent(FlexAlign.Start)
      .padding({ top: 24 })
      .width('100%')
      .height('100%')
    }
    .backgroundColor($r('sys.color.comp_background_gray'))
    .hideTitleBar(true)
    .onReady((context) => {
      // 获取参数
      this.routerModule = context.pathStack;
    })
    .onBackPressed(() => {
      this.routerModule.pop('back')
      return true
    })
  }

  @Builder
  private renderCustomHeader() {
    CommonHeader({
      showMenu: this.vm.showMenu,
      onMenuDisappear: this.vm.closeMenus,
      menuItems: [{ value: '历史记录', action: this.navigateToHistory }],
      onMenuToggle: this.vm.toggleMenu,
      title: '睡眠',
      onBack: this.handleBack
    })
  }

  @Builder
  private renderDateAndRange() {
    Column({ space: 8 }) {
      Row({ space: 6 }) {
        Text(this.vm.dateRangeText)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')

      Row({ space: 10 }) {
        TimeRangeButton({
          label: '近七天',
          isSelected: this.vm.currentRange === SleepTimeRange.WEEK,
          onTap: () => this.vm.switchTimeRange(SleepTimeRange.WEEK)
        })
        TimeRangeButton({
          label: '近一个月',
          isSelected: this.vm.currentRange === SleepTimeRange.MONTH,
          onTap: () => this.vm.switchTimeRange(SleepTimeRange.MONTH)
        })
        TimeRangeButton({
          label: '近三个月',
          isSelected: this.vm.currentRange === SleepTimeRange.THREE_MONTHS,
          onTap: () => this.vm.switchTimeRange(SleepTimeRange.THREE_MONTHS)
        })
      }
      .backgroundColor($r('sys.color.background_primary'))
      .borderRadius($r('sys.float.corner_radius_level12'))
      .width('100%')
      .padding(4)
    }
  }

  @Builder
  private renderChartSection() {
    Column({ space: 12 }) {
      Column({ space: 4 }) {
        Text(this.vm.currentDateText)
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.mask_secondary'))
        if (this.vm.currentRange === SleepTimeRange.MONTH) {
          Row({ space: 4 }) {
            Text(this.vm.totalHour.toString())
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('sys.float.Title_L'))
              .fontWeight(FontWeight.Bold)
            Text('小时')
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('sys.float.Body_M'))
            Text(this.vm.totalMinute.toString())
              .fontSize($r('sys.float.Title_L'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Bold)
            Text('分钟')
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('sys.float.Body_M'))
          }
        } else if (this.vm.currentRange === SleepTimeRange.THREE_MONTHS) {
          Row({ space: 4 }) {
            Text(this.vm.totalHour.toString())
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('sys.float.Title_L'))
              .fontWeight(FontWeight.Bold)
            Text('小时')
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_primary'))
          }
        } else {
          Row({ space: 4 }) {
            Text(this.vm.totalHour.toString())
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('sys.float.Title_L'))
              .fontWeight(FontWeight.Bold)
            Text('小时')
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('sys.float.Body_M'))
            Text(this.vm.totalMinute.toString())
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('sys.float.Title_L'))
              .fontWeight(FontWeight.Bold)
            Text('分钟')
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_primary'))
          }
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      if (this.vm.currentRange === SleepTimeRange.WEEK) {
        WeeklySleepChart({
          sleepData: this.vm.chartSleepData,
          dateLabels: this.vm.chartLabels,
          onValueSelected: this.vm.updateSelectedData
        })
      } else if (this.vm.currentRange === SleepTimeRange.MONTH) {
        MonthlySleepChart({
          sleepData: this.vm.chartSleepData,
          labels: this.vm.chartLabels,
          groupSizes: this.vm.chartGroupSizes,
          onValueSelected: this.vm.updateSelectedData
        })
      } else if (this.vm.currentRange === SleepTimeRange.THREE_MONTHS) {
        ThreeMonthsSleepChart({
          sleepData: this.vm.chartSleepData,
          labels: this.vm.chartLabels,
          groupSizes: this.vm.chartGroupSizes,
          onValueSelected: this.vm.updateSelectedData
        })
      }

      Row({ space: 16 }) {
        Row({ space: 6 }) {
          Row()
            .width(12)
            .height(8)
            .backgroundColor('#005AFF')
            .borderRadius($r('sys.float.corner_radius_level1'))
          Text('深睡')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.mask_secondary'))
        }

        Row({ space: 6 }) {
          Row()
            .width(12)
            .height(8)
            .backgroundColor('#50AAFF')
            .borderRadius($r('sys.float.corner_radius_level1'))
          Text('浅睡')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.mask_secondary'))
        }

        Row({ space: 6 }) {
          Row()
            .width(12)
            .height(8)
            .backgroundColor('#FFD000')
            .borderRadius($r('sys.float.corner_radius_level1'))
          Text('快速眼动')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.mask_secondary'))
        }

        Row({ space: 6 }) {
          Row()
            .width(12)
            .height(8)
            .backgroundColor('#FFA000')
            .borderRadius($r('sys.float.corner_radius_level1'))
          Text('清醒')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.mask_secondary'))
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }

  @Builder
  private renderStatisticsSection() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Text('睡眠质量')
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)

        Blank().layoutWeight(1)

        Text('良好')
          .fontSize($r('sys.float.Body_M'))
          .fontColor('#00CC66')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')

      Column({ space: 12 }) {
        Row({ space: 12 }) {
          // 平均深度睡眠
          Row({ space: 8 }) {
            Row()
              .width($r('app.float.vp_8'))
              .height($r('app.float.vp_8'))
              .backgroundColor('#005AFF')
              .borderRadius($r('sys.float.corner_radius_level1'))
            Column({ space: 4 }) {
              Text('平均深度睡眠')
                .fontSize($r('sys.float.Body_S'))
                .fontColor($r('sys.color.mask_secondary'))
              Row({ space: 2 }) {
                Text(this.vm.statistics.avgDeepSleep.toString())
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('sys.color.font_primary'))
                Text('小时')
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor($r('sys.color.font_primary'))
                Text(this.vm.statistics.avgDeepSleepMinute.toString())
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('sys.color.font_primary'))
                  .fontSize(24)
                Text('分钟')
                  .fontColor($r('sys.color.font_primary'))
                  .fontSize($r('sys.float.Body_S'))
              }
            }
            .alignItems(HorizontalAlign.Start)
          }
          .backgroundColor('#F9F9F9')
          .borderRadius($r('sys.float.corner_radius_level4'))
          .layoutWeight(1)
          .alignItems(VerticalAlign.Top)
          .padding($r('app.float.vp_12'))
          .alignItems(VerticalAlign.Top)

          // 平均浅度睡眠
          Row({ space: 8 }) {
            Row()
              .height($r('app.float.vp_8'))
              .width($r('app.float.vp_8'))
              .backgroundColor('#50AAFF')
              .borderRadius($r('sys.float.corner_radius_level1'))
            Column({ space: 4 }) {
              Text('平均浅度睡眠')
                .fontColor($r('sys.color.mask_secondary'))
                .fontSize($r('sys.float.Body_S'))
              Row({ space: 2 }) {
                Text(this.vm.statistics.avgLightSleep.toString())
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('sys.color.font_primary'))
                Text('小时')
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor($r('sys.color.font_primary'))
                Text(this.vm.statistics.avgLightSleepMinute.toString())
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('sys.color.font_primary'))
                Text('分钟')
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor($r('sys.color.font_primary'))
              }
            }
            .alignItems(HorizontalAlign.Start)
          }
          .alignItems(VerticalAlign.Top)
          .padding($r('app.float.vp_12'))
          .backgroundColor('#F9F9F9')
          .borderRadius($r('sys.float.corner_radius_level4'))
          .layoutWeight(1)
          .alignItems(VerticalAlign.Top)
        }

        Row({ space: 12 }) {
          // 平均快速眼动
          Row({ space: 8 }) {
            Row()
              .width(8)
              .height(8)
              .backgroundColor('#FFD000')
              .borderRadius($r('sys.float.corner_radius_level1'))
            Column({ space: 4 }) {
              Text('平均快速眼动')
                .fontSize($r('sys.float.Body_S'))
                .fontColor($r('sys.color.mask_secondary'))
              Row({ space: 2 }) {
                Text(this.vm.statistics.avgREM.toString())
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('sys.color.font_primary'))
                Text('分钟')
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor($r('sys.color.font_primary'))
              }
            }
            .alignItems(HorizontalAlign.Start)
          }
          .alignItems(VerticalAlign.Top)
          .padding(12)
          .backgroundColor('#F9F9F9')
          .borderRadius($r('sys.float.corner_radius_level4'))
          .layoutWeight(1)
          .alignItems(VerticalAlign.Top)

          // 平均清醒状态
          Row({ space: 8 }) {
            Row()
              .width(8)
              .height(8)
              .backgroundColor('#FFA000')
              .borderRadius($r('sys.float.corner_radius_level1'))
            Column({ space: 4 }) {
              Text('平均清醒状态')
                .fontSize($r('sys.float.Body_S'))
                .fontColor($r('sys.color.mask_secondary'))
              Row({ space: 2 }) {
                Text(this.vm.statistics.avgAwake.toString())
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('sys.color.font_primary'))
                Text('分钟')
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor($r('sys.color.font_primary'))
              }
            }
            .alignItems(HorizontalAlign.Start)
          }
          .alignItems(VerticalAlign.Top)
          .padding(12)
          .backgroundColor('#F9F9F9')
          .borderRadius($r('sys.float.corner_radius_level4'))
          .layoutWeight(1)
          .alignItems(VerticalAlign.Top)
        }
      }
    }
    .width('100%')
    .padding($r('app.float.vp_16'))
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius($r('sys.float.corner_radius_level8'))
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

