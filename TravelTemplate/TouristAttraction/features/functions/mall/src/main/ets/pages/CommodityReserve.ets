import { CounterComponent, CounterType, promptAction } from '@kit.ArkUI';
import { Constant, Logger } from 'common';
import { TitleBar } from 'components';
import { PurchaseInfo } from '../model/CommodityInfo';
import { CommodityDetailVM } from '../viewmodel/CommodityDetailVM';

@Builder
export function CommodityReserveBuilder() {
  CommodityReserve();
}

@ComponentV2
export struct CommodityReserve {
  vm: CommodityDetailVM = CommodityDetailVM.instance;
  @Local purchaseInfo: PurchaseInfo = new PurchaseInfo();
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  routerToAddress() {
    this.mainPathStack.pushPathByName('Addresses', true, (popInfo: ESObject) => {
      this.vm.addressInfo = popInfo.result;
    });
  }

  aboutToDisappear(): void {
    // 清空选择数量
    this.vm.count = 1;
  }

  @Builder
  AddressInfoCardBuilder() {
    Row() {
      Row({ space: 8 }) {
        Image($r('app.media.address')).size({ width: 24, height: 24 });

        Column({ space: 4 }) {
          Text(`${this.vm.addressInfo.district}${this.vm.addressInfo.detail}`).width(240)
            .fontWeight(500)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
          Text(`${this.vm.addressInfo.name} ${this.vm.addressInfo.phone}`).fontSize(12).opacity(0.4);
        }.alignItems(HorizontalAlign.Start);
      };

      Image($r('app.media.chevron_right')).size({ width: 12, height: 24 });
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .width(Constant.FULL_PERCENT)
    .padding(16)
    .onClick(() => {
      this.routerToAddress();
    });
  }

  @Builder
  AddAddressCardBuilder() {
    Row() {
      Image($r('app.media.icon_add')).size({ height: 22, width: 22 }).margin({ right: 2 });
      Text('新增/选择收货地址').fontSize(18).fontWeight(500).fontColor('#E84026');
    }
    .justifyContent(FlexAlign.Center)
    .width(Constant.FULL_PERCENT)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .padding({
      top: 24,
      bottom: 24,
    })
    .onClick(() => {
      this.routerToAddress();
    });
  }

  @Builder
  CommodityBriefCardBuilder() {
    Row() {
      Image(this.purchaseInfo.commodityInfo.banner)
        .size({ width: 68, height: 68 })
        .margin({ right: 14 })
        .borderRadius(8);
      Column() {
        Text(this.purchaseInfo.commodityInfo.name)
          .fontWeight(500)
          .width(200)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
        Text() {
          Span('￥').fontSize(12).fontColor('#E84026');
          Span(`${this.purchaseInfo.commodityInfo.spuInfo[this.purchaseInfo.selectedSpu]?.spuDiscountPrice}`)
            .fontSize(18)
            .fontWeight(500)
            .fontColor('#E84026');
        };
      }.alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.SpaceBetween);
    }.backgroundColor(Color.White)
    .borderRadius(8).width(Constant.FULL_PERCENT).padding(16);
  }

  @Builder
  CommodityCountBuilder() {
    Row() {
      Text(`规格：${this.purchaseInfo.commodityInfo.spuInfo[this.purchaseInfo.selectedSpu].spuName}`).fontWeight(500);

      CounterComponent({
        options: {
          type: CounterType.LIST,
          numberOptions: {
            value: this.vm.count,
            min: Constant.MIN_PURCHASE_QUANTITY,
            max: Constant.MAX_PURCHASE_QUANTITY,
            onChange: (value: number) => {
              this.vm.count = value;
            },
          },
        },
      }).size({ width: 80 });
    }
    .backgroundColor(Color.White)
    .borderRadius(8)
    .width(Constant.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(12);
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          TitleBar({
            isShowBack: true, title: '提交订单', clickEvent: () => {
              this.mainPathStack.pop();
            },
          });

          Column({ space: 12 }) {
            if (this.vm.addressInfo?.name.length !== 0) {
              this.AddressInfoCardBuilder();
            } else {
              this.AddAddressCardBuilder();
            }

            this.CommodityBriefCardBuilder();
            this.CommodityCountBuilder();
          }.padding(12);
        };

        Row() {
          Text() {
            Span('应付金额').fontSize(14).opacity(0.9);
            Span('￥').fontSize(12).fontColor('#E84026').fontWeight(500);
            Span(`${this.purchaseInfo.commodityInfo.spuInfo[this.purchaseInfo.selectedSpu]?.spuDiscountPrice *
            this.vm.count}`)
              .fontColor('#E84026')
              .fontSize(20)
              .fontWeight(500);
          };

          Button('提交订单').fontSize(14).backgroundColor('#64BB5C').onClick(() => {
            if (!this.vm.addressInfo.id) {
              promptAction.showToast({ message: '请先填写收货地址', duration: 1000 });
              return;
            }
            this.vm.createOrder(this.purchaseInfo, this.mainPathStack);
          }).alignSelf(ItemAlign.End);
        }.backgroundColor(Color.White).padding(16)
        .justifyContent(FlexAlign.SpaceBetween)
        .width(Constant.FULL_PERCENT);
      }
      .height(Constant.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor('#F1F3F5');
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.purchaseInfo = context.pathInfo.param as PurchaseInfo;
      Logger.info('purchase info is ' + this.purchaseInfo);
    });
  }
}