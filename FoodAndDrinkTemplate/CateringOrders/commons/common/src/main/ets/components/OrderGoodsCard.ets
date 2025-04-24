import { CarGoodInfo, GoodsOfOrder, PackageSpec } from '../models/ResponseModel';
import { Decimal } from '@kit.ArkTS';
import { CommonUrl, Constants, GoodSpecEnum } from '../constants/Common';

@Component
export struct GoodsComp {
  @Prop goodList: Array<CarGoodInfo | GoodsOfOrder>;
  @State carPgkGoodList: Array<CarGoodInfo | GoodsOfOrder> = [];
  @State carMustGoodList: Array<CarGoodInfo | GoodsOfOrder> = [];
  @State carGoodList: Array<CarGoodInfo | GoodsOfOrder> = [];

  aboutToAppear(): void {
    this.goodList.forEach(item => {
      if (item.isMust === Constants.GOODS_MUST) {
        this.carMustGoodList.push(item);
      } else if (item.specType === GoodSpecEnum.PACKAGE_TYPE) {
        this.carPgkGoodList.push(item);
      } else {
        this.carGoodList.push(item);
      }
    });
  }

  @Styles
  cardStyle(){
    .width(Constants.FULL_SIZE)
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .padding({
      left: 12,
      right: 12,
      top: 16,
      bottom: 16,
    })
  }

  build() {
    Column({ space: 12 }) {
      if (this.carPgkGoodList.length) {
        // 套餐详情
        Column() {
          List({ space: 16 }) {
            ForEach(this.carPgkGoodList, (goodInfo: CarGoodInfo | GoodsOfOrder) => {
              ListItem() {
                GoodPkgCard({ goodInfo });
              };
            }, (goodInfo: CarGoodInfo | GoodsOfOrder) => `${goodInfo.id}${goodInfo.num}${goodInfo.spec}`);
          };
        }.cardStyle();
      }
      if (this.carGoodList.length) {
        // 单品详情
        Column() {
          List({ space: 16 }) {
            ForEach(this.carGoodList, (goodInfo: CarGoodInfo | GoodsOfOrder) => {
              ListItem() {
                GoodsCard({ goodInfo });
              };
            }, (goodInfo: CarGoodInfo | GoodsOfOrder) => `${goodInfo.id}${goodInfo.num}${goodInfo.spec}`);
          };
        }.cardStyle();
      }

      if (this.carMustGoodList.length) {
        // 必选品详情
        Column() {
          Text($r('app.string.must_good'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
          List({ space: 16 }) {
            ForEach(this.carMustGoodList, (goodInfo: CarGoodInfo | GoodsOfOrder) => {
              ListItem() {
                GoodsCard({ goodInfo });
              };
            }, (orderInfo: CarGoodInfo | GoodsOfOrder) => orderInfo.id);
          }.margin({ top: 12 });
        }.cardStyle().alignItems(HorizontalAlign.Start);
      }
    };

  }
}

@Component
export struct GoodPkgCard {
  @Prop goodInfo: CarGoodInfo | GoodsOfOrder;

  build() {
    Column() {
      Row() {
        Row() {
          Image(`${CommonUrl.CLOUD_STORAGE_URL}${this.goodInfo.logo}`).width(50).height(50).borderRadius(8)
          Column() {
            Text(this.goodInfo.name)
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis });

            Row() {
              Text(`x`)
                .fontSize($r('sys.float.Caption_M'))
                .fontColor($r('sys.color.font_secondary'))
              Text(`${this.goodInfo.num}`)
                .fontSize($r('sys.float.Caption_L'))
                .fontColor($r('sys.color.font_secondary'))
            }.alignItems(VerticalAlign.Bottom)
          }
          .margin({ left: 8 })
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.SpaceBetween);
        }.layoutWeight(1);

        Row() {
          Text($r('app.string.currency_symbol_post_params',
            new Decimal(this.goodInfo.money2).mul(this.goodInfo.num!).toString()))
            .fontSize($r('sys.float.Caption_S'))
            .fontColor($r('sys.color.font_primary'))
            .decoration({
              type: TextDecorationType.LineThrough,
              color: $r('sys.color.font_secondary'),
            });
          Text($r('app.string.discount', this.goodInfo.discount))
            .fontSize($r('sys.float.Caption_L'))
            .fontColor($r('sys.color.multi_color_09'))
            .padding({
              left: 4,
              right: 4,
              top: 2,
              bottom: 2,
            })
            .borderWidth(1)
            .borderColor($r('sys.color.multi_color_09'))
            .borderRadius(4)
            .margin({ left: 4, right: 4 });
          Text() {
            Span($r('app.string.currency_symbol'))
              .fontSize($r('sys.float.Caption_S'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            Span(new Decimal(this.goodInfo.money).mul(new Decimal(this.goodInfo.num)).toString())
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
          };
        }.height(50).alignItems(VerticalAlign.Bottom);
      }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween);

      Column() {
        List({ space: 8 }) {
          ForEach(this.goodInfo.combination, (item: PackageSpec) => {
            ListItem() {
              Row() {
                Text(item.specName).fontSize($r('sys.float.Caption_L')).fontColor($r('sys.color.font_primary'))
                Text(`x${item.specNum}`).fontSize($r('sys.float.Caption_L')).fontColor($r('sys.color.font_secondary'))
              }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween);
            };
          }, (item: PackageSpec) => JSON.stringify(item));
        };
      }.margin({ top: 12 })
    };
  }
}

@Component
export struct GoodsCard {
  @Prop goodInfo: CarGoodInfo;

  build() {
    Row() {
      Row() {
        Image(`${CommonUrl.CLOUD_STORAGE_URL}${this.goodInfo.logo}`).width(50).height(50).borderRadius(8);
        Column() {
          Column() {
            Text(this.goodInfo.name)
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
            Text(this.goodInfo.spec?.split(',').join(' | '))
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: 4 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis });
          }.alignItems(HorizontalAlign.Start)

          Text(`x${this.goodInfo.num}`)
            .fontSize($r('sys.float.Caption_L'))
            .fontColor($r('sys.color.font_secondary'))
            .margin({ top: 4 });
        }.height(50).margin({ left: 8 }).alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.SpaceBetween)
      }.layoutWeight(1);

      Row() {
        Text() {
          Span($r('app.string.currency_symbol'))
            .fontSize($r('sys.float.Caption_S'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
          Span(new Decimal(this.goodInfo.money).mul(new Decimal(this.goodInfo.num)).toString())
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
        };
      }.height(48).alignItems(VerticalAlign.Bottom);
    }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween);
  }
}