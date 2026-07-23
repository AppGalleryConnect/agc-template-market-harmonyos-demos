import { fp2pxUtil } from './FontUtils';
import { common } from '@kit.AbilityKit';

/**
 * 全局设置
 */
@ObservedV2
export class FontModel {
  @Trace followSystem: boolean = false;
  @Trace fontSizeRatio: number = 1;
  @Trace sysFontSizeScale: number = 1;

  public getFg(fg: number, maxRatio: number = 1.45): number | string {
    if (this.followSystem) {
      return fg;
    }
    return fp2pxUtil(fg * Math.min(this.fontSizeRatio, maxRatio));
  }

  public getDesFg(fg: number, context: common.UIAbilityContext, maxRatio: number = 1.45): number | string {
    if (this.followSystem) {
      let sysFontScale = context.config.fontSizeScale!
      return fg * Math.min(sysFontScale, maxRatio);
    }
    return fp2pxUtil(fg * Math.min(this.fontSizeRatio, maxRatio));
  }
}
