import { UIUtils } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { LoginSheetUtils } from 'lib_account';
import { BaseViewModel, RouterParams, RouterToNews, EventEnum, CommonBreakpoint } from 'lib_common';
import { MineServiceApi, NewsResponse, PostQueryRequest, PostServiceApi } from 'lib_news_api';
import { Topic } from 'module_post';
import { LoneTakeAnimationsTransition, LongTakeTransitionParam } from 'module_transition';
import { TabEnum } from '../common/Constants';

@ObservedV2
export class InteractionViewModel extends BaseViewModel {
  private authorId: string = ''
  @Trace isRefreshing: boolean = false
  @Trace interactionList: NewsResponse[] = []
  @Trace resourceId: TabEnum = TabEnum.Watch
  @Trace selectedId: number = 0;
  @Trace isLoading: boolean = false
  @Trace currentIndex: number = 10
  @Trace currentPage: number = 0
  @Trace topic: Topic = { id: '', title: '' }
  private uiContext: UIContext
  private apiMap: Map<number, (params: PostQueryRequest) => Promise<NewsResponse[]>> =
    new Map([[0, PostServiceApi.queryPostFollowList], [1, PostServiceApi.queryPostRecommendList],
      [2, PostServiceApi.queryPostRecommendList], [3, PostServiceApi.queryPostTopicList]])
  public scroller: Scroller = new Scroller();
  @Trace lanesCount: CommonBreakpoint<number> = new CommonBreakpoint<number>({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 3,
  });

  constructor(uiContext: UIContext) {
    super()
    this.uiContext = uiContext
  }

  setAuthorId(authorId: string) {
    this.authorId = authorId
  }

  public isWatch() {
    return this.userInfoModel.isLogin && this.userInfoModel.watchers.includes(this.authorId)
  }

  public init(resourceId: TabEnum) {
    this.resourceId = resourceId
    this.refresh()
  }

  private onRecommendRefresh: () => void = () => {
    if (this.selectedId === TabEnum.Recommend) {
      this.scroller.scrollEdge(Edge.Top);
    }
    this.refresh();
  };

  setOnListenRefresh() {
    emitter.on(EventEnum.INTERACTION_RECOMMEND_REFRESH, this.onRecommendRefresh);
  }

  setTopic(topic: Topic) {
    this.topic = topic;
  }

  setOffListenRefresh() {
    emitter.off(EventEnum.INTERACTION_RECOMMEND_REFRESH, this.onRecommendRefresh);
  }

  // 懒加载id，会根据枚举值进行页面刷新
  public getEachId(newsData: NewsResponse) {
    return [
      newsData.id,
      newsData.likeCount,
      newsData.isLiked,
      newsData.commentCount,
      newsData.markCount,
      newsData.isMarked,
    ]
      .map(value => value?.toString() ?? '')
      .join('+');
  }

  public async setActionData() {
    const actionAPi = this.apiMap.get(this.resourceId)!
    this.interactionList = await actionAPi({
      currentIndex: this.currentIndex,
      currentPage: this.currentPage,
      topicTitle: this.topic.title,
    })
    this.interactionList = this.interactionList.map(item => UIUtils.makeObserved(item))
    this.isRefreshing = false
  }

  public refresh() {
    this.isRefreshing = true
    this.currentIndex = 10;
    this.currentPage = 0;
    this.setActionData()
  }

  public watchOperation() {
    if (!this.userInfoModel.isLogin) {
      LoginSheetUtils.open()
      return
    }
    if (!this.isWatch()) {
      this.addWatch()
      return
    }
    this.cancelWatch()
  }

  public addWatch() {
    this.userInfoModel.watchers.push(this.authorId)
    MineServiceApi.addWatch(this.authorId)
  }

  public cancelWatch() {
    let watchIndex = this.userInfoModel.watchers.findIndex(v => v === this.authorId)
    this.userInfoModel.watchers.splice(watchIndex, 1)
    MineServiceApi.cancelWatch(this.authorId)
  }

  public actionToNewsDetails(cardData: NewsResponse, index: number, resourceId: number, formType?: string,
    isQueryCardData: boolean = false) {
    let params: RouterParams<NewsResponse> = {
      newsId: cardData.id,
      authorId: resourceId === TabEnum.Watch ? cardData.author.authorId : '',
      type: cardData.type,
      surfaceUrl: cardData.postImgList?.[0]?.surfaceUrl,
      cardData: cardData,
      isQueryCardData: isQueryCardData,
      formType: formType ?? '',
    }
    let longTakeTransitionParam: LongTakeTransitionParam | undefined =
      LoneTakeAnimationsTransition.generateLongTakeParam(this.uiContext, 'action_flow' + resourceId + index, 9);
    if (longTakeTransitionParam) {
      params.longTakeTransitionParam = longTakeTransitionParam;
    }
    RouterToNews.pushToNewsDetails<NewsResponse>(params)
  }

  public addLike(cardInfo: NewsResponse) {
    if (!this.userInfoModel.isLogin) {
      LoginSheetUtils.open()
      return
    }
    cardInfo.isLiked = !cardInfo.isLiked
    if (cardInfo.isLiked) {
      MineServiceApi.addLike(cardInfo.id)
      cardInfo.likeCount += 1
      return
    }
    MineServiceApi.cancelLike(cardInfo.id)
    cardInfo.likeCount -= 1
  }

  public emptyToast() {
    this.contextModel.showToast({
      message: '暂无更新数据',
      alignment: Alignment.Bottom,
    })
  }

  public async loadMore() {
    this.isLoading = true
    this.currentPage += 10
    this.currentIndex = this.currentPage + 10
    const actionAPi = this.apiMap.get(this.resourceId)!
    const followList = await actionAPi({
      currentIndex: this.currentIndex,
      currentPage: this.currentPage,
      topicTitle: this.topic.title,
    })
    if (!followList?.length) {
      this.emptyToast()
    } else {
      followList.forEach(item => this.interactionList.push(UIUtils.makeObserved(item)))
    }
    this.isLoading = false
  }
}