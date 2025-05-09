import { CheckInRecord, CheckInTaskItem, FormatUtil, PickerResourceType } from 'commonlib';
import { CommonButton, CommonDivider, CommonHeader, CommonLoading, ContainerColumn } from 'componentlib';
import { TaskUtil } from '../utils/Index';
import { CheckInTaskVM } from '../viewmodels/TaskCheckInVM';

@Builder
export function checkInTaskPageBuilder() {
  CheckInTaskPage();
}

@ComponentV2
export struct CheckInTaskPage {
  vm: CheckInTaskVM = CheckInTaskVM.instance;

  build() {
    NavDestination() {
      CommonHeader({ title: '参与打卡' });
      if (this.vm.isLoading) {
        CommonLoading();
      } else {
        Scroll() {
          Column() {
            // 打卡任务标题栏
            this.taskTitleBuilder();
            Column() {
              // 当前任务
              this.currentTaskBuilder();
              // 任务列表
              this.taskDirectoryBuilder();
              // 历史打卡记录
              this.taskHistoryListBuilder();
            }
            .padding($r('app.string.padding_l'));

            Blank().layoutWeight(1);
          };
        }
        .backgroundColor($r('app.color.system_color_background_auxiliary'))
        .layoutWeight(1)
        .width($r('app.string.width_percent_full'));
      }
    }
    .hideTitleBar(true)
    .onReady(() => {
      this.vm.getTaskIntro();
    });
  }

  @Builder
  taskTitleBuilder() {
    if (this.vm.activity) {
      Stack({ alignContent: Alignment.TopStart }) {
        Image(this.vm.activity.mainDiagram)
          .width($r('app.string.width_percent_full'))
          .aspectRatio(2)
          .objectFit(ImageFit.Fill);
        Column() {
          Text(this.vm.activity.name)
            .fontSize($r('app.string.font_size_18'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.font_color_level1_invert'))
            .margin({ bottom: $r('app.string.margin_l') });
          Text() {
            Span(this.vm.activity.participationCount + '人参与');
            Span(' | ');
            Span(this.vm.activity.historyCount + '次打卡');
          }
          .fontColor($r('app.color.font_color_level2_invert'))
          .fontSize(12)
          .margin({ bottom: $r('app.string.margin_xxl') });

          Row() {
            Image($r('app.media.ic_activity_desc'))
              .width($r('app.integer.icon_size_16'))
              .margin({ right: $r('app.string.margin_xs') });
            Text('介绍')
              .fontColor($r('app.color.font_color_level1_invert'))
              .fontSize(12);
          }
          .onClick(() => {
            this.vm.jumpToActivityIntro();
          })
          .padding({
            left: $r('app.string.padding_l'),
            right: $r('app.string.padding_l'),
            top: $r('app.string.padding_xs'),
            bottom: $r('app.string.padding_xs'),
          })
          .borderRadius($r('app.string.border_radius_capsule'))
          .backgroundBlurStyle(BlurStyle.Regular,
            { colorMode: ThemeColorMode.LIGHT, adaptiveColor: AdaptiveColor.DEFAULT, scale: 0.2 });
        }
        .alignItems(HorizontalAlign.Start)
        .margin({
          top: $r('app.string.margin_xl'),
          left: $r('app.string.margin_xl'),
        });
      };
    }
  }

  @Builder
  currentTaskBuilder() {
    if (this.vm.currentTask) {
      Column() {
        ContainerColumn({ title: '当前任务' }) {
          if (this.vm.currentTask) {
            Text(this.vm.currentTask.taskName).cardSubTitleStyle();
            Text(this.vm.currentTask.taskDetail).cardContentStyle();

            CommonButton({
              title: '立即打卡',
              handleClick: () => {
                this.vm.jumpToSubmitCheckIn();
              },
            })
              .margin({ top: $r('app.string.margin_xl') });

          } else {
            Row() {
              Text('太棒了，打卡任务全部完成~').cardContentStyle();
            }
            .width($r('app.string.width_percent_full'));
          }
        };

        if (!this.vm.currentTask) {
          Image($r('app.media.ic_activity_completed'))
            .width(60)
            .height(60)
            .position({
              right: -12,
              top: -12,
            });
        }
      }
      .clip(true);
    }

  }

  @Builder
  taskDirectoryBuilder() {
    ContainerColumn({
      title: '打卡任务',
    }) {
      if (this.vm.displayTaskDirectory.length) {
        List() {
          ForEach(this.vm.displayTaskDirectory, (item: CheckInTaskItem, index: number) => {
            ListItem() {
              Row() {
                Text(`${TaskUtil.getTaskIndex(index)}. ${item.taskName}`)
                  .fontSize($r('app.string.font_size_14'))
                  .fontWeight(FontWeight.Medium)
                  .width($r('app.string.width_percent_75'))
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });
                Blank();
                Text(this.vm.isTaskChecked(item) ? '已打卡' : '未打卡')
                  .fontSize($r('app.string.font_size_10'))
                  .fontColor(this.vm.isTaskChecked(item) ? $r('app.color.font_color_level1_invert') :
                  $r('app.color.font_color_level2'))
                  .padding({
                    left: $r('app.string.padding_s'),
                    right: $r('app.string.padding_s'),
                    top: $r('app.string.padding_xs'),
                    bottom: $r('app.string.padding_xs'),
                  })
                  .borderRadius($r('app.string.border_radius_capsule'))
                  .backgroundColor(this.vm.isTaskChecked(item) ? $r('app.color.icon_color_success') :
                  $r('app.color.system_color_background_shadow'));
              }
              .width($r('app.string.width_percent_full'))
              .margin({
                top: $r('app.string.margin_xs'),
                bottom: $r('app.string.margin_xs'),
              });
            };
          }, (item: CheckInTaskItem, index: number) => '' + item.taskId + index);
        };

        if (this.vm.taskDirectory.length > this.vm.DEFAULT_DISPLAY_TASK_NUM) {
          Row() {
            Row() {
              Text(this.vm.showMoreTask ? '收起' : '展开')
                .fontSize($r('app.string.font_size_10'))
                .fontColor($r('app.color.font_color_level2'))
                .margin({ right: $r('app.string.margin_xs') });
              Image(this.vm.showMoreTask ? $r('app.media.ic_arrow_up') : $r('app.media.ic_arrow_down'))
                .width($r('app.integer.icon_size_12'))
                .fillColor($r('app.color.icon_color_level2'));
            }
            .backgroundColor($r('app.color.system_color_background_shadow'))
            .padding({
              left: $r('app.string.padding_s'),
              right: $r('app.string.padding_s'),
              top: $r('app.string.padding_xs'),
              bottom: $r('app.string.padding_xs'),
            })
            .borderRadius($r('app.string.border_radius_capsule'))
            .margin({ top: $r('app.string.margin_m') })
            .onClick(() => {
              this.vm.showMoreTask = !this.vm.showMoreTask;
            });
          }
          .width($r('app.string.width_percent_full'))
          .justifyContent(FlexAlign.Center);
        }
      }
    };
  }

  @Builder
  taskHistoryListBuilder() {
    ContainerColumn({
      title: '历史打卡',
      subTitle: this.vm.historyRecordList.length + '次打卡',
    }) {
      if (this.vm.historyRecordList.length) {
        List() {
          ForEach(this.vm.historyRecordList, (item: CheckInRecord, index: number) => {
            this.recordCardBuilder(item, index);
          }, (item: CheckInRecord, index: number) => item.taskId + '_' + index);
        };
      } else {
        Column() {
          Image($r('app.media.ic_record_empty'))
            .width(100)
            .height(100)
            .margin({ bottom: $r('app.string.margin_l') });
          Text('快留下你的第一个打卡吧~')
            .cardContentStyle()
            .margin({ bottom: $r('app.string.margin_l') });
        }
        .width($r('app.string.width_percent_full'))
        .alignItems(HorizontalAlign.Center);
      }
    };
  }

  @Builder
  recordCardBuilder(item: CheckInRecord, index: number) {
    Column() {
      Row() {
        Text() {
          Span(this.vm.historyRecordList.length - index + '. ');
          Span(this.vm.getTaskNameById(item.taskId));
        }
        .cardSubTitleStyle()
        .layoutWeight(1);

        Text(FormatUtil.formatFullTime(new Date(Number(item.createTime))))
          .cardContentStyle()
          .margin({ bottom: $r('app.string.margin_l') });
      }
      .width($r('app.string.width_percent_full'));

      if (item.textDetail) {
        Text(item.textDetail)
          .recordTextStyle()
          .margin({ bottom: $r('app.string.margin_s') });
      }

      Grid() {
        if (item.pictureDetail?.length) {
          ForEach(item.pictureDetail, (img: string) => {
            GridItem() {
              Image(img)
                .height(80)
                .aspectRatio(1);
            }
            .recordMediaContainerStyle()
            .onClick(() => {
              this.vm.jumpToFullScreenPage(PickerResourceType.IMAGE, img);
            });
          }, (img: string, index: number) => index + '_' + img);
        }
        if (item.videoDetail?.length) {
          ForEach(item.videoDetail, (video: string) => {
            GridItem() {
              Stack({ alignContent: Alignment.Center }) {
                Image($r('app.media.ic_record_video'))
                  .width($r('app.string.width_percent_25'));
              }
              .width(80)
              .height(80)
              .backgroundColor($r('app.color.system_color_background_grey_level1'));
            }
            .recordMediaContainerStyle()
            .onClick(() => {
              this.vm.jumpToFullScreenPage(PickerResourceType.VIDEO, video);
            });
          }, (video: string, index: number) => index + '_' + video);
        }
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .columnsGap(8)
      .rowsGap(8)
      .width($r('app.string.width_percent_full'));

      CommonDivider();
    }
    .width($r('app.string.width_percent_full'))
    .alignItems(HorizontalAlign.Start);
  }
}

@Extend(Text)
function cardSubTitleStyle() {
  .fontSize($r('app.string.font_size_12'))
  .fontWeight(FontWeight.Medium)
  .margin({ bottom: $r('app.string.margin_l') })
  .fontColor($r('app.color.font_color_level1'));
}

@Extend(Text)
function cardContentStyle() {
  .fontSize($r('app.string.font_size_12'))
  .margin({ bottom: $r('app.string.margin_xs') })
  .fontColor($r('app.color.font_color_level2'));
}

@Extend(Text)
function recordTextStyle() {
  .fontSize($r('app.string.font_size_12'))
  .lineHeight(18)
  .fontColor($r('app.color.font_color_level1'));
}

@Extend(GridItem)
function recordMediaContainerStyle() {
  .borderRadius($r('app.string.border_radius_8'))
  .width(80)
  .height(80)
  .clip(true);
}
