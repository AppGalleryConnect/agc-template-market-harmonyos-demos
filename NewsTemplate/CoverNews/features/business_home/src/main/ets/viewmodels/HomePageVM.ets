import { BaseViewModel, HttpServiceApi, NewsItem } from 'lib_common';

@ObservedV2
export class HomePageVM extends BaseViewModel {
  @Trace public newsList: NewsItem[] = [];
  @Trace public currentIndex: number = 0;
  public swiperController: SwiperController = new SwiperController();

  public async queryNewsList(): Promise<void> {
    const list = await HttpServiceApi.queryNewsList()
    this.newsList = list.map(v => NewsItem.create(v));
  }
}