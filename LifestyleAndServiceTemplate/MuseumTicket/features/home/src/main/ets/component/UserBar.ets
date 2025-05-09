import { HomePageVM } from '../viewModels/HomePageVM';
import { RouterModule, RouterMap } from 'commonlib';

@ComponentV2
export struct UserBar {
  vm: HomePageVM = HomePageVM.instance;

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row({ space: 16 }) {
        Image(this.vm.userInfo.avatar).width(44).height(44).borderRadius(25).alt($r('app.media.icon_avatar'));
        Text(this.vm.userInfo.nickname ? this.vm.userInfo.nickname : '华为用户')
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(400);
      };

      Row({ space: 5 }) {
        Text('常用参观人').fontSize(14).fontColor($r('app.color.font_color_green')).onClick(() => {
          RouterModule.push({ url: RouterMap.VISITOR_PAGE });
        });
        Image($r('app.media.icon_public_arrow_right')).width(10);
      }
      .backgroundColor($r('sys.color.ohos_id_color_palette_aux3'))
      .width(112)
      .height(32)
      .padding({ left: 20, right: 15 })
      .borderRadius(33);
    }
    .height(72)
    .padding({ left: 20, right: 15 })
    .borderRadius(5)
    .backgroundColor('#fff');
  }
}