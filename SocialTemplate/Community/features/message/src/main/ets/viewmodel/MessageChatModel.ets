import { pasteboard, systemDateTime } from '@kit.BasicServicesKit';
import { PersistenceV2 } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { audio } from '@kit.AudioKit';
import { rcp } from '@kit.RemoteCommunicationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Constants, GlobalContext, RouterMap, TValueType, UserInfo } from 'common';
import { CMChatConversation, CMChatConversationType, CMChatFactory, CMChatMessage } from 'instant_messaging';
import { ChatInputSendMessageModel } from 'chat_input';
import {
  ChatContentAudio,
  ChatContentImage,
  ChatContentSingleModel,
  ChatTypeEnum,
  RcpDownloader,
  SaveAlbumTool
} from 'chat_window';
import { phoneRouterControl } from 'oh_router';
import { SpeechRecognizerU } from '../utils/SpeechRecognizerU';
import { ChatSettingsPageBuilder } from '../view/ChatSettings';
import { ChatSettingsViewModel } from './ChatSettingsViewModel';
import { ForwardChatPageBuilder } from '../view/ForwardChatPage';
import { AudioRendererUtil } from '../utils/AudioRendererUtil';
import { CollectDataManager } from 'chat_history_collection';
import { POP_MENU_TYPE, PromptActionClass } from 'chat_window';
import { PrivateChatSettingEnum } from '../utils/MessageEnum';
import { PrivateChatSettingModel } from './PrivateChatSettingModel';
import { PrivateChatSettingsPageBuilder } from '../view/PrivateChatSettingsPage';
import { ViewLocationPageBuilder } from '../view/ViewLocationPage';
import { VideoPageViewBuilder } from '../view/VideoPageView';
import { CheckFullImagePageBuilder } from '../view/CheckFullImagePage';

const DEVICE_TYPE = [audio.DeviceType.EARPIECE, audio.DeviceType.SPEAKER]
const DOMAIN: number = 0x0000
const TAG: string = 'MessageChatModel'

@ObservedV2
export class MessageChatModel {
  @Trace chatContentList: ChatContentSingleModel[] = [];
  @Trace conversationVM: CMChatConversation = new CMChatConversation();
  @Trace pageTitle: string = '';
  // 是否是群聊中的成员
  @Trace isGroupMember: boolean = true;
  @Trace userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  scroller: ListScroller = new ListScroller();
  private context: UIContext
  private downloader?: RcpDownloader
  // 语音转文字识别
  currentSingleModel?: ChatContentSingleModel
  private recognizer: SpeechRecognizerU = new SpeechRecognizerU((result: string) => {
    hilog.info(DOMAIN, TAG, '%{public}s', 'result=' + result)
    if (this.currentSingleModel !== undefined) {
      this.currentSingleModel.speechToText = result
    }
  })
  audioRendererUtil: AudioRendererUtil = AudioRendererUtil.getInstance()
  deviceType = 0 //语音输出设备，默认听筒
  // 是否是好友
  @Trace isFriend: boolean = false;
  videoMutyStatus = true //视频播放音量状态（静音/非静音）

  constructor(context: UIContext) {
    this.context = context
  }

  /**
   * 获取历史消息、撤回、删除、标记已读等高级接口
   */
  async getHistoryMessageList() {
    let result =
      await CMChatFactory.instance.getHistoryMessageList(this.conversationVM.userId, this.conversationVM.groupID);
    this.chatContentList = [];
    for (let index = 0; index < result.length; index++) {
      const element = result[index];
      let chatVM = chatParseMessageModel(element, this.conversationVM.type, this.userInfo);
      this.chatContentList.push(chatVM);
      if (index === result.length - 1) {
        this.cleanConversationUnreadMessageCount(chatVM.timestamp);
      }
    }
    this.scroller.scrollToIndex(this.chatContentList.length - 1);
  }

  /**
   * 添加高级消息的事件监听器
   */
  addAdvancedMsgListener() {
    CMChatFactory.instance.addAdvancedMsgListener({
      onRecvNewMessage: (message: CMChatMessage) => {
        let chatVM = chatParseMessageModel(message, this.conversationVM.type, this.userInfo);
        this.chatContentList.push(chatVM);
        this.cleanConversationUnreadMessageCount(chatVM.timestamp);
        this.scroller.scrollToIndex(this.chatContentList.length - 1, true);
        PromptActionClass.closeDialog()
      }
    })
  }

  /**
   * 移除高级消息监听器
   */
  removeAdvancedMsgListener() {
    CMChatFactory.instance.removeAdvancedMsgListener();
  }

  sendMessageAction(content: ChatInputSendMessageModel) {
    if (this.conversationVM.type === CMChatConversationType.CHAT_GROUP &&
      !this.isGroupMember) {
      GlobalContext.getUIContext().getPromptAction().showToast({
        message: '你已不在群组中，无法发送消息',
        alignment: Alignment.Center
      })
      return;
    }
    if (this.conversationVM.type === CMChatConversationType.CHAT_C2C &&
      !this.isFriend) {
      GlobalContext.getUIContext().getPromptAction().showToast({
        message: '你们不是好友，无法发送消息',
        alignment: Alignment.Center
      })
      return;
    }

    switch (content.messageType) {
      case ChatTypeEnum.CHAT_TYPE_IMAGE: {
        this.createImageMessage(content.pictureUrl);
      }
        break
      case ChatTypeEnum.CHAT_TYPE_SOUND: {
        this.createSoundMessage(content.audioUrl, content.duration / 1000);
      }
        break
      case ChatTypeEnum.CHAT_TYPE_TEXT: {
        this.createTextMessage(content.content);
      }
        break
      case ChatTypeEnum.CHAT_TYPE_LOCATION: {
        this.createLocationMessage(content.locationName, content.locationDesc,
          content.locationLongitude, content.locationLatitude);
      }
        break
      case ChatTypeEnum.CHAT_TYPE_VIDEO: {
        this.createVideoMessage(content.videoUrl, content.mimeType, content.duration / 1000, content.snapshotPath);
      }
        break
      default:
        break
    }
  }

  /**
   * 创建自定义消息
   */
  async createTextMessage(context: string) {
    if (context.length === 0) {
      return;
    }
    let result = await CMChatFactory.instance.createTextMessage(context,
      this.conversationVM.userId, this.conversationVM.groupID);
    this.addChatToComponent(result);
  }

  /**
   * 创建地理位置消息
   */
  async createLocationMessage(name: string, desc: string, longitude: number, latitude: number) {
    let result = await CMChatFactory.instance.createLocationMessage(name, desc, longitude, latitude,
      this.conversationVM.userId, this.conversationVM.groupID);
    this.addChatToComponent(result);
  }

  async createImageMessage(filePath: string) {
    let result = await CMChatFactory.instance.createImageMessage(filePath,
      this.conversationVM.userId, this.conversationVM.groupID);
    this.addChatToComponent(result);
  }

  async createSoundMessage(filePath: string, duration: number) {
    let result = await CMChatFactory.instance.createSoundMessage(filePath, duration,
      this.conversationVM.userId, this.conversationVM.groupID);
    this.addChatToComponent(result);
  }

  /**
   * 视频接口的调用
   */
  async createVideoMessage(videoFilePath: string, type: string, duration: number,
    snapshotPath: string) {
    let result = await CMChatFactory.instance.createVideoMessage(videoFilePath, type, duration, snapshotPath,
      this.conversationVM.userId, this.conversationVM.groupID);
    this.addChatToComponent(result);
  }

  private addChatToComponent(result: CMChatMessage) {
    let chatVM = chatParseMessageModel(result, this.conversationVM.type, this.userInfo);
    this.chatContentList.push(chatVM);
    this.scroller.scrollToIndex(this.chatContentList.length - 1, true);
  }

  /**
   * 清理会话的未读消息计数
   *
   * @param conversationID  会话唯一 ID，C2C 单聊组成方式为: 'c2c_userID'；群聊组成方式为: 'group_groupID'
   */
  cleanConversationUnreadMessageCount(cleanTimestamp: number) {
    CMChatFactory.instance.cleanConversationUnreadMessageCount(this.conversationVM.conversationID, cleanTimestamp);
  }

  /**
   * 拉取群资料
   *
   * @param groupIDList 群组 ID 列表
   */
  async getGroupsInfo() {
    if (this.conversationVM.groupID.length === 0) {
      return;
    }

    let result = await CMChatFactory.instance.getGroupsInfo([this.conversationVM.groupID]);
    this.pageTitle = result[0].groupName;

    try {
      let groupList = await CMChatFactory.instance.getGroupMemberList(this.conversationVM.groupID, 0, 0);
      if (groupList?.memberInfoList.length === 0) {
        this.isGroupMember = false;
      } else {
        this.isGroupMember = true;
      }
    } catch (err) {
      this.isGroupMember = false;
    }
  }

  /**
   * 获取指定好友资料
   *
   * @param userIDList 好友 userID 列表
   *                 - ID 建议一次最大 100
   * 个，因为数量过多可能会导致数据包太大被后台拒绝，后台限制数据包最大为 1M。
   */
  async getFriendsInfo() {
    if (this.conversationVM.userId.length === 0) {
      return;
    }

    let result = await CMChatFactory.instance.getFriendsInfo([this.conversationVM.userId]);
    const friendRemark = result[0].friendRemark;
    if (friendRemark !== undefined && friendRemark.length > 0) {
      this.pageTitle = friendRemark;
    } else {
      this.pageTitle = Constants.getMockNickName(this.conversationVM.userId);
    }
  }

  /**
   * 获取指定好友资料
   *
   * @param userIDList 好友 userID 列表
   *                 - ID 建议一次最大 100
   * 个，因为数量过多可能会导致数据包太大被后台拒绝，后台限制数据包最大为 1M。
   */
  async checkFriend() {
    if (this.conversationVM.userId.length === 0) {
      return;
    }

    let result = await CMChatFactory.instance.checkFriend([this.conversationVM.userId]);
    this.isFriend = result[0]?.isFriend;
  }

  gotoChatSettingPage() {
    if (this.conversationVM.type === CMChatConversationType.CHAT_C2C) {
      let settingsVM = new PrivateChatSettingModel();
      settingsVM.pageType = PrivateChatSettingEnum.C2C;
      settingsVM.conversationID = this.conversationVM.conversationID;
      settingsVM.userId = this.conversationVM.userId;
      settingsVM.showName = this.pageTitle;
      phoneRouterControl.jumpPage({
        pageName: RouterMap.PRIVATE_CHAT_SETTINGS_PAGE,
        builder: wrapBuilder(PrivateChatSettingsPageBuilder),
        param: settingsVM as TValueType,
        onPop: (_popInfo: PopInfo) => {
          this.getHistoryMessageList();
          this.getFriendsInfo();
          this.checkFriend();
        }
      })
    } else {
      if (!this.isGroupMember) {
        GlobalContext.getUIContext().getPromptAction().showToast({
          message: '你已不在群组中'
        })
        return;
      }

      let settingsVM = new ChatSettingsViewModel();
      settingsVM.conversationID = this.conversationVM.conversationID;
      settingsVM.groupId = this.conversationVM.groupID;
      phoneRouterControl.jumpPage({
        pageName: RouterMap.CHAT_SETTINGS,
        builder: wrapBuilder(ChatSettingsPageBuilder),
        param: settingsVM as TValueType,
        onPop: (_popInfo: PopInfo) => {
          this.getHistoryMessageList();
          this.getGroupsInfo();
        }
      })
    }
  }

  chatBubbleClick(chatVM: ChatContentSingleModel) {
    if (chatVM.chatType === ChatTypeEnum.CHAT_TYPE_LOCATION) {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.VIEW_LOCATION_PAGE,
        builder: wrapBuilder(ViewLocationPageBuilder),
        param: chatVM as TValueType
      })
    } else if (chatVM.chatType === ChatTypeEnum.CHAT_TYPE_VIDEO) {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.VIDEO_PAGE_VIEW,
        param: {
          'videoChatSrc': chatVM.videoChatSrc,
          'videoMutyStatus': this.videoMutyStatus
        } as Record<string, string | boolean>,
        builder: wrapBuilder(VideoPageViewBuilder)
      })
    } else if (chatVM.chatType === ChatTypeEnum.CHAT_TYPE_IMAGE) {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.FULL_IMAGE_PAGE,
        param: chatVM.imageInfo![0].url,
        builder: wrapBuilder(CheckFullImagePageBuilder)
      })
    } else if (chatVM.chatType === ChatTypeEnum.CHAT_TYPE_SOUND) {
      if (chatVM.soundStatus && this.audioRendererUtil.url === chatVM.soundInfo?.url) {
        this.soundStop()
      } else {
        this.soundStart(chatVM)
      }
      if (this.currentSingleModel) {
        this.currentSingleModel.soundStatus = false
      }
      this.currentSingleModel = chatVM

    }
  }

  /*
   * 长按气泡弹窗菜单点击事件
   */
  onPopMenuClick(chatVM: ChatContentSingleModel, type: POP_MENU_TYPE) {
    switch (type) {
      case POP_MENU_TYPE.COPY:
        this.popMenuCopy(chatVM.textElem)
        break;
      case POP_MENU_TYPE.RELAY:
        this.gotoForwardMessage(chatVM);
        break;
      case POP_MENU_TYPE.COLLECT:
        this.collectMsg(chatVM)
        break;
      case POP_MENU_TYPE.DEL:
        this.delMsg(chatVM)
        break;
      case POP_MENU_TYPE.SPEECH_TO_TEXT:
        this.convertToText(chatVM)
        break;
      case POP_MENU_TYPE.PLAY_SPEAKER:
        const tempType = (DEVICE_TYPE.length - 1) - this.deviceType
        this.setDeviceType(tempType)
        break;
      case POP_MENU_TYPE.PLAY_MUTE:
        this.setVideoMutyStatus()
        break;
      case POP_MENU_TYPE.DOWNLOAD:
        if (chatVM.chatType === ChatTypeEnum.CHAT_TYPE_IMAGE) {
          this.imageDownload(chatVM)
        }
        if (chatVM.chatType === ChatTypeEnum.CHAT_TYPE_VIDEO) {
          this.videoDownload(chatVM)
        }
        break;

      default:
        break;
    }
  }

  //视频下载
  videoDownload(chatVM: ChatContentSingleModel) {
    let saveAlbumTool: SaveAlbumTool = new SaveAlbumTool()
    const url = chatVM.videoChatSrc
    let fileName: string = url?.split('/').pop() as string
    fileName = fileName.split('?')[0]
    let tmpContext: common.UIAbilityContext = this.context.getHostContext() as common.UIAbilityContext
    let filePath = `${tmpContext.cacheDir}/downloads/` + fileName
    if (fs.accessSync(filePath)) {
      saveAlbumTool.saveHttpVideo(filePath, this.context)
      return
    }
    if (!this.downloader) {
      this.downloader = new RcpDownloader(this.context.getHostContext() as common.UIAbilityContext)
    }

    this.downloader.startDownload(url, fileName).then((result: rcp.Response) => {
      if (result.statusCode === 200) {
        saveAlbumTool.saveHttpVideo(filePath, this.context)
      } else {
        this.context.getPromptAction().showToast({ message: '视频下载成功' })
      }
    }).catch(() => {
      this.context.getPromptAction().showToast({ message: '视频下载失败' })
    })
  }

  //图片下载
  imageDownload(chatVM: ChatContentSingleModel) {
    let saveAlbumTool: SaveAlbumTool = new SaveAlbumTool()
    const imgSrc = chatVM.imageInfo?.[0].url || ''
    let fileName: string = imgSrc?.split('/').pop() as string
    fileName = fileName.split('?')[0]
    let tmpContext: common.UIAbilityContext = this.context.getHostContext() as common.UIAbilityContext
    let filePath = `${tmpContext.cacheDir}/downloads/` + fileName
    if (fs.accessSync(filePath)) {
      saveAlbumTool.saveAlbum(filePath, this.context)
      return
    }
    if (!this.downloader) {
      this.downloader = new RcpDownloader(this.context.getHostContext() as common.UIAbilityContext)
    }

    this.downloader.startDownload(imgSrc, fileName).then((result: rcp.Response) => {
      if (result.statusCode === 200) {
        saveAlbumTool.saveAlbum(filePath, this.context)
      } else {
        this.context.getPromptAction().showToast({ message: $r('app.string.image_download_failed') })
      }
    }).catch(() => {
      this.context.getPromptAction().showToast({ message: $r('app.string.image_download_failed') })
    })
  }

  //收藏
  collectMsg(chatVM: ChatContentSingleModel) {
    CollectDataManager.getInstance().addCollectMsg(chatVM)
    GlobalContext.getUIContext().getPromptAction().showToast({
      message: '收藏成功'
    })
  }

  //删除消息
  delMsg(chatVM: ChatContentSingleModel) {
    CMChatFactory.instance.delMessages([chatVM.forwardMessage as object])
    const index = this.chatContentList.findIndex(val => val.chatId === chatVM.chatId) ?? -1
    if (index > -1) {
      this.chatContentList.splice(index, 1)
    }
    GlobalContext.getUIContext().getPromptAction().showToast({
      message: '删除成功'
    })
  }

  // 语音转换为文字
  convertToText(chatVM: ChatContentSingleModel) {
    this.currentSingleModel = chatVM

    // speechRecognizer.createEngine参数一致，对象唯一
    this.recognizer.setListener()
    let url: string = chatVM.soundInfo?.url ?? ''
    let fileName: string = url.split('/').pop() as string
    fileName = fileName.split('?')[0]
    let tmpContext: common.UIAbilityContext = this.context.getHostContext() as common.UIAbilityContext
    let filePath = `${tmpContext.cacheDir}/downloads/` + fileName
    if (fs.accessSync(filePath)) {
      this.recognizer.writeAudio(Date.now().toString(), filePath)
      return
    }

    this.downloader = new RcpDownloader(this.context.getHostContext() as common.UIAbilityContext)
    this.downloader.startDownload(url, fileName).then((_resp) => {
      this.recognizer.writeAudio(Date.now().toString(), filePath)
    }).catch(() => {
      this.context.getPromptAction().showToast({ message: $r('app.string.download_failed') })
    })
  }

  /*
   * 气泡菜单-复制
   */
  async popMenuCopy(content: string) {
    try {
      const systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
      let pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, content);
      await systemPasteboard.setData(pasteData);
      GlobalContext.getUIContext().getPromptAction().showToast({
        message: '复制成功'
      })
    } catch (err) {
      GlobalContext.getUIContext().getPromptAction().showToast({
        message: '复制失败'
      })
    }
  }

  /*
   * 设置语音输出设备
   */
  setDeviceType(deviceType: number) {
    this.deviceType = deviceType
    this.audioRendererUtil.setOutDevice(DEVICE_TYPE[this.deviceType])
  }

  /*
   * 语音播放状态回调
   */
  soundStatusCallBack = (status: boolean) => {
    if (this.currentSingleModel) {
      this.currentSingleModel.soundStatus = status
    }
  }

  /*
   * 语音开始播放
   */
  async soundStart(chatVM: ChatContentSingleModel) {
    await this.audioRendererUtil.readySoundFile(chatVM.soundInfo?.url, this.context)
    this.audioRendererUtil.setOutDevice(DEVICE_TYPE[this.deviceType])
    this.audioRendererUtil.start(chatVM.soundInfo?.url || '')
  }


  /*
   * 语音停止播放
   */
  soundStop() {
    this.audioRendererUtil.stop()
  }

  /**
   * 跳转转发消息页面
   */
  gotoForwardMessage(chatVM: ChatContentSingleModel) {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.FORWARD_CHAT_PAGE,
      builder: wrapBuilder(ForwardChatPageBuilder),
      param: chatVM as TValueType
    })
  }

  //设置视频播放的静音状态
  setVideoMutyStatus() {
    this.videoMutyStatus = !this.videoMutyStatus
  }
}

export function chatParseMessageModel(element: CMChatMessage, type: number, userInfo: UserInfo) {
  let chatVM = new ChatContentSingleModel();
  chatVM.forwardMessage = element.forwardMessage;
  chatVM.chatId = element.msgID;
  chatVM.conversationType = type;
  chatVM.timestamp = element.timestamp;
  chatVM.chatType = element.elemType;
  chatVM.groupId = element.groupID ?? '';
  chatVM.userId = element.userID ?? '';
  chatVM.sender = element.sender;
  chatVM.groupTipContent = element.groupTipContent;
  chatVM.keyId = element.seq + systemDateTime.getTime(true).toString();
  chatVM.isOwner = element.isSelf;
  chatVM.textElem = element.textElem;
  chatVM.locationName = element.locationName;
  chatVM.locationDesc = element.locationDesc;
  chatVM.locationLongitude = element.locationLongitude;
  chatVM.locationLatitude = element.locationLatitude;
  chatVM.videoChatSrc = element.videoChatSrc;
  chatVM.type = element.type;
  chatVM.duration = element.duration;
  chatVM.snapshotPath = element.snapshotPath;
  if (chatVM.isOwner) {
    chatVM.avatarUrl = userInfo.avatarUrl;
    chatVM.nickName = userInfo.nickName;
  } else {
    chatVM.nickName = Constants.getMockNickName(element.sender);
    chatVM.avatarUrl = Constants.getMockAvatar(element.sender);
  }
  chatVM.avatarUrl = element.faceURL;
  chatVM.nickName = element.nickName;
  chatVM.friendRemark = element.friendRemark;
  if (element.imageInfo !== undefined) {
    let imgInfoList: ChatContentImage[] = []
    element.imageInfo.forEach((item) => {
      const tmpContentImgInfo = new ChatContentImage()
      tmpContentImgInfo.uuid = item.uuid
      tmpContentImgInfo.type = item.type
      tmpContentImgInfo.size = item.size
      tmpContentImgInfo.width = item.width
      tmpContentImgInfo.height = item.height
      tmpContentImgInfo.url = item.url
      imgInfoList.push(tmpContentImgInfo)
    })
    chatVM.imageInfo = imgInfoList
  }
  if (element.soundInfo !== undefined) {
    const audioInfo: ChatContentAudio = new ChatContentAudio()
    audioInfo.path = element.soundInfo.path
    audioInfo.uuid = element.soundInfo.uuid
    audioInfo.dataSize = element.soundInfo.dataSize
    audioInfo.duration = element.soundInfo.duration
    audioInfo.url = element.soundInfo.url
    chatVM.soundInfo = audioInfo
  }
  return chatVM;
}