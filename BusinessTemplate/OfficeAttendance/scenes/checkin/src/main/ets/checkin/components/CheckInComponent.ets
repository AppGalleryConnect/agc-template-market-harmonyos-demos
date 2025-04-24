import {
  DialogMap,
  FormatUtil,
  LocationUtil,
  MainEntryVM,
  RouterModule,
  TabIndex,
  VibratorUtil,
  WindowUtil
} from '@ohos_agcit/office_attendance_common_lib'
import { CheckInStatus } from '@ohos_agcit/office_attendance_common_lib/src/main/ets/constants/CheckInEnums';
import { Animator as animator, AnimatorResult } from '@kit.ArkUI';
import { RequestProxy } from '../../api/RequestProxy';
import { CheckInChannelUtil } from '../util/CheckInChannelUtil';
import { ServiceCardNotificationUtil } from '../util/ServiceCardNotificationUtil';

@ComponentV2
export struct CheckInComponent {
  @Local checkInComponentHeight: number | string = '100%'
  private circleAnimator: AnimatorResult | undefined = this.create()

  create(): AnimatorResult {
    const circleAnimator = animator.create({
      // 建议使用 this.getUIContext.createAnimator()接口
      duration: 1000,
      easing: 'ease-in-out',
      delay: 0,
      fill: 'backwards',
      direction: 'alternate',
      iterations: -1,
      begin: 1,
      end: 1.05
    })
    circleAnimator.onFrame = (value: number) => {
      this.scaleX = value;
      this.scaleY = value;
    }
    return circleAnimator;
  }

  @Param onCheckIn: () => void = () => {
  };
  @Local checkInStatus: CheckInStatus = CheckInStatus.NOT_STARTED;
  @Local max: number = 170;
  @Local min: number = 160;
  @Local scaleX: number = 1;
  @Local scaleY: number = 1;
  @Local displayAddition: boolean = false;
  @Local timerId: number = 0;
  @Local location: string | undefined = undefined;
  @Local time: string = FormatUtil.formatTime(new Date())
  @Consumer() isPageShow: boolean = false;
  @Consumer() currentTabIndex: number = MainEntryVM.instance.curIndex;

  @Monitor('isPageShow')
  tryCheckInAutomatically() {
    if (this.isPageShow) { // 是否需要增加当前所处tab index的判断待定
      if (CheckInChannelUtil.fromServiceCard()) {
        this.checkin();
        CheckInChannelUtil.reset();
      } else {
        RequestProxy.isQuickCheckIn().then((value: boolean) => {
          if (value) {
            this.checkin();
          }
        })
      }
    }
  }

  @Monitor('currentTabIndex')
  tryWhenTabChanged() {
    if (this.currentTabIndex === TabIndex.CHECKIN) {
      RequestProxy.isQuickCheckIn().then((value: boolean) => {
        if (value) {
          this.checkin();
        }
      })
    }
  }

  aboutToAppear() {
    this.calculateScrollAreaHeight();
    this.timerId = setInterval(() => {
      this.time = FormatUtil.formatTime(new Date());
    }, 1000);
  }

  aboutToDisappear(): void {
    clearInterval(this.timerId); // 页面退出时，取消定时器
  }

  build() {
    Scroll() {
      Stack() {
        Column() {
          Stack() {
            Shape() {
              this.circleBuilder(this.max, 0.1)
              this.circleBuilder(this.min, 1.0)
            }.align(Alignment.Center).width(180).height(180)

            this.checkInBuilder($r('app.media.click'), $r('app.string.checkin_tip'), CheckInStatus.NOT_STARTED)
            this.checkInBuilder($r('app.media.ticking'), $r('app.string.checkin_is_finished'), CheckInStatus.FINISHED)
            this.checkInStatusTipBuilder($r('app.string.checkin_is_on_going'), CheckInStatus.ON_GOING)
            this.checkInStatusTipBuilder($r('app.string.checkin_is_failed'), CheckInStatus.FAILED)
          }.align(Alignment.Top)
          .onClick(async () => {
            this.checkin();
          }).margin({ top: 76 })

          this.additionBuilder()
        }
        .alignItems(HorizontalAlign.Center)
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.SpaceBetween)


        Stack() {
          Circle()
            .shadow({
              radius: vp2px(8),
              offsetX: 0,
              offsetY: vp2px(2),
              color: 'rgba(0,0,0,0.08)'
            })
            .borderRadius('50%')
            .height(40)
            .width(40)
            .fill(Color.White)
          Image($r('app.media.settings')).height(24).width(24)
        }
        .height(40)
        .width(40)
        .margin({ right: 16, bottom: 24 })
        .alignContent(Alignment.Center)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          RouterModule.openDialog(DialogMap.CHECK_IN_SETTINGS)
        })
      }.height('100%')
      .width('100%').alignContent(Alignment.BottomEnd)
    }.height(this.checkInComponentHeight).scrollBar(BarState.Off).onAreaChange((oldValue, newValue) => {
      this.calculateScrollAreaHeight()
    })
  }

  @Builder
  circleBuilder(size: number, opacity: number) {
    Circle()
      .width(size)
      .height(size)
      .scale({ x: this.scaleX, y: this.scaleY })
      .fillOpacity(opacity)
      .fill($r('app.color.checkin_background'))
      .renderFit(RenderFit.CENTER)
  }

  @Builder
  checkInBuilder(image: Resource, text: Resource, checkInStatus: CheckInStatus) {
    Column() {
      Image(image)
        .width(64)
        .height(64)
        .margin({ top: 32 })
        .opacity(this.checkInStatus === checkInStatus ? 1 : 0)
      Text(text)
        .width(72)
        .height(24)
        .fontSize(18)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 8 })
        .opacity(this.checkInStatus === checkInStatus ? 1 : 0)
    }.height(160)
  }

  @Builder
  checkInStatusTipBuilder(text: Resource, checkInStatus: CheckInStatus) {
    Text(text)
      .fontSize(24)
      .fontColor(Color.White)
      .fontWeight(FontWeight.Bolder)
      .opacity(this.checkInStatus === checkInStatus ? 1 : 0)
      .scale({ x: this.scaleX, y: this.scaleY })
      .height(180)
      .renderFit(RenderFit.CENTER)
  }

  @Builder
  additionBuilder() {
    if (this.displayAddition) {
      Column() {
        Text(this.location).fontSize(14).fontColor(Color.Black).margin({ bottom: 16 })

        Divider()
          .vertical(true)
          .strokeWidth(1)
          .color($r('app.color.checkin_background'))
          .height(20);
        Circle()
          .width(5)
          .height(5)
          .stroke($r('app.color.checkin_background'))
          .fill(Color.White);

        Text(this.time).fontSize(26).margin({ top: 16, bottom: 16 })

        Circle()
          .width(5)
          .height(5)
          .stroke($r('app.color.checkin_background'))
          .fill(Color.White);
        Divider()
          .vertical(true)
          .strokeWidth(1)
          .color($r('app.color.checkin_background'))
          .height(20);
      }.margin({ bottom: 28 })
    }
  }

  addCheckInDetail(address: string) {
    const today: Date = new Date();
    RequestProxy.addCheckInDetail({
      'day': FormatUtil.formatDate(today),
      'dayOfWeek': today.getDay(),
      'location': address,
      'time': FormatUtil.formatTime(today)
    })
  }

  checkin() {
    if (this.checkInStatus !== CheckInStatus.NOT_STARTED) {
      return;
    }
    this.circleAnimator?.play();
    this.checkInStatus = CheckInStatus.ON_GOING;
    this.displayAddition = false;
    VibratorUtil.notification(500, 0);

    const id = setTimeout(() => {
      this.checkInStatus = CheckInStatus.FAILED;
      this.finishAnimator();
      this.resetCheckInStatusLater();
    }, 8000) // 5秒未获取到位置，打卡失败

    LocationUtil.getLocationName().then((address: string | undefined) => {
      this.finishAnimator();
      clearInterval(id);
      if (this.checkInStatus === CheckInStatus.FAILED || this.checkInStatus === CheckInStatus.NOT_STARTED) {
        return; //如果已经打卡超时，不再处理
      }

      if (address) {
        this.location = address;
        this.checkInStatus = CheckInStatus.FINISHED;
        this.displayAddition = true;
        this.addCheckInDetail(address)
        this.onCheckIn();
      } else {
        this.checkInStatus = CheckInStatus.FAILED;
      }
      this.resetCheckInStatusLater();
      ServiceCardNotificationUtil.notify(this.checkInStatus);
    });
  }

  private finishAnimator() {
    this.circleAnimator?.finish();
    this.scaleX = 1;
    this.scaleY = 1;
  }

  private resetCheckInStatusLater() {
    setTimeout(() => {
      this.checkInStatus = CheckInStatus.NOT_STARTED;
      ServiceCardNotificationUtil.notify(this.checkInStatus);
    }, 1500);
  }

  private calculateScrollAreaHeight() {
    const height = WindowUtil.getInstance()?.getAppStorageData().windowHeightVp as number;
    if (height - 56 - 36 - 113 - 80 > 435) { // 如何实际显示内容区域高于高保真设计的高度435，则按百分之百显示，否则按高保真高度显示
      this.checkInComponentHeight = '100%'
      return;
    }

    this.checkInComponentHeight = 435;
  }
}