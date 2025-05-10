import { CommonConstants, RouterModule } from 'commonlib';
import { ConfirmDialogComponent } from '../components/ConfirmDialogComponent';
import { SettingItem } from '../types/Index';
import { MinePageVM } from '../viewModels/MinePageVM';
import { promptAction } from '@kit.ArkUI';

@Builder
export function SettingsPageBuilder() {
  SettingsPage();
}

@ComponentV2
struct SettingsPage {
  vm: MinePageVM = MinePageVM.instance;
  @Local cacheSize: number = 100.33;
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: ConfirmDialogComponent({
      delete: () => {
        this.cacheSize = 0;
      },
    }),
    customStyle: true,
    autoCancel: true,
  });

  build() {
    NavDestination() {
      Column() {
        Column({ space: 12 }) {
          ForEach(this.vm.settingList, (item: SettingItem, index: number) => {
            Row() {
              Text(item.label).opacity(0.9);
              Row({ space: 8 }) {
                Text(index === 3 ? `${this.cacheSize}M` : '').opacity(0.6);
                Image($r('app.media.ic_right')).size({ height: 26, width: 8 });
              };
            }
            .height(60)
            .padding(20)
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .onClick(() => {
              if (index !== 3) {
                RouterModule.push({ url: item.page });
              }
            });
          });
        }

        Button('退出登录')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor('#E84026')
          .width(CommonConstants.FULL_WIDTH)
          .constraintSize({ maxWidth: CommonConstants.FULL_WIDTH })
          .margin({ left: 24, right: 24, bottom: 12 })
          .onClick(() => {
            this.vm.logout()
            promptAction.showToast({ message: '退出成功~！' })
            RouterModule.pop()
          })
          .visibility(this.vm.userInfo.isLogin ? Visibility.Visible : Visibility.Hidden)
      }
      .padding({ top: 12, left: 16, right: 16 })
      .height('100%')
      .backgroundColor('#F1F3F5')
      .justifyContent(FlexAlign.SpaceBetween);
    }.title('设置');
  }
}

