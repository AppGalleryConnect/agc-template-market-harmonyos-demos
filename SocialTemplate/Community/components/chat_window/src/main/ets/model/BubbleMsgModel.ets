import { ChatContentSingleModel, ChatTypeEnum } from 'chat_base'

export enum POP_MENU_TYPE {
  COPY = 0, //复制
  RELAY = 1, //转发
  COLLECT = 2, //收藏
  DEL = 3, //删除
  SPEECH_TO_TEXT = 4, //语音转文字
  PLAY_SPEAKER = 5, //免提播放
  PLAY_MUTE = 6, //静音播放
  DOWNLOAD = 7 //下载
}

export class BubbleMsgItem {
  icon: string | Resource = ''
  title: string = ''
  type: number = POP_MENU_TYPE.COPY

  constructor(title: string, icon: string | Resource, type: number) {
    this.icon = icon
    this.title = title
    this.type = type
  }
}

export class BubbleMsgModel {
  static menuList: BubbleMsgItem[] = [
    new BubbleMsgItem('复制', $r('app.media.ic_copy'), POP_MENU_TYPE.COPY),
    new BubbleMsgItem('转发', $r('app.media.ic_relay'), POP_MENU_TYPE.RELAY),
    new BubbleMsgItem('收藏', $r('app.media.ic_collect'), POP_MENU_TYPE.COLLECT),
    new BubbleMsgItem('删除', $r('app.media.ic_del'), POP_MENU_TYPE.DEL),
    new BubbleMsgItem('语音转文字', $r('app.media.ic_speech_to_text'), POP_MENU_TYPE.SPEECH_TO_TEXT),
    new BubbleMsgItem('免提播放', $r('app.media.ic_play_speaker'), POP_MENU_TYPE.PLAY_SPEAKER),
    new BubbleMsgItem('静音播放', $r('app.media.ic_play_mute'), POP_MENU_TYPE.PLAY_MUTE),
    new BubbleMsgItem('下载', $r('app.media.ic_download'), POP_MENU_TYPE.DOWNLOAD)
  ]

  static getMenuData(type: ChatTypeEnum) {
    let data: BubbleMsgItem[] = BubbleMsgModel.menuList
    switch (type) {
      case ChatTypeEnum.CHAT_TYPE_NONE: //未知消息
        // data = []
        break;
      case ChatTypeEnum.CHAT_TYPE_TEXT: //自定义消息（文本消息）
        data = [new BubbleMsgItem('复制', $r('app.media.ic_copy'), POP_MENU_TYPE.COPY),
          new BubbleMsgItem('转发', $r('app.media.ic_relay'), POP_MENU_TYPE.RELAY),
          new BubbleMsgItem('收藏', $r('app.media.ic_collect'), POP_MENU_TYPE.COLLECT),
          new BubbleMsgItem('删除', $r('app.media.ic_del'), POP_MENU_TYPE.DEL)]
        break;
      case ChatTypeEnum.CHAT_TYPE_IMAGE: //图片消息
        data = [
          new BubbleMsgItem('转发', $r('app.media.ic_relay'), POP_MENU_TYPE.RELAY),
          new BubbleMsgItem('收藏', $r('app.media.ic_collect'), POP_MENU_TYPE.COLLECT),
          new BubbleMsgItem('删除', $r('app.media.ic_del'), POP_MENU_TYPE.DEL),
          new BubbleMsgItem('下载', $r('app.media.ic_download'), POP_MENU_TYPE.DOWNLOAD)]
        break;
      case ChatTypeEnum.CHAT_TYPE_SOUND: //语音消息
        data = [
          new BubbleMsgItem('收藏', $r('app.media.ic_collect'), POP_MENU_TYPE.COLLECT),
          new BubbleMsgItem('删除', $r('app.media.ic_del'), POP_MENU_TYPE.DEL),
          new BubbleMsgItem('语音转文字', $r('app.media.ic_speech_to_text'), POP_MENU_TYPE.SPEECH_TO_TEXT),
          new BubbleMsgItem('免提播放', $r('app.media.ic_play_speaker'), POP_MENU_TYPE.PLAY_SPEAKER)]
        break;
      case ChatTypeEnum.CHAT_TYPE_VIDEO: //视频消息
        data = [
          new BubbleMsgItem('转发', $r('app.media.ic_relay'), POP_MENU_TYPE.RELAY),
          new BubbleMsgItem('收藏', $r('app.media.ic_collect'), POP_MENU_TYPE.COLLECT),
          new BubbleMsgItem('删除', $r('app.media.ic_del'), POP_MENU_TYPE.DEL),
          new BubbleMsgItem('静音播放', $r('app.media.ic_play_mute'), POP_MENU_TYPE.PLAY_MUTE),
          new BubbleMsgItem('下载', $r('app.media.ic_download'), POP_MENU_TYPE.DOWNLOAD)]
        break;
      case ChatTypeEnum.CHAT_TYPE_LOCATION: //地理位置消息
        data = [
          new BubbleMsgItem('转发', $r('app.media.ic_relay'), POP_MENU_TYPE.RELAY),
          new BubbleMsgItem('收藏', $r('app.media.ic_collect'), POP_MENU_TYPE.COLLECT),
          new BubbleMsgItem('删除', $r('app.media.ic_del'), POP_MENU_TYPE.DEL)]
        break;

      default:
        break;
    }
    return data
  }
}

export class Params {
  width: number | string = 0
  height: number | string = 0
  chatVM: ChatContentSingleModel | undefined = undefined

  constructor(width: number | string, height: number | string, chatVM: ChatContentSingleModel) {
    this.width = width
    this.height = height
    this.chatVM = chatVM
  }
}