import { CommonConstants } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { MsgMenuItem } from '../components/MessageItem';
import { SetReadIcon } from '../components/SetReadIcon';
import { MineMsgMenuItem } from '../types/Types';
import { MessageViewModel } from '../viewmodels/MessageVM';

@Builder
export function MessagePageBuilder() {
  MessagePage()
}

@ComponentV2
struct MessagePage {
  @Local vm: MessageViewModel = new MessageViewModel();

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '消息',
          rightPartBuilder: () => {
            this.rightPartBuilder()
          },
        })
        Column() {
          List({ space: CommonConstants.SPACE_M }) {
            ForEach(this.vm.menuInfoList, (v: MineMsgMenuItem) => {
              ListItem() {
                MsgMenuItem({
                  info: v,
                  fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
                })
              }
            }, (v: MineMsgMenuItem) => v.menuTitle)
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .align(Alignment.Top)
          .padding({
            left: this.vm.breakPointModel.pagePadding,
            right: this.vm.breakPointModel.pagePadding,
          })
        }
        .layoutWeight(1)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
  }

  @Builder
  rightPartBuilder() {
    SetReadIcon({
      enable: this.vm.allowClean,
      confirm: () => {
        this.vm.setAllRead();
      },
    })
  }
}