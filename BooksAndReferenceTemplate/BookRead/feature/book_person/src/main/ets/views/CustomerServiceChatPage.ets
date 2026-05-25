import { AvatarInfo, ChatView } from 'customer_service_chat';

@Entry
@ComponentV2
export struct CustomerServiceChatPage {
  @Local serviceAvatarInfo: AvatarInfo = {
    avatar: $r('app.media.startIcon'),
    name: '在线客服'
  }
  @Local userAvatarInfo: AvatarInfo = {
    avatar: $r('app.media.startIcon'),
    name: '悠悠'
  }
  windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77

  build() {
    NavDestination() {
      ChatView({
        serviceAvatarInfo: this.serviceAvatarInfo,
        userAvatarInfo: this.userAvatarInfo,
      })
    }
    .backgroundColor($r('sys.color.comp_background_gray'))
    .expandSafeArea([SafeAreaType.KEYBOARD, SafeAreaType.SYSTEM])
    .padding({
      top: this.windowTopHeight
    })
    .title('在线客服')
  }
}