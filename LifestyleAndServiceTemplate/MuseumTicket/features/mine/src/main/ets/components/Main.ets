import { RouterMap, RouterModule, CommonConstants } from 'commonlib';
import { MinePageVM } from '../viewModels/MinePageVM';


@ComponentV2
export struct Main {
  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Text('个人信息')
          .fontSize(CommonConstants.FONT_SIZE_L)
          .fontColor(CommonConstants.FONT_COLOR_BLACK)
          .fontWeight(500);
        Row() {
          Image($r('app.media.icon_public_arrow_right')).fillColor(CommonConstants.FONT_COLOR_BLACK).width(12);
        }.width(24).height(24);
      }.height(47).onClick(() => {
        RouterModule.push({ url: RouterMap.MINE_PROFILE_EDIT });
      });

      Divider().width('100%');
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Text('隐私政策')
          .fontSize(CommonConstants.FONT_SIZE_L)
          .fontColor(CommonConstants.FONT_COLOR_BLACK)
          .fontWeight(500);
        Row() {
          Image($r('app.media.icon_public_arrow_right')).fillColor(CommonConstants.FONT_COLOR_BLACK).width(12);
        }.width(24).height(24);
      }.height(47).onClick(() => {
        RouterModule.push({ url: RouterMap.PRIVACY });
      });

    }.width('100%').backgroundColor(CommonConstants.BG_COLOR_WHITE).borderRadius(8).padding({ left: 22, right: 22 });
  }
}