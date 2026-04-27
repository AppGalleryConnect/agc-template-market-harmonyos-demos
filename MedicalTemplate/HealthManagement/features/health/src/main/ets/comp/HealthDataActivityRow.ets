import { PersistenceV2 } from '@kit.ArkUI';
import { HealthDataInputModel } from '../viewmodel/HealthDataInputModel';

/**
 * @usage: 健康数据今日运动活动组件，用于展示今日运动时间和消耗卡路里数据。主要数据结构包括HealthDataInputModel（健康数据输入模型），
 * 包含todayExerciseTime（今日运动时间）和todayExerciseConsumption（今日运动消耗）等关键数据。使用PersistenceV2进行数据持久化连接。
 * @layout: 横向排列布局（Row），包含三个区域：左侧运动时间Column、中间分隔线Blank、右侧运动消耗Column、
 * 右侧分隔线Blank。每个数据区域采用垂直居中对齐，包含数值Text和描述Text。
 * @constraints: 数据模型HealthDataInputModel必须提供，运动时间和消耗数据类型为number，分隔线样式固定。
 * @isGen: true
 * @fileType: component
 * @zhName: 健康数据活动行组件
 */
@ComponentV2
export struct HealthDataActivityRow {
  @Local dataInputModelVM: HealthDataInputModel =
    PersistenceV2.connect(HealthDataInputModel, () => new HealthDataInputModel())!;

  build() {
    Row() {
      Column() {
        Text(this.dataInputModelVM.todayExerciseTime.toString())
          .fontColor(Color.Black)
          .fontSize($r('sys.float.Title_M'))
          .fontWeight(FontWeight.Medium)
          .lineHeight($r('app.float.vp_30'))
        Blank().height($r('app.float.vp_6'))
        Text($r('app.string.health_today_exercise_time'))
          .fontColor($r('app.color.color_99000000'))
          .fontSize($r('sys.float.Body_S'))
          .lineHeight($r('app.float.vp_18'))
      }
      .height('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)

      Blank()
        .height($r('app.float.vp_34'))
        .width('1px')
        .backgroundColor($r('sys.color.mask_fourth'))

      Column() {
        Text(this.dataInputModelVM.todayExerciseConsumption.toString())
          .fontColor(Color.Black)
          .fontSize($r('sys.float.Title_M'))
          .fontWeight(FontWeight.Medium)
          .lineHeight($r('app.float.vp_30'))
        Blank().height($r('app.float.vp_6'))

        Text($r('app.string.health_today_exercise_consumption'))
          .fontColor($r('app.color.color_99000000'))
          .fontSize($r('sys.float.Body_S'))
          .lineHeight($r('app.float.vp_18'))
      }
      .height('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)

      Blank()
        .height($r('app.float.vp_34'))
        .width('1px')
        .backgroundColor($r('sys.color.mask_fourth'))
      Column() {
        Text(this.dataInputModelVM.todayStatus)
          .fontColor($r('app.color.color_6ACE7A'))
          .fontSize($r('sys.float.Title_M'))
          .fontWeight(FontWeight.Medium)
          .lineHeight($r('app.float.vp_30'))
        Blank().height($r('app.float.vp_6'))

        Text($r('app.string.health_today_status'))
          .fontColor($r('app.color.color_99000000'))
          .fontSize($r('sys.float.Body_S'))
          .lineHeight($r('app.float.vp_18'))
      }
      .height('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)

    }
    .backgroundColor(Color.White)
    .height($r('app.float.vp_84'))
    .width('100%')
    .borderRadius($r('sys.float.corner_radius_level7'))
    .clip(true)
  }
}