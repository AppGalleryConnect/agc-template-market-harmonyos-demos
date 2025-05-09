import { CheckInActivity } from 'commonlib';
import { CommonHeader, CommonLoading, ContainerRow } from 'componentlib';
import { CheckInActivityVM } from '../viewmodels/CheckInActivityVM';


@ComponentV2
export struct CheckInActivityView {
  vm: CheckInActivityVM = CheckInActivityVM.instance;

  aboutToAppear(): void {
    this.vm.getActivityList();
  }

  build() {
    Column() {
      CommonHeader({ title: '打卡活动' });
      if (this.vm.isLoading) {
        CommonLoading();
      } else {
        if (this.vm.activityList.length) {
          List() {
            ForEach(this.vm.activityList, (activity: CheckInActivity) => {
              this.checkInActivityBuilder(activity);
            }, (activity: CheckInActivity) => activity.activityId + activity.name);
          }
          .backgroundColor($r('app.color.system_color_background_auxiliary'))
          .edgeEffect(EdgeEffect.Spring)
          .padding($r('app.string.padding_l'));
        } else {
          Text('暂无数据');
        }
      }
    }
    .backgroundColor($r('app.color.system_color_background_auxiliary'))
    .width($r('app.string.width_percent_full'))
    .height($r('app.string.height_percent_full'));

  }

  @Builder
  checkInActivityBuilder(activity: CheckInActivity) {
    ContainerRow() {
      Flex() {
        Image(activity.mainDiagram)
          .height($r('app.string.height_percent_full'))
          .aspectRatio(16 / 9)
          .flexShrink(0)
          .borderRadius($r('app.string.border_radius_8'));
        Column() {
          Text(activity.name)
            .fontColor($r('app.color.font_color_level1'))
            .fontWeight(FontWeight.Medium)
            .fontSize($r('app.string.font_size_16'));
          Text(activity.summary)
            .margin({ top: $r('app.string.margin_xs') })
            .fontColor($r('app.color.font_color_level3'))
            .fontSize($r('app.string.font_size_12'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('auto');
          Blank();
          if (activity.price === 0) {
            Text('免费')
              .fontColor($r('app.color.font_color_level2'))
              .fontSize($r('app.string.font_size_12'));
          } else {
            Text() {
              Span('¥ ').fontSize($r('app.string.font_size_10'));
              Span(activity.price.toFixed(2));
            }
            .fontColor($r('app.color.system_theme_color'));
          }
        }
        .height($r('app.string.height_percent_full'))
        .alignItems(HorizontalAlign.Start)
        .margin({ left: $r('app.string.margin_s') });
      }
      .height(72)
      .onClick(() => {
        this.vm.jumpToActivityIntroPage(activity);
      });
    };

  }
}