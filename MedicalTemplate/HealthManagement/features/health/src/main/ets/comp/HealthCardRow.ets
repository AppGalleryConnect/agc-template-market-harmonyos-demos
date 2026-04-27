import { PersistenceV2 } from '@kit.ArkUI';
import {
  BloodGlucosePageBuilder,
  BloodPressurePageBuilder,
  HeartRatePageBuilder,
  SleepPageBuilder
} from 'data_dashboard';
import { RouterMap, UserInfo } from 'common';
import { phoneRouterControl } from 'oh_router';
import { HealthCardModel } from '../viewmodel/HealthCardModel';
import { HealthDataInputPageBuilder } from '../views/HealthDataInputPage';
import { HealthReportPageBuilder } from '../views/HealthReportPage';
import { HealthReportEmptyPageBuilder } from '../views/HealthReportEmptyPage';
import { HealthReportModel } from '../viewmodel/HealthReportModel';
import { PairedDeviceMacList } from 'device';
import { RemindPairDialog, RemindPairModel } from './RemindPairDialog';

/**
 * @usage: 健康卡片行组件，用于展示不同类型的健康数据卡片。支持四种卡片类型：有数据卡片(type=1)、无数据卡片(type=2)、
 * 图像文本日期卡片(type=3)、图像文本数据卡片(type=4)。主要数据结构包括HealthCardModel（健康卡片数据模型）。
 * 包含if-else逻辑根据卡片类型渲染不同内容和处理点击事件。
 * @layout: 组件采用垂直布局（Column），顶部为图标和标题，中间根据卡片类型显示不同内容区域，底部为时间状态文本。所有元素左对齐排列。
 * @constraints:
 * @domain: 健康医疗
 * @zhName: 健康卡片组件
 * @isGen: true
 * @fileType: component
 * @subPage: HealthReportPage,HealthReportEmptyPage,BloodGlucosePage,BloodPressurePage,HeartRatePage,SleepPage,
 * HealthDataInputPage
 * @image: screenshot/health/HealthCard.jpg
 */
@ComponentV2
export struct HealthCardRow {
  @Param @Require healthCardModelVM: HealthCardModel;
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local macList: PairedDeviceMacList = PersistenceV2.connect(PairedDeviceMacList, () => new PairedDeviceMacList())!;

  build() {
    Column() {
      Column() {
        Image(this.healthCardModelVM.img)
          .width($r('app.float.vp_26'))
          .height($r('app.float.vp_26'))
        Blank().height($r('app.float.vp_8'))
        Text(this.healthCardModelVM.title)
          .fontColor(Color.Black)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .lineHeight($r('app.float.vp_24'))

        if (this.healthCardModelVM.type === 1 ||
          this.healthCardModelVM.type === 2) {
          this.hasDataCard();
        } else if (this.healthCardModelVM.type === 3) {
          this.ImageTextDateCard()
        } else {
          this.ImageTextDataCard()
        }

        Text(this.healthCardModelVM.timeStatus)
          .fontColor($r('app.color.color_66000000'))
          .fontSize($r('sys.float.Caption_M'))
          .lineHeight($r('app.float.vp_14'))
      }
      .size({ width: '100%', height: '100%' })
      .backgroundColor(Color.White)
      .padding($r('app.float.vp_16'))
      .alignItems(HorizontalAlign.Start)
      .borderRadius($r('sys.float.corner_radius_level7'))
      .clip(true)
      .onClick(() => {
        if (this.macList.pairedList.length === 0) {
          RemindPairDialog.ShowPopup(new RemindPairModel());
          return;
        }
        if (this.healthCardModelVM.type === 1) {
          this.gotoHealthData();
        } else if (this.healthCardModelVM.type === 2) {
          this.gotoHealthReport();
        } else if (this.healthCardModelVM.type === 3) {
          this.gotoSleep();
        } else if (this.healthCardModelVM.type === 4) {
          this.gotoBloodPressure();
        } else if (this.healthCardModelVM.type === 5) {
          this.gotoHeartRate();
        } else if (this.healthCardModelVM.type === 6) {
          this.gotoBloodGlucose();
        }
      })
    }
    .padding({
      left: $r('app.float.vp_12'),
    })
    .size({ width: '100%', height: $r('app.float.vp_180') })

  }

  @Builder
  hasDataCard() {
    Column() {
      Text(this.healthCardModelVM.value)
        .fontColor(Color.Black)
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Medium)
        .lineHeight($r('app.float.vp_24'))

      Blank().height($r('app.float.vp_4'))

      Text(this.healthCardModelVM.desc)
        .fontColor($r('app.color.color_999'))
        .fontSize($r('sys.float.Body_S'))
        .lineHeight($r('app.float.vp_18'))
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .height($r('app.float.vp_76'))
    .width('100%')
  }

  @Builder
  ImageTextDataCard() {
    Column() {
      if (this.healthCardModelVM.desc === '暂无数据') {
        Text(this.healthCardModelVM.desc)
          .fontColor($r('app.color.color_999'))
          .fontSize($r('sys.float.Body_S'))
          .lineHeight($r('app.float.vp_18'))
      } else {
        Blank().height($r('app.float.vp_8'))
        Image(this.healthCardModelVM.icon)
          .width('100%')
          .height($r('app.float.vp_34'))
        Blank().height($r('app.float.vp_8'))

        Text() {
          Span(this.healthCardModelVM.value)
            .fontColor(Color.Black)
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(FontWeight.Medium)
          if (this.healthCardModelVM.diastolicValue) {
            Span('/' + this.healthCardModelVM.diastolicValue)
              .fontColor(Color.Black)
              .fontSize($r('sys.float.Title_S'))
              .fontWeight(FontWeight.Medium)
          }
          Span(this.healthCardModelVM.desc)
            .fontColor($r('app.color.color_80000000'))
            .fontSize($r('sys.float.Body_S'))
            .fontWeight(FontWeight.Medium)
        }

        Blank().height($r('app.float.vp_4'))
      }
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .height($r('app.float.vp_76'))
    .width('100%')
  }

  @Builder
  ImageTextDateCard() {
    Column() {
      if (this.healthCardModelVM.desc === '暂无数据') {
        Text(this.healthCardModelVM.desc)
          .fontColor($r('app.color.color_999'))
          .fontSize($r('sys.float.Body_S'))
          .lineHeight($r('app.float.vp_18'))
      } else {
        Blank().height($r('app.float.vp_8'))
        Image(this.healthCardModelVM.icon)
          .width('100%')
          .height($r('app.float.vp_34'))
        Blank().height($r('app.float.vp_8'))

        Text() {
          Span(this.parseTimeData()[0])
            .fontColor(Color.Black)
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(FontWeight.Medium)
          Span($r('app.string.health_info_hours'))
            .fontColor($r('app.color.color_80000000'))
            .fontSize($r('sys.float.Body_S'))
            .fontWeight(FontWeight.Medium)

          Span(this.parseTimeData()[1])
            .fontColor(Color.Black)
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(FontWeight.Medium)
          Span($r('app.string.health_info_minute'))
            .fontColor($r('app.color.color_80000000'))
            .fontSize($r('sys.float.Body_S'))
            .fontWeight(FontWeight.Medium)
        }

        Blank().height($r('app.float.vp_4'))
      }

    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .height($r('app.float.vp_76'))
    .width('100%')
  }

  parseTimeData() {
    let timeStr = this.healthCardModelVM.desc.replace('时', '|&&|');
    timeStr = timeStr.replace('分', '');
    return timeStr.split('|&&|');
  }

  // 跳转到健康数据
  gotoHealthData() {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.HEALTH_DATA_INPUT_PAGE,
      builder: wrapBuilder(HealthDataInputPageBuilder)
    })
  }

  // 跳转到健康报告页
  gotoHealthReport(): void {
    const healthReportModel: HealthReportModel = HealthReportModel.instance;

    // 在跳转前刷新数据，确保使用最新的用户录入数据
    healthReportModel.refreshHealthData();

    const hasData: boolean = healthReportModel.hasHealthData();

    if (hasData) {
      // 有数据，跳转到正常的健康报告页
      phoneRouterControl.jumpPage({
        pageName: RouterMap.HEALTH_REPORT_PAGE,
        builder: wrapBuilder(HealthReportPageBuilder)
      });
    } else {
      // 没有数据，跳转到空数据页
      phoneRouterControl.jumpPage({
        pageName: RouterMap.HEALTH_REPORT_EMPTY_PAGE,
        builder: wrapBuilder(HealthReportEmptyPageBuilder)
      });
    }
  }

  // 跳转到血压详情页
  gotoBloodPressure() {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.BLOOD_PRESSURE_PAGE,
      builder: wrapBuilder(BloodPressurePageBuilder),
      onPop: (_popInfo: PopInfo) => {
        // 删除栈，但无需pop页面
        phoneRouterControl.deletePage()
      }
    })
  }

  // 跳转到血糖详情页
  gotoBloodGlucose() {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.BLOOD_GLUCOSE_PAGE,
      builder: wrapBuilder(BloodGlucosePageBuilder),
      onPop: (_popInfo: PopInfo) => {
        // 删除栈，但无需pop页面
        phoneRouterControl.deletePage()
      }
    })
  }

  gotoHeartRate() {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.HEART_RATE_PAGE,
      builder: wrapBuilder(HeartRatePageBuilder),
      onPop: (_popInfo: PopInfo) => {
        // 删除栈，但无需pop页面
        phoneRouterControl.deletePage()
      }
    })
  }

  // 跳转到睡眠详情页
  gotoSleep() {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.SLEEP_PAGE,
      builder: wrapBuilder(SleepPageBuilder),
      onPop: (_popInfo: PopInfo) => {
        // 删除栈，但无需pop页面
        phoneRouterControl.deletePage()
      }
    })
  }

  /**
   * 检查是否有健康数据
   * 判断标准：体重和身高不为0（这两个是计算BMI的必要条件）
   */
  @Computed
  get getHealthReportStatus(): boolean {
    return this.userInfo.weight > 0 && this.userInfo.height > 0;
  }
}