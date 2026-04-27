import { BulletVM } from '../viewmodel/BulletVM';

@Builder
export function GlowStickDisplayBuilder() {
  GlowStickDisplay();
}

@ComponentV2
export struct GlowStickDisplay {
  vm: BulletVM = BulletVM.instance;
  @Local isQuit: boolean = false;

  aboutToAppear(): void {
    clearInterval(this.vm.glowInterval)
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
        }
        .height('100%')
        .width('100%')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
        .linearGradient({
          direction: GradientDirection.Bottom,
          repeating: false,
          colors: this.vm.linearColors,
        })
        .onAppear(() => {
          this.vm.startGlow();
        });

        if (this.isQuit) {
          Button('退出荧光棒')
            .size({ width: 120, height: 40 })
            .fontColor($r('sys.color.warning'))
            .backgroundColor($r('sys.color.comp_background_primary'))
            .borderRadius(20).onClick(() => {
            this.vm.stack.pop();
          });
        }
      };
    }.onClick(() => {
      this.isQuit = !this.isQuit;
    }).hideTitleBar(true);
  }
}