import { BreakpointModel, BreakpointType } from '../models/BreakpointModel';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct Banner {
  @Param bannerArray: Array<ResourceStr> = [
    $r('app.media.ic_banner01'),
    $r('app.media.ic_banner02'),
    $r('app.media.ic_banner01'),
    $r('app.media.ic_banner02')
  ];
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  // banner 显示个数
  swiperDisplayCount: BreakpointType<number> = new BreakpointType<number>({
    sm: 1,
    md: 2,
    lg: 2,
    xl: 2,
  });

  build() {
    Column() {
      Swiper() {
        ForEach(this.bannerArray, (item: ResourceStr) => {
          Image(item)
            .interpolation(ImageInterpolation.High)
            .objectFit(ImageFit.Fill)
            .draggable(false)
            .borderRadius(16)
            .margin({ left: 6, right: 6 })
            .width(new BreakpointType<number>({
              sm: 328,
              md: 336,
              lg: 496,
              xl: 496
            }).getValue(this.breakpointModel.currentBreakpoint))
            .height(new BreakpointType<number>({
              sm: 184,
              md: 189,
              lg: 279,
              xl: 279
            }).getValue(this.breakpointModel.currentBreakpoint));
        }, (item: string, index: number) => item + index);
      }
      .indicator(false)
      .nextMargin(new BreakpointType<number>({
        sm: 0,
        md: 0,
        lg: 120,
        xl: 120
      }).getValue(this.breakpointModel.currentBreakpoint))
      .loop(true)
      .autoPlay(true)
      .displayCount(this.swiperDisplayCount.getValue(this.breakpointModel.currentBreakpoint))
      .layoutWeight(1);
    }
    .width('100%')
    .height(new BreakpointType<number>({
      sm: 159,
      md: 189,
      lg: 279,
      xl: 279
    }).getValue(this.breakpointModel.currentBreakpoint));
  }
}