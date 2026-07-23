import { FastWeb } from '@hw-agconnect/fast-web';
import { CommonConstants, RouterUtils } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { WebIdMap } from '../constants/Constants';
import { MsgIMChatViewModel } from '../viewmodels/MessageIMChatVM';

@Builder
export function MsgIMChatPageBuilder() {
  MsgIMChatPage()
}

@ComponentV2
struct MsgIMChatPage {
  @Local vm: MsgIMChatViewModel = new MsgIMChatViewModel();

  aboutToAppear() {
    this.vm.setWebDebuggingAccess(false);
    this.vm.registerJavaScriptProxy(this.vm);
    this.vm.setWebProperty();
  }

  aboutToDisappear(): void {
    this.vm.deleteJavaScriptRegister();
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: this.vm.chatAuthor?.authorNickName || '',
          onBack: () => {
            RouterUtils.pop('1');
          },
        })
        Column() {
          if (this.vm.haveOfflineWeb) {
            FastWeb({
              webId: WebIdMap.ChatWebId,
              url: $rawfile('chat.html'),
            })
          } else {
            Web({
              src: $rawfile('chat.html'),
              controller: this.vm.webController,
            })
              .geolocationAccess(false)
              .fileAccess(false)
              .darkMode(WebDarkMode.Auto)
              .forceDarkAccess(true)
              .defaultFontSize(14 * this.vm.settingInfo.fontSizeRatio)
              .layoutWeight(1)
              .backgroundColor($r('sys.color.background_secondary'))
              .onShowFileSelector(this.vm.onShowFileSelector)
              .javaScriptProxy({
                object: this.vm,
                name: this.vm.JAVASCRIPT_PROXY_NAME,
                methodList: this.vm.METHOD_LIST,
                controller: this.vm.webController,
              })
          }
        }
        .layoutWeight(1)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .onBackPressed(() => {
      RouterUtils.pop('1');
      return true;
    })
  }
}