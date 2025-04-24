import { AccountUtil } from 'account';
import { ContactInfo, UserInfo } from 'types';
import { HotlineUtil, Logger } from 'common';
import { AppStorageV2 } from '@kit.ArkUI';
import { HOTLINE_DATA, HotlineInfo } from '../model/HotlineInfo';

@ObservedV2
export class MineVM {
  @Trace userInfo: UserInfo = AccountUtil.getUserInfo();
  @Trace contactInfo: ContactInfo = AppStorageV2.connect(ContactInfo, 'contactInfo', () => new ContactInfo())!;
  public static _instance: MineVM;

  public static get instance() {
    if (!MineVM._instance) {
      MineVM._instance = new MineVM();
    }
    return MineVM._instance;
  }

  mapContactInfo() {
    let hotlines = [HotlineUtil.getConsultPhone(), HotlineUtil.getRescuePhone(), HotlineUtil.getComplaintPhone()];

    HOTLINE_DATA.map((item: HotlineInfo, index: number) => {
      item.phone = hotlines[index];
    });

    Logger.info('Hotlines info is ' + JSON.stringify(HOTLINE_DATA));
  }
}