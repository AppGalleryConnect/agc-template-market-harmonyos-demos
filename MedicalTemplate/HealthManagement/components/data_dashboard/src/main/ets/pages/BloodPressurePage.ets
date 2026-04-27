// 血压数据看板页面
import WeeklyBloodPressureChart from '../cards/WeeklyBloodPressureChart';
import MonthlyBloodPressureChart from '../cards/MonthlyBloodPressureChart';
import ThreeMonthsBloodPressureChart from '../cards/ThreeMonthsBloodPressureChart';
import { TimeRange } from '../types/BloodPressureTypes';
import { BloodPressureVM } from '../viewmodel/BloodPressureVM';
import { CommonHeader } from '../components/CommonHeader';

/**
 * @usage: 用于展示血压数据看板的主页面。包含自定义导航栏（返回按钮、标题、菜单按钮）、日期范围选择器、
 * 时间范围切换按钮（近七天/近一个月/近三个月）、血压图表展示区域（包含平均血压和平均脉搏显示、血压状态评估、高压低压图例）、
 * 脉搏统计卡片（平均血压值和平均脉搏）。主要数据结构包括BloodPressureVM（血压视图模型）。
 * 包含if逻辑用于根据时间范围显示不同的血压图表组件。
 * @layout: 页面采用垂直布局（Column），顶部为自定义导航栏（Stack布局），下方为主要内容区域（Column布局），包含日期范围选择器（居中对齐）
 * 时间范围切换按钮组（水平排列）、图表展示区域（包含当前血压值显示和高压低压图例）、脉搏统计卡片（水平分割显示平均血压值和平均脉搏）。
 * @constraints:
 * @domain: 健康医疗
 * @isGen: true
 * @fileType: page
 * @zhName: 血压数据看板页面
 * @subPage: BloodPressureHistoryPage
 * @component: WeeklyBloodPressureChart,MonthlyBloodPressureChart,ThreeMonthsBloodPressureChart,TimeRangeButton,
 * PulseCard,CommonHeader
 * @image: screenshot/health/BloodPressure.jpg
 */
@ComponentV2
export struct BloodPressurePage {
  private vm: BloodPressureVM = BloodPressureVM.instance;
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
    this.routerModule.pushPathByName('BloodPressureHistoryPage', null);
  }

  build() {
    NavDestination() {
      Column() {
        this.renderCustomHeader()
        Scroll() {
          Column({ space: 12 }) {
            this.renderDateAndRange();
            this.renderChartSection();
            PulseCard({
              avgPulse: this.vm.statistics.avgPulse
            })

          }
          .justifyContent(FlexAlign.Start)
          .width('100%')
          .padding({
            top: 8,
            bottom: 24,
            left: 16,
            right: 16
          })
        }
        .width('100%')
        .align(Alignment.Top)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
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
      title: '血压',
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
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Row({ space: 10 }) {
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
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.mask_secondary'))

        Row({ space: 6 }) {
          Text('平均血压')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.mask_secondary'))
          Text(this.vm.currentSystolic.toString())
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
          Text('mmHg')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.mask_secondary'))
          Text('正常高值')
            .fontSize($r('sys.float.Body_S'))
            .fontColor('#FF6B00')
        }

        Row({ space: 6 }) {
          Text('平均脉搏')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.mask_secondary'))
          Text('-- ')
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
          Text('/分钟')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.mask_secondary'))
        }
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .padding({ top: 16, left: 16, right: 16 })

      if (this.vm.currentRange === TimeRange.WEEK) {
        WeeklyBloodPressureChart({
          systolicValues: this.vm.chartSystolicValues,
          diastolicValues: this.vm.chartDiastolicValues,
          currentIndex: 3,
          onValueSelected: this.vm.updateSelectedBloodPressure
        })
          .width('100%')
          .height(240)
          .padding({ left: 0, right: 0 })
      } else if (this.vm.currentRange === TimeRange.MONTH) {
        MonthlyBloodPressureChart({
          systolicValues: this.vm.chartSystolicValues,
          diastolicValues: this.vm.chartDiastolicValues,
          dateLabels: this.vm.chartLabels,
          currentIndex: 4,
          onValueSelected: this.vm.updateSelectedBloodPressure
        })
          .width('100%')
          .height(240)
          .padding({ left: 0, right: 0 })
      } else {
        ThreeMonthsBloodPressureChart({
          systolicValues: this.vm.chartSystolicValues,
          diastolicValues: this.vm.chartDiastolicValues,
          monthLabels: this.vm.chartLabels,
          currentIndex: 4,
          onValueSelected: this.vm.updateSelectedBloodPressure
        })
          .width('100%')
          .height(240)
          .padding({ left: 0, right: 0 })
      }

      Row({ space: 16 }) {
        Row({ space: 6 }) {
          Circle()
            .width(8)
            .height(8)
            .fill($r('sys.color.multi_color_10'))
          Text('高压（收缩压）')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.mask_secondary'))
        }

        Row({ space: 6 }) {
          Circle()
            .width(8)
            .height(8)
            .fill('#2196F3')
          Text('低压（舒张压）')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.mask_secondary'))
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ bottom: 16 })
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


// 脉搏卡片组件
@ComponentV2
struct PulseCard {
  @Param avgPulse: number = 128;

  build() {
    Row({ space: 16 }) {
      Column({ space: 6 }) {
        Row({ space: 6 }) {
          Text(`128/88`)
            .fontSize($r('sys.float.Title_M'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
          Text('mmHg')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.mask_secondary'))
        }

        Text('平均血压平均值')
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
          Text('-- ')
            .fontSize($r('sys.float.Subtitle_L'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
          Text('/分钟')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.mask_secondary'))
        }

        Text('平均脉搏')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.mask_secondary'))
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding({
      top: 20,
      bottom: 20,
      left: 20,
      right: 20
    })
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }
}

@Builder
export function BloodPressurePageBuilder() {
  BloodPressurePage()
}

