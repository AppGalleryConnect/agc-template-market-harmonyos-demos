import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { SendUtil } from '../util/Index';
import { RemoteApi } from '../http/Api';
import { ControlInfo, MyControl } from '../model/Index';
import { getInstance } from '../components/RouteModule';

@ObservedV2
export class ControllerPageVM {
  @Trace controlInfo: ControlInfo = AppStorageV2.connect<ControlInfo>(ControlInfo, () => new ControlInfo())!;
  @Trace myControl: MyControl = PersistenceV2.connect<MyControl>(MyControl, () => new MyControl())!;
  private static _instance: ControllerPageVM;

  public static get instance() {
    if (!ControllerPageVM._instance) {
      ControllerPageVM._instance = new ControllerPageVM();
    }
    return ControllerPageVM._instance;
  }

  public async getInfraredInfo(data: ControlInfo) {
    const res = await RemoteApi.getInfrared(data);
    SendUtil.sendInfrared(res.frequency, res.pattern);
  }

  public getParam() {
    const param: ControlInfo | undefined = getInstance().getParamByName('ControllerPage')[0] as ControlInfo | undefined;
    if (param) {
      AppStorageV2.remove<ControlInfo>(ControlInfo);
      this.controlInfo = AppStorageV2.connect<ControlInfo>(ControlInfo, () => param)!;
    }
  }

  public updateMyControl(data: ControlInfo) {
    this.myControl.removeControl(data.id);
    this.myControl.addControl(data);
  }
}