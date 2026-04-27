/**
 * 月度报告 Model
 */
import { MonthlyReportData } from '../types/MonthlyReportTypes';
import { MONTHLY_REPORT_DATA } from '../mock/MonthlyReportMockData';

@ObservedV2
export class MonthlyReportModel {
  private static _instance: MonthlyReportModel;
  @Trace reportData: MonthlyReportData = MONTHLY_REPORT_DATA;
  @Trace selectedDateIndex: number = 0;
  // 月份选项列表
  dateOptions: string[] = [
    '2024年12月',
    '2024年11月',
    '2024年10月',
    '2024年9月',
    '2024年8月'
  ];

  public static get instance() {
    if (!MonthlyReportModel._instance) {
      MonthlyReportModel._instance = new MonthlyReportModel();
    }
    return MonthlyReportModel._instance;
  }

  /**
   * 选择日期
   */
  public selectDate(index: number): void {
    this.selectedDateIndex = index;
    // 创建新对象以触发响应式更新
    const newData: MonthlyReportData = {
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
    console.log('选择月份:', this.dateOptions[index]);
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
   * 生成报告
   */
  public generateReport(): void {
    // TODO: 实现生成报告功能
    console.log('生成月度报告');
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

