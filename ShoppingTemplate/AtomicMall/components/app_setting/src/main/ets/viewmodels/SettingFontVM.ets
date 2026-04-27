import { ToastDialog } from '@hw-agconnect/ui-toast';
import { fp2pxUtil } from '../common/FontUtils';
import { BaseViewModel } from '../models/BaseViewModel';

@ObservedV2
export class SettingFontViewModel extends BaseViewModel {
  @Trace currentRatio: number = this.fontModel.fontSizeRatio;
  @Trace uiContext: UIContext | null = null;

  confirm(ratio: number) {
    this.currentRatio = ratio;
    this.fontModel.fontSizeRatio = ratio;
    ToastDialog.showToast({ message: '字号设置已成功' });
  }

  setUIContext(uiContext: UIContext) {
    this.uiContext = uiContext;
  }

  getDescFg(fg: number): number | string {
    return fp2pxUtil(fg);
  }
}
