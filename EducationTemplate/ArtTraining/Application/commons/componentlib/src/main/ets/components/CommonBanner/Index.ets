import { util } from '@kit.ArkTS';
import { WindowUtil } from 'commonlib';


@ComponentV2
export struct CommonBanner {
  // 图片展示比例
  @Param coverRatio: number = 16 / 9;
  // 图片列表
  @Param covers: ResourceStr[] = [];
  @Local
  private _swiperHeight: number = 0;
  @Local
  private _swiperBottomAnchor: number = 0;
  private readonly _ID: string = util.generateRandomUUID(false);
  @Event handleClick: (index: number) => void;

  async aboutToAppear() {
    let screenWidth: number = WindowUtil.display.width;
    let topAvoidHeight: number = WindowUtil.avoidAreaSize.top;
    this._swiperHeight = px2vp(screenWidth / this.coverRatio);
    this._swiperBottomAnchor = this._swiperHeight - topAvoidHeight;
  }

  build() {
    RelativeContainer() {
      Column()
        .height(this._swiperBottomAnchor)
        .width('100%')
        .id(this._ID);
      Swiper() {
        ForEach(this.covers && this.covers.length > 0 ? this.covers : [''],
          (item: ResourceStr, index: number) => {
            Image(item)
              .width($r('app.string.width_percent_full'))
              .objectFit(ImageFit.Cover)
              .height(this._swiperHeight)
              .aspectRatio(this.coverRatio)
              .onClick(() => {
                this.handleClick?.(index);
              })
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
          },
          (item: ResourceStr, index: number) => index + JSON.stringify(item),
        );
      }
      .width('100%')
      .autoPlay(true)
      .interval(3500)
      .indicator(this.covers && this.covers.length > 1 ?
      new DotIndicator()
        .color('#80FFFFFF')
        .selectedColor($r('sys.color.navigation_drag_bar_item_default'))
        .itemWidth(4)
        .itemHeight(4)
        .selectedItemWidth(12)
        .selectedItemHeight(4) :
        false,
      )
      .loop(true)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
      .alignRules({
        'bottom': { 'anchor': this._ID, 'align': VerticalAlign.Bottom },
        'left': { 'anchor': this._ID, 'align': HorizontalAlign.Start },
      });
    }
    .width('100%')
    .height('auto');
  }
}