import { AppStorageV2 } from '@kit.ArkUI';
import { SearchImgType } from '../common/model';
import { PostInfo, MyPostList } from 'common_travel_guide';
import { PostInfoDataSource } from './AttractionPageVM';
import { homePagePostList } from '../common/mock/PostDetailMockData';

@ObservedV2
export class MainPageVM {
  @Trace classificationList: SearchImgType[] =
    [{ img: $r('app.media.icon_hotel'), text: '酒店' }, { img: $r('app.media.ic_air_ticket'), text: '机票' },
      { img: $r('app.media.ic_train_ticket'), text: '火车票' }, { img: $r('app.media.ic_travel'), text: '旅游' },
      { img: $r('app.media.ic_attraction'), text: '景点/攻略' }];

  // 连接 MyPostList 以监听发布的新帖子（使用 @Trace 确保响应式）
  @Trace myPostList: MyPostList = AppStorageV2.connect(MyPostList, () => new MyPostList())!

  // 首页瀑布流数据源
  @Trace homePostDataSource: PostInfoDataSource = new PostInfoDataSource([])
  @Trace homePostList: PostInfo[] = homePagePostList

  constructor() {
    this.updateHomePostList()
  }

  // 更新首页帖子列表，合并 MyPostList 和 homePagePostList
  updateHomePostList() {
    // 将 MyPostList 的帖子放在最前面，然后添加原有的首页帖子
    const mergedList: PostInfo[] = [...this.myPostList.list, ...this.homePostList]
    this.homePostDataSource.updateData(mergedList)
  }

  // 监听 MyPostList.updateCount 的变化（当添加新帖子时触发）
  @Monitor('myPostList.updateCount')
  onMyPostListChange() {
    this.updateHomePostList()
  }
}