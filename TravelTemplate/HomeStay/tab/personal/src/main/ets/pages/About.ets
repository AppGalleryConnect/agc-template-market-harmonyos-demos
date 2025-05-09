import { TitleBar } from 'component';
import { Constants, NavPathName } from 'constant';
import { TenantInfo } from '../model/Index';

@Builder
export function AboutBuilder() {
  About();
}

@Component
export struct About {
  @State tenantInfo: TenantInfo | undefined = AppStorage.get('tenantInfo');
  @Consume('mainPathStack') mainPathStack: NavPathStack;

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '关于我们', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Column({ space: 24 }) {
          Image(this.tenantInfo?.banner)
            .size({ width: 80, height: 80 })
            .borderRadius(8)
            .objectFit(ImageFit.Contain);

          Text(this.tenantInfo?.introduction)
            .fontSize(14)
            .lineHeight(36);

          Column({ space: 12 }) {
            Row() {
              Text('查看隐私政策').fontSize(14).fontColor('#000000').opacity(0.9);
              Image($r('app.media.icon_direction_right')).size({ width: 12, height: 12 });
            }
            .width(Constants.FULL_SCREEN)
            .justifyContent(FlexAlign.SpaceBetween)
            .borderRadius(8)
            .padding(12)
            .backgroundColor('#F6F6F6')
            .onClick(() => {
              this.mainPathStack.pushPathByName(NavPathName.PRIVACY_POLICY_PAGE, null);
            });

            Row() {
              Text('查看用户协议').fontSize(14).fontColor('#000000').opacity(0.9);
              Image($r('app.media.icon_direction_right')).size({ width: 12, height: 12 });
            }
            .width(Constants.FULL_SCREEN)
            .justifyContent(FlexAlign.SpaceBetween)
            .borderRadius(8)
            .padding(12)
            .backgroundColor('#F6F6F6')
            .onClick(() => {
              this.mainPathStack.pushPathByName(NavPathName.TERMS_OF_SERVICE_PAGE, null);
            });
          };

        }.padding(16).height('90%').width(Constants.FULL_SCREEN);
      };
    }.hideTitleBar(true);
  }
}