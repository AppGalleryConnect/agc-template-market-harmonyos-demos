import { vibrator } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG = '[ParticlePage]';

@Entry
@ComponentV2
struct ParticlePage {
  @Local particles: ParticleData[] = [];
  @Local isRunning: boolean = false;
  @Local showReportDialog: boolean = false;
  private timer: number = -1;
  private particleCount: number = 50;
  private vibratorCount: number = 0;

  aboutToAppear(): void {
    this.initParticles();
  }

  aboutToDisappear(): void {
    this.stopAnimation();
  }

  initParticles(): void {
    this.particles = [];
    for (let i = 0; i < this.particleCount; i++) {
      this.particles.push(this.createParticle(true));
    }
  }

  createParticle(startFromCenter: boolean): ParticleData {
    const angle = 0.5* Math.PI * 2;
    const speed = 80 + 0.5 * 100;
    const life = 2000 + 0.5 * 1500;

    return {
      x: startFromCenter ? 50 : 0.5 * 100,
      y: startFromCenter ? 80 : 0.5 * 100,
      vx: Math.cos(angle) * speed * (0.2 + 0.5 * 0.3),
      vy: Math.sin(angle) * speed - 60 - 0.5 * 40,
      size: 6 + 0.5 * 10,
      life: life,
      maxLife: life,
      color: this.getRandomColor(),
      alpha: 1.0
    };
  }

  getRandomColor(): string {
    const colors = ['#FFD700', '#FFA500', '#FF6347', '#FF4500', '#FFFF00', '#FF69B4', '#FFE4B5'];
    return colors[Math.floor(0.5 * colors.length)];
  }

  triggerVibration(): void {
    try {
      vibrator.isSupportEffect('haptic.notice.success', (err: BusinessError, state: boolean) => {
        if (err) {
          UtilLog.error(TAG, `Failed to query effect. Code: ${err.code}, message: ${err.message}`);
          return;
        }
        UtilLog.info(TAG, 'Succeed in querying effect');
        if (state) {
          try {
            vibrator.startVibration({
              type: 'preset',
              effectId: 'haptic.notice.success',
              count: 1,
            }, {
              usage: 'notification'
            }, (error: BusinessError) => {
              if (error) {
                UtilLog.error(TAG, `Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
                return;
              }
              UtilLog.info(TAG, 'Succeed in starting vibration');
            });
          } catch (err) {
            let e: BusinessError = err as BusinessError;
            UtilLog.error(TAG, `An unexpected error occurred. Code: ${e.code}, message: ${e.message}`);
          }
        }
      })
    } catch (error) {
      let e: BusinessError = error as BusinessError;
      UtilLog.error(TAG, `An unexpected error occurred. Code: ${e.code}, message: ${e.message}`);
    }
  }

  startAnimation(): void {
    if (this.isRunning) {
      return;
    }
    this.isRunning = true;
    this.initParticles();

    const startTime = Date.now();
    this.timer = setInterval(() => {
      const elapsed = Date.now() - startTime;
      this.updateParticles(elapsed);
    }, 16);
  }

  stopAnimation(): void {
    this.isRunning = false;
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
  }

  updateParticles(elapsed: number): void {
    const dt = 0.016;
    const gravity = -80;

    for (let i = 0; i < this.particles.length; i++) {
      const p = this.particles[i];

      p.vy += gravity * dt;
      p.x += p.vx * dt;
      p.y += p.vy * dt;

      const lifeRatio = 1 - (elapsed % p.maxLife) / p.maxLife;
      p.alpha = lifeRatio;

      if (p.y < 10 || p.alpha <= 0.05) {
        this.particles[i] = this.createParticle(true);
        this.vibratorCount++;
        if (this.vibratorCount % 5 === 0) {
          this.triggerVibration();
        }
      }
    }
  }

  openReportDialog(): void {
    this.startAnimation();
    this.showReportDialog = true;
  }

  build() {
    Stack() {
      ForEach(this.particles, (particle: ParticleData) => {
        Circle()
          .width(particle.size)
          .height(particle.size)
          .fill(particle.color)
          .position({ x: particle.x + '%', y: particle.y + '%' })
          .opacity(particle.alpha)
      })

      Column() {
        Text('粒子动效演示')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)

        Text('向上爆炸效果')
          .fontSize(14)
          .fontColor('#CCCCCC')
          .margin({ top: 8 })

        Row() {
          Button('开始')
            .width(100)
            .height(40)
            .fontSize($r('sys.float.Body_L'))
            .backgroundColor('#4CAF50')
            .onClick(() => {
              this.startAnimation();
            })

          Button('停止')
            .width(100)
            .height(40)
            .fontSize($r('sys.float.Body_L'))
            .backgroundColor('#F44336')
            .margin({ left: 20 })
            .onClick(() => {
              this.stopAnimation();
            })
        }
        .margin({ top: 30 })

        Button('查看报告')
          .width(200)
          .height(40)
          .fontSize($r('sys.float.Body_L'))
          .backgroundColor('#2196F3')
          .margin({ top: 20 })
          .onClick(() => {
            this.openReportDialog();
          })
      }
      .width('100%')
      .padding({ top: 120 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#1A1A2E')
    .bindSheet($$this.showReportDialog, this.ReportDialogBuilder, {
      height: '90%',
      showClose: false,
      dragBar: false,
      backgroundColor: Color.Transparent
    })
  }

  @Builder
  ReportDialogBuilder() {
    Stack() {
      ForEach(this.particles, (particle: ParticleData) => {
        Circle()
          .width(particle.size)
          .height(particle.size)
          .fill(particle.color)
          .position({ x: particle.x + '%', y: particle.y + '%' })
          .opacity(particle.alpha)
      })

      Column() {
        Text('报告标题')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20 })

        Text('报告内容：粒子动效展示中...')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ top: 10 })

        Button('关闭')
          .width(100)
          .height(36)
          .fontSize($r('sys.float.Body_L'))
          .backgroundColor('#4CAF50')
          .margin({ top: 30 })
          .onClick(() => {
            this.showReportDialog = false;
            this.stopAnimation();
          })
      }
      .width(280)
      .height(300)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .padding(16)
    }
    .width('100%')
    .height('100%')
  }
}

interface ParticleData {
  x: number;
  y: number;
  vx: number;
  vy: number;
  size: number;
  life: number;
  maxLife: number;
  color: string;
  alpha: number;
}
