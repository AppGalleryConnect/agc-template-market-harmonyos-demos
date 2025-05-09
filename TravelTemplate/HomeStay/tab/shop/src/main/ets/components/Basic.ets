import { Constants } from 'constant';
import { Commodity } from 'type';

@Component
export struct Basic {
  private swiperController: SwiperController = new SwiperController();
  @Prop commodity: Commodity;

  build() {
    Column() {
      Swiper(this.swiperController) {
        ForEach(this.commodity.detailImages, (item: ResourceStr) => {
          Image(item).objectFit(ImageFit.Contain).width(Constants.FULL_SCREEN);
        }, (item: ResourceStr) => item.toString());
      }.indicator(new DotIndicator()
        .itemWidth(6)
        .itemHeight(6)
        .selectedItemWidth(12)
        .selectedItemHeight(6)
        .color($r('app.color.common_bg_color'))
        .selectedColor($r('sys.color.comp_background_emphasize')));

      Column() {
        Row() {
          Text(`￥${this.commodity.retailPrice[0]}`).fontSize(16).fontColor(Color.Red).fontWeight(600);
          Text('运费 免邮').fontSize(10).fontColor(Color.Gray);
        }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.SpaceBetween).margin({ top: 12 });

        Text(`${this.commodity.goodsName}`).fontSize(14).margin({ top: 6 }).fontWeight(500);
      }.width(Constants.FULL_SCREEN).alignItems(HorizontalAlign.Start).padding({ left: 12, right: 12 });
    };
  }
}