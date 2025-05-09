import { CheckInTaskItem } from 'commonlib';
import { CommonButton, CommonHeader, CommonLoading, ContainerColumn } from 'componentlib';
import { TASK_INTRO_TAB_LIST } from '../constants/Constants';
import { TaskIntroTabMap } from '../constants/Enums';
import { TaskIntroTabItem } from '../types/Index';
import { TaskUtil } from '../utils/Index';
import { ActivityIntroductionVM } from '../viewmodels/ActivityIntroductionVM';

@Builder
export function activityIntroductionPageBuilder() {
  ActivityIntroductionPage();
}

@ComponentV2
export struct ActivityIntroductionPage {
  vm: ActivityIntroductionVM = ActivityIntroductionVM.instance;

  build() {
    NavDestination() {
      CommonHeader({ title: this.vm.activity?.name ?? '' });
      if (this.vm.isLoading) {
        CommonLoading();
      } else {
        Scroll() {
          Column() {
            // 封面图和标题栏
            this.taskTitleBuilder();
            // 介绍栏
            this.taskDetailBuilder();
            Blank().layoutWeight(1);
          };
        }
        .backgroundColor($r('app.color.system_color_background_auxiliary'))
        .layoutWeight(1)
        .width($r('app.string.width_percent_full'));

        if (this.vm.showBottomButton) {
          CommonButton({
            title: this.vm.bottomButtonLabel,
            handleClick: () => {
              this.vm.jumpToTaskPage();
            },
          })
            .padding({ top: $r('app.string.padding_l') });
        }
      }
    }
    .hideTitleBar(true)
    .onReady(() => {
      this.vm.getActivityIntro();
    })
    .onHidden(() => {
      this.vm.showBottomButton = true;
    })

  }

  @Builder
  taskTitleBuilder() {
    if (this.vm.activity) {
      Image(this.vm.activity.mainDiagram)
        .width($r('app.string.width_percent_full'));
      Column() {
        ContainerColumn() {
          Text(this.vm.activity.name)
            .fontSize($r('app.string.font_size_16'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.font_color_level1'))
            .margin({ bottom: $r('app.string.margin_xs') });
          Text(this.vm.activity.summary)
            .contentTextStyle()
            .margin({ bottom: $r('app.string.margin_l') });
          Row() {
            Text(this.vm.activity.price ? '¥' + this.vm.activity.price.toFixed(2) : '免费')
              .layoutWeight(1)
              .fontSize($r('app.string.font_size_12'))
              .fontColor($r('app.color.system_theme_color'));
            Text(this.vm.activity.historyCount + '次打卡').contentTextStyle();
          };
        };
      }
      .padding({
        top: $r('app.string.padding_l'),
        left: $r('app.string.padding_l'),
        right: $r('app.string.padding_l'),
      })
      .width($r('app.string.width_percent_full'));
    }
  }

  @Builder
  taskDetailBuilder() {
    if (this.vm.activity) {
      Row() {
        Column() {
          Tabs({ barPosition: BarPosition.Start, index: this.vm.currentIndex, controller: this.vm.tabController }) {
            ForEach(TASK_INTRO_TAB_LIST, (item: TaskIntroTabItem, index: number) => {
              TabContent()
                .tabBar(this.tabBarBuilder(item.label, index))
                .backgroundColor($r('app.color.system_color_background_auxiliary'));
            }, (item: TaskIntroTabItem, index: number) => index + JSON.stringify(item));
          }
          .margin({ top: $r('app.string.margin_m') })
          .width($r('app.string.width_percent_full'))
          .height('auto')
          .animationDuration(0)
          .vertical(false)
          .barHeight(32)
          .barMode(BarMode.Scrollable)
          .onChange((index: number) => {
            this.vm.currentIndex = index;
          });

          Divider().strokeWidth(1).color($r('app.color.system_color_divider'));

          if (this.vm.currentIndex === TaskIntroTabMap.INTRO) {
            this.taskIntroBuilder();
          } else if (this.vm.currentIndex === TaskIntroTabMap.TOC) {
            this.taskTocBuilder();
          }
        }
        .backgroundColor($r('app.color.system_color_background_white'))
        .borderRadius($r('app.string.border_radius_16'));
      }
      .width($r('app.string.width_percent_full'))
      .padding({
        left: $r('app.string.padding_l'),
        right: $r('app.string.padding_l'),
      });
    }
  }

  @Builder
  taskIntroBuilder() {
    if (this.vm.activity) {
      Column() {
        Text() {
          Span(this.vm.activity.participationCount + '人参与');
          Span(' | ');
          Span(this.vm.activity.historyCount + '次打卡');
        }
        .contentTextStyle()
        .fontColor($r('app.color.font_color_level1'))
        .margin({ bottom: $r('app.string.margin_l') });

        Text('课程介绍')
          .fontSize($r('app.string.font_size_14'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.font_color_level1'))
          .margin({ bottom: $r('app.string.margin_s') })
          .textAlign(TextAlign.Center)
          .width($r('app.string.width_percent_full'));

        Text(this.vm.activity.detail)
          .contentTextStyle()
          .fontWeight(FontWeight.Regular)
      }
      .padding($r('app.string.padding_l'))
      .width($r('app.string.width_percent_full'))
      .alignItems(HorizontalAlign.Start);
    }
  }

  @Builder
  taskTocBuilder() {
    Column() {
      if (this.vm.activity?.taskDirectory) {
        ForEach(this.vm.activity.taskDirectory, (item: CheckInTaskItem, index: number) => {
          Text(`${TaskUtil.getTaskIndex(index)}. ${item.taskName}`)
            .fontSize($r('app.string.font_size_14'))
            .fontColor($r('app.color.font_color_level1'))
            .margin({ bottom: $r('app.string.margin_xs') });
          Text(item.taskDetail).contentTextStyle().margin({ bottom: $r('app.string.margin_l') });
        }, (item: CheckInTaskItem) => JSON.stringify(item));
      }
    }
    .width($r('app.string.width_percent_full'))
    .padding($r('app.string.padding_l'))
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  tabBarBuilder(name: string, index: number) {
    Column() {
      Text(name)
        .fontColor(this.vm.currentIndex === index ? $r('app.color.system_theme_color') :
        $r('app.color.font_color_level1'))
        .fontSize($r('app.string.font_size_16'))
        .fontWeight(FontWeight.Medium)
        .lineHeight(22)
        .margin({ bottom: $r('app.string.margin_s') });
      Divider()
        .strokeWidth(2)
        .width(20)
        .color($r('app.color.system_theme_color'))
        .opacity(this.vm.currentIndex === index ? 1 : 0);
    }
    .backgroundColor($r('app.color.system_color_background_white'))
    .padding({
      left: $r('app.string.padding_xs'),
      right: $r('app.string.padding_xs'),
    })
    .width('40%');
  }
}

@Extend(Text)
function contentTextStyle() {
  .fontSize($r('app.string.font_size_12'))
  .lineHeight(18)
  .fontColor($r('app.color.font_color_level2'));
}