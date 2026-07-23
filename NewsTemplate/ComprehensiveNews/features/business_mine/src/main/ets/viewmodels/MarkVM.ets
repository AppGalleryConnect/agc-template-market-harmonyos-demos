import { emitter } from '@kit.BasicServicesKit';
import { BaseViewModel, LoadingModel, PopViewUtils, EventEnum, BreakpointType } from 'lib_common';
import { MineServiceApi, NewsModel, NewsResponse } from 'lib_news_api';
import { cancelDialogBuilder, CancelDialogParams } from '../components/CancelDialogBuilder';

@ObservedV2
export class MarkViewModel extends BaseViewModel {
  @Trace list: NewsModel[] = [];
  @Trace loadingModel: LoadingModel<NewsResponse[]> = new LoadingModel(MineServiceApi.queryMyMarks);
  public lanesMap: BreakpointType<number> = new BreakpointType<number>({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 3,
  });

  constructor() {
    super();
    this.queryList();
  }

  queryList(showLoading: boolean = true) {
    this.loadingModel.callApi({
      pageLoading: showLoading,
      dialogLoading: false,
    }).then((list) => {
      this.list = list.map(v => new NewsModel(v))
    })
  }

  async cancelMark(v: NewsModel) {
    await MineServiceApi.cancelMark(v.id);
    PopViewUtils.closePopView();
    this.contextModel.showToast({ message: '取消收藏成功' });
    this.queryList(false);
    emitter.emit(EventEnum.INTERACTION_RECOMMEND_REFRESH)
  }

  popDialog(v: NewsModel) {
    PopViewUtils.showPopView(wrapBuilder(cancelDialogBuilder), {}, {
      btnText: '取消收藏',
      onCancel: () => {
        this.cancelMark(v);
      },
    } as CancelDialogParams);
  }
}