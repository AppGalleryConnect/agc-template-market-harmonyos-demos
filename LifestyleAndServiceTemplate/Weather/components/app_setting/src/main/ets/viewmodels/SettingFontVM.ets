import { FontUtil } from 'lib_foundation';
import { fp2pxUtil } from '../common/FontUtils';
import { BaseViewModel } from '../models/BaseViewModel';

@ObservedV2
export class SettingFontViewModel extends BaseViewModel {
  @Trace currentRatio: number = FontUtil.getRate();
  @Trace uiContext: UIContext | null = null;

  setUIContext(uiContext: UIContext) {
    this.uiContext = uiContext;
  }

  getDescFg(fg: number): number | string {
    return fp2pxUtil(fg);
  }
}