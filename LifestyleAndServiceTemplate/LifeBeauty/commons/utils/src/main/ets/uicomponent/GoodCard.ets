import { AppStorageV2 } from '@kit.ArkUI';
import { CommonConstants } from '../common/Constant';
import { CommonUtils } from '../common/Utils';
import { GetUserInfoResp, GoodInfo } from '../model/Model';
import { RouterMap, RouterModule } from '../router/RouterModule';
import { LoginButtonType2 } from './Login';

@ComponentV2
export struct GoodCard {
  @Param goodInfo: GoodInfo = new GoodInfo();
  @Local bgH: number | undefined = 0;
  @Local userInfo: GetUserInfoResp = AppStorageV2.connect(GetUserInfoResp, () => new GetUserInfoResp())!;

  @Computed
  get isBindPhone() {
    return Boolean(this.userInfo.mobile);
  }

  build() {
    Column() {
      Image(CommonUtils.handleImgUrl(this.goodInfo.images[0])).width(CommonConstants.FULL_PERCENT)

      Column({ space: 10 }) {
        Text(this.goodInfo.title)
          .fontSize(14)
          .width(CommonConstants.FULL_PERCENT)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)

        Row({ space: 6 }) {
          Text('￥' + CommonUtils.handleCash(this.goodInfo.vipPrice)).fontSize(14).fontWeight(500).fontColor('#E84026')
          Text('￥' + CommonUtils.handleCash(this.goodInfo.price))
            .fontSize(10)
            .fontWeight(400)
            .fontColor($r('app.color.common_grey'))
            .decoration({
              type: TextDecorationType.LineThrough,
            })
          Blank()
          if (this.isBindPhone) {
            Button() {
              Text($r('app.string.good_card_appoint_btn'))
                .fontSize(14)
                .fontWeight(500)
                .fontColor($r('app.color.common_fg_white'))
                .width(56)
                .height(20)
                .textAlign(TextAlign.Center)
            }
            .backgroundColor($r('app.color.common_theme_color'))
            .padding({
              left: 8,
              right: 8,
              top: 4,
              bottom: 4,
            })
            .onClick(() => {
              RouterModule.push({ url: RouterMap.BOOK_GOOD, param: this.goodInfo });
            })
          } else {
            LoginButtonType2({
              onBind: () => {
                RouterModule.push({ url: RouterMap.BOOK_GOOD, param: this.goodInfo });
              },
            }).onClick(() => {
            })
          }
        }
        .width(CommonConstants.FULL_PERCENT)
      }
      .padding(10)
    }
    .clip(true)
    .backgroundColor($r('app.color.common_card_bg'))
    .borderRadius(8)
    .onClick(() => {
      RouterModule.push({ url: RouterMap.GOOD_DETAIL, param: this.goodInfo });
    })
  }
}
