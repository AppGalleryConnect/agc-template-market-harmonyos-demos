import { util } from '@kit.ArkTS';
import { WindowUtil } from 'commonlib/src/main/ets/utils/WindowUtil';

@ComponentV2
export struct CommonBanner {
  @Param
  private x: number = 16;
  @Param
  private y: number = 9;
  @Param
  private covers: (PixelMap | ResourceStr | DrawableDescriptor)[] | null | undefined = [];
  @Param
  private imageFit: ImageFit = ImageFit.Cover;
  @Param
  private color: ResourceColor = '#FFFFFFFF';
  @Local
  private _swiperHeight: number = 0;
  @Local
  private _swiperBottomAnchor: number = 0;
  private readonly _ID: string = util.generateRandomUUID(false);

  async aboutToAppear() {
    let screenWidth: number = WindowUtil.display.width;
    let topAvoidHeight: number = WindowUtil.avoidAreaSize.top;
    this._swiperHeight = px2vp(screenWidth / this.x * this.y);
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
          (item: ResourceStr) => {
            Image(item)
              .height(this._swiperHeight)
              .width('100%')
              .objectFit(this.imageFit)
              .draggable(false)
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
              .backgroundColor(this.color);
          },
          (item: ResourceStr) => JSON.stringify(item));
      }
      .width('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
      .autoPlay(true)
      .interval(3500)
      .indicator(this.covers && this.covers.length > 1 ?
      new DotIndicator()
        .color('#80FFFFFF')
        .selectedColor('#FFFFFFFF')
        .itemWidth(4)
        .itemHeight(4)
        .selectedItemWidth(12)
        .selectedItemHeight(4) :
        false,
      )
      .loop(true)
      .vertical(false)
      .disableSwipe(false)
      .alignRules({
        'bottom': { 'anchor': this._ID, 'align': VerticalAlign.Bottom },
        'left': { 'anchor': this._ID, 'align': HorizontalAlign.Start },
      })
      .backgroundColor(this.color);
    }
    .width('100%')
    .height('auto');
  }
}