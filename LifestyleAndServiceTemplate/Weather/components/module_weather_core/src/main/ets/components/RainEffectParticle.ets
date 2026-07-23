import { RainLevel, RainConfig } from '../utils/RainConfig';
import { CardRect } from '../common/CoreType';

/**
 * 雨滴粒子效果组件，包含雨丝下落和卡片表面溅射两层粒子
 */
@ComponentV2
export struct RainEffectParticle {
  // 雨量等级
  @Param rainLevel: RainLevel = RainLevel.NONE;
  // 卡片碰撞区域Map，用于溅射粒子定位
  @Param cardRects: Map<string, CardRect> = new Map();
  // 前后台恢复版本号，变化时重启粒子
  @Param resumeVersion: number = 0;
  // 主题背景颜色，用于动态调整雨滴颜色
  @Param themeColor: string = '#FFFFFF';
  // 碰撞卡片Y坐标，用于溅射发射器定位
  @Local private cardY: number = 0;
  // 碰撞卡片X坐标，用于溅射发射器定位
  @Local private cardX: number = 0;
  // 碰撞卡片宽度，用于溅射发射器尺寸
  @Local private cardWidth: number = 0;
  // 粒子可见性，用于恢复时先隐藏再显示的刷新机制
  @Local private particleVisible: boolean = true;
  // 粒子重启键，递增触发Particle组件重建
  @Local private particleRestartKey: number = 0;
  private timerId: number = 0;

  aboutToAppear(): void {
    this.onCardRectsChange();
  }

  aboutToDisappear(): void {
    clearTimeout(this.timerId);
  }

  /**
   * 监听卡片区域变化，更新溅射发射器位置
   */
  @Monitor('cardRects')
  onCardRectsChange(): void {
    const uiNow = this.cardRects.get('uiNow');
    if (uiNow) {
      this.cardX = uiNow.x;
      this.cardY = uiNow.y;
      this.cardWidth = uiNow.width;
    }
  }

  /**
   * 监听恢复版本变化，隐藏后延迟显示以重启粒子
   */
  @Monitor('resumeVersion')
  onResumeVersionChange(): void {
    this.particleVisible = false;
    this.particleRestartKey++;
    if (this.timerId !== 0) {
      clearTimeout(this.timerId);
    }
    this.timerId = setTimeout(() => {
      this.particleVisible = true;
      this.timerId = 0;
    }, 50);
  }

  build() {
    Stack() {
      if (this.rainLevel !== RainLevel.NONE && this.particleVisible) {
        this.ParticleContent();
      }
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(HitTestMode.Transparent)
  }

  /**
   * 粒子内容构建：第一层为全屏雨丝下落，第二层为卡片表面溅射水花
   */
  @Builder
  private ParticleContent() {
    Particle({
      particles: [
        {
          emitter: {
            particle: {
              type: ParticleType.IMAGE,
              config: {
                src: $r('app.media.rain_drop_streak'),
                size: RainConfig.getRainSize(),
              },
              count: -1,
              lifetime: RainConfig.getLifetime(this.rainLevel),
              lifetimeRange: 500,
            },
            emitRate: RainConfig.getEmitRate(this.rainLevel),
            position: [0, 0],
            shape: ParticleEmitterShape.RECTANGLE,
            size: ['100%', 5],
          },
          color: {
            range: RainConfig.getRainColor(this.themeColor),
          },
          opacity: {
            range: RainConfig.getRainOpacity(this.themeColor),
          },
          velocity: {
            speed: RainConfig.getParticleFallSpeed(this.rainLevel),
            angle: RainConfig.getParticleFallAngle(this.rainLevel),
          },
          acceleration: {
            speed: { range: RainConfig.getParticleAccSpeed(this.rainLevel) },
            angle: { range: RainConfig.getParticleAccAngle(this.rainLevel) },
          },
        },
      ],
    })
      .width('100%')
      .height('100%')
      .hitTestBehavior(HitTestMode.Transparent)

    Particle({
      particles: [
        {
          emitter: {
            particle: {
              type: ParticleType.POINT,
              config: { radius: 2 },
              count: -1,
              lifetime: 400,
              lifetimeRange: 200,
            },
            emitRate: RainConfig.getEmitRate(this.rainLevel) > 0 ?
              Math.ceil(RainConfig.getEmitRate(this.rainLevel) / 3) : 0,
            position: [this.cardX, this.cardY],
            shape: ParticleEmitterShape.RECTANGLE,
            size: [this.cardWidth, 4],
          },
          color: {
            range: RainConfig.getSplashColor(this.themeColor),
          },
          opacity: {
            range: RainConfig.getSplashOpacity(this.themeColor),
            updater: {
              type: ParticleUpdater.CURVE,
              config: [{
                from: 1.0,
                to: 0.0,
                startMillis: 0,
                endMillis: 400,
                curve: Curve.Linear,
              }],
            },
          },
          velocity: {
            speed: RainConfig.getParticleSplashSpeed(this.rainLevel),
            angle: [210, 330],
          },
          acceleration: {
            speed: { range: [300, 500] },
            angle: { range: [85, 95] },
          },
        },
      ],
    })
      .width('100%')
      .height('100%')
      .hitTestBehavior(HitTestMode.Transparent)
      .emitter([
        { index: 0, position: { x: this.cardX, y: this.cardY }, size: { width: this.cardWidth, height: 4 } },
      ])
  }
}
