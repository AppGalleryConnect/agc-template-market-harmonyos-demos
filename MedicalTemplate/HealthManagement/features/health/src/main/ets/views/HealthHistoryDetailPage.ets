//健康历史详情页面
import { phoneRouterControl } from 'oh_router';
import { TValueType, UnitConverter, BarVM } from 'common';
import { HealthHistoryItem } from '../types/HealthHistoryTypes';

@Builder
export function HealthHistoryDetailPageBuilder(value: TValueType) {
  HealthHistoryDetailPage({
    value: value
  })
}

//健康历史详情页面
@ComponentV2
export struct HealthHistoryDetailPage {
  @Param @Require value: TValueType;
  @Local historyData: HealthHistoryItem = {
    id: '1',
    date: '9月12日',
    weight: 112.4,
    fullDate: '2025年9月12日',
    height: 167,
    age: 28,
    bmi: 23.2,
    bodyFat: 32.1,
    fatMass: 39.3,
    heartRate: 85,
    bloodPressureSystolic: 128,
    bloodPressureDiastolic: 88,
    bloodGlucose: 5.0
  };

  aboutToAppear(): void {
    this.historyData = this.value as HealthHistoryItem;
  }

  handleBack = (): void => {
    phoneRouterControl.popPage();
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Image($r('app.media.ic_backward2'))
            .width(40)
            .aspectRatio(1)
            .margin({ left: 16, top: 32, right: 8 })
            .onClick(this.handleBack)

          Text(this.historyData.fullDate)
            .size({ height: 27 })
            .margin({ top: 32 })
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(700)
            .fontColor($r('sys.color.black'))

          Blank().layoutWeight(1)
        }
        .height(UnitConverter.px2vp(BarVM.instance.statusBarHeight.value) + 48)
        .width('100%')
        .margin({ top: 16, bottom: 8 })

        Column({ space: 12 }) {
          Row({ space: 0 }) {
            Column({ space: 6 }) {
              Text(this.historyData.weight.toFixed(1))
                .fontSize($r('sys.float.Title_M'))
                .fontWeight(FontWeight.Bold)
                .fontColor($r('sys.color.black'))
                .fontFamily('HarmonyOS Sans SC')
              Text('体重(斤)')
                .fontSize($r('sys.float.Body_S'))
                .fontColor($r('sys.color.font_secondary'))
                .fontFamily('HarmonyOS Sans SC')
            }
            .layoutWeight(1)

            Divider()
              .vertical(true)
              .height(42)
              .color($r('sys.color.comp_divider'))
              .strokeWidth('1px')

            Column({ space: 6 }) {
              Text(this.historyData.height.toString())
                .fontSize($r('sys.float.Title_M'))
                .fontWeight(FontWeight.Bold)
                .fontColor($r('sys.color.black'))
                .fontFamily('HarmonyOS Sans SC')
              Text('身高(厘米)')
                .fontSize($r('sys.float.Body_S'))
                .fontColor($r('sys.color.font_secondary'))
                .fontFamily('HarmonyOS Sans SC')
            }
            .layoutWeight(1)

            Divider()
              .vertical(true)
              .height(42)
              .color($r('sys.color.comp_divider'))
              .strokeWidth('1px')

            Column({ space: 6 }) {
              Text(this.historyData.age.toString())
                .fontSize($r('sys.float.Title_M'))
                .fontWeight(FontWeight.Bold)
                .fontColor($r('sys.color.black'))
                .fontFamily('HarmonyOS Sans SC')
              Text('年龄')
                .fontSize($r('sys.float.Body_S'))
                .fontColor($r('sys.color.font_secondary'))
                .fontFamily('HarmonyOS Sans SC')
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding({
            left: 24,
            right: 24,
            top: 24,
            bottom: 24
          })
          .backgroundColor(Color.White)
          .borderRadius($r('sys.float.corner_radius_level7'))
          .clip(true)

          Column({ space: 0 }) {
            this.renderDataRow('BMI', this.historyData.bmi.toFixed(1), false)
            this.renderDataRow('体脂率', `${this.historyData.bodyFat.toFixed(1)}%`, false)
            this.renderDataRow('脂肪重量', this.historyData.fatMass.toFixed(1), false)
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius($r('sys.float.corner_radius_level7'))
          .clip(true)

          Column({ space: 0 }) {
            this.renderDataRow('心率', `${this.historyData.heartRate}次/分`, false)
            this.renderDataRow('血压',
              `${this.historyData.bloodPressureSystolic}/${this.historyData.bloodPressureDiastolic}mmHg`, false)
            this.renderDataRow('血糖', `${this.historyData.bloodGlucose.toFixed(1)}mmol/L`, false)
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius($r('sys.float.corner_radius_level7'))
          .clip(true)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({
          left: 16,
          right: 16,
          top: 8,
          bottom: 16
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.comp_background_gray'))
    }
    .hideTitleBar(true)
  }

  @Builder
  private renderDataRow(label: string, value: string, showDivider: boolean) {
    Column() {
      Row() {
        Text(label)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.black'))
          .fontFamily('HarmonyOS Sans SC')
          .layoutWeight(1)

        Text(value)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.black'))
          .fontFamily('HarmonyOS Sans SC')
      }
      .width('100%')
      .padding({
        left: 24,
        right: 24,
        top: 20,
        bottom: 20
      })

      if (showDivider) {
        Divider()
          .color($r('sys.color.comp_divider'))
          .strokeWidth('1px')
      }
    }
  }
}

