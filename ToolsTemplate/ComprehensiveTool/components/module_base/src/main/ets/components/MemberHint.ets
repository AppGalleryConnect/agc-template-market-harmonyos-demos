import {
  LoginSheetUtils,
} from 'aggregated_login';
import { MemberSheetUtils } from 'membership';
import { MAX_FREE_USE_TIME } from '../constant/Index';
import { LoginManageUtil } from '../util/LoginManageUtil';
import { MemberManageUtil } from '../util/MemberManageUtil';

let uiContext: UIContext;

@ComponentV2
export struct MemberHint {
  @Param fontColor: ResourceStr = $r('sys.color.font_primary');
  @Param bgColor: ResourceStr = $r('sys.color.comp_background_tertiary');
  @Param btnFontColor: ResourceStr = $r('sys.color.font_emphasize');
  @Param count: number = 0;

  aboutToAppear(): void {
    uiContext = this.getUIContext();
  }

  build() {
    Row() {
      Text(`免费使用次数${this.count}/${MAX_FREE_USE_TIME}，开通会员解除次数限制！`)
        .fontSize(14)
        .fontColor(this.fontColor)
        .width('65%')
        .maxLines(2);

      Row({ space: 4 }) {
        Text('立即开通').fontColor(this.btnFontColor).fontSize(14).fontWeight(FontWeight.Medium);
        Image($r('app.media.subscribe_hint_right')).size({ height: 24, width: 12 });
      }.onClick(() => {
        let loginManageUtil = new LoginManageUtil(uiContext);
        if (!loginManageUtil.userInfoModel.isLogin) {
          LoginSheetUtils.open(loginManageUtil.params, this.getUIContext());
        } else {
          let memberManageUtil = new MemberManageUtil(this.getUIContext());
          MemberSheetUtils.open(memberManageUtil.productsInfo, uiContext);
        }
      });
    }
    .backgroundColor(this.bgColor)
    .padding(12)
    .borderRadius(16)
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween);
  }
}

