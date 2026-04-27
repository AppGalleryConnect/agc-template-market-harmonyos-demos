import { iData, UserInfoModel } from 'lib_foundation';
import { ChatView } from 'module_custom_service_chat'
import { KeyboardAvoidMode } from '@ohos.arkui.UIContext';


@Builder
export function buildCustomServicePage() {
  CustomServicePage()
}

@ComponentV2
export struct CustomServicePage {
  @Local
  userInfo: UserInfoModel = iData.global.userInfo;

  build() {
    NavDestination() {
      ChatView({
        userAvatar: this.userInfo.avatar ? this.userInfo.avatar : $r('app.media.ic_default_avatar'),
      })
    }
    .title('在线客服', { backgroundColor: $r('app.color.background_color_primary') })
    .onReady(() => {
      this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE_WITH_CARET)
    })
    .onHidden(() => {
      this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET_WITH_CARET)
    })
  }
}