import { AvSessionController, PlayController, PlaySession, VideoPlayData } from '@agctemplate/video_swiper';
import { AppStorageV2, TipsDialog } from '@kit.ArkUI';
import {
  LiveInteractionMgr,
  LoginUserInfo,
  GiftModel,
  PreferType,
  RichChat,
  Audience,
  LiveItem
} from 'live_interaction';
import { RichEditorSpan } from 'live_interaction';
import { MoreLiveCard } from 'live_interaction';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { SimpleChat } from 'live_interaction';
import { emitter } from '@kit.BasicServicesKit';
import { PreferConstant, PreferenceUtil } from '@agctemplate/utils';
import { AccountUtil, AppStorageKeys, BarVM, BreakPoint } from '@agctemplate/widgets';
import { RouterMap, RouterModule } from '@agctemplate/router_module';
import { addFollowing, deleteFollowing } from '@agctemplate/detail/src/main/ets/models/AudienceData';
import { jumpProfilePage } from '@agctemplate/detail/src/main/ets/profile/ProfilePage';
import { TextInput } from '@agctemplate/detail/src/main/ets/input/CommentKeyboard';
import { AudienceRes } from '@agctemplate/server';
import { LiveMsgModel } from '../models/LiveModel'
import { PublicScreenLayer } from 'live_interaction/src/main/ets/components/PublicScreenLayer'
import { BottomLineLayer } from '../component/BottomLineLayer'
import { BulletVM } from 'live_interaction/src/main/ets/viewModels/BulletVM';
import { BusinessError } from '@kit.BasicServicesKit';
import { audio } from '@kit.AudioKit'
import { wifiManager } from '@kit.ConnectivityKit';
import { abilityAccessCtrl, Context, PermissionRequestResult, common } from '@kit.AbilityKit';
import { media } from '@kit.MediaKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { UserInfo } from 'live_interaction'

const TAG = '[VerticalScreenComponent]'
const DISTRIBUTION_VERSION = 6000

@ComponentV2
export struct DetailPageComponent {
  liveInteractionMgr: LiveInteractionMgr = new LiveInteractionMgr()
  @Param videoData: VideoPlayData | undefined = undefined;
  @Param playControl: PlayController | undefined = undefined;
  @Param playerSession: PlaySession | undefined = undefined
  @Local liveStreamer: LiveMsgModel = LiveMsgModel.instance
  @Param @Require audienceList: Array<AudienceRes>
  @Local screenDirection: number = 0 // 0：竖屏 1：横屏
  @Local isShowMoreSettings: boolean = false
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private windowClass = (this.context as common.UIAbilityContext).windowStage.getMainWindowSync()
  @Local logoUser: UserInfo = AccountUtil.getUserInfo();
  @Local payItem: GiftModel = new GiftModel('', '', 0, 0)
  @Local preferType: PreferType = PreferType.PORTRAIT
  private preferenceVideoQuality = PreferenceUtil.getInstance(this.context, PreferConstant.VIDEO_QUALITY)
  @Local breakPoint: BreakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint())!;
  @Local userAvatar: Resource | string = $r('app.media.person')
  @Local bulletVM: BulletVM = AppStorageV2.connect(BulletVM, 'bulletVM', () => new BulletVM())!
  countUpTextTimerController: TextTimerController = new TextTimerController();
  @Local isMicroOpen: boolean = true
  @Local netRssi: number = -100
  @Local isShowMyRoom: boolean = false
  @Local isShowRankList: boolean = false
  @Local isModerator: boolean[] = []
  private customDialogComponentId: number = 0;
  private avRecorder: media.AVRecorder | undefined = undefined;
  private timeId: number | undefined = undefined;
  @Local maxAmplitude: number = 0;
  private allowFlag: boolean = true;
  private file: fs.File | undefined = undefined
  groupId: number = audio.DEFAULT_VOLUME_GROUP_ID;
  recvWifiRssiChangeFunc = (data: number) => {
    this.netRssi = data
    if (this.netRssi <= -70) {
      this.showToast('直播网络不稳定！')
    }
  }
  recvWifiConnectionChangeFunc = (result: number) => {
    if (!result && this.allowFlag) {
      this.allowFlag = false;
      this.netRssi = -100
      this.showToast('网络连接已断开，已关闭直播间')
      this.endRecordingProcess()
      this.countUpTextTimerController.pause()
      RouterModule.push({
        url: RouterMap.End_Live_Page
      })
    }
    console.info('Receive wifi connection change event: ' + result);
  }
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: TipsDialog({
      title: '温馨提醒',
      content: '您是否确认关闭直播',
      primaryButton: {
        value: '取消',
        role: ButtonRole.ERROR,
        action: () => {
          console.info('Callback when the first button is clicked')
        },
      },
      secondaryButton: {
        value: '确定',
        action: () => {
          this.endRecordingProcess()
          this.countUpTextTimerController.pause()
          RouterModule.push({
            url: RouterMap.End_Live_Page
          })
          console.info('Callback when the second button is clicked')
        }
      }
    })
  });

  setOrientation(orientation: number) {
    this.windowClass.setPreferredOrientation(orientation)
  }

  aboutToDisappear(): void {
    try {
      this.liveInteractionMgr.chatMgr.stop()
      TextInput.instance.spansRemain = []
      emitter.off(4)
      wifiManager.off('wifiRssiChange', this.recvWifiRssiChangeFunc);
      wifiManager.off('wifiConnectionChange', this.recvWifiConnectionChangeFunc);
      this.dialogController = null; // 将dialogController置空
    } catch (e) {
    }
  }

  aboutToAppear() {
    this.liveStreamer.nickname = this.logoUser.name;
    this.liveStreamer.avatar = this.logoUser.avatar;
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let context: Context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    atManager.requestPermissionsFromUser(context, ['ohos.permission.GET_WIFI_INFO'],
      (err: BusinessError, data: PermissionRequestResult) => {
        if (err) {
          console.error(`requestPermissionsFromUser fail, code: ${err.code}, message: ${err.message}`)
        } else {
          console.info(data.authResults[0].toString())
        }
      })
    this.liveInteractionMgr.chatMgr.play()
    this.getMicroStatus()
    this.startRecordingProcess()
    this.getNetStatus()
    try {
      wifiManager.on('wifiRssiChange', this.recvWifiRssiChangeFunc);
      wifiManager.on('wifiConnectionChange', this.recvWifiConnectionChangeFunc);
    } catch (e) {
    }
    this.audienceList.forEach((item: AudienceRes) => {
      if (item.isModerator) {
        this.isModerator.push(true)
      } else {
        this.isModerator.push(false)
      }
    })
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
    this.liveInteractionMgr.onGetMoreLives = (): MoreLiveCard[] => {
      return this.getMoreLives()
    }
    this.liveInteractionMgr.onClearScreen = (isClear: boolean) => {
      hilog.info(0x000, TAG, 'onClearScreen:' + isClear)
    }
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
      if (this.screenDirection === 0) {
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
      // this.playerSession.startPip()
    }
    this.liveInteractionMgr.onCheckLogin = (): boolean => {
      return this.logoUser.isLogin
    }
    this.liveInteractionMgr.onLogin = () => {
      RouterModule.push({ url: RouterMap.LOGIN_PAGE, param: true })
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
    let chat1 = new SimpleChat('Labubu集中营', '这不行啊，我方不占优势1')
    chat1.like = true
    chat1.fans = true
    chat1.fanName = '无限荣耀'
    chat1.fanLevel = 10
    chat1.pay = true
    chat1.payLevel = 3
    this.liveInteractionMgr.addNormalChat(chat1)
    this.liveInteractionMgr.addNormalChat(new SimpleChat('体育前线', '厉害了我的姐~'))
    this.liveInteractionMgr.addNormalChat(new SimpleChat('会说国语的老外', '这不行啊，我方不占优势3'))
    this.liveInteractionMgr.addNormalChat(new SimpleChat('会说国语的老外', '这不行啊，我方不占优势4'))
    this.liveInteractionMgr.addNormalChat(new SimpleChat('白姐聊新闻', '画风好精美'))
    this.liveInteractionMgr.addNormalChat(new SimpleChat('吃货小睡鼠', '这不行啊，我方不占优势5'))
    this.liveInteractionMgr.addNormalChat(new SimpleChat('吃货小睡鼠', '这不行啊，我方不占优势6'))
    this.liveInteractionMgr.addNormalChat(new SimpleChat('白姐聊新闻', '画风好精美'))
    this.liveInteractionMgr.addNormalChat(new SimpleChat('体育前线', '厉害了我的姐~'))
    this.liveInteractionMgr.addNormalChat(new SimpleChat('娱记大杂烩', '这不行啊，我方不占优势7'))
    this.liveInteractionMgr.addNormalChat(new SimpleChat('娱记大杂烩', '这不行啊，我方不占优势8'))
    this.liveInteractionMgr.addNormalChat(new SimpleChat('体育前线', '画风好精美'))
    this.liveInteractionMgr.setGiftData(giftData)
  }

  @Builder
  adSetDetail(audience: AudienceRes, index: number) {
    Column() {
      Row() {
        Text('设置')
          .fontWeight(700)
          .fontSize(20)
        Blank()
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontSize(10.8)
            .fontColor([$r('sys.color.icon_primary')])
        }
        .size({ width: 24, height: 24 })
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.getUIContext().getPromptAction().closeCustomDialog(this.customDialogComponentId)
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 24 })

      Column() {
        Row() {
          Image($r(audience.avatar))
            .width(40)
            .height(40)
            .borderRadius(20)
          Text(audience.nickName)
            .fontWeight(400)
            .fontSize(16)
            .margin({ left: 8 })
          Blank()
        }
        .width('100%')

        Row() {
          Text('设置为管理员')
            .fontWeight(500)
            .fontSize(16)
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: audience.isModerator })
            .onChange((isOn: boolean) => {
              audience.isModerator = isOn
              this.isModerator[index] = isOn
              if (isOn) {
                this.liveInteractionMgr.addSystemChat(`${audience.nickName} 已成为管理员！`)
              } else {
                this.liveInteractionMgr.addSystemChat(`${audience.nickName} 已不是管理员！`)
              }
            })
        }
        .height(40)
        .width('100%')
        .margin({ top: 8 })

        Row() {
          Text('禁言')
            .fontWeight(500)
            .fontSize(16)
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: audience.isMute })
            .onChange((isOn: boolean) => {
              audience.isMute = isOn
              if (isOn) {
                this.liveInteractionMgr.addSystemChat(`${audience.nickName} 已被禁言！`)
              } else {
                this.liveInteractionMgr.addSystemChat(`${audience.nickName} 已解除禁言！`)
              }
            })
        }
        .height(40)
        .margin({ top: 12 })
        .width('100%')
      }
      .padding({
        left: 16,
        right: 16,
        top: 28,
        bottom: 28
      })
    }
  }

  @Builder
  rankListSheet() {
    Column() {
      Column({ space: 16 }) {
        Row() {
          Text('热门主播排行榜')
            .width(232)
            .height(27)
            .fontSize(20)
            .fontWeight(700)
            .margin({ left: 8, right: 8 })
          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.xmark'))
              .fontSize(24)
              .fontColor([$r('sys.color.icon_primary')])
          }
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .size({ width: 40, height: 40 })
          .onClick(() => {
            this.isShowRankList = !this.isShowRankList
          })
        }
        .width('100%')
        .height(40)
        .margin({ top: 16 })
        .justifyContent(FlexAlign.SpaceBetween)

        List({ space: 12 }) {
          ForEach(
            this.liveInteractionMgr.rankList,
            (item: LiveItem) => {
              ListItem() {
                Row({ space: 12 }) {
                  Text(item.rankId + '')
                    .width(20)
                    .textAlign(TextAlign.Center)
                    .fontSize(16)
                    .fontColor(item.rankId === 1 ? '#ffe73a3a' : (item.rankId === 2 ? '#ffd7591d' : (
                      item.rankId === 3 ? '#ffe3af46' : '#aaa'
                    )))
                  Image(item.avatar)
                    .width(50)
                    .height(50)
                    .borderRadius(25)
                  Column({ space: 8 }) {
                    Text(item.nickName)
                      .fontSize(16)
                      .fontWeight(800)
                    Row() {
                      Text(item.category)
                        .fontSize(12)
                        .fontColor('#888')
                        .fontWeight(400)
                      Text('|')
                        .fontSize(12)
                        .fontColor('#888')
                        .fontWeight(400)
                        .margin({ left: 3 })
                      Text(item.watching >= 10000 ? `${item.watching / 10000}万人在看` : `${item.watching}人在看`)
                        .fontSize(12)
                        .fontColor('#888')
                        .fontWeight(400)
                        .margin({ left: 3 })
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)

                  Text(item.hot >= 10000 ? `${item.hot / 10000}万` : `${item.hot}`)
                    .width(40)
                    .textAlign(TextAlign.End)
                    .fontSize(14)
                    .fontColor('#666')
                    .fontWeight(600)
                }
                .width('100%')
                .height(50)
                .justifyContent(FlexAlign.SpaceBetween)
              }
            },
            (item: LiveItem) => item.rankId.toString()
          )
        }
        .height(300)
        .scrollBar(BarState.Off)
      }
      .width('90%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  mgMyRoom() {
    List({ space: 8 }) {
      ForEach(this.audienceList, (item: AudienceRes, index: number) => {
        ListItem() {
          Row() {
            Image($r(item.avatar))
              .width(40)
              .height(40)
              .borderRadius(20)
            Text(item.nickName)
              .fontWeight(400)
              .fontSize(16)
              .margin({ left: 8 })
            Blank()
            if (item.isModerator && this.isModerator[index]) {
              Image($r('app.media.administrator'))
                .width(24)
                .height(24)
            }
          }
          .onClick(() => {
            this.getUIContext().getPromptAction().openCustomDialog({
              builder: () => {
                this.adSetDetail(item, index)
              },
              width: 328
            }).then((dialogId: number) => {
              this.customDialogComponentId = dialogId;
            })
          })
          .width('100%')
        }
      }, (item: AudienceRes) => item.id)
    }
    .margin({ left: 28, right: 28, bottom: 28 })
    .scrollBar(BarState.Off)
    .layoutWeight(1)
  }

  build() {
    Column() {
      //第一行
      Row() {
        Stack({ alignContent: Alignment.TopStart }) {
          Row()
            .width(104)
            .height(32)
            .borderRadius(20)
            .backgroundColor('rgba(0, 0, 0, 0.4)')
          Image(this.liveStreamer.avatar)
            .width(28)
            .height(28)
            .margin(2)
            .borderRadius(14)
          Text(this.liveStreamer.nickname)
            .width(50)
            .height(14)
            .margin({ left: 34, top: 2 })
            .fontSize(10)
            .fontWeight(500)
            .fontColor('#fff')
            .textAlign(TextAlign.Start)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Image($r('app.media.illustration'))
            .width(6.5)
            .height(9)
            .margin({ top: 18.5, left: 37 })
            .opacity(0.6)
          Text('1.8w')
            .height(14)
            .margin({ top: 16, left: 48 })
            .fontSize(8)
            .fontWeight(400)
            .textAlign(TextAlign.Start)
            .fontColor('#fff')
            .opacity(0.6)
        }
        .margin({ top: 10.5 })

        Blank()
        Row() {
          Row() {
            ForEach([0, 1, 2], (index: number) => {
              Image($r(this.audienceList[index]?.avatar))
                .width(24)
                .height(24)
                .borderRadius(12)
                .margin({ right: 4 })
            }, (item: number, index: number) => {
              return index + '__' + JSON.stringify(item);
            })
            Stack({ alignContent: Alignment.Center }) {
              Row()
                .width(40)
                .height(24)
                .borderRadius(18)
                .backgroundColor('#000')
                .opacity(0.4)
              Text(this.audienceList.length.toString())
                .height(14)
                .fontSize(10)
                .fontWeight(500)
                .fontColor('#fff')
                .textAlign(TextAlign.Start)
            }
          }
          .onClick(() => {
            this.isShowMyRoom = true
          })
          .bindSheet($$this.isShowMyRoom, this.mgMyRoom(), {
            title: { title: '我的直播间' },
            height: 592,
            backgroundColor: $r('sys.color.comp_background_tertiary'),
            blurStyle: BlurStyle.COMPONENT_THICK,
            preferType: SheetType.CENTER
          })
          .margin({ right: 4 })

          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.power'))
              .fontSize(14.4)
              .fontColor(['#E6FFFFFF'])
          }
          .width(24)
          .height(24)
          .backgroundColor('#000')
          .opacity(0.4)
          .onClick(() => {
            if (this.dialogController != null) {
              this.dialogController.open();
            }
          })
        }
        .padding({ top: 14.5 })
      }
      .width('100%')

      //第二行
      Row() {
        Row() {
          Image($r('app.media.rank'))
            .width(20)
            .height(20)
            .margin({
              top: 6,
              bottom: 6,
              right: 4,
              left: 6
            })
          Text('热门榜NO.1')//后续替换成this.interactionMgr.rankId
            .fontColor('rgba(255, 255, 255, 1)')
            .fontWeight(600)
            .fontSize(12)
            .lineHeight(16)
        }
        .width(102)
        .height(32)
        .backgroundColor('rgba(0, 0, 0, 0.4)')
        .borderRadius(8)
        .bindSheet($$this.isShowRankList, this.rankListSheet(), {
          height: 400,
          showClose: false,
          preferType: SheetType.CENTER
        })
        .onClick(() => {
          this.isShowRankList = !this.isShowRankList
        })

        Row() {
          Image($r('app.media.live_time'))
            .width(20)
            .height(20)
            .margin({ left: 8 })
          TextTimer({ isCountDown: false, controller: this.countUpTextTimerController })//开播时长
            .format('mm:ss')
            .width(32)
            .fontWeight(600)
            .fontSize(12)
            .fontColor('rgba(255, 255, 255, 1)')
            .margin({ left: 5 })
            .onVisibleAreaChange([0], (isExpanding: boolean, currentRatio: number) => {
              if (isExpanding) {
                this.countUpTextTimerController.start()
              }
            })
            .onTimer((utc: number, elapsedTime: number) => {
              this.liveStreamer.liveTime = elapsedTime
              console.info(`时间计时器${utc}和${elapsedTime}`)
            })
        }
        .width(86)
        .height(32)
        .backgroundColor('rgba(0, 0, 0, 0.4)')
        .borderRadius(8)
        .margin({ left: 4 })

        Blank()

        Row() {
          SymbolGlyph(this.isMicroOpen ? $r('sys.symbol.mic_fill') :
            $r('sys.symbol.mic_slash_fill'))//闭麦时为mic_slash_fill
            .fontSize(24)
            .fontColor(['#E6FFFFFF'])
            .margin({ left: 8 })
            .onClick(() => {
              this.isMicroOpen = !this.isMicroOpen
              if (this.isMicroOpen) {
                this.startRecordingProcess();
              } else {
                this.endRecordingProcess();
                this.maxAmplitude = 0;
              }
            })
          this.volumeSlider()
          Blank()
          Image(this.netRssi > -50 ? $r('app.media.wifi_good') : (this.netRssi > -70 ? $r('app.media.wifi_normal') :
            (this.netRssi > -80 ? $r('app.media.wifi_bad') : $r('app.media.wifi_slash'))))
            .width(24)
            .height(24)
            .margin({ right: 8 })
        }
        .width(86)
        .height(32)
        .backgroundColor('rgba(0, 0, 0, 0.4)')
        .borderRadius(8)
      }
      .width('100%')
      .margin({ top: 12 })

      //弹幕
      PublicScreenLayer({ chatManager: this.liveInteractionMgr.chatMgr, interactionMgr: this.liveInteractionMgr })

      //底部发表评论
      BottomLineLayer({
        liveInteractionMgr: this.liveInteractionMgr,
        audienceList: this.audienceList,
        shareInfo: this.liveInteractionMgr.shareInfo,
        defaultResolution: this.liveInteractionMgr.defaultResolution,
        bulletVM: this.bulletVM,
        giftData: this.liveInteractionMgr.giftData,
        toComment: () => {
          this.liveInteractionMgr.onComment()
        },
        onPip: this.liveInteractionMgr.onPip,
        onChangeResolution: this.liveInteractionMgr.onChangeResolution,
        onReport: this.liveInteractionMgr.onReport,
        onCheckAndLogin: (): boolean => {
          if (!this.liveInteractionMgr.onCheckLogin()) {
            if (!this.liveInteractionMgr.onLogin()) {
              return false;
            }
          }
          return true;
        },
        onGetUserInfo: this.liveInteractionMgr.onGetLoginUserInfo,
        onPay: this.liveInteractionMgr.onPay,
        userAvatar: this.liveStreamer.avatar
      })
    }
    .width('100%')
    .height('100%')
    .padding({
      left: 16,
      right: 16,
      top: BarVM.instance.staBarH,
      bottom: 20
    })
    .alignItems(HorizontalAlign.Start)
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

  getNetStatus() {
    try {
      wifiManager.getLinkedInfo((err, data: wifiManager.WifiLinkedInfo) => {
        if (err) {
          console.error('get linked info error');
          return;
        }
        this.netRssi = data.rssi
      })
    } catch (e) {
    }
  }

  async getMicroStatus() {
    let audioVolumeGroupManager = await audio.getAudioManager().getVolumeManager().getVolumeGroupManager(this.groupId)
    audioVolumeGroupManager.isMicrophoneMute().then((value: boolean) => {
      this.isMicroOpen = !value
      console.info('micro status get success')
    });
  }

  async startRecordingProcess(): Promise<void> {
    try { // 1.创建录制实例
      this.avRecorder = await media.createAVRecorder();
      // 2.获取录制文件fd赋予avConfig里的url；参考FilePicker文档
      const context = this.getUIContext().getHostContext();
      const path = context!.cacheDir;
      const filepath = path + '/temp.mp3';

      let avProfile: media.AVRecorderProfile = {
        audioBitrate: 112000, // 音频比特率。
        audioChannels: 2, // 音频声道数。
        audioCodec: media.CodecMimeType.AUDIO_AAC, // 音频编码格式，当前支持AAC、MP3和G711MU。
        aacProfile: media.AacProfile.AAC_HE, // 音频编码扩展格式，从API version 22开始支持AAC_HE和AAC_HE_V2。
        audioSampleRate: 48000, // 音频采样率。
        fileFormat: media.ContainerFormatType.CFT_MPEG_4A, // 封装格式，当前支持MP4、M4A、MP3、WAV、AMR和AAC。
      };

      this.file = fs.openSync(filepath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      const fdNumber = this.file.fd;

      let avConfig: media.AVRecorderConfig = {
        audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC, // 音频输入源，这里设置为麦克风。
        profile: avProfile,
        url: 'fd://' + fdNumber, // 参考应用文件访问与管理中的开发示例获取创建的音频文件fd填入此处。
      };

      // 3.配置录制参数完成准备工作
      await this.avRecorder.prepare(avConfig);

      // 4.开始录制
      await this.avRecorder.start();

      // 通过getAudioCapturerMaxAmplitude接口获取声音振幅大小。
      this.timeId = setInterval(() => {
        this.avRecorder!.getAudioCapturerMaxAmplitude((_: BusinessError, amplitude: number) => {
          this.maxAmplitude = amplitude;
        });
      }, 100);
    } catch (e) {
    }
  }

  async endRecordingProcess() {
    try {
      clearInterval(this.timeId);
      await this.avRecorder?.release(); // 销毁录音实例。
    } catch (err) {
      console.error(err.code + err.message);
    } finally {
      fs.closeSync(this.file?.fd);
    }
  }

  @Builder
  volumeSlider() {
    Column() {
      Column()
        .width(4)
        .height(2)
        .borderRadius(2)
        .backgroundColor(this.maxAmplitude > 15000 ? 'rgba(255, 255, 255, 1)' : 'rgba(196, 196, 196, 1)')
        .margin({ bottom: 2 })
      Column()
        .width(4)
        .height(2)
        .borderRadius(2)
        .backgroundColor(this.maxAmplitude > 11750 ? 'rgba(255, 255, 255, 1)' : 'rgba(196, 196, 196, 1)')
        .margin({ bottom: 2 })
      Column()
        .width(4)
        .height(2)
        .borderRadius(2)
        .backgroundColor(this.maxAmplitude > 8500 ? 'rgba(255, 255, 255, 1)' : 'rgba(196, 196, 196, 1)')
        .margin({ bottom: 2 })
      Column()
        .width(4)
        .height(2)
        .borderRadius(2)
        .backgroundColor(this.maxAmplitude > 5250 ? 'rgba(255, 255, 255, 1)' : 'rgba(196, 196, 196, 1)')
        .margin({ bottom: 2 })
      Column()
        .width(4)
        .height(2)
        .borderRadius(2)
        .backgroundColor(this.maxAmplitude > 2000 ? 'rgba(255, 255, 255, 1)' : 'rgba(196, 196, 196, 1)')
    }
    .margin({ left: 2 })
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

