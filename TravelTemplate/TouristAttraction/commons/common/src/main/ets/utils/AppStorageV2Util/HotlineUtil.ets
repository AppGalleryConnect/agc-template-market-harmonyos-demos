import { AppStorageV2 } from '@kit.ArkUI';
import { ContactInfo } from 'types';

@ObservedV2
export class HotlineUtil {
  private static contactInfo: ContactInfo = AppStorageV2.connect(ContactInfo, 'contactInfo', () => new ContactInfo())!;

  static getConsultPhone() {
    return HotlineUtil.contactInfo.consult;
  }

  static getRescuePhone() {
    return HotlineUtil.contactInfo.rescue;
  }

  static getComplaintPhone() {
    return HotlineUtil.contactInfo.complain;
  }
}