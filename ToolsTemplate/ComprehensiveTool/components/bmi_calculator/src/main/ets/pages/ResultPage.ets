import { getBmiNavPathStack, getRouteParams, clearRouteParams } from '../common/Route';
import { RecordItem } from '../common/RecordItem';
import { loadRecords, getLatestRecord, getRecordById, RecordsModel } from '../common/BmiStorage';

@Extend(Text)
function commonTextStyle() {
  .fontSize(14)
  .fontWeight(FontWeight.Medium)
  .fontColor($r('sys.color.font_primary'))
  .textAlign(TextAlign.Start);
}

@Builder export function ResultPageBuilder() {
  ResultPage();
}

@ComponentV2
struct ResultPage {
  @Local bmiResult: number = 0;
  @Local evaluation: string = '';
  @Local evaluationColor: string = '';
  @Local heightValue: number = 0;
  @Local weightValue: number = 0;
  @Local calculationTime: string = '';
  @Local recordsModel: RecordsModel = loadRecords();
  @Local recordId: string = '';

  aboutToAppear() {
    const params = getRouteParams();
    if (params && params.recordId) {
      this.recordId = params.recordId;
      this.initFromRecordId(this.recordId);
    } else {
      this.initFromLatestRecord();
    }
  }

  aboutToDisappear(): void {
    clearRouteParams();
  }

  private initFromRecordId(recordId: string): void {
    const record = getRecordById(recordId, this.recordsModel);
    if (record) {
      this.setDataFromRecord(record);
    } else {
      this.setEmptyData();
    }
  }

  private initFromLatestRecord() {
    const record = getLatestRecord(this.recordsModel);
    if (record) {
      this.setDataFromRecord(record);
    } else {
      this.setEmptyData();
    }
  }

  private setDataFromRecord(record: RecordItem) {
  this.bmiResult = record.bmiValue;
  this.evaluation = record.evaluation;
  this.heightValue = record.height;
  this.weightValue = record.weight;
  this.calculationTime = `${record.date} ${record.time}`;
  this.setEvaluationColor();
}

private setEmptyData() {
  this.bmiResult = 0;
  this.evaluation = '';
  this.heightValue = 0;
  this.weightValue = 0;
  this.calculationTime = '';
  this.evaluationColor = '#000000';
}

private setEvaluationColor() {
  if (this.evaluation === '偏瘦') {
    this.evaluationColor = '#ED6F21';
  } else if (this.evaluation === '正常') {
    this.evaluationColor = '#64BB5C';
  } else if (this.evaluation === '偏胖') {
    this.evaluationColor = '#ED6F21';
  } else {
    this.evaluationColor = '#E84026';
  }
}

build() {
  NavDestination() {
    Column() {
      Row() {
        Text('计算结果')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'));
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 24 });

      Column() {
        if (this.calculationTime) {
          Text(`${this.calculationTime}`)
            .fontSize(12)
            .fontColor($r('sys.color.font_tertiary'))
            .textAlign(TextAlign.Center)
            .margin({ bottom: 8 });
        }

        if (this.evaluation) {
          Text(`${this.evaluation}`)
            .fontSize(20)
            .fontColor(this.evaluationColor)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .margin({ bottom: 8 });

          Row() {
            Row({ space:4 }) {
              Text(`${this.heightValue.toFixed(1)}cm`)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .textAlign(TextAlign.Center)
              Text(`${this.weightValue.toFixed(1)}kg`)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .textAlign(TextAlign.Center)
            }
            .margin({ right: 12 });
            Text(`BMI指数：${this.bmiResult.toFixed(1)}`)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .textAlign(TextAlign.Center)
          }
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 23 });

          if (this.evaluation === '偏瘦') {
            Text('你的身体偏瘦，建议增加高蛋白食品摄入并关注肠胃功能的健康与调养。')
              .commonTextStyle();
          } else if (this.evaluation === '正常') {
            Text('你的体重很健康，请继续保持！')
              .commonTextStyle();
          } else if (this.evaluation === '偏胖') {
            Text('你的体重偏重，建议对饮食进行更科学的规划，并可抽空适当进行运动。')
              .commonTextStyle();
          } else {
            Text('很遗憾，你已经达到了肥胖水平，为了你的健康，请减少脂肪、糖分以及碳水的摄入并在每天进行适量运动。')
              .commonTextStyle();
          }
        }
      }
      .width('100%')
      .padding(16)
      .borderRadius(16)
      .backgroundColor('#FFFFFF')

      Blank()

      Column() {
        Button('重新计算')
          .width('100%')
          .height(40)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#0BCFB1')
          .position({ bottom: 24 })
          .onClick(() => {
            getBmiNavPathStack().pop();
          });
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .padding(16);
  }
  .backgroundColor('#F1F3F5');
}
}
