import { User } from '@ohos_agcit/children_education_datasource';
import { CommonConstants } from '@ohos_agcit/children_education_utils';
import { CommonServices } from '../components/CommonServices';
import { LoginState } from '../components/LoginState';

@ComponentV2
export struct MinePage {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  @Consumer(CommonConstants.IS_VIP) isVip: boolean = false;
  @Consumer(CommonConstants.USER_INFO) user: User = new User();

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('我的')
          .fontSize(24)
          .fontFamily('鸿蒙黑体')
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.black'));
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(36);

      LoginState();

      CommonServices();
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .padding({ right: '4%', left: '4%', top: 10 })
    .backgroundColor('#F1F3F5');
  }
}