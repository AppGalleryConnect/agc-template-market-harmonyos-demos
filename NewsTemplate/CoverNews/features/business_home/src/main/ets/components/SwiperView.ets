import { NewsItem, RouterMap, RouterUtils } from 'lib_common';
import { BigImage } from './BigImage';

@ComponentV2
export struct SwiperView {
  @Param newsList: NewsItem[] = [];
  @Param swiperController: SwiperController = new SwiperController();
  @Event onCurrentIndexChange: (index: number) => void = () => {};
  @Local currentIndex: number = 0;

  build() {
    Swiper(this.swiperController) {
      Repeat(this.newsList)
        .virtualScroll()
        .key((item: NewsItem) => item.id)
        .each((item: RepeatItem<NewsItem>) => {
          BigImage({
            newsItem: item.item,
            onItemTap: (news: NewsItem) => {
              RouterUtils.pushPathByName(RouterMap.NEWS_DETAIL_PAGE, news.id);
            },
          })
        })
    }
    .width('100%')
    .height('100%')
    .vertical(true)
    .loop(true)
    .autoPlay(false)
    .indicator(false)
    .onChange((index: number) => {
      this.currentIndex = index;
      this.onCurrentIndexChange(index);
    })
  }
}