import { https, TenantInfoResp, TenantResp } from 'network';
import { TenantInfo } from 'type';

@Observed
export class MainPageVM {
  @Track location: string[] = [];
  @Track introduction: string = '';
  @Track tenantInfo: TenantInfo = new TenantInfo();
  private static _instance: MainPageVM;

  public static get instance() {
    if (!MainPageVM._instance) {
      MainPageVM._instance = new MainPageVM();
    }
    return MainPageVM._instance;
  }

  public async init() {
    await this.getTenantInfo();
  }

  public async getTenantInfo() {
    const res: TenantResp = await https.getTenantInfo() as TenantResp;
    if (res.code === 200) {
      this.handleTenantInfo(res.data);
    }
  }

  handleTenantInfo(data: TenantInfoResp) {
    this.tenantInfo = new TenantInfo(data.id, data.appName, data.labelList, data.banner, data.phone, data.address,
      data.position.split(','), data.introduction);
    AppStorage.setOrCreate('tenantInfo', this.tenantInfo);
  }
}
