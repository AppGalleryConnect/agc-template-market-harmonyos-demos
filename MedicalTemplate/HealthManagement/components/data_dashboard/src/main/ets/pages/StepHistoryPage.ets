//步数历史页
import { StepHistoryItem } from '../types/StepTypes';
import { StepHistoryVM } from '../viewmodel/StepHistoryVM';
import { CommonHeader } from '../components/CommonHeader';


/**
 * @usage: 用于展示步数历史记录的页面。包含自定义导航栏（返回按钮、标题）、统计概览卡片（总时长、总次数、总消耗）、月份选择器、
 * 步数历史记录列表。主要数据结构包括StepHistoryVM（步数历史视图模型）、StepHistoryItem（步数历史记录项）。
 * 包含ForEach逻辑用于渲染历史记录列表和分割线。
 * @layout: 页面采用垂直布局（Column），顶部为自定义导航栏（Stack布局），下方为主要内容区域（Column布局），
 * 包含统计概览卡片（水平三等分显示时长、次数、消耗）、月份选择区域（水平布局，左对齐月份标题，右对齐下拉箭头）、
 * 历史记录列表（垂直布局，每项包含步数、时长距离、日期时间）。
 * @constraints: 导航栏高度和样式不允许修改，统计卡片布局结构不允许修改，历史记录项布局结构不允许修改，月份选择器样式不允许修改。
 * @isGen: true
 * @fileType: page
 * @zhName: 步数历史记录页面
 * @subPage:
 * @component: StatisticsCard,StepHistoryItemView
 */
@ComponentV2
export struct StepHistoryPage {
  private vm: StepHistoryVM = StepHistoryVM.instance;
  @Local routerModule: NavPathStack = new NavPathStack();
  handleBack = (): void => {
    this.routerModule.pop();
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Scroll() {
          Column({ space: 12 }) {
            StatisticsCard({
              totalDuration: this.vm.totalDuration,
              totalCount: this.vm.totalCount,
              totalCalories: this.vm.totalCalories
            })
            this.renderMonthSection()
          }
          .width('100%')
          .padding({
            left: 16,
            right: 16,
            top: 24,
            bottom: 24
          })
        }
        .align(Alignment.Top)
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)
        .margin({ top: 60 })

        this.renderCustomHeader()
      }
      .width('100%')
      .height('100%')
      .padding({ top: 24 })
    }
    .backgroundColor($r('sys.color.comp_background_gray'))
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

  @Builder
  private renderCustomHeader() {
    CommonHeader({
      title: '历史记录',
      onBack: this.handleBack
    })
  }

  @Builder
  private renderMonthSection() {
    Column({ space: 12 }) {
      Row() {
        Text(this.vm.months[this.vm.selectedMonthIndex].monthTitle)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))

        Blank().layoutWeight(1)

        Image($r('app.media.iconRight'))
          .width(16)
          .height(16)
          .rotate({ angle: 90 })
      }
      .width('100%')
      .padding({
        top: 16,
        bottom: 8,
        left: 16,
        right: 16
      })
      .onClick(this.vm.toggleMonthMenu)
      .bindMenu(this.vm.showMonthMenu, this.vm.monthMenuItems, {
        placement: Placement.BottomRight,
        onDisappear: this.vm.closeMenu,
        offset: { x: -16, y: 0 }
      })

      Column({ space: 0 }) {
        ForEach(this.vm.months[this.vm.selectedMonthIndex].records, (record: StepHistoryItem, index: number) => {
          StepHistoryItemView({ item: record })

          if (index < this.vm.months[this.vm.selectedMonthIndex].records.length - 1) {
            Divider()
              .color($r('sys.color.comp_divider'))
              .strokeWidth('1px')
              .margin({ left: 16, right: 16 })
          }
        })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius($r('sys.float.corner_radius_level8'))
      .clip(true)
    }
  }
}


@ComponentV2
struct StatisticsCard {
  @Param totalDuration: number = 0;
  @Param totalCount: number = 0;
  @Param totalCalories: number = 0;

  build() {
    Row() {
      Column({ space: 8 }) {
        Text(this.totalDuration.toFixed(1))
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
        Text('时长(小时)')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.mask_secondary'))
      }
      .layoutWeight(1)


      Divider()
        .vertical(true)
        .height(60)
        .color($r('sys.color.comp_divider'))
        .strokeWidth('1px')


      Column({ space: 8 }) {
        Text(this.totalCount.toString())
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
        Text('次数')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.mask_secondary'))
      }
      .layoutWeight(1)


      Divider()
        .vertical(true)
        .height(60)
        .color($r('sys.color.comp_divider'))
        .strokeWidth('1px')


      Column({ space: 8 }) {
        Text(this.totalCalories.toLocaleString())
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
        Text('总消耗(千卡)')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.mask_secondary'))
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding({
      top: 24,
      bottom: 24,
      left: 16,
      right: 16
    })
    .backgroundColor(Color.White)
    .borderRadius($r('sys.float.corner_radius_level8'))
  }
}


@ComponentV2
struct StepHistoryItemView {
  @Param item: StepHistoryItem = {
    steps: 0,
    duration: '00:00:00',
    distance: 0,
    dateTime: ''
  };

  build() {
    Row() {
      Column({ space: 6 }) {
        Row({ space: 4 }) {
          Text(this.item.steps.toString())
            .fontSize($r('sys.float.Subtitle_L'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
          Text('步')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.mask_secondary'))
        }

        Row({ space: 8 }) {
          Text(this.item.duration)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.mask_secondary'))
          Text(`${this.item.distance.toFixed(2)}公里`)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.mask_secondary'))
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(this.item.dateTime)
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.mask_secondary'))
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 16,
      bottom: 16
    })
  }
}


@Builder
export function StepHistoryPageBuilder() {
  StepHistoryPage()
}
