import { CounterComponent, CounterType } from '@kit.ArkUI';
import { Constant, Logger } from 'common';
import { TitleBar } from 'uicomponents';
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
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  routerToAddress() {
    this.mainPathStack.pushPathByName('Addresses', true, (popInfo: ESObject) => {
      this.vm.addressInfo = popInfo.result;
    });
  }

  getFriendlySpecString(): string {
    const spu = this.purchaseInfo.commodityInfo.spuInfo[this.purchaseInfo.selectedSpu];
    if (!spu) {
      return '规格：未选择';
    }

    if (spu.specValues && spu.specValues.length > 0) {
      const specStrings = spu.specValues.map((spec) => spec.value);
      return `规格：${specStrings.join(' / ')}`;
    }

    return `规格：${spu.spuName}`;
  }

  aboutToDisappear(): void { // 清空选择数量
    this.vm.count = 1;
  }

  @Builder
  AddressInfoCardBuilder() {
    Row({ space: 12 }) {
      Row({ space: 16 }) {
        Image($r('app.media.address')).size({ width: 24, height: 24 });

        Column({ space: 2 }) {
          Text(`${this.vm.addressInfo.district}${this.vm.addressInfo.detail}`)
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
          Text(`${this.vm.addressInfo.name} ${this.vm.addressInfo.phone}`)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'));
        }.alignItems(HorizontalAlign.Start).layoutWeight(1);
      }.layoutWeight(1);

      Image($r('app.media.chevron_right')).size({ width: 12, height: 24 }).margin({ left: 12 });
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(16)
    .width(Constant.FULL_PERCENT)
    .padding({
      top: 8,
      bottom: 8,
      left: 12,
      right: 12,
    })
    .onClick(() => {
      this.routerToAddress();
    });
  }

  @Builder
  AddAddressCardBuilder() {
    Row({ space: 8 }) {
      Image($r('app.media.icon_add')).size({ height: 24, width: 24 });
      Text('新增/选择收货地址')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.warning'));
    }
    .justifyContent(FlexAlign.Center)
    .width(Constant.FULL_PERCENT)
    .height(72)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(16)
    .padding({
      top: 16, bottom: 16,
    })
    .onClick(() => {
      this.routerToAddress();
    });
  }

  @Builder
  CommodityBriefCardBuilder() {
    Row({ space: 12 }) {
      Image(this.purchaseInfo.commodityInfo.banner).size({ width: 56, height: 56 }).borderRadius(8);
      Column({ space: 4 }) {
        Text(this.purchaseInfo.commodityInfo.name)
          .fontSize($r('sys.float.Body_L'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontWeight(FontWeight.Medium);

        Row({ space: 2 }) {
          Text() {
            Span('￥').fontSize($r('sys.float.Body_S'));
            Span(`${this.purchaseInfo.commodityInfo.spuInfo[this.purchaseInfo.selectedSpu]?.spuDiscountPrice}`)
              .fontSize($r('sys.float.Body_L'));
          }.fontWeight(FontWeight.Medium).fontColor($r('sys.color.multi_color_08'));

          Text(`￥${this.purchaseInfo.commodityInfo.spuInfo[this.purchaseInfo.selectedSpu]?.spuOriginalPrice}`)
            .fontSize(12)
            .decoration({ type: TextDecorationType.LineThrough })
            .fontColor($r('sys.color.font_tertiary'));
        };
      }.alignItems(HorizontalAlign.Start).layoutWeight(1);
    }
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(16)
    .width(Constant.FULL_PERCENT)
    .padding(12);
  }

  @Builder
  CommodityCountBuilder() {
    Row() {
      Text(this.getFriendlySpecString()).fontSize(14).fontColor($r('sys.color.font_primary'));

      CounterComponent({
        options: {
          type: CounterType.LIST, numberOptions: {
            value: this.vm.count,
            min: Constant.MIN_PURCHASE_QUANTITY,
            max: Constant.MAX_PURCHASE_QUANTITY,
            onChange: (value: number) => {
              this.vm.count = value;
            },
          },
        },
      }).size({ width: 120 });
    }
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(16)
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
          }.padding({
            top: 8,
            left: 16,
            right: 16,
            bottom: 8,
          });
        };

        Row() {
          Text() {
            Span('应付金额').fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_primary'));
            Span('￥').fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.warning')).fontWeight(FontWeight.Medium);
            Span(`${this.purchaseInfo.commodityInfo.spuInfo[this.purchaseInfo.selectedSpu]?.spuDiscountPrice *
              this.vm.count}`)
              .fontColor($r('sys.color.warning'))
              .fontSize($r('sys.float.Title_S'))
              .fontWeight(FontWeight.Medium);
          };

          Button('提交订单')
            .fontSize(14)
            .width(96)
            .backgroundColor($r('sys.color.multi_color_04'))
            .enabled(this.vm.addressInfo?.name.length !== 0)
            .onClick(() => {
              if (!this.vm.addressInfo.id) {
                this.getUIContext().getPromptAction().showToast({ message: '请先填写收货地址', duration: 1000 });
                return;
              }
              this.vm.createOrder(this.purchaseInfo, this.mainPathStack);
            });
        }
        .backgroundColor($r('sys.color.font_on_primary'))
        .height(56 + this.windowBottomHeight)
        .padding({
          top: 8,
          bottom: 8 + this.windowBottomHeight,
          left: 16,
          right: 16,
        })
        .justifyContent(FlexAlign.SpaceBetween)
        .width(Constant.FULL_PERCENT);
      }
      .height(Constant.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('sys.color.background_secondary'));
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.purchaseInfo = context.pathInfo.param as PurchaseInfo;
      Logger.info('purchase info is ' + this.purchaseInfo);
    });
  }
}