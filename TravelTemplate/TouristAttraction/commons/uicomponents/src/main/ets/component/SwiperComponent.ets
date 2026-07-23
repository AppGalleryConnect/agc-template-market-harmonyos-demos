import { ImagePreviewOptions } from 'image_preview';

@Builder
export function SwiperComponent(data: IDataSource, height = 316, options: ImagePreviewOptions,
  onImgClick: (index: number) => void) {
  Swiper() {
    LazyForEach(data, (item: ResourceStr, index: number) => {
      Image(item).size({ width: '100%', height }).id(options.snapshotId(item, index)).onClick(() => {
        onImgClick(index)
      });
    }, (item: string) => item);
  }.cachedCount(1).indicator(
    new DotIndicator().selectedColor($r('sys.color.multi_color_04')),
  ).gesture(
    LongPressGesture({ repeat: true, duration: 400 })
      .onAction((event: GestureEvent) => {
        return true;
      })
      .onActionEnd((event: GestureEvent) => {
      }),
  );
}