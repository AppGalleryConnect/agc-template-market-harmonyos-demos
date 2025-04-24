import { LocationVM } from '@ohos_agcit/car_beauty_care_shop';
import { AppointmentVM } from '../mode/AppointmentVM';
import { ReservedCard } from './ReservedCard';
import { SelectedData } from '../mode/AppointmentModel';
import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib';
import { PromptAction } from '@kit.ArkUI';

@Builder
export function ReservedCardListBuilder() {
  ReservedCardList();
}

@ComponentV2
export struct ReservedCardList {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  topRectHeight: number = 0;
  private scroller: Scroller = new Scroller();
  appointmentVM: AppointmentVM = AppointmentVM.instance;
  locationVM: LocationVM = LocationVM.instance;
  @Local showCancelDialog: boolean = false;
  @Local currentReservedInfo?: SelectedData | null = null;
  ;
  private promptAction: PromptAction = new PromptAction();

  aboutToAppear(): void {
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
  }

  private cancelAppointment() {
    if (this.currentReservedInfo) {
      const success = this.appointmentVM.cancelAppointOrder(this.currentReservedInfo);
      if (success) {
        this.promptAction.showToast({
          message: $r('app.string.cancel_reserve_success'),
          duration: 2000,
        });
      } else {
        this.promptAction.showToast({
          message: $r('app.string.cancel_reserve_failure'),
          duration: 2000,
        });
      }
      this.showCancelDialog = false;
    }
  }

  build() {
    NavDestination() {
      Stack() {
        Scroll(this.scroller) {
          if (this.appointmentVM.appointmentOrder.length === 0) {
            Column() {
              Image($r('app.media.noappointment'))
                .width(120)
                .height(120)
                .margin({ bottom: 12 });

              Text($r('app.string.reserve_none'))
                .fontSize(16)
                .fontColor($r('app.color.darkGrey'));
            }
            .margin({ top: 100 })
            .padding(15)
            .alignItems(HorizontalAlign.Center);
          } else {
            Column() {
              List({ space: 12 }) {
                ForEach(this.appointmentVM.appointmentOrder, (item: SelectedData) => {
                  ListItem() {
                    ReservedCard({
                      reservedCard: item,
                      onCancelClick: () => {
                        this.currentReservedInfo = item;
                        this.showCancelDialog = true;
                      },
                    });
                  }
                  .backgroundColor(Color.White)
                  .borderRadius(16)
                  .padding(10);
                });
              }
              .width(CommonConstants.FULL_WIDTH)
              .margin({ top: 12, bottom: 12 });
            }
            .padding({
              left: 16,
              right: 16,
            })
            .backgroundColor($r('app.color.lightWhite'));
          }
        };

        // 全局取消预约对话框
        if (this.showCancelDialog) {
          Column() {
            // 对话框内容
            Column() {
              Column() {
                Text($r('app.string.reserve_cancel'))
                  .fontSize(20)
                  .fontWeight(FontWeight.Medium)
                  .margin({ bottom: 12 });

                Text($r('app.string.cancel_confirm'))
                  .fontSize(16)
              }
              .height(100)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .width(CommonConstants.FULL_WIDTH);

              Row() {
                Text($r('app.string.confirm'))
                  .fontSize(16)
                  .fontColor($r('app.color.RedConfirm'))
                  .onClick(() => {
                    this.cancelAppointment();
                  })

                Text($r('app.string.cancel'))
                  .fontSize(16)
                  .onClick(() => {
                    this.showCancelDialog = false;
                  });
              }
              .justifyContent(FlexAlign.SpaceEvenly)
              .width(CommonConstants.FULL_WIDTH)
              .margin({ top: 16 });
            }
            .width(328)
            .height(164)
            .backgroundColor(Color.White)
            .borderRadius(32)
            .position({ x: '50%', y: '50%' })
            .translate({ x: -164, y: -82 })
            .zIndex(999);
          }
          .width(CommonConstants.FULL_WIDTH)
          .height(CommonConstants.FULL_HEIGHT)
          .backgroundColor('rgba(0,0,0,0.5)')
          .position({ x: 0, y: 0 })
          .onClick(() => {
            this.showCancelDialog = false;
          })
          .zIndex(998);


        }
      }
      .alignContent(Alignment.TopStart)
    }
    .title('我的预约')
    .margin({
      top: px2vp(this.topRectHeight),
    })
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    })
    .linearGradient({
      angle: 135,
      colors: [['#D2E2F5', 0.0], ['#F1F3F5', 0.4]],
    });
  }
}