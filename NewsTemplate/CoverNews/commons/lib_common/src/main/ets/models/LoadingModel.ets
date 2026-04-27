import { CommonLoadingDialog } from '../components/LoadingView';

export interface LoadingParams<T> {
  pageLoading?: boolean;
  dialogLoading?: boolean;
  requestParams?: T;
}

@ObservedV2
export class LoadingModel<U, T = Object> {
  @Trace loading: boolean = false;
  private api: (params?: T) => Promise<U>;

  constructor(api: (params?: T) => Promise<U>) {
    this.api = api;
  }

  callApi(params: LoadingParams<T>) {
    if (params.pageLoading) {
      this.loading = true;
    }
    if (params.dialogLoading) {
      CommonLoadingDialog.show();
    }
    return this.api(params.requestParams)
      .then((resp) => {
        return resp;
      })
      .finally(() => {
        this.loading = false;
        CommonLoadingDialog.close();
      })
  }
}