import { GlobalContext } from '../comp/GlobalContext';
import { fp2pxUtil } from 'base_common';

/**
 * 全局设置
 */
@ObservedV2
export class FontModel {
  // 是否跟随系统
  @Trace followSystem: boolean = false;
  // 自定义字体大小缩放倍数
  @Trace fontSizeRatio: number = 1;
  // 系统字体大小缩放系数
  @Trace sysFontSizeScale: number = 1;

  // 计算得到fontsize
  public getFg(fg: number, maxRatio: number = 1.45): number | string {
    if (this.followSystem) {
      return fg;
    }
    return fp2pxUtil(fg * Math.min(this.fontSizeRatio, maxRatio));
  }

  // 计算得到非字体size
  public getDesFg(fg: number, maxRatio: number = 1.45): number | string {
    if (this.followSystem) {
      let sysFontScale = GlobalContext.getContext().config.fontSizeScale!
      return fg * Math.min(sysFontScale, maxRatio);
    }
    return fp2pxUtil(fg * Math.min(this.fontSizeRatio, maxRatio));
  }

  public getFontScale(maxRatio: number = 1.45): number {
    if (this.followSystem) {
      let sysFontScale = GlobalContext.getContext().config.fontSizeScale!
      return Math.min(sysFontScale, maxRatio);
    }
    return this.fontSizeRatio
  }
}
