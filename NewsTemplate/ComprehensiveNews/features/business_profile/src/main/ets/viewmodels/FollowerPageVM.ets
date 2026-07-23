import { BaseViewModel, BreakpointType, LoadingModel, RouterMap, RouterUtils } from 'lib_common';
import { AuthorModel, AuthorResponse, AuthorServiceApi } from 'lib_news_api';
import { AuthorDataSource } from '../common/DataSource';

@ObservedV2
export class FollowerPageViewModel extends BaseViewModel {
  @Trace userId: string = '';
  @Trace title: string = '我的粉丝';
  @Trace emptyTip: string = '暂无粉丝';
  @Trace dataSource: AuthorDataSource = new AuthorDataSource();
  @Trace loadingModel: LoadingModel<AuthorResponse[], string> = new LoadingModel((userId?: string) => {
    return AuthorServiceApi.queryFollowers(userId ?? '');
  });
  columnOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 3,
  });

  init() {
    this.userId = RouterUtils.getParamByName(RouterMap.PROFILE_FOLLOWER) as string;
    this.title = this.userId === this.userInfoModel.authorId ? '我的粉丝' : '他的粉丝';
    this.queryFollowList();
  }

  queryFollowList() {
    this.loadingModel.callApi({
      pageLoading: true,
      requestParams: this.userId,
    }).then((list) => {
      const result = list.map(v => new AuthorModel(v));
      this.dataSource.setData(result);
    });
  }

  customBack() {
    RouterUtils.pop('refresh');
  }

  getColumnsTemplate() {
    const columns = this.columnOptions.getValue(this.breakPointModel.currentBreakpoint);
    return Array(columns).fill('1fr').join(' ');
  }
}