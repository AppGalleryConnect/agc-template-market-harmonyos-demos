import { RainLevel } from '../utils/RainConfig';
import { CardRect } from '../common/CoreType';
import { RainEffectParticle } from './RainEffectParticle';

/**
 * 雨滴动效容器组件，根据雨量等级显示粒子效果，穿透触摸事件
 */
@ComponentV2
export struct RainEffect {
  // 雨量等级
  @Param rainLevel: RainLevel = RainLevel.NONE;
  // 卡片碰撞区域Map，用于溅射粒子定位
  @Param cardRects: Map<string, CardRect> = new Map();
  // 前后台恢复版本号，变化时重启粒子
  @Param resumeVersion: number = 0;
  // 主题背景颜色，用于动态调整雨滴颜色
  @Param themeColor: string = '#FFFFFF';

  build() {
    Stack() {
      if (this.rainLevel !== RainLevel.NONE) {
        RainEffectParticle({
          rainLevel: this.rainLevel,
          cardRects: this.cardRects,
          resumeVersion: this.resumeVersion,
          themeColor: this.themeColor,
        })
      }
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .hitTestBehavior(HitTestMode.Transparent)
  }
}
