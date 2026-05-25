import { common } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';
import { PcHomeFirstPane } from '../../components/PcHomeFirstPane';
import { MineViewContent } from './MineView';

@Builder
export function MineViewHostBuilder() {
  MineViewHost();
}

@ComponentV2
struct MineViewHost {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  private hostContext: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  private isPcLayout(): boolean {
    try {
      const type = this.hostContext.resourceManager.getDeviceCapabilitySync().deviceType;
      return type === resourceManager.DeviceType.DEVICE_TYPE_2IN1;
    } catch (_e) {
      return false;
    }
  }

  @Builder
  private pcHeader(title: string) {
    Row({ space: 8 }) {
      SymbolGlyph($r('sys.symbol.arrow_left'))
        .fontSize(20)
        .fontColor([$r('sys.color.font_primary')])
        .onClick(() => {
          this.appPathStack.pop();
        });
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'));
      Blank();
    }
    .width('100%')
    .height(44)
    .alignItems(VerticalAlign.Center)
    .padding({ left: 12, right: 12, top: 12, bottom: 8 });
  }

  build() {
    NavDestination() {
      if (this.isPcLayout()) {
        Row() {
          Column() {
            PcHomeFirstPane();
          }
          .layoutWeight(240)
          .height('100%')
          .width('100%');

          Divider()
            .vertical(true)
            .strokeWidth(1)
            .color($r('sys.color.comp_divider'))
            .height('100%');

          Column() {
            Column() {
              this.pcHeader('我的');
              MineViewContent();
            }
            .width('100%')
            .height('100%');
          }
          .layoutWeight(860)
          .height('100%')
          .width('100%')
          .backgroundColor($r('sys.color.background_secondary'));
        }
        .width('100%')
        .height('100%')
        .backgroundColor($r('sys.color.background_secondary'));
      } else {
        MineViewContent();
      }
    }
    .title('我的')
    .hideTitleBar(this.isPcLayout())
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    });
  }
}

