import {
  Constants,
  OrderTypeEnum,
  Reduction,
  RouterMap,
  SheetHeaderComp,
  StoreInfoModel,
  WindowModel,
} from 'common/Index';
import { AppStorageV2 } from '@kit.ArkUI';

@Preview
@ComponentV2
export struct TitleComp {
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack();
  @Local storeModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!
  @Local showShopDiscount: boolean = false
  @Local swiperIndex: number = 0;

  build() {
    Column() {
      Row() {
        Row() {
          Text($r('app.string.order_pick_self'))
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.storeModel.orderType === OrderTypeEnum.PICK_SELF ? Color.White :
            $r('sys.color.mask_secondary'))
            .backgroundColor(this.storeModel.orderType === OrderTypeEnum.PICK_SELF ? '#86AD2B' : '#00000000')
            .borderRadius(14)
            .padding({
              left: 8,
              right: 8,
              top: 4,
              bottom: 4,
            })
            .height(28)
            .onClick(() => {
              this.storeModel.orderType = OrderTypeEnum.PICK_SELF
            })
          Text($r('app.string.takeaway_tag'))
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.storeModel.orderType === OrderTypeEnum.TAKEAWAY_DELIVERY ? Color.White :
            $r('sys.color.mask_secondary'))
            .backgroundColor(this.storeModel.orderType === OrderTypeEnum.TAKEAWAY_DELIVERY ? '#86AD2B' : '#00000000')
            .borderRadius(14)
            .padding({
              left: 8,
              right: 8,
              top: 4,
              bottom: 4,
            })
            .height(28)
            .onClick(() => {
              this.storeModel.orderType = OrderTypeEnum.TAKEAWAY_DELIVERY
            })
        }.margin({ left: 17 }).height(28).backgroundColor('#0D000000').borderRadius(14);
      }
      .borderRadius(20)
      .height(36)

      Row() {
        Image($r('app.media.logo')).width(40).height(40).borderRadius(4);
        Column() {
          Row() {
            Text(this.storeModel.storeInfo.name)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
            Image($r('app.media.ic_right')).width(12).margin({ left: 6 });
          };

          Row() {
            Image($r('app.media.ic_position')).width(12);
            Text($r('app.string.store_distance', this.storeModel.storeInfo.distanceStr))
              .fontSize(10)
              .fontColor($r('sys.color.mask_secondary'))
              .lineHeight(16)
              .layoutWeight(1)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ left: 4 });
          }.layoutWeight(1);
        }
        .height(40)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ left: 8 })
        .layoutWeight(1);
      }
      .margin({ left: 12, right: 12, top: 12 })
      .constraintSize({ maxWidth: Constants.FULL_SIZE })
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.Start)
      .onClick(() => {
        this.pageStack.pushPathByName(RouterMap.MERCHANT_DETAIL_PAGE, null, false)
      })

      Row() {
        Swiper() {
          ForEach(this.storeModel.storeInfo?.reduction, (item: Reduction) => {
            Row() {
              Image($r('app.media.ic_news')).width(16)
              Text(item.name)
                .fontColor('#61860B')
                .fontSize($r('sys.float.Caption_M'))
                .textAlign(TextAlign.Start)
                .margin({ left: 8 })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)
            }.layoutWeight(1)

          }, (item: Reduction) => (JSON.stringify(item)))
        }
        .displayMode(SwiperDisplayMode.STRETCH)
        .loop(true)
        .autoPlay(true)
        .vertical(true)
        .indicator(false)
        .interval(2000)
        .layoutWeight(1)
        .onChange((index) => {
          this.swiperIndex = index;
        })

        Image($r('app.media.ic_more')).width('16')
      }
      .height(24)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor('#33A9D542')
      .borderRadius(12)
      .padding({
        left: 12,
        right: 12,
        top: 5,
        bottom: 5,
      })
      .onClick(() => {
        this.showShopDiscount = true
      })
      .bindSheet($$this.showShopDiscount, this.myBuilder(() => {
        this.showShopDiscount = false
      }), {
        height: 421,
        blurStyle: BlurStyle.Thick,
        showClose: false,
      })
      .margin({ top: 12, left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH });
    }
    .padding({
      top: 10,
      bottom: 8,
    })
    .margin({ top: this.windowModel.getWindowTopHeight() })
    .alignItems(HorizontalAlign.Start)
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
  }

  @Builder
  myBuilder(close: () => void) {
    Column() {
      SheetHeaderComp({
        title: $r('app.string.store_announce'),
        close: () => {
          close()
        },
      })
      List({ space: 18 }) {
        ForEach(this.storeModel.storeInfo?.reduction, (reduction: Reduction) => {
          ListItem() {
            Row() {
              Row() {
                Image($r('app.media.ic_news')).width(16)
                Text(reduction.name)
                  .fontSize(12)
                  .fontColor($r('sys.color.font_secondary'))
                  .margin({ left: 12 })
                  .layoutWeight(1)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }.layoutWeight(1)

              Button(reduction.status === 0 ? $r('app.string.claim_btn') : $r('app.string.collected'))
                .fontColor(Color.White)
                .fontSize(8)
                .fontWeight(FontWeight.Regular)
                .height(18)
                .margin({ left: 8 })
                .padding({ left: 8, right: 8 })
                .backgroundColor(reduction.status === 0 ? '#61860B' : '#000000')
                .opacity(reduction.status === 0 ? 1 : 0.4)
                .onClick(() => {
                  reduction.status = 1
                })

            }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween)
          }
        }, (reduction: Reduction) => JSON.stringify(reduction))
      }
      .width(Constants.FULL_SIZE)
      .constraintSize({ maxWidth: Constants.FULL_SIZE })
      .padding({
        top: 13,
        bottom: 13,
        left: 16,
        right: 16,
      })
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .backgroundColor($r('sys.color.background_primary'))
      .borderRadius({ topLeft: 12, topRight: 12 })
      .padding({ top: 16, left: 12, right: 12 })
      .margin({ top: 8 })
    }
    .width(Constants.FULL_SIZE)
    .height(421)
    .padding({ left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH, top: 8 })
    .backgroundColor($r('sys.color.background_secondary'))
    .borderRadius({ topLeft: 32, topRight: 32 })
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
  }
}