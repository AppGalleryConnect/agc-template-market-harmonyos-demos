import { TimeUtil } from 'common';

@ObservedV2
export class HealthDataInputModel {
  @Trace todayExerciseTime = 120; // 今日运动时间
  @Trace todayExerciseConsumption = 346; // 今日运动消耗
  @Trace todayStatus = '良好'; // 今日身体状态

  @Trace bmiValue = 0; // bmi值
  @Trace bmiType = 1; // 1: 偏瘦；2正常；3偏胖；4肥胖
  @Trace bodyFatPercentage = 0; // 实际体脂率
  @Trace fatWeight = 0; // 实际脂肪重量

  @Trace weight = 0; // 体重
  @Trace weightIndex: number | number[] = 0; // 体重索引
  @Trace waistCircumference = 0; // 腰围
  @Trace hipCircumference = 0; // 臀围

  @Trace bloodSugar = 0; // 血糖
  @Trace bloodSugarIndex: number | number[] = 0; // 血糖索引
  @Trace bloodSugarTime = '暂未录入数据'; // 血糖录入时间
  @Trace bloodPressureSystolic = 0; // 收缩压
  @Trace bloodPressureDiastolic = 0; // 舒张压
  @Trace bloodPressureTime = '暂未录入数据'; // 血压录入时间
  @Trace heartRate = 0; // 心率
  @Trace heartRateTime = '暂未录入数据'; // 心率录入时间

  bmiCalculator(height: number, weight: number) {
    return (Math.round(weight / ((height/100) * (height/100)) * 10)) / 10;
  }

  /**
   * 偏瘦：< 18.5
   * 正常：18.5 - 24.9
   * 偏胖：25 - 29.9
   * 肥胖：≥ 30
   */
  bmiTypeCalculator(bmiValue: number) {
    if (bmiValue < 18.5) {
      return 1;
    } else if (bmiValue >= 18.5 && bmiValue < 25) {
      return 2;
    } else if (bmiValue >= 25 && bmiValue < 30) {
      return 3;
    } else {
      return 4;
    }
  }

  getBodyFatPercentage(bir: string, bmi: number, sex: string) {
    const birthday = TimeUtil.parseDate(bir, TimeUtil.PATTERN_DATE_HYPHEN);
    const currentTime = new Date().getTime()
    const currentAge = (currentTime - birthday)/(3600 * 24 * 30 * 12 * 1000);
    const age = (Math.round(currentAge * 10)) / 10;
    if (sex === '男') {
      let per = ((1.2 * bmi) + (0.23 * age) - 16.2);
      return (Math.round(per * 10)) / 10;
    } else {
      let per = ((1.2 * bmi) + (0.23 * age) - 5.4);
      return (Math.round(per * 10)) / 10;
    }
  }
}