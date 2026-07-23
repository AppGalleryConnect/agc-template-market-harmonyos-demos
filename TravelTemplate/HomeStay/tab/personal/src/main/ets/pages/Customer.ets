import { CommonHeader } from 'component';
import { Constants } from 'constant';
import { ChatView } from 'customer_service_chat';

@Builder
export function CustomerBuilder() {
  Customer();
}

@ComponentV2
export struct Customer {
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        CommonHeader({ title: '在线客服', showBackButton: true, backButtonClick: () => {
          this.mainPathStack.pop();
        }});

        ChatView({ placeHolder: '请在此输入您的问题' })
          .layoutWeight(1)
          .margin({ bottom: 24 });
      }
      .width(Constants.FULL_SCREEN)
      .height(Constants.FULL_SCREEN);
    }.hideTitleBar(true);
  }
}
