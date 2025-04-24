import { CommonConstants, dealAllError, showToast, AccountUtil } from '@ohos_agcit/car_beauty_care_commonlib';
import { MINE_LIST } from '../../constants/Constants'
import { MineServiceItem } from '../../types/Types'
import { TitleBarView } from '@ohos_agcit/car_beauty_care_componentlib'

class DividerTmp {
  strokeWidth: Length = 1
  startMargin: Length = 60
  endMargin: Length = 10
  color: ResourceColor = '#ffe9f0f0'

  constructor(strokeWidth: Length, startMargin: Length, endMargin: Length, color: ResourceColor) {
    this.strokeWidth = strokeWidth
    this.startMargin = startMargin
    this.endMargin = endMargin
    this.color = color
  }
}

@ComponentV2
export struct MineView {
  logTag: string = 'PrepareLoginPage';
  domainId: number = 0x0000;
  topRectHeight: number = AppStorage.get('topRectHeight') || 0;
  scroller: Scroller = new Scroller();
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  @Local egDivider: DividerTmp = new DividerTmp(1, 40, 0, '#ffe9f0f0');

  // Redirect to another page.
  private jumpLoginPage(quickLoginAnonymousPhone: string | undefined) {
    if (quickLoginAnonymousPhone) {
      // Obtain the anonymous mobile number, pass it, and redirect to the one-tap sign-in screen.
      const params: Record<string, Object> = { 'anonymousPhone': quickLoginAnonymousPhone };
      this.appPathStack.pushPathByName('QuickLoginPage', params, true);
    } else {
      // If the anonymous mobile number cannot be obtained, an error message is displayed.
      const hint: string = getContext().resourceManager.getStringSync($r('app.string.get_mobile_number_error'));
      showToast(hint);
    }
  }

  @Builder
  ServiceItem(serviceItem: MineServiceItem) {
    Row() {
      Image(serviceItem.icon)
        .width(24)
        .height(24)
      Text(serviceItem.label)
        .fontSize(16)
        .fontFamily('鸿蒙黑体')
        .fontWeight(FontWeight.Medium)
        .margin({ left: 16});
      Blank()
      Image($r('app.media.ic_right_arrow_lined'))
        .width(7)
        .height(14)
        .fillColor('rgba(0,0,0,0.2)')
    }
    .width(CommonConstants.FULL_WIDTH)
    .height(56)
    .onClick(() => {
      this.appPathStack.pushPathByName(serviceItem.routePath, true);
    })
  }

  build() {
    NavDestination() {
      Scroll(this.scroller) {
        Column() {
          Row() {
            Image(AccountUtil.getUserInfo().avatar)
              .width(56)
              .height(56)
              .borderRadius(28)
              .margin({ left: 12 })


            Text(AccountUtil.getUserInfo().nickname)
              .fontSize(18)
              .fontFamily('鸿蒙黑体')
              .fontWeight(FontWeight.Medium)
              .margin({ left: 12 })
          }
          .width(CommonConstants.FULL_WIDTH)
          .height(72)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .margin({ top: 5 })
          .onClick(async () => {
            if (AccountUtil.getAccountInfo().idToken === '') {
              await AccountUtil.quickLogin();
              this.jumpLoginPage(AccountUtil.getAccountInfo().quickLoginAnonymousPhone);
            } else {
              this.appPathStack.pushPathByName('userInfoPage', true);
            }
          });

          // 常用服务
          Column() {
            TitleBarView({
              title:$r('app.string.common_services')
            })

            List() {
              ForEach(MINE_LIST, (item: MineServiceItem) => {
                ListItem() {
                  this.ServiceItem(item)
                }
              }, (item: MineServiceItem) => JSON.stringify(item))
            }
            .width(CommonConstants.FULL_WIDTH)
            .divider(this.egDivider)
            .margin({
              top:8
            })
          }
          .width(CommonConstants.FULL_WIDTH)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .justifyContent(FlexAlign.Start)
          .margin({ top: 12})
          .padding({
            top:24,
            left:12,
            right:12,
            bottom:4
          })

        }
        .height(CommonConstants.FULL_HEIGHT)
        .padding({
          left:16,
          right:16
        })
      }
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring)
    }
    .title('我的')
    .padding({
      top: px2vp(this.topRectHeight) + 10,
    })
    .width('100%')
    .linearGradient({
      angle: 180,
      colors: [['#D0E1F5', 0], ['#F1F3F5', 1]],
    });

  }
}