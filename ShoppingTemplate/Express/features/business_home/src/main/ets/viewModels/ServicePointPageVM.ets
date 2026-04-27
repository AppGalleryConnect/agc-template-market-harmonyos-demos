import { emitter } from '@kit.BasicServicesKit';
import { getServicePointList, IServicePoint, RouterModule } from 'lib_foundation';
import { Logger, RouterMap, toastUtil } from 'module_base';


@ObservedV2
export class ServicePointPageVM {
  private static _instance: ServicePointPageVM;
  @Trace public servicePointList: IServicePoint[] = []
  @Trace public selectedServicePoint: IServicePoint | undefined

  public static get instance() {
    if (!ServicePointPageVM._instance) {
      ServicePointPageVM._instance = new ServicePointPageVM();
    }
    return ServicePointPageVM._instance;
  }

  public async init() {
    const param = RouterModule.getNavParam<number>({ url: RouterMap.SERVICE_POINT_PAGE })
    this.getServicePointList(param)
  }

  public async getServicePointList(id?: number) {
    const res = await getServicePointList()
    this.servicePointList = res;
    if (id) {
      this.selectedServicePoint = this.servicePointList.find((item) => {
        return item.id === id
      })
    } else {
      this.selectedServicePoint = res[0]
    }
  }

  public save() {
    RouterModule.pop()
    let servicePoint: emitter.EventData = {
      data: this.selectedServicePoint,
    };
    try {
      emitter.emit('servicePoint', servicePoint);
    } catch (e) {
      Logger.error(JSON.stringify(e))
    }
    toastUtil.showToast('保存成功！');
  }
}
