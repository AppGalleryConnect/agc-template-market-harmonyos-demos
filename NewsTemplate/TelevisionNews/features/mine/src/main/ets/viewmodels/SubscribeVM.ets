import { ValueType } from '@kit.ArkData';
import { BaseViewModel, BreakpointType, RouterMap, RouterUtils } from 'lib_common';
import { AvModel, AvResponse, MineServiceApi } from 'lib_tv_apis';
import { SubscribeDataSource } from '../common/DataSource';


@ObservedV2
export class SubscribeViewModel extends BaseViewModel {
  @Trace mySubscribe: AvResponse[] = []
  @Trace userId: string = ''
  @Trace emptyTip: string = '暂无订阅';
  @Trace dataSource: SubscribeDataSource = new SubscribeDataSource();
  columnOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 3,
  });

  @Computed
  get hasSubscribe() {
    return !!this.dataSource.getAllData().length && this.dataSource.getAllData().some(v => v.isFollow)
  }

  async init() {
    this.userId = RouterUtils.getParamByName(RouterMap.SETTING_SUBSCRIBE) as string;
    this.querySubscribe();
  }

  async querySubscribe() {
    MineServiceApi.queryMySubscribe(this.userId ?? '').then((list: AvModel[]) => {
      const result = list.map(v => new AvModel(v));
      this.dataSource.setData(result);
    });
  }

  public pushToAvDetails(cardData: Record<string, ValueType>) {
    let params: Record<string, ValueType | undefined> = {
      'avId': cardData.id,
      'isCreateSubWindow': cardData.isCreateSubWindow,
    }
    RouterUtils.pushPathByName(RouterMap.VIDEO_PROGRAM_DETAILS, params)
  }

  getColumnsTemplate() {
    const columns = this.columnOptions.getValue(this.breakPointModel.currentBreakpoint);
    return Array(columns).fill('1fr').join(' ');
  }

  subscribeOperation(v: AvModel) {
    v.isFollow ? this.cancelSubscribe(v) : this.addSubscribe(v)
  }

  cancelSubscribe(v: AvModel) {
    MineServiceApi.cancelSubscribeWatch(v.id);
    v.isFollow = !v.isFollow
  }

  addSubscribe(v: AvModel) {
    MineServiceApi.AddSubscribeWatch(v.id)
    v.isFollow = !v.isFollow
  }

  setSubscribe(v: AvModel) {
    let cap = this.dataSource.getAllData().find(item => item.id === v.id)
    if (cap) {
      cap.isFollow = v.isFollow
    }
  }

  cancelSubscribeAll() {
    if (!this.hasSubscribe) {
      return
    }
    MineServiceApi.cancelAllSubscribe()
    this.dataSource.getAllData().forEach(v => v.isFollow = false)
  }
}