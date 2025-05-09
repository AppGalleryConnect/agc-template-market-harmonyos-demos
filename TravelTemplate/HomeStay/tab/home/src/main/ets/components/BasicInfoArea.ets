import { common } from '@kit.AbilityKit';
import { ConfirmDialog } from 'component';
import { Constants, NavPathName } from 'constant';
import { consult, routeToPetal } from 'util';
import { HomePageVM } from '../viewmodel/HomePageVM';

@Component
export struct BasicInfoArea {
  @Prop isHome: boolean = false;
  vm: HomePageVM = HomePageVM.instance;
  @Consume('mainPathStack') mainPathStack: NavPathStack;
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: ConfirmDialog({
      call: () => {
        consult(this.vm.hotelInfo.appInfo.phone);
      },
      phone: this.vm.hotelInfo.appInfo.phone,
    }),
    customStyle: true,
    autoCancel: true,
  });

  jumpToInfo() {
    if (this.isHome) {
      this.mainPathStack.pushPathByName(NavPathName.HOTEL, null);
    }
  }

  build() {
    Row({ space: 8 }) {
      Image($r('app.media.brand')).size({ width: 60, height: 60 }).borderRadius(8).onClick(() => {
        this.jumpToInfo();
      });

      Column({ space: 6 }) {
        Row() {
          Text(this.vm.hotelInfo.appInfo.appName)
            .fontSize(20)
            .fontWeight(500)
            .fontColor('#111111')
            .width(200)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .onClick(() => {
              this.jumpToInfo();
            });

          Row() {
            Image($r('app.media.navigating')).size({ height: 24, width: 24 }).onClick(() => {
              routeToPetal(getContext(this) as common.UIAbilityContext, this.vm.hotelInfo.appInfo.appName);
            });
            Image($r('app.media.phone'))
              .size({ height: 24, width: 24 })
              .onClick(() => {
                if (this.dialogController !== null) {
                  this.dialogController.open();
                }
              });
          };
        }.justifyContent(FlexAlign.SpaceBetween).width(Constants.FULL_SCREEN);

        Row({ space: 4 }) {
          Image($r('app.media.icon_position')).size({ height: 12, width: 12 });
          Text(this.vm.hotelInfo.appInfo.address).fontSize(12).onClick(() => {
            this.jumpToInfo();
          });
        }.alignSelf(ItemAlign.Start);
      }.width('80%');
    }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.Start);
  }
}