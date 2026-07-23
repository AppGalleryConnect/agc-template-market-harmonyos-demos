@ComponentV2
export struct ParticleComponents {
  build() {
    Column() {
      Particle({
        particles: [
          {
            // 发射器配置
            emitter: {
              particle: {
                type: ParticleType.IMAGE, // 粒子类型为图片
                config: {
                  src: $r('app.media.practice_7'),
                  size: [12, 12]
                },
                count: 100 // 粒子总数
              },
              emitRate: 50, // 每秒发射粒子数
              // 发射器位置：组件中心
              position: [0,0],
              // 发射器形状为点，实现从中心点喷射
              shape: ParticleEmitterShape.CIRCLE
            },
            scale: {
              range: [0.5, 1.5],
              updater: {
                type: ParticleUpdater.CURVE,
                config: [
                  {
                    from: 0.5,
                    to: 1.5,
                    startMillis: 0,
                    endMillis: 1000,
                    curve: Curve.EaseOut
                  }
                ]
              }
            },
            // 速度：向四周喷射，速度大小随机
            velocity: {
              speed: [50, 150], // 速度范围 50~150
              angle: [0, 360]   // 角度范围 0~360°，实现全方向
            },
            // 加速度：粒子减速，模拟阻力
            acceleration: {
              speed: {
                range: [5, 10],
                updater: {
                  type: ParticleUpdater.CURVE,
                  config: [
                    {
                      from: 10,
                      to: 0,
                      startMillis: 0,
                      endMillis: 2000,
                      curve: Curve.Linear
                    }
                  ]
                }
              },
              angle: {
                range: [0, 360]
              }
            },
          },
          {
            // 发射器配置
            emitter: {
              particle: {
                type: ParticleType.IMAGE, // 粒子类型为圆点
                config: {
                  src: $r('app.media.practice_2'),
                  size: [12, 12]
                },
                count: 200 // 粒子总数
              },
              emitRate: 50, // 每秒发射粒子数
              // 发射器位置：组件中心
              position: [0,0],
              // 发射器形状为点，实现从中心点喷射
              shape: ParticleEmitterShape.CIRCLE
            },
            // 缩放：粒子从小到大
            scale: {
              range: [0.5, 1.5],
              updater: {
                type: ParticleUpdater.CURVE,
                config: [
                  {
                    from: 0.5,
                    to: 1.5,
                    startMillis: 0,
                    endMillis: 1000,
                    curve: Curve.EaseOut
                  }
                ]
              }
            },
            // 速度：向四周喷射，速度大小随机
            velocity: {
              speed: [50, 150], // 速度范围 50~150
              angle: [0, 360]   // 角度范围 0~360°，实现全方向
            },
            // 加速度：粒子减速，模拟阻力
            acceleration: {
              speed: {
                range: [5, 10],
                updater: {
                  type: ParticleUpdater.CURVE,
                  config: [
                    {
                      from: 10,
                      to: 0,
                      startMillis: 0,
                      endMillis: 2000,
                      curve: Curve.Linear
                    }
                  ]
                }
              },
              angle: {
                range: [0, 360]
              }
            },
          },
          {
            // 发射器配置
            emitter: {
              particle: {
                type: ParticleType.IMAGE, // 粒子类型为图片
                config: {
                  src: $r('app.media.practice_10'),
                  size: [12, 12]
                },
                count: 100 // 粒子总数
              },
              emitRate: 50, // 每秒发射粒子数
              // 发射器位置：组件中心
              position: [0,0],
              // 发射器形状为点，实现从中心点喷射
              shape: ParticleEmitterShape.CIRCLE
            },
            scale: {
              range: [0.5, 1.5],
              updater: {
                type: ParticleUpdater.CURVE,
                config: [
                  {
                    from: 0.5,
                    to: 1.5,
                    startMillis: 0,
                    endMillis: 1000,
                    curve: Curve.EaseOut
                  }
                ]
              }
            },
            // 速度：向四周喷射，速度大小随机
            velocity: {
              speed: [50, 150], // 速度范围 50~150
              angle: [0, 360]   // 角度范围 0~360°，实现全方向
            },
            // 加速度：粒子减速，模拟阻力
            acceleration: {
              speed: {
                range: [5, 10],
                updater: {
                  type: ParticleUpdater.CURVE,
                  config: [
                    {
                      from: 10,
                      to: 0,
                      startMillis: 0,
                      endMillis: 2000,
                      curve: Curve.Linear
                    }
                  ]
                }
              },
              angle: {
                range: [0, 360]
              }
            },
          },
        ]
      })
        .width(390)
        .height(534)
    }
  }
}