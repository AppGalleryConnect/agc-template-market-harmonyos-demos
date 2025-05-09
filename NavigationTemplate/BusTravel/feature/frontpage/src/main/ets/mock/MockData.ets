import {
  newsItem,
  SwiperInterface,
  HotNewsSegmentInterface,
  LostFindSegmentInterface,
  NewsDetailSegmentInterface
} from '../model/Interface'

export const swiperData: Array<SwiperInterface> = [
  {
    id: '001',
    image: $r('app.media.swiper_1')
  },
  {
    id: '002',
    image: $r('app.media.swiper_1')
  },
  {
    id: '003',
    image: $r('app.media.swiper_1')
  }
]

export const newsData: Array<newsItem> = [
  {
    id: '001',
    image: $r('app.media.newimage_1'),
    title: $r('app.string.news_item_title_1'),
    time: $r('app.string.news_item_time_1')
  },
  {
    id: '002',
    image: $r('app.media.newimage_1'),
    title: $r('app.string.news_item_title_2'),
    time: $r('app.string.news_item_time_2')
  },
  {
    id: '003',
    image: $r('app.media.newimage_1'),
    title: $r('app.string.news_item_title_3'),
    time: $r('app.string.news_item_time_3')
  }
]

export const hotNewsPiece: Array<HotNewsSegmentInterface> = [
  {
    id: '001',
    image: $r('app.media.news_hotimage_1'),
    title: $r('app.string.hot_news_title_1'),
    time: $r('app.string.hot_news_time_1'),
    visit: $r('app.string.hot_news_visit_1')
  },
  {
    id: '002',
    image: $r('app.media.news_hotimage_1'),
    title: $r('app.string.hot_news_title_2'),
    time: $r('app.string.hot_news_time_2'),
    visit: $r('app.string.hot_news_visit_2')
  },
  {
    id: '003',
    image: $r('app.media.news_hotimage_1'),
    title: $r('app.string.hot_news_title_3'),
    time: $r('app.string.hot_news_time_3'),
    visit: $r('app.string.hot_news_visit_3')
  }
]

export const lostFindPiece: Array<LostFindSegmentInterface> = [
  {
    id: '001',
    time: $r('app.string.lost_find_time_1'),
    type: $r('app.string.lost_find_type_1'),
    line: $r('app.string.lost_find_line_1'),
    description: $r('app.string.lost_find_description_1'),
    image: $r('app.media.newimage_1')
  },
  {
    id: '002',
    time: $r('app.string.lost_find_time_2'),
    type: $r('app.string.lost_find_type_2'),
    line: $r('app.string.lost_find_line_2'),
    description: $r('app.string.lost_find_description_2'),
    image: $r('app.media.newimage_1')
  }
]

export const newsDetailPiece: NewsDetailSegmentInterface[] = [
  {
    title: $r('app.string.news_detail_title'),
    time: $r('app.string.news_detail_time'),
    visit: $r('app.string.news_detail_visit'),
    image: $r('app.media.newimage_1'),
    subtitle: $r('app.string.news_detail_subtitle'),
    content: $r('app.string.news_detail_content'),
  }
]