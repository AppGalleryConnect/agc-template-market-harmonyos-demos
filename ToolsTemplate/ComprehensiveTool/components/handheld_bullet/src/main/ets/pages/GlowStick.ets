import { SliderPickerDialog } from '../components/SliderPickerDialog';
import { BulletVM } from '../viewmodel/BulletVM';

@Builder
export function GlowStickBuilder() {
  GlowStick();
}

@ComponentV2
export struct GlowStick {
  vm: BulletVM = BulletVM.instance;

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        Text('设置')
          .fontSize(14)
          .width('100%')
          .textAlign(TextAlign.Start)
          .fontColor($r('sys.color.font_secondary'))
          .margin({ bottom: 8 });

        Row() {
          Text('颜色变换速度').fontSize(14);

          Text(`${this.vm.bullet.speed}`).onClick(() => {
            this.vm.cloneGlowStickSpeedOption = this.vm.cloneGlowSpeedOptions();
            this.vm.isShowGlowStickerPicker = true;
          }).bindSheet($$this.vm.isShowGlowStickerPicker, SliderPickerDialog(this.vm.cloneGlowStickSpeedOption), {
            title: { title: '颜色变换速度' },
            preferType: SheetType.CENTER,
            height: 320,
          });
        }
        .padding(12)
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .borderRadius(16)
        .backgroundColor($r('sys.color.background_primary'));

        Button('开启荧光棒').borderRadius(20).fontColor($r('sys.color.font_on_primary')).width('100%').onClick(() => {
          this.vm.stack.pushPathByName('GlowStickDisplay', null, false);
        });
      }
      .padding(16)
      .justifyContent(FlexAlign.Start)
      .backgroundColor($r('sys.color.background_secondary'))
      .height('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP]);
    }.hideTitleBar(true);
  }
}