import { PersistenceV2 } from '@kit.ArkUI';
import { RouterMap } from 'common';
import { StepCountPageBuilder } from 'data_dashboard';
import { PairedDeviceMacList } from 'device';
import { phoneRouterControl } from 'oh_router';
import { HealthModel } from '../viewmodel/HealthModel';
import { RemindPairDialog, RemindPairModel } from './RemindPairDialog';

/**
 * @usage: 用于显示运动相关的健康数据(折叠屏展开状态)。主要是活动热量、锻炼时长、运动距离、今日步数。
 * 包含runningSingleView自定义Builder方法用于构建单个运动数据项。
 * @layout: 页面采用行布局（Row），包含左，右侧空白区域和主要内容。主要内容整体采用垂直布局（Column），分为上下两部分：
 * 上部分为三个运动数据项的水平排列，下部分为步数显示区域,各数据项采用水平分布。
 * @constraints:
 * @domain: 健康医疗
 * @zhName: 健康运动行组件（折叠屏展开状态）
 * @fileType: component
 * @isGen: true
 * @subPage：StepCountPage
 * @image: screenshot/health/HealthRunningFold.jpg
 */
@ComponentV2
export struct HealthRunningFoldRow {
  @Param @Require healthModelVM: HealthModel;
  @Local macList: PairedDeviceMacList = PersistenceV2.connect(PairedDeviceMacList, () => new PairedDeviceMacList())!;
  // 跳转到步数详情页
  navigateToStepCount = (): void => {
    if (this.macList.pairedList.length === 0) {
      RemindPairDialog.ShowPopup(new RemindPairModel());
      return;
    }

    phoneRouterControl.jumpPage({
      pageName: RouterMap.STEP_COUNT_PAGE,
      builder: wrapBuilder(StepCountPageBuilder),
      onPop: (_popInfo: PopInfo) => {
        // 删除栈，但无需pop页面
        phoneRouterControl.deletePage()
      }
    })
  }

  build() {
    Row() {
      Blank().width($r('app.float.vp_16'))
      Column() {
        Row() {
          this.runningSingleView($r('app.string.health_Activity_heat'),
            0,
            $r('app.string.health_Activity_heat_unit'),
            $r('app.color.color_ED6F21'));

          Blank().layoutWeight(1)
          this.runningSingleView($r('app.string.health_exercise_duration'),
            1,
            $r('app.string.health_exercise_duration_unit'),
            $r('app.color.color_F9A01E'));

          Blank().layoutWeight(1)
          this.runningSingleView($r('app.string.health_travel_distance'),
            2,
            $r('app.string.health_travel_distance_unit'),
            $r('app.color.color_46B1E3'));
        }
        .width('100%')
        .height($r('app.float.vp_52'))

        Blank()
          .width('100%')
          .height('1px')
          .color($r('sys.color.comp_divider'))

        Row() {
          Row() {
            Image($r('app.media.health_running_step'))
              .width($r('app.float.vp_24'))
              .height($r('app.float.vp_24'))
            Blank().width($r('app.float.vp_6'))
            Text($r('app.string.health_step_count'))
              .fontColor($r('sys.color.mask_secondary'))
              .fontSize($r('sys.float.Body_S'))
          }

          Text() {
            Span(this.healthModelVM.stepCount > 0 ? this.healthModelVM.stepCount.toString() : '--')
              .fontColor(Color.Black)
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Bold)
            Span($r('app.string.health_step_count_unit'))
              .fontColor($r('sys.color.mask_secondary'))
              .fontSize($r('sys.float.Caption_M'))
          }
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .height($r('app.float.vp_44'))
        .onClick(this.navigateToStepCount)
      }
      .layoutWeight(1)
      .height('100%')

      Blank().width($r('app.float.vp_16'))
    }
    .backgroundColor(Color.White)
    .height($r('app.float.vp_96'))
    .width('100%')
    .borderRadius($r('sys.float.corner_radius_level6'))
    .clip(true)
  }

  @Builder
  runningSingleView(title: ResourceStr, valueType: number, unit: ResourceStr, color: ResourceColor) {
    Row() {
      Row()
        .size({ width: $r('app.float.vp_6'), height: $r('app.float.vp_6') })
        .borderRadius($r('sys.float.corner_radius_level2'))
        .backgroundColor(color)
      Blank().width($r('app.float.vp_6'))
      Text(title)
        .fontColor($r('sys.color.mask_secondary'))
        .fontSize($r('sys.float.Body_S'))
        .lineHeight($r('app.float.vp_20'))

      Blank().width($r('app.float.vp_8'))

      Text() {
        if (valueType === 0) {
          Span(this.healthModelVM.activityHeat > 0 ? this.healthModelVM.activityHeat.toString() : '--')
            .fontColor(Color.Black)
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(FontWeight.Bold)
            .lineHeight($r('app.float.vp_20'))
        } else if (valueType === 1) {
          Span(this.healthModelVM.exerciseDuration > 0 ? this.healthModelVM.exerciseDuration.toString() : '--')
            .fontColor(Color.Black)
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(FontWeight.Bold)
            .lineHeight($r('app.float.vp_20'))
        } else {
          Span(this.healthModelVM.travelDistance > 0 ? this.healthModelVM.travelDistance.toString() : '--')
            .fontColor(Color.Black)
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(FontWeight.Bold)
            .lineHeight($r('app.float.vp_20'))
        }
        Span(unit)
          .fontColor($r('sys.color.mask_secondary'))
          .fontSize($r('sys.float.Caption_M'))
      }
    }
    .justifyContent(FlexAlign.Start)
  }
}