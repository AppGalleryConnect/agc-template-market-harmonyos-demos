import {
  Constants,
  CouponStateEnum,
  HttpRequest,
  IndexPageRouter,
  OrderTypeEnum,
  RouterMap,
  StoreInfoModel,
  TabBarType,
  UserIconModel,
  UserInfoModel,
} from 'common';
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';

@Builder
export function HomePageBuilder() {
  HomePage()
}

@ComponentV2
struct HomePage {
  @Consumer('pageStack') pageStack?: NavPathStack
  @Consumer('currentIndex') currentIndex?: TabBarType
  @Local storeModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!;
  @Local userIconInfo: UserIconModel = PersistenceV2.connect(UserIconModel, () => new UserIconModel())!;
  @Local swiperIndex: number = 0;
  @Local bannerList: Array<ResourceStr> = [$r('app.media.home_banner'), $r('app.media.home_banner')];
  @Local collectList: Array<ResourceStr> =
    [$r('app.media.ic_collect'), $r('app.media.ic_collect'), $r('app.media.ic_collect'), $r('app.media.ic_collect'),
      $r('app.media.ic_collect'), $r('app.media.ic_collect')];
  @Local myCouponsNum: number = 0
  private scroller: Scroller = new Scroller();

  @Computed
  get myCouponsStr() {
    return this.myCouponsNum > 5 ? '5+' : this.myCouponsNum.toString()
  }

  @Computed
  get avatarUri(): string {
    return `file://${getContext().filesDir}/${this.userIconInfo.userIconPath}`
  }

  @Computed
  get userIcon(): ResourceStr {
    if (this.userInfo.isRelative) {
      return this.userIconInfo.isSaved ? this.avatarUri : $r('app.media.ic_user_img')
    } else {
      return $r('app.media.default_hd')
    }
  }

  @Monitor('currentIndex')
  infoChange(monitor: IMonitor) {
    if (monitor.value()?.now === TabBarType.HOME_PAGE) {
      this.getMyCoupon()
    }
  }

  @Styles
  cardStyle(){
    .width(Constants.FULL_SIZE)
    .margin({ left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH, bottom: 8 })
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
    .borderRadius(16)
    .backgroundColor(Color.White);
  }

  @Builder
  userCard() {
    Column() {
      Text(new Date().getHours() < 12 ? $r('app.string.good_morning') : $r('app.string.good_afternoon'))
        .fontSize(12)
        .fontColor($r('sys.color.mask_secondary'))
      Row() {
        Row() {
          Image(this.userIcon).width(40).height(40).borderRadius(50)
          Column() {
            Text(this.userInfo.getUserName()).fontSize(12).fontColor('#E6000000').fontWeight(FontWeight.Medium);
            Row() {
              Text($r('app.string.score')).fontSize(10).fontColor('#E6000000').margin({ left: 3 });
              Text(this.userInfo.getTotalScore()).fontSize(10).fontColor('#E6000000').margin({ left: 16 });
              Text($r('app.string.coupon_num')).fontSize(10).fontColor('#E6000000').margin({ left: 22 });
              Text(this.myCouponsStr).fontSize(10).fontColor('#E6000000').margin({ left: 16 });
            }.margin({ top: 9 });
          }.alignItems(HorizontalAlign.Start).margin({ left: 12 });
        };

        if (this.userInfo.isRelative) {
          Column() {
            Image($r('app.media.ic_public_qrcode')).width(24).height(24);
            Text($r('app.string.membership_code')).fontSize(10).fontColor('#E6000000').margin({ top: 3 });
          }.onClick(() => {
            this.pageStack?.pushPathByName(RouterMap.MEMBER_CODE_PAGE, null)
          })
        }
      }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween).margin({ top: 12 });
    }
    .padding({
      top: 8,
      bottom: 12,
      left: 12,
      right: 12,
    })
    .cardStyle()
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  orderCard() {
    Row() {
      Column() {
        Image($r('app.media.ic_pick_self')).width(100).height(67);
        Text($r('app.string.pick_self'))
          .fontSize(16)
          .fontColor('#E6000000')
          .fontWeight(FontWeight.Medium)
          .margin({ top: 10 });
        Text($r('app.string.pick_self_desc')).fontSize(10).fontColor($r('sys.color.mask_secondary')).margin({ top: 6 });
      }.onClick(() => {
        this.storeModel.orderType = OrderTypeEnum.PICK_SELF
        this.pageStack?.pushPathByName(RouterMap.SELECT_STORE_PAGE, null, (popInfo: PopInfo) => {
          let result = popInfo.result as IndexPageRouter
          this.currentIndex = result.index ?? TabBarType.HOME_PAGE;
          this.storeModel.storeId = result.storeId ?? '';
        })
      })

      Column() {
        Image($r('app.media.ic_takeaway')).width(100).height(67);
        Text($r('app.string.takeaway_delivery'))
          .fontSize(16)
          .fontColor('#E6000000')
          .fontWeight(FontWeight.Medium)
          .margin({ top: 10 });
        Text($r('app.string.takeaways_desc')).fontSize(10).fontColor($r('sys.color.mask_secondary')).margin({ top: 6 });
      }.margin({ left: 40 }).onClick(() => {
        this.storeModel.orderType = OrderTypeEnum.TAKEAWAY_DELIVERY
        this.pageStack?.pushPathByName(RouterMap.SELECT_STORE_PAGE, null, (popInfo: PopInfo) => {
          let result = popInfo.result as IndexPageRouter
          this.currentIndex = result.index ?? TabBarType.HOME_PAGE;
          this.storeModel.storeId = result.storeId ?? '';
        })
      })
    }.cardStyle().padding({ top: 16, bottom: 21 }).justifyContent(FlexAlign.Center);
  }

  @Builder
  collectCard() {
    Column() {
      Text($r('app.string.collect_six')).fontWeight(FontWeight.Medium);
      Row() {
        Text($r('app.string.collect_six_desc'))
          .fontSize(12)
          .fontColor($r('sys.color.mask_secondary'))
          .margin({ left: 1 });
        Text(`${this.userInfo.userInfo.sixProcess}/${Constants.DRINK_PROCESS_MAX}`)
          .fontSize(12)
          .fontColor('#86AD2B')
      }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween).margin({ top: 8 });

      List({ space: 12 }) {
        ForEach(this.collectList, (item: ResourceStr, index: number) => {
          ListItem() {
            Image(this.userInfo.userInfo.sixProcess > index ? $r('app.media.ic_collected') : item).width(36).height(36);
          };
        }, (item: ResourceStr) => item.toString());
      }.listDirection(Axis.Horizontal).layoutWeight(1).scrollBar(BarState.Off).margin({ left: 12, top: 8 });
    }.height(120).padding(12).cardStyle().alignItems(HorizontalAlign.Start);
  }

  @Builder
  promotionCard() {
    Stack() {
      Image($r('app.media.ic_promotion')).width(Constants.FULL_SIZE).height(120);
      Text($r('app.string.membership_day')).fontSize(24).fontColor(Color.White).margin({ bottom: 11, left: 17 });
    }.cardStyle().clip(true).alignContent(Alignment.BottomStart);
  }

  @Builder
  banner() {
    Swiper() {
      ForEach(this.bannerList, (item: ResourceStr) => {
        Row() {
          Image(item).width(Constants.FULL_SIZE).height(249);
        };
      }, (item: ResourceStr) => (JSON.stringify(item)),
      );
    }
    .displayMode(SwiperDisplayMode.STRETCH)
    .loop(true)
    .autoPlay(true)
    .vertical(true)
    .indicator(false)
    .interval(2000)
    .onChange((index) => {
      this.swiperIndex = index;
    });
  }

  build() {
    Stack() {
      Column() {
        this.banner();
      }.justifyContent(FlexAlign.Start).height(Constants.FULL_SIZE).backgroundColor('#F1F3F5');

      Scroll(this.scroller) {
        Column() {
          this.userCard();
          this.orderCard();
          this.collectCard();
          this.promotionCard();
        }

      }.layoutWeight(1)
      .scrollBar(BarState.Off)
      .padding({ top: 220 });

    }
    .width('100%');
  }

  getMyCoupon() {
    this.myCouponsNum = 0
    HttpRequest.getMyCoupons().then((res) => {
      res.forEach(item => {
        // 过滤可使用的优惠券 日期在有效期内
        if (new Date().getTime() < new Date(`${item.endTime} 23:59:59`).getTime() &&
          item.state === CouponStateEnum.USABLE) {
          this.myCouponsNum++
        }
      })
    })
  }
}