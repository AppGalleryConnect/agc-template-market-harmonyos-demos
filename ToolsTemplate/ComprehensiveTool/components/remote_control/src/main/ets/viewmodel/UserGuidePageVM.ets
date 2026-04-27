import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';
import { RemoteApi } from '../http/Api';
import { ControlInfo, BrandParam, InfraredInfo, MyControl } from '../model/Index';
import { getInstance } from '../components/RouteModule';

@ObservedV2
export class UserGuidePageVM {
  @Trace myControl: MyControl = PersistenceV2.connect<MyControl>(MyControl, () => new MyControl())!;
  @Trace controlInfo: ControlInfo = AppStorageV2.connect<ControlInfo>(ControlInfo, () => new ControlInfo())!;
  @Trace isDialogShow: boolean = false;
  // 步骤位置记录
  @Trace curentIndex: number = 0;
  // 当前页面次数记录
  @Trace tryCount: number = 1;
  // 品牌信息
  @Trace brandParam: BrandParam | undefined = undefined;
  @Trace protocolList: InfraredInfo[] = [];
  private static _instance: UserGuidePageVM;

  public static get instance() {
    if (!UserGuidePageVM._instance) {
      UserGuidePageVM._instance = new UserGuidePageVM();
    }
    return UserGuidePageVM._instance;
  }

  public initData() {
    this.curentIndex = 0;
    this.tryCount = 1;
    AppStorageV2.remove<ControlInfo>(ControlInfo);
    const id: string = util.generateRandomUUID(false);
    this.controlInfo = AppStorageV2.connect<ControlInfo>(ControlInfo, () => new ControlInfo(id))!;
  }


  // 获取备选协议
  public async getProtocolList() {
    this.brandParam = getInstance().getParamByName('UserGuidePage')[0] as BrandParam | undefined;
    if (this.brandParam) {
      this.protocolList = await RemoteApi.getInfraredByBrand(this.brandParam.brandId);
      // 获取当前协议
      this.controlInfo.protocol = this.protocolList[this.tryCount-1].id;
      // 获取默认名称
      this.controlInfo.name = `${this.brandParam.name}空调`;
    }
  }
}