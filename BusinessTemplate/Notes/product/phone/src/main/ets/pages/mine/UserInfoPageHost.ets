import { common } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';
import { UserInfoForm } from 'login';
import { PcHomeFirstPane } from '../../components/PcHomeFirstPane';

@Builder
export function UserInfoPageBuilder() {
  UserInfoPageHost();
}

@ComponentV2
struct UserInfoPageHost {
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
              this.pcHeader('个人信息');
              UserInfoForm();
            }
            .width('100%')
            .height('100%');
          }
          .layoutWeight(860)
          .height('100%')
          .width('100%');
        }
        .width('100%')
        .height('100%')
        .backgroundColor($r('sys.color.background_secondary'));
      } else {
        UserInfoForm();
      }
    }
    .title('个人信息')
    .hideTitleBar(this.isPcLayout())
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    });
  }
}
