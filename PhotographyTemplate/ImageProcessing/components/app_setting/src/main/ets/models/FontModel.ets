import { fp2pxUtil } from '../common/FontUtils';

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
  public getFg(fg: number, maxRatio: number = 3.2): number | string {
    if (this.followSystem) {
      return fg;
    }
    return fp2pxUtil(fg * Math.min(this.fontSizeRatio, maxRatio));
  }

  // 回调
  public onChange: () => void = () => {
  };

  @Monitor('followSystem', 'fontSizeRatio', 'sysFontSizeScale')
  callback() {
    this.onChange();
  }
}
