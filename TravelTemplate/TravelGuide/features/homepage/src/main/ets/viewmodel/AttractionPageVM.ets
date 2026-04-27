import { AppStorageV2 } from '@kit.ArkUI'
import { PostInfo, MyPostList } from 'common_travel_guide'
import { attractionRecommendList, attractionLatestList } from '../common/mock/PostDetailMockData'

// DataSource for LazyForEach
export class PostInfoDataSource implements IDataSource {
  private listeners: DataChangeListener[] = []
  private originDataArray: PostInfo[] = []

  constructor(dataArray: PostInfo[]) {
    this.originDataArray = dataArray
  }

  totalCount(): number {
    return this.originDataArray.length
  }

  getData(index: number): PostInfo {
    return this.originDataArray[index]
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener)
    if (pos >= 0) {
      this.listeners.splice(pos, 1)
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded()
    })
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index)
    })
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index)
    })
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index)
    })
  }

  updateData(dataArray: PostInfo[]): void {
    this.originDataArray = dataArray
    this.notifyDataReload()
  }

  updateItem(index: number, item: PostInfo): void {
    if (index >= 0 && index < this.originDataArray.length) {
      this.originDataArray[index] = item
      this.notifyDataChange(index)
    }
  }

  getDataArray(): PostInfo[] {
    return this.originDataArray
  }
}

@ObservedV2
export class AttractionPageVM {
  @Trace searchContent: string = ''
  @Trace currentCity: string = '南京'
  @Trace placeName: string = ''
  @Trace locationPermission: boolean = false

  // 连接 MyPostList 以监听发布的新帖子
  @Trace myPostList: MyPostList = AppStorageV2.connect(MyPostList, () => new MyPostList())!

  // DataSource for LazyForEach - 使用 @Trace 确保响应式
  @Trace recommendDataSource: PostInfoDataSource = new PostInfoDataSource([])
  @Trace latestDataSource: PostInfoDataSource = new PostInfoDataSource([])

  // 推荐/最新列表数据（使用mock数据）
  @Trace recommendList: PostInfo[] = attractionRecommendList

  // 最新列表数据（使用mock数据）
  @Trace latestList: PostInfo[] = attractionLatestList

  constructor() {
    this.updateRecommendList()
    this.updateLatestList()
  }

  // 更新推荐列表，合并 MyPostList 和原有数据
  updateRecommendList() {
    const mergedList: PostInfo[] = [...this.myPostList.list, ...this.recommendList]
    this.recommendDataSource.updateData(mergedList)
  }

  // 更新最新列表，合并 MyPostList 和原有数据
  updateLatestList() {
    const mergedList: PostInfo[] = [...this.myPostList.list, ...this.latestList]
    this.latestDataSource.updateData(mergedList)
  }

  // 监听 MyPostList.updateCount 的变化（当添加新帖子时触发）
  @Monitor('myPostList.updateCount')
  onMyPostListChange() {
    this.updateRecommendList()
    this.updateLatestList()
  }
}



