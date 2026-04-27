import { ToastDialog } from '@hw-agconnect/ui-toast';
import { IServicePoint, RouterModule, RouterMap, HttpApi, BaseViewModel, BreakpointNameEnum } from 'lib_foundation';

@ObservedV2
export class ServicePointPageVM extends BaseViewModel {
  @Trace servicePointList: IServicePoint[] = [];
  @Trace selectedServicePoint: IServicePoint | undefined;

  @Computed
  get listLanes() {
    const currentBreakpoint = this.breakPointModel.currentBreakpoint;
    switch (currentBreakpoint) {
      case BreakpointNameEnum.LG:
      case BreakpointNameEnum.XL:
        return 2;
      default:
        return 1;
    }
  }

  async init() {
    const param = RouterModule.getNavParam<number>({ url: RouterMap.SERVICE_POINT_PAGE })
    this.getServicePointList(param)
  }

  async getServicePointList(id?: number) {
    const resp = await HttpApi.getServicePointList()
    this.servicePointList = resp;
    if (id) {
      this.selectedServicePoint = this.servicePointList.find((item) => item.id === id);
    } else {
      this.selectedServicePoint = resp[0];
    }
  }

  save() {
    ToastDialog.showToast({ message: '保存成功！'});
    RouterModule.pop(this.selectedServicePoint)
  }
}
