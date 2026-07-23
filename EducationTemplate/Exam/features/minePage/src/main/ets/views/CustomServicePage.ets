import { AvatarInfo, ChatView } from 'customer_service_chat';
import { AppStorageV2 } from '@kit.ArkUI';
import { UserInfo } from 'login_info';

@Builder
export function CustomServicePageBuilder() {
  CustomServicePage();
}

@ComponentV2
struct CustomServicePage {
  @Local user: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;
  @Local serviceAvatarInfo: AvatarInfo = {
    avatar: $r('app.media.avatar'),
    name: '在线客服'
  }
  @Local userAvatarInfo: AvatarInfo = {
    avatar: this.user.avatar ? this.user.avatar : $r('app.media.path2x'),
    name: this.user.name
  }

  build() {
    NavDestination() {
      ChatView({
        serviceAvatarInfo: this.serviceAvatarInfo,
        userAvatarInfo: this.userAvatarInfo,
      })
    }
    .backgroundColor($r('sys.color.comp_background_gray'))
    .expandSafeArea([SafeAreaType.KEYBOARD, SafeAreaType.SYSTEM])
    .title('在线客服')
  }
}
