import { ActivityInfo } from '../model/ActivityInfo';
import { Constants, DateUtils, NavigationTitleBuilder, UiUtils } from 'commons';
import Logger from 'commons/src/main/ets/utils/Logger';

@Builder
export function ActivityDetailPageBuilder() {
  ActivityDetailPage()
}

@Component
export struct ActivityDetailPage {
  @Consume('pageStack') pageStack: NavPathStack;
  @Prop detail: ActivityInfo | undefined = undefined;

  aboutToAppear(): void {
    let params: ActivityInfo[] = this.pageStack.getParamByName('ActivityDetail') as ActivityInfo[];
    if (params.length >= 1) {
      this.detail = params[0];
      Logger.debug('activityDetail=' + JSON.stringify(this.detail));
    }
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Image($r(this.detail?.resource0Url))
            .width('92%')
            .height(166)
            .objectFit(ImageFit.Cover)
            .borderRadius(16)
        }

        Column() {
          Row() {
            Image($r('app.media.icon_activity_title')).width(16).height(16).margin({ left: 13, right: 8 })
            Text(this.detail?.name)
              .fontSize($r('sys.float.Body_M'))
              .fontColor('#E6000000')
              .fontFamily(Constants.HARMONY_HEITI)
              .fontWeight(FontWeight.Bold)
              .align(Alignment.Start)
              .width('90%')
          }.margin({ top: 12, bottom: 12 }).justifyContent(FlexAlign.Start)

          Row() {
            Image($r('app.media.icon_activity_location')).width(16).height(16).margin({ left: 13, right: 8 })
            Text('地点:' + this.detail?.address)
              .fontSize($r('sys.float.Body_M'))
              .fontColor('#E6000000')
              .fontFamily(Constants.HARMONY_HEITI)
              .fontWeight(FontWeight.Regular)
              .align(Alignment.Start)
              .width('90%')
          }.margin({ bottom: 12 }).justifyContent(FlexAlign.Start)

          Row() {
            Image($r('app.media.icon_activity_time')).width(16).height(16).margin({ left: 13, right: 8 })
            Text('时间:' + DateUtils.formatDateToMinutes(new Date(this.detail?.activityStartTime)) + '-' +
            DateUtils.formatDateToMinutes(new Date(this.detail?.activityEndTime)))
              .fontSize($r('sys.float.Body_M'))
              .fontColor('#E6000000')
              .fontFamily(Constants.HARMONY_HEITI)
              .fontWeight(FontWeight.Regular)
              .align(Alignment.Start)
              .width('90%')
          }.margin({ bottom: 12 }).justifyContent(FlexAlign.Start)

          if (this.detail?.desc !== undefined && this.detail?.desc !== '') {
            Row() {
              Image($r('app.media.icon_activity_notice')).width(16).height(16).margin({ left: 13, right: 8 })
              Text('备注:' + this.detail?.desc)
                .fontSize($r('sys.float.Body_M'))
                .fontColor('#E6000000')
                .fontFamily(Constants.HARMONY_HEITI)
                .fontWeight(FontWeight.Regular)
                .align(Alignment.Start)
                .width('90%')
            }.margin({ bottom: 12 }).justifyContent(FlexAlign.Start)
          }
          Divider().strokeWidth(1).margin({ bottom: 16 }).width('92%')

          Swiper() {
            if (!this.isNullOrEmpty(this.detail?.resource1Url)) {
              Image($r(this.detail?.resource1Url))
                .objectFit(ImageFit.Cover)
                .width('92%')
                .height(166)
                .borderRadius(16)
                .overlay(this.ActivityDetailDesc(this.detail), { align: Alignment.TopStart })
            }
            if (!this.isNullOrEmpty(this.detail?.resource2Url)) {
              Image($r(this.detail?.resource2Url))
                .objectFit(ImageFit.Cover)
                .width('92%')
                .height(166)
                .borderRadius(16)
                .overlay(this.ActivityDetailDesc(this.detail), { align: Alignment.TopStart })
            }
            if (!this.isNullOrEmpty(this.detail?.resource3Url)) {
              Image($r(this.detail?.resource3Url))
                .objectFit(ImageFit.Cover)
                .width('92%')
                .height(166)
                .borderRadius(16)
                .overlay(this.ActivityDetailDesc(this.detail), { align: Alignment.TopStart })
            }
          }
          .loop(true)
          .autoPlay(true)
          .indicator(
            // 图片2张以上显示圆点
            ((!this.isNullOrEmpty(this.detail?.resource1Url) && !this.isNullOrEmpty(this.detail?.resource2Url)) ||
              (!this.isNullOrEmpty(this.detail?.resource2Url) && !this.isNullOrEmpty(this.detail?.resource3Url)) ||
              (!this.isNullOrEmpty(this.detail?.resource1Url) && !this.isNullOrEmpty(this.detail?.resource3Url))) ?
            Indicator.dot()
              .itemWidth(4)
              .itemHeight(4)
              .color('#99000000')
              .selectedColor('#DBFFFFFF') : false
          )
          .margin({ bottom: 12 })
        }.backgroundColor(Color.White).borderRadius(16).margin({ left: 16, right: 16, top: 16 })

        Row() {
          if (this.detail?.activityStartTime !== undefined && this.detail?.activityStartTime > new Date().getTime()) {
            if (this.detail && this.detail.activityEnrolledCount < this.detail.activityUserNumber) {
              Button('¥' + this.detail.fee + ' 立即报名')
                .width('90%')
                .backgroundColor($r('app.color.button_background_color'))
                .align(Alignment.Center)
                .alignSelf(ItemAlign.Center)
                .height(36)
                .borderRadius(20)
                .onClick(() => {
                  this.getUIContext().showAlertDialog(UiUtils.buildAlertDialogOption('暂不支持，敬请期待'))
                })
            } else {
              Button('活动已报满，请看看其他活动吧')
                .width('90%')
                .backgroundColor($r('app.color.light_grey'))
                .align(Alignment.Center)
                .alignSelf(ItemAlign.Center)
                .borderRadius(20)
                .height(36)
                .onClick(() => {
                  this.pageStack.popToIndex(this.pageStack.getIndexByName('ActivityList')[0])
                })
            }
          }
        }.width('100%').justifyContent(FlexAlign.Center).margin({ top: 28 })
      }.backgroundColor($r('app.color.page_background_color'))
    }.onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack
    })
    .title(NavigationTitleBuilder('活动详情'))
    .backgroundColor($r('app.color.page_background_color'))
  }

  @Builder
  ActivityDetailDesc(detail: ActivityInfo | undefined): CustomBuilder {
    Column() {
      Row() {
        Text(detail?.descTitle)
          .fontSize(16)
          .fontColor(Color.White)
          .fontFamily(Constants.HARMONY_HEITI)
          .fontWeight(FontWeight.Medium)
      }.width('92%').justifyContent(FlexAlign.Start).margin({ top: 63, bottom: 12 })

      Row() {
        Text(detail?.descDetail)
          .fontSize(14)
          .fontColor(Color.White)
          .fontFamily(Constants.HARMONY_HEITI)
          .fontWeight(FontWeight.Regular)
      }.width('92%').justifyContent(FlexAlign.Start).margin({ bottom: 32 })
    }
  }

  isNullOrEmpty(param: string | undefined): boolean {
    return param == null || param === undefined || param === ''
  }
}