import { CapsuleSegmentButtonV2, ColorMetrics, SegmentButtonV2Items } from '@kit.ArkUI';
import { BulletVM } from '../viewmodel/BulletVM';
import { Bullet } from './Bullet';
import { GlowStick } from './GlowStick';

@Builder
export function BulletPageBuilder() {
  BulletPage();
}

@ComponentV2
struct BulletPage {
  vm: BulletVM = BulletVM.instance;
  @Local hybridItems: SegmentButtonV2Items = new SegmentButtonV2Items([
    { text: '弹幕墙', icon: $r('app.media.icon_barrage') },
    { text: '荧光棒', icon: $r('app.media.icon_glow_stick') },
  ]);

  build() {
    NavDestination() {
      Column() {
        CapsuleSegmentButtonV2({
          items: this.hybridItems,
          selectedIndex: this.vm.homeTabIndex!!,
          itemSelectedBackgroundColor: ColorMetrics.rgba(255, 255, 255),
          itemSelectedFontColor: ColorMetrics.rgba(0, 0, 0, 0.9),
        }).width('calc(100% - 32vp)');

        if (this.vm.homeTabIndex === 0) {
          Bullet();
        } else {
          GlowStick();
        }
      }
      .backgroundColor($r('sys.color.background_secondary'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP]);
    }
    .title('手持弹幕')
    .backgroundColor($r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    .height('100%')
    .width('100%')
    .onReady((ctx) => {
      this.vm.stack = ctx.pathStack;
    });
  }
}