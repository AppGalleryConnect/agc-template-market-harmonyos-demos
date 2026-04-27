export interface INewsItem {
  id: string;
  title: string;
  coverImage: ResourceStr;
  coverImageBg: ResourceStr;
  subtitle: string;
  source: string;
  time: string;
  readCount: number;
  content: string;
  isLiked?: boolean;
}

@ObservedV2
export class NewsItem {
  @Trace id: string = '';
  @Trace title: string = '';
  @Trace coverImage: ResourceStr = '';
  @Trace coverImageBg: ResourceStr = '';
  @Trace subtitle: string = '';
  @Trace source: string = '';
  @Trace time: string = '';
  @Trace readCount: number = 0;
  @Trace content: string = '';
  @Trace isLiked: boolean = false;

  static create(params: INewsItem): NewsItem {
    const item: NewsItem = new NewsItem();
    item.id = params.id;
    item.title = params.title;
    item.coverImage = params.coverImage;
    item.coverImageBg = params.coverImageBg;
    item.subtitle = params.subtitle;
    item.source = params.source;
    item.time = params.time;
    item.readCount = params.readCount;
    item.content = params.content;
    item.isLiked = params.isLiked ?? false;
    return item;
  }
}