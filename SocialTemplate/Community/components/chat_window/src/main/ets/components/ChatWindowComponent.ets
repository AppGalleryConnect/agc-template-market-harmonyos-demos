/**
 * @usage: 展示会话窗口，按消息类型渲染列表
 * @layout: Column + 导航栏 + List + 模板（文本/图片/语音/视频/位置/群提示）
 * @constraints: 虚拟滚动；请求定位权限；右上菜单可选；安全边距
 * @isGen: false
 * @fileType: component
 * @domain: 社交交友
 * @zhName: 聊天窗口组件
 * @subPage: ChatLocationRow,ChatNavigationBar,ChatTextRow,ChatVideo,ChatImageRow,ChatVoiceRow
 * @component:
 * @image: screenshots/chat_window_list_one.jpeg,screenshots/chat_window_list_two.jpeg
 */
import { AppStorageV2 } from '@kit.ArkUI';
import { ChatLocationRow } from './ChatLocationRow';
import { ChatNavigationBar } from './ChatNavigationBar';
import { ChatTextRow } from './ChatTextRow';
import { ChatBreakpoint, ChatContentSingleModel, ChatTypeEnum } from 'chat_base';
import { ChatVideo } from './ChatVideo';
import { ChatImageRow } from './ChatImageRow';
import { ChatVoiceRow } from './ChatVoiceRow';

@ComponentV2
export struct ChatWindowComponent {
  @Param title: string = '';
  @Param @Require chatContentList: ChatContentSingleModel[];
  @Param @Require onReturnClick: () => void = () => {
  }
  @Param onChatBubbleClick: (chatVM: ChatContentSingleModel) => void =
    (_chatVM: ChatContentSingleModel) => {
    }
  @Param onChatAvatarClick: (chatVM: ChatContentSingleModel) => void =
    (_chatVM: ChatContentSingleModel) => {
    }
  @Param isShowRightImage: boolean = true
  @Param menuList: MenuElement[] = [];
  @Param scroller: ListScroller = new ListScroller();
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;

  build() {
    Column() {
      ChatNavigationBar({
        title: this.title,
        onReturnClick: this.onReturnClick,
        isShowRightImage: this.isShowRightImage,
        rightImageRes: $r('app.media.chat_more'),
        menuList: this.menuList
      })

      Column() {
        List({ space: 12, scroller: this.scroller }) {
          ListItem().height('1vp')
          Repeat<ChatContentSingleModel>(this.chatContentList)
            .each((_ri: RepeatItem<ChatContentSingleModel>) => {
              // 默认模板

            })
            .key((item: ChatContentSingleModel): string => item.keyId)
            .virtualScroll({
              totalCount: this.chatContentList.length
            })
            .templateId((chatVM: ChatContentSingleModel): string => {
              return chatVM.chatType.toString();
            })
            .template(ChatTypeEnum.CHAT_TYPE_TEXT.toString(), (ri: RepeatItem<ChatContentSingleModel>) => {
              // 自定义消息（纯文本、表情、超链接等）
              ListItem() {
                ChatTextRow({
                  chatVM: ri.item,
                  keyId: ri.item.keyId,
                  onChatAvatarClick: this.onChatAvatarClick
                })
              }
            })
            .template(ChatTypeEnum.CHAT_TYPE_LOCATION.toString(), (ri: RepeatItem<ChatContentSingleModel>) => {
              // 地理位置
              ListItem() {
                ChatLocationRow({
                  chatVM: ri.item,
                  keyId: ri.item.keyId,
                  onChatBubbleClick: this.onChatBubbleClick,
                  onChatAvatarClick: this.onChatAvatarClick
                })
              }
            })
            .template(ChatTypeEnum.CHAT_TYPE_IMAGE.toString(), (ri: RepeatItem<ChatContentSingleModel>) => {
              // 图片消息
              ListItem() {
                ChatImageRow({
                  chatVM: ri.item,
                  onChatAvatarClick: this.onChatAvatarClick,
                  onChatBubbleClick: this.onChatBubbleClick
                })
              }
            })
            .template(ChatTypeEnum.CHAT_TYPE_SOUND.toString(), (ri: RepeatItem<ChatContentSingleModel>) => {
              // 语音消息
              ListItem() {
                ChatVoiceRow({
                  chatVM: ri.item,
                  onChatAvatarClick: this.onChatAvatarClick,
                  onChatBubbleClick: this.onChatBubbleClick
                })
              }
            })
            .template(ChatTypeEnum.CHAT_TYPE_VIDEO.toString(), (ri: RepeatItem<ChatContentSingleModel>) => {
              //视频展示
              ListItem() {
                ChatVideo({
                  chatVM: ri.item,
                  onChatAvatarClick: this.onChatAvatarClick,
                  onChatBubbleClick: this.onChatBubbleClick
                })
              }
            })
            .template(ChatTypeEnum.CHAT_GROUP_TIPS.toString(), (ri: RepeatItem<ChatContentSingleModel>) => {
              // 群消息提醒
              ListItem() {
                Text(ri.item.groupTipContent)
                  .fontSize($r('sys.float.Body_S'))
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('app.color.color_66000000'))
                  .lineHeight($r('app.float.vp_18'))
                  .maxLines(-1)
              }.width('100%')
            })
          ListItem().height('1vp')
        }
        .height('100%')
        .width('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      }
      .layoutWeight(1)
      .width('100%')
      .padding({
        left: this.chatBreakpoint.pagePadding,
        right: this.chatBreakpoint.pagePadding
      })
    }
    .width('100%')
    .height('100%')
  }
}
