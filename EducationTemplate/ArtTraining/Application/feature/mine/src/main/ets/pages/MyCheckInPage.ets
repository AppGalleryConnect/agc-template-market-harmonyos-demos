import { CheckInActivity } from 'commonlib';
import { CommonHeader, CommonLoading, ContainerColumn, ContainerRow } from 'componentlib';
import { MyCheckInVM } from '../viewModels/MyCheckInVM';

@Builder
export function myCheckInPageBuilder() {
  MyCheckInPage();
}

@ComponentV2
export struct MyCheckInPage {
  vm: MyCheckInVM = MyCheckInVM.instance;

  aboutToAppear(): void {
    this.vm.getMyCheckIn();
  }

  build() {
    NavDestination() {
      CommonHeader({ title: '我的打卡' });
      if (this.vm.isLoading) {
        CommonLoading();
      } else {
        this.checkInTaskList();
      }
    }
    .hideTitleBar(true);
  }

  @Builder
  checkInTaskList() {
    Column() {
      if (this.vm.taskList.length) {
        List() {
          ForEach(this.vm.taskList, (task: CheckInActivity) => {
            ListItem() {
              this.taskCardBuilder(task);
            }
            .onClick(()=> {
              this.vm.jumpToTaskPage(task);
            })
          }, (item: CheckInActivity) => item.activityId.toString());
        };
      } else {
        ContainerColumn() {
          Column() {
            Image($r('app.media.ic_checkin_empty'))
              .width(140)
              .height(140)
              .margin({ bottom: $r('app.string.margin_m') });
            Text('没有参与的打卡活动哦~')
              .fontSize($r('app.string.font_size_14'))
              .fontColor($r('app.color.font_color_level2'));
          }
          .width($r('app.string.width_percent_full'))
          .padding({
            top: 100,
            bottom: 100,
          });
        };
      }
    }
    .layoutWeight(1)
    .padding($r('app.string.padding_l'))
    .layoutWeight(1)
    .backgroundColor($r('app.color.system_color_background_auxiliary'))
    .width($r('app.string.width_percent_full'));
  }

  @Builder
  taskCardBuilder(task: CheckInActivity) {
    ContainerRow() {
      Image(task.mainDiagram)
        .height(64)
        .aspectRatio(16 / 9)
        .borderRadius($r('app.string.border_radius_8'))
        .margin({ right: $r('app.string.margin_l') });
      Column() {
        Text(task.name)
          .fontSize($r('app.string.font_size_16'))
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: $r('app.string.margin_xs') })
          .fontColor($r('app.color.font_color_level1'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
        Text(task.summary)
          .fontSize($r('app.string.font_size_12'))
          .margin({ bottom: $r('app.string.margin_xs') })
          .fontColor($r('app.color.font_color_level2'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
        Blank()
        Text(task.price === 0 ? '免费' : `¥ ${task.price}`)
          .fontSize($r('app.string.font_size_12'))
          .fontColor($r('app.color.font_color_level2'));
      }
      .height(64)
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start);
    }
  }
}

