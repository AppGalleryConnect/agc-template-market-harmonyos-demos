import { NavRouterInfo, queryDigitalNewsList, queryNewsSourceList, RouterModule } from 'lib_foundation';
import { RouterMap } from '../common/Constant';
import { NewsArea } from '../model/NewsArea';
import { NewsPage } from '../model/NewspaperPage';
import { NewsSource } from '../model/NewsSource';

@ObservedV2
export class ENewsViewModel {
  // 报纸版面列表
  @Trace newspaperPages: NewsPage[] = [];
  // 报纸来源列表
  @Trace newsSourceList: NewsSource[] = [];
  // 所选择的日期
  @Trace selectDate: Date = new Date();
  // 所选择的报纸来源
  @Trace selectNewsSource: NewsSource = new NewsSource();

  queryNewsSourceList() {
    return queryNewsSourceList().then((list) => {
      this.newsSourceList = list as NewsSource[];
      if (list.length) {
        this.selectNewsSource = list[0] as NewsSource;
      }
    })
  }

  queryNewspaperPages() {
    const sourceId = this.selectNewsSource.id;
    const publishDate = this.selectDate.getTime();
    return queryDigitalNewsList(sourceId, publishDate)
      .then((resp) => {
        const list = resp as NewsPage[];
        this.newspaperPages = list;
      })
  }

  // 日期变化回调
  onDateChange(date: Date) {
    this.selectDate = date;
    this.queryNewspaperPages();
  }

  // 新闻来源变化回调
  onNewsSourceChange(source: NewsSource) {
    this.selectNewsSource = source;
    this.queryNewspaperPages();
  }

  // 新闻区域点击回调
  jumpNewsDetail(area: NewsArea) {
    const routerParams: NavRouterInfo = {
      url: RouterMap.NEWS_DETAIL,
      param: area.newsId,
    };
    RouterModule.push(routerParams);
  }
}