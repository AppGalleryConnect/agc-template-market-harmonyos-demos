import { common } from '@kit.AbilityKit';
import { DialPanel } from 'dial_panel';
import { Constants, NavPathName } from 'constant';
import { routeToPetal } from 'util';
import { HomePageVM } from '../viewmodel/HomePageVM';

@ComponentV2
export struct BasicInfoArea {
  @Param isHome: boolean = false;
  vm: HomePageVM = HomePageVM.instance;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  private dialPanel: DialPanel = new DialPanel(this.getUIContext())
    .setTitle('联系客服')
    .setPhoneNumber(this.vm.hotelInfo.appInfo.phone);

  jumpToInfo() {
    if (this.isHome) {
      this.mainPathStack.pushPathByName(NavPathName.HOTEL, null);
    }
  }

  build() {
    Row() {
      Row({ space: 8 }) {
        Image($r('app.media.brand')).size({ width: 60, height: 60 }).borderRadius(8).onClick(() => {
          this.jumpToInfo();
        });

        Column({ space: 6 }) {
          Row({ space: 8 }) {
            Text(this.vm.hotelInfo.appInfo.appName)
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .onClick(() => {
                this.jumpToInfo();
              });
            if (!this.isHome) {
              Image($r('app.media.navigating')).size({ height: 16, width: 16 }).onClick(() => {
                routeToPetal(this.getUIContext().getHostContext() as common.UIAbilityContext,
                  this.vm.hotelInfo.appInfo.appName);
              });
            }
          }


          Text(this.vm.hotelInfo.appInfo.address).fontSize(12).onClick(() => {
            this.jumpToInfo();
          }).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis });

        }.layoutWeight(1).alignItems(HorizontalAlign.Start);
      }.layoutWeight(1);

      Row({ space: 12 }) {
        if (this.isHome) {
          Image($r('app.media.navigating')).size({ height: 16, width: 16 }).onClick(() => {
            routeToPetal(this.getUIContext().getHostContext() as common.UIAbilityContext,
              this.vm.hotelInfo.appInfo.appName);
          });
        }

        Image($r('app.media.phone'))
          .size({ height: 16, width: 16 })
          .onClick(() => {
            this.dialPanel.open();
          });
      }.height(Constants.FULL_SCREEN).alignItems(VerticalAlign.Top).padding({ top: 12 });
    }
    .width(Constants.FULL_SCREEN)
    .justifyContent(FlexAlign.SpaceBetween)
    .height(84)
    .padding(12)
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_primary'));
  }
}