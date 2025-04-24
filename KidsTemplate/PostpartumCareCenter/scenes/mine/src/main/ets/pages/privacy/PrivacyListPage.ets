import { MainEntryVM } from '@ohos_agcit/postpartum_care_center_uicomponents';
import { Logger } from '@ohos_agcit/postpartum_care_center_utils';

@Builder
export function PrivacyListPageBuilder() {
  PrivacyListPage();
}

class PrivacyItem {
  name: string;
  linkPageName: string;

  constructor(name: string, linPageName: string) {
    this.name = name;
    this.linkPageName = linPageName;
  }
}

@ComponentV2
@Preview
export struct PrivacyListPage {
  vm: MainEntryVM = MainEntryVM.instance;
  private privacyItems: Array<PrivacyItem> = [
    new PrivacyItem('隐私政策', 'PrivacyPolicyPage'),
    new PrivacyItem('第三方信息共享清单', 'InfoSharingListPage'),
    new PrivacyItem('个人信息收集清单', 'PersonalInfoCollectListPage'),
  ];

  aboutToAppear(): void {
    Logger.info('come to PrivacyListPage');
  }

  build() {
    NavDestination() {
      List() {
        ForEach(this.privacyItems, (item: PrivacyItem) => {
          ListItem() {
            Column() {
              Row() {
                Text(item.name)
                  .fontColor('rgba(0,0,0,0.90)')
                  .fontSize('app.string.font_size_16')
                  .fontFamily('HarmonyHeiTi')
                  .fontWeight(FontWeight.Medium)
                  .textAlign(TextAlign.Start);

                Image($r('app.media.chevron_right'))
                  .width(12)
                  .height(24)
                  .padding({ right: $r('app.string.margin_ms') });
              }
              .width('100%')
              .height(56)
              .justifyContent(FlexAlign.SpaceBetween)
              .onClick(() => {
                this.vm.navStack.pushPathByName(item.linkPageName, null);
              });

              Divider()
                .color('rgba(0,0,0,0.20)')
                .strokeWidth(1);
            };
          }
          .padding({ left: $r('app.string.padding_16'), right: $r('app.string.padding_16') });
        }, (item: PrivacyItem) => JSON.stringify(item));
      }
      .margin({ top: $r('app.string.margin_xs') })
      .width('100%');
    }
    .title('关于我们')
    .backgroundColor('#F1F3F5');
  }
}