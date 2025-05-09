import {
  CarGoodInfo,
  CommonUrl,
  Constants,
  Good,
  GoodRouter,
  GoodSpecEnum,
  MyCarModel,
  RouterMap,
} from 'common/Index';
import { AppStorageV2, MeasureText } from '@kit.ArkUI';
import { SpecSheetBuilder } from './SpecSheetComp';

@ComponentV2
export struct GoodInfoComp {
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack();
  @Param @Require good: Good;
  @Local myCarModel: MyCarModel = AppStorageV2.connect(MyCarModel) as MyCarModel
  @Local specSheetFlag: boolean = false;
  @Local showGoodContent: boolean = true;
  @Local goodTextWidth: number = 0;

  @Computed
  get carGoodInfo() {
    return this.myCarModel.myCar.carGoods?.find((item: CarGoodInfo) => item.goodId === this.good.id)
  }

  goodChange() {
    let nameWidth: number = MeasureText.measureText({
      textContent: this.good.name,
      fontSize: '14px',
    });
    if (nameWidth > this.goodTextWidth) {
      this.showGoodContent = false;
    } else {
      this.showGoodContent = true;
    }
  }

  goGoodDetail() {
    this.pageStack.pushPathByName(RouterMap.GOOD_DETAIL_PAGE, { goodInfo: this.good } as GoodRouter);
  }

  build() {
    Row() {
      Image(`${CommonUrl.CLOUD_STORAGE_URL}${this.good?.logo}`).width(82).height(82).borderRadius(8)
      Column() {
        Column() {
          Text(this.good?.name)
            .fontSize(14)
            .fontWeight(500)
            .fontColor($r('sys.color.font_primary'))
            .lineHeight(20);
          if (this.showGoodContent) {
            Text(this.good?.content)
              .fontSize(10)
              .lineHeight(14)
              .fontColor($r('sys.color.mask_tertiary'))
              .margin({ top: 2 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis });
          }
          Text(Number(this.good?.sales) > 100 ? $r('app.string.sales_more') :
          $r('app.string.month_sale', this.good?.sales))
            .fontSize(10)
            .lineHeight(14)
            .fontColor($r('sys.color.mask_tertiary'))
            .margin({ top: 2 });
        }.alignItems(HorizontalAlign.Start)

        Row() {
          Row() {
            Text() {
              Span($r('app.string.currency_symbol'))
                .fontSize(8)
                .fontWeight(500)
                .fontColor($r('sys.color.font_primary'))
                .lineHeight(14);
              Span(`${Number(this.good?.money)}`)
                .fontSize(14)
                .fontWeight(500)
                .fontColor($r('sys.color.font_primary'))
                .lineHeight(20);
            };
          };

          Row() {
            Text(this.good?.specType === GoodSpecEnum.PACKAGE_TYPE ? $r('app.string.select_package') :
            $r('app.string.select_spec'))
              .fontSize(10)
              .fontColor($r('sys.color.white'))
              .padding({
                top: 5,
                bottom: 5,
                left: 8,
                right: 8,
              });
          }
          .borderRadius(14)
          .backgroundColor($r('app.color.mainColor'))
          .onClick(() => {
            if (this.good?.specType === GoodSpecEnum.PACKAGE_TYPE) {
              this.goGoodDetail();
              return;
            }
            this.specSheetFlag = true;
          });
        }.margin({ top: 6 }).width(Constants.FULL_SIZE).height(22).justifyContent(FlexAlign.SpaceBetween);

      }
      .layoutWeight(1)
      .height(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ left: 5.5, top: 1, bottom: 1 })
      .alignItems(HorizontalAlign.Start)
      .onAreaChange((oldValue, newValue) => {
        if (newValue.width && oldValue.width !== newValue.width) {
          this.goodTextWidth = Number(newValue.width);
          this.goodChange();
        }
      })
    }
    .alignItems(VerticalAlign.Top)
    .width(Constants.FULL_SIZE)
    .height(80)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => {
      this.goGoodDetail();
    })
    .bindSheet($$this.specSheetFlag, SpecSheetBuilder(this.good, () => {
      this.specSheetFlag = false
    }), {
      height: 500,
      blurStyle: BlurStyle.Thick,
      showClose: false,
    });
  }
}