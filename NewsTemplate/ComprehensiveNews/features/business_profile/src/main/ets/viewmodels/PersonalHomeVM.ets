import { emitter } from '@kit.BasicServicesKit';
import { BaseViewModel, BreakpointType, CircleButtonModifier, RouterMap, RouterUtils, EventEnum } from 'lib_common';
import { AuthorModel, AuthorServiceApi, BaseNewsServiceApi } from 'lib_news_api';
import { LayoutNewsDataSource } from '../common/DataSource';
import { ListModel } from '../common/ListModel';


@ObservedV2
export class PersonalPageViewModel extends BaseViewModel {
  @Trace userId: string = '';
  @Trace userInfo: AuthorModel | null = null;
  @Trace showInfoTop: boolean = false;
  @Trace curIndex: number = 0;
  @Trace targetIndex: number = 0;
  @Trace loading: boolean = false;
  @Trace userLoading: boolean = false;
  @Trace articleDataSource: LayoutNewsDataSource = new LayoutNewsDataSource();
  @Trace videoDataSource: LayoutNewsDataSource = new LayoutNewsDataSource();
  @Trace postDataSource: LayoutNewsDataSource = new LayoutNewsDataSource();
  @Trace dataSource: ListModel[] = [
    new ListModel(this.articleDataSource),
    new ListModel(this.videoDataSource),
    new ListModel(this.postDataSource),
  ];
  buttonModifier: CircleButtonModifier = new CircleButtonModifier();
  columnOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 3,
  });

  async init(showLoading: boolean = true) {
    this.userId = RouterUtils.getParamByName(RouterMap.PROFILE_HOME) as string || this.userInfoModel.authorId;
    await this.queryAuthorInfo(showLoading);
    await this.queryArticleList();
    await this.queryVideoList();
    await this.queryPostList();
  }

  private onPostRefreshCallback: () => void = () => {
    this.queryPostList();
  };

  onRefreshPost() {
    emitter.on(EventEnum.INTERACTION_RECOMMEND_REFRESH, this.onPostRefreshCallback);
  }

  offRefreshPost() {
    emitter.off(EventEnum.INTERACTION_RECOMMEND_REFRESH, this.onPostRefreshCallback);
  }

  async onRefreshing() {
    this.loading = true;
    await this.init(false);
    this.loading = false;
  }

  async queryAuthorInfo(showLoading: boolean = true) {
    if (showLoading) {
      this.userLoading = true;
    }
    await AuthorServiceApi.queryAuthorInfo(this.userId)
      .then((user) => {
        if (user) {
          this.userInfo = new AuthorModel(user);
        }
      })
      .finally(() => {
        this.userLoading = false;
      });

  }

  async queryArticleList() {
    const list = await BaseNewsServiceApi.queryAuthorArticles(this.userId);
    this.articleDataSource.setData(list);
    this.dataSource[0].count = list.length;
  }

  async queryVideoList() {
    const list = await BaseNewsServiceApi.queryAuthorVideos(this.userId);
    this.videoDataSource.setData(list);
    this.dataSource[1].count = list.length;
  }

  async queryPostList() {
    const list = await BaseNewsServiceApi.queryAuthorPosts(this.userId);
    list.forEach((item) => {
      item.extraInfo.showUserBar = false;
      item.extraInfo.showTimeBottom = true;
      item.extraInfo.authorId = this.userId
    })
    this.postDataSource.setData(list);
    this.dataSource[2].count = list.length;
  }

  jumpChatPage() {
    RouterUtils.pushPathByName(RouterMap.MINE_MSG_IM_CHAT, this.userInfo);
  }

  getColumnsTemplate() {
    const columns = this.columnOptions.getValue(this.breakPointModel.currentBreakpoint);
    return Array(columns).fill('1fr').join(' ');
  }

  @Computed
  get isMyself() {
    return this.userInfoModel.authorId === this.userInfo?.authorId;
  }

  @Computed
  get authorNameMaxWidth() {
    let width = 24 + 8 + 12;

    if (!this.isMyself) {
      width += 72;
      width += 16;
      width += 4;
    }

    return width;
  }
}