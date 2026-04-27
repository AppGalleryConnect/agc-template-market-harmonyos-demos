//心率历史详情页
import { HeartRateRecord } from '../types/HeartRateTypes';
import { HeartRateDetailVM } from '../viewmodel/HeartRateDetailVM';
import { CommonHeader } from '../components/CommonHeader';

@Builder
export function HeartRateDetailPageBuilder() {
  HeartRateDetailPage()
}

/**
 * @usage: 用于展示特定日期心率详细记录的页面。包含自定义导航栏（返回按钮、日期标题）、心率记录列表。
 * 主要数据结构包括HeartRateDetailVM（心率详情视图模型）、HeartRateRecord（心率记录项）。包含ForEach逻辑用于渲染心率记录列表和分割线
 * @layout: 页面采用垂直布局（Column），顶部为自定义导航栏（Stack布局），下方为主要内容区域（Column布局），
 * 包含心率记录列表（垂直布局，每项水平排列显示心率值和记录时间）。
 * @constraints: 导航栏高度和样式不允许修改，心率记录项布局结构不允许修改，分割线样式不允许修改。
 * @isGen: true
 * @fileType: page
 * @zhName: 心率详情页面
 * @subPage:
 * @component: HeartRateRecordItemView
 */
@ComponentV2
export struct HeartRateDetailPage {
  @Local routerModule: NavPathStack = new NavPathStack();
  private vm: HeartRateDetailVM = HeartRateDetailVM.instance;
  handleBack = (): void => {
    this.routerModule.pop();
  }

  @Builder
  private renderCustomHeader() {
    CommonHeader({
      onBack: this.handleBack,
      title: this.vm.dateTitle
    })
  }

  @Builder
  private renderRecordList() {
    Column({ space: 0 }) {
      ForEach(this.vm.records, (record: HeartRateRecord, index: number) => {
        HeartRateRecordItemView({ record: record })
        if (index < this.vm.records.length - 1) {
          Divider()
            .margin({
              top: 4,
              left: 16,
              right: 16,
              bottom: 4
            })
            .color($r('sys.color.comp_divider'))
        }
      })
    }
    .backgroundColor($r('sys.color.background_primary'))
    .width('100%')
    .borderRadius($r('sys.float.corner_radius_level8'))
  }

  build() {
    NavDestination() {
      Column() {
        this.renderCustomHeader()
        Column({ space: 12 }) {
          this.renderRecordList()
        }
        .padding({ left: $r('app.float.vp_12'), right: $r('app.float.vp_12'), top: $r('app.float.vp_24'), bottom: $r('app.float.vp_12') })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.comp_background_gray'))
      .padding({ top: 24 })
    }
    .hideTitleBar(true)
    .onReady((ctx) => {
      // 获取参数
      this.routerModule = ctx.pathStack;
    })
    .onBackPressed(() => {
      this.routerModule.pop()
      return true
    })
  }
}

@ComponentV2
struct HeartRateRecordItemView {
  @Param record: HeartRateRecord = {
    value: '',
    time: ''
  };

  build() {
    Row() {
      Text(this.record.value)
        .fontSize($r('sys.float.Subtitle_S'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)

      Text(this.record.time)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.mask_secondary'))
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 20,
      bottom: 20
    })
  }
}

