@Builder
export function SwiperComponent(data: IDataSource) {
  Swiper() {
    LazyForEach(data, (item: ResourceStr) => {
      Image(item).size({ width: '100%', height: 240 })
    }, (item: string) => item)
  }.cachedCount(3)
}