import { FormatUtil } from 'commonlib';
import { MainEntryVM } from '../viewmodels/MainEntryVM';

@ComponentV2
export struct MineView {
  vm: MainEntryVM = MainEntryVM.instance;

  build() {
    Column() {
      Text('加入会员，享受更多权益');
      Row() {
        Image(FormatUtil.formatImgResource(this.vm.userInfo.avatar))
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor($r('app.color.icon_color_level2_invert'));
        Text('手机号：' + this.vm.userInfo.cellphone);
      };

      Button('立即授权')
        .onClick(() => {
          this.vm.requestPhoneNumber();
        });
    };
  }
}

