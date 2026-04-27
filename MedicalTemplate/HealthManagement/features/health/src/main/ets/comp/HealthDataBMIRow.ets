import { PersistenceV2 } from '@kit.ArkUI';
import { HealthDataInputModel } from '../viewmodel/HealthDataInputModel';

/**
 * @usage: 健康数据BMI展示组件，用于显示用户的BMI指数和健康状态。主要数据结构包括HealthDataInputModel（健康数据输入模型），
 * 包含bmiValue（BMI数值）等关键数据。使用PersistenceV2进行数据持久化连接。包含BMI类型判断逻辑和进度条显示。
 * @layout: 垂直布局（Column），顶部为BMI标题Text，中间为RelativeContainer相对布局容器，
 * 包含底部灰色进度条Row、橙色高亮进度条Row和BMI数值Text，底部为BMI状态描述Text。
 * @constraints: 数据模型HealthDataInputModel必须提供，BMI数值类型为number，进度条宽度和颜色固定，BMI类型判断逻辑不可修改。
 * @isGen: true
 * @fileType: component
 * @zhName: 健康数据BMI行组件
 */
@ComponentV2
export struct HealthDataBMIRow {
  @Local dataInputModelVM: HealthDataInputModel =
    PersistenceV2.connect(HealthDataInputModel, () => new HealthDataInputModel())!;

  build() {
    Column() {
      Blank().height($r('app.float.vp_4'))
      Text($r('app.string.health_bmi_title'))
        .fontColor(Color.Black)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Medium)
        .lineHeight($r('app.float.vp_20'))
      Blank().height($r('app.float.vp_2'))

      RelativeContainer() {
        Row()
          .width('100%')
          .height($r('app.float.vp_12'))
          .borderRadius($r('sys.float.corner_radius_level3'))
          .backgroundColor($r('app.color.color_E5E5E5'))
          .id('bmiBottomId')
          .alignRules({
            left: { anchor: '__container__', align: HorizontalAlign.Start },
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
          })

        Row()
          .width('25%')
          .height($r('app.float.vp_12'))
          .borderRadius($r('sys.float.corner_radius_level3'))
          .backgroundColor($r('app.color.color_ED6F21'))
          .margin({ left: this.getBMITypeMargin() })
          .id('bmiLightId')
          .alignRules({
            left: { anchor: '__container__', align: HorizontalAlign.Start },
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
          })

        Text(this.dataInputModelVM.bmiValue.toString())
          .fontColor(Color.Black)
          .fontSize($r('app.float.vp_18'))
          .fontWeight(FontWeight.Medium)
          .lineHeight($r('app.float.vp_20'))
          .id('bmiValueId')
          .alignRules({
            middle: { anchor: 'bmiLightId', align: HorizontalAlign.Center },
            top: { anchor: '__container__', align: VerticalAlign.Top }
          })

        Image($r('app.media.health_bmi_triangle'))
          .width($r('app.float.vp_12'))
          .height($r('app.float.vp_8'))
          .id('bmiIconId')
          .alignRules({
            middle: { anchor: 'bmiValueId', align: HorizontalAlign.Center },
            top: { anchor: 'bmiValueId', align: VerticalAlign.Bottom }
          })
      }
      .width('100%')
      .height($r('app.float.vp_36'))

      Row() {
        Text($r('app.string.health_bmi_type_underweight'))
          .fontColor($r('sys.color.mask_secondary'))
          .fontSize($r('sys.float.Body_S'))
          .lineHeight($r('app.float.vp_18'))
          .width('25%')
          .textAlign(TextAlign.Center)
        Text($r('app.string.health_bmi_type_normal'))
          .fontColor($r('sys.color.mask_secondary'))
          .fontSize($r('sys.float.Body_S'))
          .lineHeight($r('app.float.vp_18'))
          .width('25%')
          .textAlign(TextAlign.Center)
        Text($r('app.string.health_bmi_type_overweight'))
          .fontColor($r('sys.color.mask_secondary'))
          .fontSize($r('sys.float.Body_S'))
          .lineHeight($r('app.float.vp_18'))
          .width('25%')
          .textAlign(TextAlign.Center)
        Text($r('app.string.health_bmi_type_obesity'))
          .fontColor($r('sys.color.mask_secondary'))
          .fontSize($r('sys.float.Body_S'))
          .lineHeight($r('app.float.vp_18'))
          .width('25%')
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height($r('app.float.vp_42'))

      Row() {
        Column() {
          Image($r('app.media.health_bmi_fatPercentage'))
            .width($r('app.float.vp_24'))
            .height($r('app.float.vp_24'))
          Blank().height($r('app.float.vp_8'))
          Text($r('app.string.health_bmi_type_bodyFatPercentage'))
            .fontColor(Color.Black)
            .fontSize($r('sys.float.Body_M'))
            .lineHeight($r('app.float.vp_20'))
          Blank().height($r('app.float.vp_4'))
          Text() {
            Span(this.dataInputModelVM.bodyFatPercentage.toString())
              .fontColor(Color.Black)
              .fontSize($r('sys.float.Title_S'))
              .fontWeight(FontWeight.Medium)
            Span($r('app.string.health_bmi_current_fat_per'))
              .fontColor(Color.Black)
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
          }
        }
        .backgroundColor('#FFF9F9F9')
        .alignItems(HorizontalAlign.Start)
        .height($r('app.float.vp_100'))
        .layoutWeight(1)
        .padding($r('app.float.vp_12'))
        .borderRadius($r('sys.float.corner_radius_level4'))
        .clip(true)

        Blank().width($r('app.float.vp_8'))
        Column() {
          Image($r('app.media.health_bmi_fatWeight'))
            .width($r('app.float.vp_24'))
            .height($r('app.float.vp_24'))
          Blank().height($r('app.float.vp_8'))
          Text($r('app.string.health_bmi_type_fatWeight'))
            .fontColor(Color.Black)
            .fontSize($r('sys.float.Body_M'))
            .lineHeight($r('app.float.vp_20'))
          Blank().height($r('app.float.vp_4'))
          Text() {
            Span(this.dataInputModelVM.fatWeight.toString())
              .fontColor(Color.Black)
              .fontSize($r('sys.float.Title_S'))
              .fontWeight(FontWeight.Medium)
            Span($r('app.string.health_bmi_kilogram'))
              .fontColor(Color.Black)
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
          }
        }
        .backgroundColor('#FFF9F9F9')
        .alignItems(HorizontalAlign.Start)
        .height($r('app.float.vp_100'))
        .layoutWeight(1)
        .padding($r('app.float.vp_12'))
        .borderRadius($r('sys.float.corner_radius_level4'))
        .clip(true)
      }
      .width('100%')
      .height($r('app.float.vp_100'))
    }
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Start)
    .height($r('app.float.vp_230'))
    .width('100%')
    .padding($r('app.float.vp_12'))
    .borderRadius($r('sys.float.corner_radius_level7'))
    .clip(true)
  }

  getBMITypeMargin() {
    if (this.dataInputModelVM.bmiType <= 1) {
      return '0%';
    } else if (this.dataInputModelVM.bmiType === 2) {
      return '25%';
    } else if (this.dataInputModelVM.bmiType === 3) {
      return '50%';
    } else {
      return '75%';
    }
  }
}