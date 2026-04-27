//睡眠历史详情页
import { SleepRecord } from '../types/SleepTypes';
import { SleepDetailVM } from '../viewmodel/SleepDetailVM';
import { CommonHeader } from '../components/CommonHeader';

@Builder
export function SleepDetailPageBuilder() {
  SleepDetailPage()
}

/**
 * @usage: 用于展示特定日期睡眠详细记录的页面。包含自定义导航栏（返回按钮、日期标题）、睡眠记录列表。
 * 主要数据结构包括SleepDetailVM（睡眠详情视图模型）、SleepRecord（睡眠记录项）。包含ForEach逻辑用于渲染睡眠记录列表和分割线。
 * @layout: 页面采用垂直布局（Column），顶部为自定义导航栏（Stack布局），下方为主要内容区域（Column布局），
 * 包含睡眠记录列表（垂直布局，每项水平排列显示睡眠标签和对应数值）。
 * @constraints: 导航栏高度和样式不允许修改，睡眠记录项布局结构不允许修改，分割线样式不允许修改。
 * @isGen: true
 * @fileType: page
 * @zhName: 睡眠详情页面
 * @subPage:
 * @component: SleepRecordItemView
 */
@ComponentV2
export struct SleepDetailPage {
  private vm: SleepDetailVM = SleepDetailVM.instance;
  handleBack = (): void => {
    this.routerModule.pop();
  }
  @Local routerModule: NavPathStack = new NavPathStack();

  @Builder
  private renderRecordList() {
    Column({ space: 0 }) {
      ForEach(this.vm.records, (record: SleepRecord, index: number) => {
        SleepRecordItemView({ record: record })
        if (index < this.vm.records.length - 1) {
          Divider()
            .margin({
              top: 4,
              bottom: 4,
              left: 16,
              right: 16
            })
            .color($r('sys.color.comp_divider'))
        }
      })
    }
    .width('100%')
    .borderRadius($r('sys.float.corner_radius_level8'))
    .backgroundColor($r('sys.color.background_primary'))
  }

  @Builder
  private renderCustomHeader() {
    CommonHeader({
      title: this.vm.dateTitle,
      onBack: this.handleBack
    })
  }

  build() {
    NavDestination() {
      Column() {
        this.renderCustomHeader()
        Column({ space: 12 }) {
          this.renderRecordList()
        }
        .padding({
          left: 12,
          right: 12,
          top: 24,
          bottom: 12
        })
      }
      .backgroundColor($r('sys.color.comp_background_gray'))
      .padding({ top: 24 })
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .onReady((context) => {
      // 获取参数
      this.routerModule = context.pathStack;
    })
    .onBackPressed(() => {
      this.routerModule.pop()
      return true
    })
  }
}

@ComponentV2
struct SleepRecordItemView {
  @Param record: SleepRecord = {
    label: '',
    value: ''
  };

  build() {
    Row() {
      Text(this.record.label)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .fontSize($r('sys.float.Subtitle_S'))
        .fontColor($r('sys.color.font_primary'))

      Text(this.record.value)
        .fontColor($r('sys.color.mask_secondary'))
        .fontSize($r('sys.float.Body_L'))
    }
    .padding({
      left: 16,
      right: 16,
      top: 20,
      bottom: 20
    })
    .width('100%')
  }
}

