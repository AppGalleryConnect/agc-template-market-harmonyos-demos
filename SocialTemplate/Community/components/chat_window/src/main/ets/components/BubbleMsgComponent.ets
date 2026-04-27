/**
 * @usage: 聊天气泡弹出菜单，动态生成菜单项
 * @layout: Column + Popup 菜单容器 + 子项栅格
 * @constraints: 弹层关闭回调；遮罩透明度；点击项触发业务
 * @isGen: false
 * @fileType: component
 * @domain: 社交交友
 * @zhName: 气泡菜单组件
 * @subPage: popMenuItemComponent
 * @component:
 * @image:
 */
import { ChatContentSingleModel } from 'chat_base';
import { BubbleMsgItem, BubbleMsgModel } from '../model/BubbleMsgModel';
import { PromptActionClass } from '../utils/PromptActionClass';
import { popMenuItemComponent } from './popMenuItemComponent';

@ComponentV2
export struct BubbleMsgComponent {
  @Local handlePopup: boolean = true;
  @Param @Require chatVM: ChatContentSingleModel
  @Local menuData: BubbleMsgItem[] = []
  closePop = () => {
    this.handlePopup = false
  }

  aboutToAppear(): void {
    this.menuData = BubbleMsgModel.getMenuData(this.chatVM.chatType)
    PromptActionClass.closePop = this.closePop
  }

  @Builder
  popBuilder() {
    Column() {
      PopMsgComponet({
        menuData: this.menuData,
        chatVM: this.chatVM
      })
    }
  }

  build() {
    Column() {
    }
    .width('100%').height('100%')
    .bindPopup(this.handlePopup!!, {
      builder: this.popBuilder,
      placement: Placement.Top,
      popupColor: '#CC000000',
      backgroundBlurStyle: BlurStyle.NONE,
      radius: 8,
      onWillDismiss:(
        (dismissPopupAction: DismissPopupAction) => {
          dismissPopupAction.dismiss();
          PromptActionClass.closeDialog()
        }
      )
    })
    .onClick(() => {
      PromptActionClass.closeDialog()
    })
  }
}


@ComponentV2
export struct PopMsgComponet {
  @Param @Require menuData: BubbleMsgItem[]
  @Param @Require chatVM: ChatContentSingleModel

  build() {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceAround }) {
      ForEach(this.menuData, (item: BubbleMsgItem) => {
        popMenuItemComponent({
          item: item,
          chatVM: this.chatVM
        })
      }, (item: BubbleMsgItem, index: number) => item.title + index)
    }.constraintSize({ maxWidth: 248, minWidth: 190 })
    .padding({ bottom: 14 })

  }
}
