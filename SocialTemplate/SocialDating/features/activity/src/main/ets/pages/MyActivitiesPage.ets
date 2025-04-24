import { DateUtils, NavigationTitleBuilder, UiUtils } from 'commons';
import { Constants } from 'commons';
import { EnrolledActivity, StatusDisplay } from '../model/EnrolledActivity';

@Builder
export function MyActivitiesPageBuilder() {
  MyActivitiesPage()
}

@Component
export struct MyActivitiesPage {
  @Consume('pageStack') pageStack: NavPathStack;
  private scroller: Scroller = new Scroller();
  private enrolledActivities: EnrolledActivity[] | null = null;

  aboutToAppear(): void {
    let params: EnrolledActivity[][] = this.pageStack.getParamByName('MyActivitiesPage') as EnrolledActivity[][];
    if (params != null) {
      this.enrolledActivities = params[0];
    }
  }

  build() {
    NavDestination() {
      Scroll(this.scroller) {
        Column() {
          ForEach(this.enrolledActivities, (item: EnrolledActivity) => {
            EnrolledActivityComponent({ enrolledActivity: item })
          }, (item: EnrolledActivity) => item.id?.toString())
        }
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .scrollBarColor(0xFFF8F6F6)
      .scrollBarWidth(5)
      .edgeEffect(EdgeEffect.Spring)
    }.onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack
    }).backgroundColor($r('app.color.page_background_color')).title(NavigationTitleBuilder('我的订单'))
  }
}

@Component
export struct EnrolledActivityComponent {
  @State enrolledActivity: EnrolledActivity | null = null;
  @State statusDisplay: StatusDisplay | null = null;

  aboutToAppear(): void {
    if (this.enrolledActivity != null && this.enrolledActivity.status != null) {
      this.statusDisplay = EnrolledActivity.getStatusDisplayInfo(this.enrolledActivity.status);
    }
  }

  build() {
    Column() {
      Row() {
        Column() {
          Image($r(this.enrolledActivity?.activity?.resource0Url))
            .width(120)
            .height(120)
            .borderRadius(8)
        }
        .width(120)
        .height(120)
        .margin({ left: 12, top: 12, bottom: 16 })
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)

        Column() {
          Row() {
            Image($r('app.media.icon_activity_title')).width(16).height(16).margin({ left: 12, right: 8 })
            Text(this.enrolledActivity?.activity?.name)
              .fontSize($r('sys.float.Body_M'))
              .fontColor('#E6000000')
              .fontFamily(Constants.HARMONY_HEITI)
              .fontWeight(FontWeight.Bold)
              .align(Alignment.Start)
              .width('90%')
          }.margin({ top: 12, bottom: 12 }).justifyContent(FlexAlign.Start).width('100%')

          Row() {
            Image($r('app.media.icon_activity_time')).width(16).height(16).margin({ left: 12, right: 8 })
            Text(DateUtils.formatDateToMinutes(new Date(this.enrolledActivity?.activity?.activityStartTime)) +
              '-' + DateUtils.formatDateToMinutes(new Date(this.enrolledActivity?.activity?.activityEndTime)))
              .fontSize($r('sys.float.Body_M'))
              .fontColor('#E6000000')
              .fontFamily(Constants.HARMONY_HEITI)
              .fontWeight(FontWeight.Regular)
              .align(Alignment.Start)
              .width('90%')
          }.margin({ bottom: 12 }).justifyContent(FlexAlign.Start).width('100%')

          Row() {
            Image($r('app.media.icon_activity_location')).width(16).height(16).margin({ left: 12, right: 8 })
            Text(this.enrolledActivity?.activity?.address)
              .fontSize($r('sys.float.Body_M'))
              .fontColor('#E6000000')
              .fontFamily(Constants.HARMONY_HEITI)
              .fontWeight(FontWeight.Regular)
              .align(Alignment.Start)
              .wordBreak(WordBreak.NORMAL)
              .maxLines(2)
              .width('90%')
              .copyOption(CopyOptions.LocalDevice)
          }.margin({ bottom: 12 }).justifyContent(FlexAlign.Start).width('100%').alignItems(VerticalAlign.Top)

        }.width('55%').alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.Start)
      }
      .width('92%')
      .alignItems(VerticalAlign.Top)

      Row() {
        Text(this.statusDisplay?.statusDisplayValue)
          .fontSize($r('sys.float.Body_M'))
          .fontFamily(Constants.HARMONY_HEITI)
          .fontColor(this.statusDisplay?.statusValueColor)
          .fontWeight(FontWeight.Regular)
          .width(64)
          .height(32)
          .textAlign(TextAlign.Center)
          .borderRadius(16)
          .backgroundColor(this.statusDisplay?.statusButtonColor)
          .onClick(() => {
            this.getUIContext().showAlertDialog(UiUtils.buildAlertDialogOption('暂不支持，敬请期待'))
          })
      }.width('92%').justifyContent(FlexAlign.End).padding({ right: 12 })
      .margin({ bottom: 16 })

    }.backgroundColor(Color.White)
    .borderRadius(16)
    .margin({ bottom: 16 })
  }
}