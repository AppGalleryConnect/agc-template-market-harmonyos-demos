import { fp2pxUtil } from '../util/FontUtils';
import { FontModel } from './FontModel';
import { AppStorageV2 } from '@kit.ArkUI';

@ObservedV2
export class SettingFontViewModel {
  @Trace fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  @Trace currentRatio: number = this.fontModel.fontSizeRatio;
  @Trace uiContext: UIContext | null = null;

  confirm(ratio: number) {
    this.currentRatio = ratio;
    this.fontModel.fontSizeRatio = ratio;
    this.uiContext?.getPromptAction().showToast({ message: '字号设置已成功' });
  }

  setUIContext(uiContext: UIContext) {
    this.uiContext = uiContext;
  }

  getDescFg(fg: number): number | string {
    return fp2pxUtil(fg);
  }
}