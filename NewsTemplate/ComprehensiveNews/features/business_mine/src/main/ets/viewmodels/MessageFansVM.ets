import { BaseViewModel } from 'lib_common';
import { AuthorModel, MessageServiceApi, MineServiceApi } from 'lib_news_api';
import { AuthorDataSource } from '../common/DataSource';

@ObservedV2
export class MsgFansViewModel extends BaseViewModel {
  @Trace fansDataSource: AuthorDataSource = new AuthorDataSource();

  constructor() {
    super();
    this.setAllRead();
    this.queryNewFansList();
  }

  async queryNewFansList() {
    const list = await MineServiceApi.queryNewFans();
    this.fansDataSource.setData(list.map(v => new AuthorModel(v)));
  }

  setAllRead() {
    MessageServiceApi.setNewFansRead();
  }
}