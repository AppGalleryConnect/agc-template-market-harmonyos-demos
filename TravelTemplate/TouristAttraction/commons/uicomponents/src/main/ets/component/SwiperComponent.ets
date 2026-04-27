@Builder
export function SwiperComponent(data: IDataSource) {
  Swiper() {
    LazyForEach(data, (item: ResourceStr) => {
      Image(item).size({ width: '100%', height: 240 });
    }, (item: string) => item);
  }.cachedCount(1).gesture(
    LongPressGesture({ repeat: true, duration: 400 })
      // 由于repeat设置为true，长按动作存在时会连续触发，触发间隔为duration（默认值500ms）
      .onAction((event: GestureEvent) => {
        return true;
      })
      .onActionEnd((event: GestureEvent) => {
      }),
  );
}