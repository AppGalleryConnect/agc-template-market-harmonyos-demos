import { NewsArea } from './NewsArea';

/**
 * 报纸模型
 */
export class NewsPage {
  id: number = 0
  newsImg: string = ''
  preloadImg?: PixelMap | undefined = undefined
  newsName: string = ''
  position: string = ''
  width?: string = ''
  height?: string = ''
  paperId: number = 0
  paperTime: string = ''
}

/**
 * 带有新闻区域的报纸模型
 */
export class NewsPageWithAreaInfo {
  id: number = 0
  newsImg: string = ''
  preloadImg: PixelMap | undefined = undefined
  newsName: string = ''
  width: string = ''
  height: string = ''
  paperId: number = 0;
  paperTime: string = ''
  newsAreas: NewsArea[] = [];

  constructor(item?: NewsPage) {
    if (!item) {
      return;
    }
    this.id = item.id;
    this.newsImg = item.newsImg;
    this.preloadImg = item.preloadImg;
    this.newsName = item.newsName;
    this.width = item.width ?? '';
    this.height = item.height ?? '';
    this.paperId = item.paperId
    this.paperTime = item.paperTime;
    this.newsAreas = this.getNewsAreaList(item.position);
  }

  /**
   * 计算新闻区域信息
   * @param position
   * @returns
   */
  getNewsAreaList(position: string): NewsArea[] {
    const areaStrList = position.split('||');

    return areaStrList.map((v: string) => {
      const children = v.split(',,');
      const positions = children[0].split(',').map(v => Number(v));

      const area = new NewsArea();
      area.newsId = children[2];
      area.title = children[3];
      area.newsUrl = children[1];
      area.left = positions[0] / Number(this.width);
      area.top = positions[1] / Number(this.height);
      area.right = positions[2] / Number(this.width);
      area.bottom = positions[5] / Number(this.height);

      return area;
    })
  }
}
