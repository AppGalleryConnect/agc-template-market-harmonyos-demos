import { LiveItem } from '../../../../Index'
import { LiveCard } from '../components/MoreLive'
import { BaseChatMessage } from '../components/public_screen/chat/BaseChatMesage'
import { ChatManager } from '../components/public_screen/chat/ChatManager'
import { SystemChat } from '../components/public_screen/views/SystemChat'
import { Audience } from '../models/Audience'
import { GiftModel } from '../models/GiftGroup'

@ObservedV2
export class LiveInteractionMgr {
  @Trace presenter?: Audience
  @Trace audiences: Audience[] = []
  @Trace rankList: LiveItem[] = []
  loadingError: number = 0
  @Trace rankId: number = 1
  shareInfo:ShareInfo = new ShareInfo('', '', '', '')
  chatMgr: ChatManager = new ChatManager()
  defaultResolution: string = ''
  resolution: string = ''
  reason: string[] = []
  shareUrl: string = ''
  giftData: Array<GiftModel> = []
  onSendGift?: Function
  onComment: Function = () => {
  }
  onLiveClick: Function = (card: LiveCard) => {
  }
  onExit: Function = () => {
  }
  onProfileClick: Function = (id: string): void => {
  }
  onFullScreen: Function = () => {
  };
  onAddFollowingClick: Function = (id: string) => {
  }
  onDeleteFollowingClick: Function = (id: string) => {
  }
  onLike: Function = () => {
  }
  onGetMoreLives: Function = () => {
  }
  onChangeResolution: Function = () => {
  }
  onReport: Function = () => {
  }
  onClearScreen: Function = () => {
  }
  onPip: Function = () => {
  }
  onCheckLogin: Function = () => {
  }
  onGetLoginUserInfo: Function = () => {
  }
  onLogin: Function = () => {
  }
  onPay: Function = (item: GiftModel) => {
  }

  setGiftData(giftData: Array<GiftModel>) {
    this.giftData = giftData
  }

  setPresenter(presenter: Audience) {
    this.presenter = presenter
  }

  getPresenter(): Audience | undefined {
    return this.presenter
  }

  setAudience(audiences: Audience[]) {
    this.audiences = audiences
  }

  setLoadingError(errorCode: number) {
    this.loadingError = errorCode
  }

  addSystemChat(message: string) {
    this.chatMgr.addSystemMessage(new SystemChat(message))
  }

  addNormalChat(chat: BaseChatMessage) {
    this.chatMgr.addNormalChatMessage(chat)
  }

  sendGift(gift:Gift) {
    if (this.onSendGift) {
      this.onSendGift(gift)
    }
  }
}

export interface LoginUserInfo {
  id: number;
  avatar: string | Resource;
  name: string;
  nickname: string;
}

export class Gift {
  sender: string
  senderAvatar: ResourceStr | string | Resource
  giftId: number
  giftCount: number

  constructor(sender: string, senderAvatar: ResourceStr | string, giftId: number, giftCount: number = 1) {
    this.sender = sender
    this.senderAvatar = senderAvatar
    this.giftId = giftId
    this.giftCount = giftCount
  }
}

export class ShareInfo{
  cover: ResourceStr
  title: string
  articleFrom: string
  id:string
  constructor(cover:string, title:string, articleFrom:string, id:string) {
    this.cover = cover
    this.title = title
    this.articleFrom = articleFrom
    this.id = id
  }
}