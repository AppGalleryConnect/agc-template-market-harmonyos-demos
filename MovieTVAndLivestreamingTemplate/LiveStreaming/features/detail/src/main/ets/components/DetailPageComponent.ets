import { AvSessionController, PlayController, PlaySession, VideoPlayData } from '@agctemplate/video_swiper';
import { common } from '@kit.AbilityKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import {
  FullScreenLayer,
  LiveInteractionMgr,
  VerticalScreenLayer,
  LoginUserInfo,
  GiftModel,
  PreferType,
  RichChat,
  Audience,
  LiveItem,
  Gift,
  ShareInfo
} from 'live_interaction';
import { RichEditorSpan } from 'live_interaction';
import { MoreLiveCard } from 'live_interaction';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { OrderInfo, OrderState, SampleOrderInfo } from '../models/OrderInfo';
import { SimpleChat } from 'live_interaction';
import { deviceInfo, emitter } from '@kit.BasicServicesKit';
import { display } from '@kit.ArkUI';
import { container, PreferConstant, PreferenceUtil } from '@agctemplate/utils';
import {
  AccountUtil,
  AppStorageKeys,
  BarVM,
  BreakPoint,
  cardsData,
  LiveCardModel
} from '@agctemplate/widgets';
import { RouterMap, RouterModule } from '@agctemplate/router_module';
import { AggregatedPaymentPicker, ChannelType } from '@agctemplate/aggregated_payment';
import { LiveInfo } from '../models/LiveInfo';
import { addFollowing, convertAudience, deleteFollowing } from '../models/AudienceData';
import { jumpProfilePage } from '../profile/ProfilePage';
import { TextInput } from '../input/CommentKeyboard';
import { AudienceArrRes, AudienceRes, RequestAPI } from '@agctemplate/server';
import { UserInfo } from 'live_interaction'

const TAG = '[VerticalScreenComponent]'
const PORTRAIT = 0
const LANDSCAPE = 1
const PORTRAIT_INVERTED = 2
const LANDSCAPE_INVERTED = 3

@ComponentV2
export struct DetailPageComponent {
  liveInteractionMgr: LiveInteractionMgr = new LiveInteractionMgr()
  @Local watchRecords: LiveCardModel = AppStorageV2.connect(LiveCardModel, () => new LiveCardModel(cardsData[0]))!
  @Param @Require videoData: VideoPlayData;
  @Param @Require playControl: PlayController;
  @Param @Require playerSession: PlaySession
  @Local showControl: boolean = true // 用于控制清屏
  @Local screenDirection: number = display.getDefaultDisplaySync().orientation // 0：竖屏 1：横屏 2：反向竖屏 3：反向横屏
  @Local isShowMoreSettings: boolean = false
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private windowClass = (this.context as common.UIAbilityContext).windowStage.getMainWindowSync()
  @Local logoUser: UserInfo = AccountUtil.getUserInfo();
  @Local payItem: GiftModel = new GiftModel('', '', 0, 0)
  @Local preferType: PreferType = PreferType.PORTRAIT
  private preferenceVideoQuality = PreferenceUtil.getInstance(this.context, PreferConstant.VIDEO_QUALITY)
  restoreDirection: number = 0
  @Local breakPoint: BreakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint())!;
  @Local isFromVertical: boolean = false
  callback: Callback<number> = (data: number) => {
    this.screenDirection = display.getDefaultDisplaySync().orientation
  }

  setOrientation(orientation: number) {
    try {
      this.windowClass.setPreferredOrientation(orientation)
    } catch (error) {
      let err = error as BusinessError;
      console.error(`setOrientation failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
  }

  @Monitor('breakPoint.value')
  onChange() {
    this.initPlayerLayout()
  }

  changeOrientation() {
    if (this.screenDirection === PORTRAIT || this.screenDirection === PORTRAIT_INVERTED) {
      this.setOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE_RESTRICTED)
      try {
        this.windowClass.setWindowSystemBarEnable([])
      } catch (e) {
        hilog.error(0x0000, TAG, `setWindowSystemBarEnable failed: ${e}`);
      }
      this.screenDirection = LANDSCAPE
      this.playControl.disableSwipe(true)
      this.playControl.backPressListener().registerOnBackPress(() => {
        this.onBackPressed()
      })
    } else {
      this.playControl.backPressListener().clearOnBackPress()
      this.setOrientation(window.Orientation.USER_ROTATION_PORTRAIT)
      try {
        this.windowClass.setWindowSystemBarEnable(['status', 'navigation'])
      } catch (e) {
        hilog.error(0x0000, TAG, `setWindowSystemBarEnable failed: ${e}`);
      }
      this.screenDirection = PORTRAIT
      this.playControl.disableSwipe(false)
    }
    this.initPlayerLayout()
    this.isFromVertical = true
  }

  onBackPressed(): void {
    hilog.info(0x000, TAG, 'onBackPress')
    if (this.screenDirection === LANDSCAPE || this.screenDirection === LANDSCAPE_INVERTED) {
      this.changeOrientation()
    }
  }

  aboutToDisappear(): void {
    try {
      display.off('change', this.callback)
      this.playControl.backPressListener().clearOnBackPress()
      TextInput.instance.spansRemain = []
      emitter.off(4)
      this.setOrientation(window.Orientation.UNSPECIFIED)
    } catch (e) {
      hilog.error(0x0000, TAG, `aboutToDisappear failed: ${e}`);
    }
  }

  initPlayerLayout() {
    if (this.preferType === PreferType.LANDSCAPE &&
      (this.screenDirection === PORTRAIT || this.screenDirection === PORTRAIT_INVERTED)) {
      this.playerSession.playLayout.playerPositionX = 0;
      this.playerSession.playLayout.playerPositionY = 160;
      this.playerSession.playLayout.playerWidth = '100%';
      this.playerSession.playLayout.playerHeight = this.breakPoint.value === 'md' ? '40%' : '204'
    } else {
      this.playerSession.playLayout.playerPositionX = 0;
      this.playerSession.playLayout.playerPositionY = 0;
      this.playerSession.playLayout.playerWidth = '100%';
      this.playerSession.playLayout.playerHeight = '100%'
    }
  }

  onPayGiftSuccess(name: string, price: number, id: number) {
    let sampleOrderInfo = AppStorageV2.connect(SampleOrderInfo, () => new SampleOrderInfo())!;
    let orderNo = '202507' + Date.now()
    let content = name
    let orderInfo =
      new OrderInfo(id.toString(), OrderState.Paid, orderNo, content, false)
    sampleOrderInfo.orderInfos.unshift(orderInfo)
    this.liveInteractionMgr.sendGift(new Gift(this.logoUser.name, this.logoUser.avatar, id, 1))
    this.showToast('支付成功~');
  }

  onPayGiftError(name: string, price: number, id: number) {
    let sampleOrderInfo = AppStorageV2.connect(SampleOrderInfo, () => new SampleOrderInfo())!;
    let orderNo = '202507' + Date.now()
    let content = name
    let orderInfo =
      new OrderInfo(id.toString(), OrderState.WaitToPay, orderNo, content, false)
    orderInfo.startTime = Date.now()
    sampleOrderInfo.orderInfos.push(orderInfo)
    AppStorageV2.connect(SampleOrderInfo, () => sampleOrderInfo)!;
    this.showToast('支付失败~');
  }

  aboutToAppear() {
    try {
      display.on('change', this.callback)
    } catch (e) {
    }
    this.playControl.loopPlay = true
    container.resolve(RequestAPI).getAudience((this.videoData as LiveInfo).data.streamer.id).then((res) => {
      let audienceArr: Audience[] = [];
      (res.getBody() as AudienceArrRes).audienceArr.map((value: AudienceRes) => {
        audienceArr.push(convertAudience(value))
      })
      this.liveInteractionMgr.setAudience(audienceArr)
    })

    this.playerSession.onStateChange('stateChange', (state: string) => {
      // 进入详情播放页播放下一集
      if (state === 'playing') {
        (this.videoData as LiveInfo).liveId = this.watchRecords.id;
        container.resolve(RequestAPI).setMyWatchRecord((this.videoData as LiveInfo).liveId)
      }
    })
    this.preferType = (this.videoData as LiveInfo).preferType
    this.initPlayerLayout()
    this.liveInteractionMgr.setPresenter(convertAudience((this.videoData as LiveInfo).data.streamer))
    this.liveInteractionMgr.rankList = this.getRankList()
    this.liveInteractionMgr.defaultResolution =
      this.preferenceVideoQuality.get('resolution', '1080P 原画（高帧率）') as string
    let event: emitter.InnerEvent = {
      eventId: 4
    };
    let callback: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
      AvSessionController.getInstance().isAllow =
        PreferenceUtil.getInstance(this.getUIContext().getHostContext(), PreferConstant.BACKGROUND_PLAY)
          .get('backgroundPlay') as boolean
      hilog.info(0x0000, TAG, `eventData: ${JSON.stringify(eventData)}`);
    }
    try {
      emitter.on(event, callback);
    } catch (e) {
    }

    this.liveInteractionMgr.rankId = 2
    this.liveInteractionMgr.onFullScreen = () => {
      this.changeOrientation()
    }
    this.liveInteractionMgr.onGetMoreLives = (): MoreLiveCard[] => {
      return this.getMoreLives()
    }
    this.liveInteractionMgr.onClearScreen = (isClear: boolean) => {
      hilog.info(0x000, TAG, 'onClearScreen:' + isClear)
    }
    this.liveInteractionMgr.shareInfo =
      new ShareInfo((this.videoData as LiveInfo).data.cover, (this.videoData as LiveInfo).data.title,
        (this.videoData as LiveInfo).data.streamer.nickName, (this.videoData as LiveInfo).data.id)
    this.liveInteractionMgr.onComment = () => {
      RouterModule.push({
        url: RouterMap.COMMENT_KEY_BOARD_PAGE, onPop: (popInfo: PopInfo) => {
          if (popInfo) {
            this.liveInteractionMgr.chatMgr.addNormalChatMessage(new RichChat(this.logoUser.name,
              popInfo.result as RichEditorSpan[]))
            let info = popInfo.result as RichEditorSpan[]
          }
        }
      })
    }
    this.liveInteractionMgr.onProfileClick = (audience: Audience) => {
      if (this.screenDirection === PORTRAIT || this.screenDirection === PORTRAIT_INVERTED) {
        jumpProfilePage(audience)
      }
    }
    this.liveInteractionMgr.onAddFollowingClick = (id: string) => {
      addFollowing(id)
    }
    this.liveInteractionMgr.onDeleteFollowingClick = (id: string) => {
      deleteFollowing(id)
    }
    this.liveInteractionMgr.onExit = () => {
      RouterModule.pop()
    }

    this.liveInteractionMgr.onLike = () => {
      hilog.info(0x000, TAG, 'onLike')
    }
    this.liveInteractionMgr.onChangeResolution = (resolution: string) => {
      this.liveInteractionMgr.resolution = resolution
      hilog.info(0x000, TAG, 'onChangeResolution')
    }
    this.liveInteractionMgr.onReport = (reasons: Array<string>) => {
      this.liveInteractionMgr.reason = reasons
      hilog.info(0x000, TAG, 'onReport')
    }
    this.liveInteractionMgr.onPip = () => {
      this.playerSession.startPip()
    }
    this.liveInteractionMgr.onCheckLogin = (): boolean => {
      return this.logoUser.isLogin
    }
    this.liveInteractionMgr.onLogin = () => {
      this.playControl.pause();
      let restoreDirection: number = this.screenDirection
      if ((this.screenDirection === LANDSCAPE || this.screenDirection === LANDSCAPE_INVERTED) &&
        (display.getFoldStatus() !== display.FoldStatus.FOLD_STATUS_EXPANDED && deviceInfo.deviceType === 'phone')) {
        this.changeOrientation()
      }
      RouterModule.push({
        url: RouterMap.LOGIN_PAGE, param: true, onPop: () => {
          this.playControl.play();
          if ((restoreDirection === LANDSCAPE || restoreDirection === LANDSCAPE_INVERTED) &&
            (display.getFoldStatus() !== display.FoldStatus.FOLD_STATUS_EXPANDED && deviceInfo.deviceType === 'phone')){
            this.changeOrientation()
          }
        }
      })
    }
    this.liveInteractionMgr.onGetLoginUserInfo = (): LoginUserInfo | null => {
      if (this.logoUser.isLogin) {
        return {
          id: this.logoUser.id,
          name: this.logoUser.name,
          nickname: this.logoUser.nickname,
          avatar: this.logoUser.avatar
        }
      }
      return null
    }
    this.liveInteractionMgr.addSystemChat('欢迎来到华为直播间！华为视频禁止任何传播违法、违规、低俗等信息的行为，一经发现将予以封禁处理。请勿轻信以任何方式的诱导打赏、私下交易等行为，以人身或财产损失。')
    let chat1 = new SimpleChat('卡夫卡的甲虫', '这不行啊，我方不占优势1')
    chat1.like = true
    chat1.fans = true
    chat1.fanName = '无限荣耀'
    chat1.fanLevel = 10
    chat1.pay = true
    chat1.payLevel = 3
    this.liveInteractionMgr.addNormalChat(chat1)
    this.liveInteractionMgr.addNormalChat(new SimpleChat('双子星', '厉害了我的姐~'))
    this.liveInteractionMgr.addNormalChat(new SimpleChat('卡夫卡的甲虫', '这不行啊，我方不占优势3'))
    this.liveInteractionMgr.addNormalChat(new SimpleChat('卡夫卡的甲虫', '这不行啊，我方不占优势4'))
    this.liveInteractionMgr.addNormalChat(new SimpleChat('艾力', '画风好精美'))
    this.liveInteractionMgr.addNormalChat(new SimpleChat('卡夫卡的甲虫', '这不行啊，我方不占优势5'))
    this.liveInteractionMgr.addNormalChat(new SimpleChat('卡夫卡的甲虫', '这不行啊，我方不占优势6'))
    this.liveInteractionMgr.addNormalChat(new SimpleChat('艾力', '画风好精美'))
    this.liveInteractionMgr.addNormalChat(new SimpleChat('双子星', '厉害了我的姐~'))
    this.liveInteractionMgr.addNormalChat(new SimpleChat('卡夫卡的甲虫', '这不行啊，我方不占优势7'))
    this.liveInteractionMgr.addNormalChat(new SimpleChat('卡夫卡的甲虫', '这不行啊，我方不占优势8'))
    this.liveInteractionMgr.addNormalChat(new SimpleChat('艾力', '画风好精美'))
    this.liveInteractionMgr.onPay = (item: GiftModel) => {
      this.isShowPay = true
      this.payItem = item
      this.restoreDirection = this.screenDirection
    }
    this.liveInteractionMgr.setGiftData(giftData)
    this.liveInteractionMgr.onLiveClick = (liveCard: MoreLiveCard) => {
      this.playControl.changeIndex((this.playControl.curentIndex + 2) % 5)
      hilog.debug(0x000, TAG, 'onLiveClick:' + (this.playControl.curentIndex + 2) % 5)
    }
  }

  @Local isShowPay: boolean = false

  @Builder
  paymentChannelSheet() {
    AggregatedPaymentPicker({
      price: this.payItem.price.toString(),
      goodsName: '礼物赠送',
      channelInfo: [{
        channelType: ChannelType.HUAWEI_PAY,
        name: '华为支付',
        icon: $r('app.media.hw_pay'),
        preOrderInfo: '',
      }, {
        channelType: ChannelType.WECHAT_PAY,
        preOrderInfo: '',
        appId: '',
        icon: $r('app.media.wechat'),
        name: '微信支付',
      }, {
        channelType: ChannelType.ALI_PAY,
        name: '支付宝支付',
        icon: $r('app.media.alipay'),
        preOrderInfo: '',
      }],
      paySuccessEvent: () => {
        this.onPayGiftSuccess(this.payItem.name, this.payItem.price, this.payItem.id)
        this.isShowPay = false;
      },
      payFailEvent: () => {
        this.onPayGiftError(this.payItem.name, this.payItem.price, this.payItem.id)
        this.isShowPay = false;
      }
    })
  }

  build() {
    Stack() {
      if (this.screenDirection === PORTRAIT || this.screenDirection === PORTRAIT_INVERTED) {
        VerticalScreenLayer({
          preferType: this.preferType,
          interactionMgr: this.liveInteractionMgr

        })
      } else {
        FullScreenLayer({
          isFromVertical: this.isFromVertical,
          interactionMgr: this.liveInteractionMgr
        })

      }
    }
    .bindSheet($$this.isShowPay, this.paymentChannelSheet(), {
      height: 450, preferType: SheetType.CENTER, onWillDismiss: () => {
        this.isShowPay = false
      }
    })
    .height('100%')
    .width('100%')
    .padding({
      top: this.screenDirection === PORTRAIT || this.screenDirection === PORTRAIT_INVERTED ? BarVM.instance.staBarH : 0,
      bottom: this.screenDirection === PORTRAIT || this.screenDirection === PORTRAIT_INVERTED ? BarVM.instance.aiBarH :
        0
    })

  }

  showToast(message: string) {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: message,
        duration: 2000
      });
    } catch (error) {
      //在此处进行异常处理
    }
  }

  getMoreLives() {
    let cardsData: Array<MoreLiveCard> = [
      {
        cover: 'app.media.cover_3',
        title: '旅行vlog直播',
        watching: 10000,
        category: '旅游',
        streamer: 'Leo在路上',
      } as MoreLiveCard,
      {
        cover: 'app.media.cover_4',
        title: '新版本BOSS速通',
        watching: 16666,
        category: '维京传奇',
        streamer: '暴躁桃子',
      } as MoreLiveCard,
      {
        cover: 'app.media.cover_1',
        title: '游戏冲榜',
        watching: 18100,
        category: '王者荣耀',
        streamer: '轩哥开黑',
      } as MoreLiveCard,
      {
        cover: 'app.media.cover_2',
        title: '美食速递',
        watching: 666,
        category: '美食',
        streamer: '小雅吃',
      } as MoreLiveCard,
      {
        cover: 'app.media.cover_2',
        title: '外卖盲盒挑战',
        watching: 1800,
        category: '美食',
        streamer: '姜姜吃不胖',
      } as MoreLiveCard,
      {
        cover: 'app.media.cover_4',
        title: '弹唱网友点歌',
        watching: 1314,
        category: '唱歌',
        streamer: '吉他老张',
      } as MoreLiveCard,
      {
        cover: 'app.media.cover_3',
        title: '监狱跑刀',
        watching: 78787878,
        category: '三角洲行动',
        streamer: '老飞鱼66',
      } as MoreLiveCard,
      {
        cover: 'app.media.cover_3',
        title: 'Excel函数速成',
        watching: 1919,
        category: '学习',
        streamer: '职场小达人',
      } as MoreLiveCard,
      {
        cover: 'app.media.cover_4',
        title: '15分钟燃脂训练',
        watching: 999,
        category: '运动',
        streamer: '健身小熊',
      } as MoreLiveCard,
      {
        cover: 'app.media.cover_1',
        title: '学生党闭眼入评测',
        watching: 114514,
        category: '数码',
        streamer: '赛博阿力',
      } as MoreLiveCard
    ]
    return cardsData
  }

  getRankList() {
    let rankList: Array<LiveItem> = [
      new LiveItem(1, $r('app.media.image_bai'), '李苏苏', '美食', 88000, 750000),
      new LiveItem(2, $r('app.media.image_hui'), '扎克王', '英雄联盟', 79000, 700000),
      new LiveItem(3, $r('app.media.image_yu'), '不知名网友', '炉石传说', 66000, 600000),
      new LiveItem(4, $r('app.media.image_ti'), '山山而川', '旅游', 50000, 500000),
      new LiveItem(5, $r('app.media.image_labubu'), '止戈', '英雄联盟', 42000, 400000),
      new LiveItem(6, $r('app.media.image_chi'), '枪王之王', '和平精英', 30000, 360000),
      new LiveItem(7, $r('app.media.image_yu'), '世界之大', '旅游', 18000, 300000),
      new LiveItem(8, $r('app.media.image_bai'), '小白兔奶糖', '二次元', 12000, 200000),
      new LiveItem(9, $r('app.media.image_hui'), '上分哥', '王者荣耀', 9888, 120000),
      new LiveItem(10, $r('app.media.image_ti'), '我是小白', '和平精英', 6550, 50000),
    ]
    return rankList
  }
}


export const giftData: Array<GiftModel> = [
  new GiftModel('小心心', $r('app.media.likes'), 1, 0),
  new GiftModel('奖励撒花', $r('app.media.celebrate'), 5, 1),
  new GiftModel('小心心', $r('app.media.likes'), 1, 2),
  new GiftModel('小心心', $r('app.media.likes'), 1, 3),
  new GiftModel('小心心', $r('app.media.likes'), 1, 4),
  new GiftModel('奖励撒花', $r('app.media.celebrate'), 5, 5),
  new GiftModel('小心心', $r('app.media.likes'), 1, 6),
  new GiftModel('小心心', $r('app.media.likes'), 1, 7)
];

