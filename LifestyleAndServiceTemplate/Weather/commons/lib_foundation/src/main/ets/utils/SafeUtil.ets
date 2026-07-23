import { PersistenceV2 } from '@kit.ArkUI';
import { FLAG_SHOW_ADS } from '../constants/AppConfig';
import { RouterMap } from '../constants/RouterMap';
import { PopViewUtils } from './PopViewUtils';
import { RouterModule } from './RouterModule';

@ObservedV2
class SafeModel {
  @Trace agreed: boolean = false;
}

@ObservedV2
export class SafeUtil {
  private static _safeInfo: SafeModel = PersistenceV2.connect(SafeModel, 'safeInfo', () => new SafeModel())!;
  static showAd: boolean = FLAG_SHOW_ADS;

  public static setAgreed() {
    SafeUtil._safeInfo.agreed = true;
    PopViewUtils.closePopView();
    RouterModule.replace({ url: SafeUtil.showAd ? RouterMap.SPLASH_AD : RouterMap.MAIN })
  }

  public static getAgreed() {
    return SafeUtil._safeInfo.agreed;
  }
}

