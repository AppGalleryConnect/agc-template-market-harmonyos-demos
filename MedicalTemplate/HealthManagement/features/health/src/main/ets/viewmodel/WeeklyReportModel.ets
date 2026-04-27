/**
 * 周度报告 Model
 */
import { WeeklyReportData } from '../types/WeeklyReportTypes';
import { WEEKLY_REPORT_DATA } from '../mock/WeeklyReportMockData';

@ObservedV2
export class WeeklyReportModel {
  private static _instance: WeeklyReportModel;

  @Trace reportData: WeeklyReportData = WEEKLY_REPORT_DATA;
  @Trace selectedDateIndex: number = 0;

  // 日期选项列表
  dateOptions: string[] = [
    '2024年2月27日 - 03月02日',
    '2024年2月20日 - 02月26日',
    '2024年2月13日 - 02月19日',
    '2024年2月06日 - 02月12日',
    '2024年1月30日 - 02月05日'
  ];

  public static get instance() {
    if (!WeeklyReportModel._instance) {
      WeeklyReportModel._instance = new WeeklyReportModel();
    }
    return WeeklyReportModel._instance;
  }

  /**
   * 选择日期
   */
  public selectDate(index: number): void {
    this.selectedDateIndex = index;
    // 创建新对象以触发响应式更新
    const newData: WeeklyReportData = {
      startDate: this.reportData.startDate,
      endDate: this.reportData.endDate,
      dateRange: this.dateOptions[index],
      weightTrend: this.reportData.weightTrend,
      bodyFatTrend: this.reportData.bodyFatTrend,
      bloodPressure: this.reportData.bloodPressure,
      heartRate: this.reportData.heartRate
    };
    this.reportData = newData;
    // TODO: 根据选择的日期加载对应的数据
    console.log('选择日期:', this.dateOptions[index]);
  }

  /**
   * 生成报告
   */
  public generateReport(): void {
    // TODO: 实现生成报告功能
    console.log('生成周度报告');
  }

  /**
   * 获取体重变化文字
   */
  public getWeightChangeText(): string {
    const change = this.reportData.weightTrend.change;
    if (change > 0) {
      return `+${change.toFixed(1)}`;
    } else if (change < 0) {
      return change.toFixed(1);
    }
    return '0';
  }

  /**
   * 获取体脂率变化文字
   */
  public getBodyFatChangeText(): string {
    const change = this.reportData.bodyFatTrend.change;
    if (change > 0) {
      return `+${change.toFixed(1)}`;
    } else if (change < 0) {
      return change.toFixed(1);
    }
    return '0';
  }
}

