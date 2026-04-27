// 健康报告页面基础组件
import { phoneRouterControl } from 'oh_router';
import { UnitConverter, BarVM } from 'common';

// 图表数据点类型
export interface ChartDataPoint {
  date: string;
  value: number;
}

// 报告数据接口
export interface ReportViewModel {
  reportData: ReportData;

  getWeightChangeText(): string;

  getBodyFatChangeText(): string;
}

export interface ReportData {
  dateRange: string;
  weightTrend: WeightTrendData;
  bodyFatTrend: BodyFatTrendData;
  bloodPressure: BloodPressureData;
  heartRate: HeartRateData;
}

export interface WeightTrendData {
  maxWeight: number;
  minWeight: number;
  chartData: ChartDataPoint[];
}

export interface BodyFatTrendData {
  maxBodyFat: number;
  minBodyFat: number;
  chartData: ChartDataPoint[];
}

export interface BloodPressureData {
  systolic: number;
  diastolic: number;
}

export interface HeartRateData {
  maxHeartRate: number;
  minHeartRate: number;
  restingHeartRate: number;
  averageHeartRate: number;
}

// 报告页面配置
export class ReportPageConfig {
  title: string = '';
  weightChartComponent: WrappedBuilder<[ChartDataPoint[]]> | null = null;
  bodyFatChartComponent: WrappedBuilder<[ChartDataPoint[]]> | null = null;
}

// 基础报告页面组件
@ComponentV2
export struct BaseReportPage {
  @Require @Param vm: ReportViewModel;
  @Require @Param config: ReportPageConfig;
  private handleBack = (): void => {
    phoneRouterControl.popPage();
  }

  build() {
    NavDestination() {
      Column() {
        this.buildNavigationBar()

        Scroll() {
          Column({ space: 16 }) {
            Text(this.vm.reportData.dateRange)
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.black'))
              .fontFamily('HarmonyOS Sans SC Medium')
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ top: 12, bottom: 12 })

            this.buildWeightTrendCard()
            this.buildBodyFatTrendCard()
            this.buildBloodPressureCard()
            this.buildHeartRateCard()
          }
          .width('100%')
          .padding({
            left: 16,
            right: 16,
            top: 8,
            bottom: 24
          })
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.comp_background_gray'))
    }
    .hideTitleBar(true)
  }

  @Builder
  private buildNavigationBar() {
    Row() {
      Image($r('app.media.ic_backward2'))
        .width(40)
        .aspectRatio(1)
        .margin({ left: 16, top: 24, right: 8 })
        .onClick(this.handleBack)

      Text(this.config.title)
        .size({ height: 27 })
        .margin({ top: 24 })
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(700)
        .fontColor($r('sys.color.black'))

      Blank().layoutWeight(1)
    }
    .height(UnitConverter.px2vp(BarVM.instance.statusBarHeight.value) + 48)
    .width('100%')
    .margin({ top: 8, bottom: 4 })
  }

  @Builder
  private buildWeightTrendCard() {
    Column({ space: 12 }) {
      Text('体重趋势')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.black'))
        .width('100%')
        .padding({ left: 20, right: 20, top: 16 })

      Row({ space: 0 }) {
        this.buildStatColumn(
          this.vm.reportData.weightTrend.maxWeight.toString(),
          '最高体重(斤)',
          $r('sys.float.Title_M')
        )
        this.buildStatColumn(
          this.vm.reportData.weightTrend.minWeight.toString(),
          '最低体重(斤)',
          $r('sys.float.Title_M')
        )
        this.buildStatColumn(
          this.vm.getWeightChangeText(),
          '变化',
          24
        )
      }
      .width('100%')
      .padding({ left: 20, right: 20 })

      if (this.config.weightChartComponent !== null) {
        this.config.weightChartComponent.builder(this.vm.reportData.weightTrend.chartData)
      }
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius($r('sys.float.corner_radius_level7'))
    .padding({ bottom: 16 })
    .clip(true)
  }

  @Builder
  private buildBodyFatTrendCard() {
    Column({ space: 12 }) {
      Text('体脂率趋势')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.black'))
        .width('100%')
        .padding({ left: 20, right: 20, top: 16 })

      Row({ space: 0 }) {
        this.buildStatColumn(
          this.vm.reportData.bodyFatTrend.maxBodyFat.toFixed(1),
          '最高',
          24
        )
        this.buildStatColumn(
          this.vm.reportData.bodyFatTrend.minBodyFat.toFixed(1),
          '最低',
          24
        )
        this.buildStatColumn(
          this.vm.getBodyFatChangeText(),
          '变化',
          24
        )
      }
      .width('100%')
      .padding({ left: 20, right: 20 })

      if (this.config.bodyFatChartComponent !== null) {
        this.config.bodyFatChartComponent.builder(this.vm.reportData.bodyFatTrend.chartData)
      }
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius($r('sys.float.corner_radius_level7'))
    .padding({ bottom: 16 })
    .clip(true)
  }

  @Builder
  private buildBloodPressureCard() {
    Column() {
      Text('血压')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.black'))
        .width('100%')
        .padding({
          left: 20,
          right: 20,
          top: 20,
          bottom: 12
        })

      Row({ space: 0 }) {
        Column({ space: 4 }) {
          Row({ space: 6 }) {
            Text() {
              Span(`${this.vm.reportData.bloodPressure.systolic}/`)
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('sys.color.black'))
                .fontFamily('HarmonyOS Sans SC Medium')
              Span(`${this.vm.reportData.bloodPressure.diastolic}`)
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('sys.color.black'))
                .fontFamily('HarmonyOS Sans SC Medium')
            }

            Text('mmHg')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_secondary'))
              .fontFamily('HarmonyOS Sans SC')
              .margin({ top: 6 })
          }
          .alignItems(VerticalAlign.Bottom)

          Text('平均血压平均值')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
            .fontFamily('HarmonyOS Sans SC')
        }
        .alignItems(HorizontalAlign.Center)
        .layoutWeight(1)

        Divider()
          .vertical(true)
          .height(45)
          .color($r('sys.color.comp_divider'))
          .strokeWidth('1px')
          .margin({ left: 8, right: 8 })

        Column({ space: 4 }) {
          Row({ space: 8 }) {
            Text('- -')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.black'))
              .fontFamily('HarmonyOS Sans SC Medium')

            Text('/分钟')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_secondary'))
              .fontFamily('HarmonyOS Sans SC')
              .margin({ top: 6 })
          }
          .alignItems(VerticalAlign.Bottom)

          Text('平均脉搏')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
            .fontFamily('HarmonyOS Sans SC')
        }
        .alignItems(HorizontalAlign.Center)
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius($r('sys.float.corner_radius_level7'))
    .clip(true)
  }

  @Builder
  private buildHeartRateCard() {
    Column() {
      Text('心率')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.black'))
        .width('100%')
        .padding({
          left: 20,
          right: 20,
          top: 20,
          bottom: 16
        })

      Row({ space: 0 }) {
        this.buildHeartRateItem('最高心率', this.vm.reportData.heartRate.maxHeartRate)
        this.buildHeartRateItem('最低心率', this.vm.reportData.heartRate.minHeartRate)
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 16 })

      Row({ space: 0 }) {
        this.buildHeartRateItem('静息心率', this.vm.reportData.heartRate.restingHeartRate)
        this.buildHeartRateItem('平均心率', this.vm.reportData.heartRate.averageHeartRate)
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius($r('sys.float.corner_radius_level7'))
    .clip(true)
  }

  @Builder
  private buildStatColumn(value: string, label: string, fontSize: number | Resource) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(fontSize)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.black'))
      Text(label)
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.font_secondary'))
    }
    .layoutWeight(1)
  }

  @Builder
  private buildHeartRateItem(label: string, value: number) {
    Column({ space: 0 }) {
      Row({ space: 6 }) {
        Circle({ width: 8, height: 8 })
          .fill($r('sys.color.warning'))

        Text(label)
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_secondary'))
          .fontFamily('HarmonyOS Sans SC')
      }
      .margin({ bottom: 8 })

      Row({ space: 6 }) {
        Text(`${value}`)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.black'))
          .fontFamily('HarmonyOS Sans SC Medium')
          .margin({ left: 14 })

        Text('次/分')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_secondary'))
          .fontFamily('HarmonyOS Sans SC')
          .margin({ top: 6 })
      }
      .alignItems(VerticalAlign.Bottom)
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
  }
}
