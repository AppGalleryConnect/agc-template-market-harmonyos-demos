import { buttonItem, getMedia, NAV_PAGE_NAME } from '@agctemplate/resources';
import { appRouter, Logger, WindowManager } from '@agctemplate/utils';
import { PlayController, PlaySession, ProcessBar, AVPlayerListener } from 'video_swiper';
import { BulletSettingItem } from '../models/BulletSettingData';
import { MyStorage, reverseSpeed, speedArr, speeds } from '../models/SpeedData';
import { BulletVM } from '../viewmodels/BulletVM';
import { ShortDramaDetailItemVM } from '../viewmodels/ShortDramaDetailItemVM';
import { BulletLayer } from './BulletLayer';
import { BulletSetting } from './BulletSetting';
import { PlaySetting } from './PlaySetting';
import { Side } from './Side';
import { VideoDesLayer } from './VideoDesLayer';
import { AppStorageV2, display } from '@kit.ArkUI';
import { AppStorageKeys, BreakPoint, UserInfoModel, ColorMode, FontModel, fp2pxUtil } from '@agctemplate/widgets';
import { CastingLayer, CastService, CastPicker } from 'module_cast';
import { Params, PromptActionClass } from './PromptActionClass';
import { ProcessController } from 'video_swiper/src/main/ets/view/ProcessController';
import { lockedBuilder, LockedLayer } from './LockedLayer';
import { ShortDramaDetailListVM } from '../viewmodels/ShortDramaDetailListVM';
import { DetailVideoData } from '../models/DetailVideoData';
import { Preferences } from '../viewdata/Preferences'
import { ConfigurationConstant } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { TimeoutStateManager } from '../viewmodels/TimeoutStateManager';
import { TimeoutPersistence } from '../viewdata/TimeoutPersistence';

@ObservedV2
export class GlobalTimeoutState {
  @Trace expireTime: number = 0
  @Trace itemName: string = ''
  @Trace isActive: boolean = false
}

const TAG = 'DetailMaskLayer'
const DOMAIN = 0x0000

interface ParamsModel {
  id: string
  curIndex: number
}

interface AspectRatio {
  width: number;
  height: number;
}

interface VideoType {
  short: AspectRatio;
  long: AspectRatio;
}

const videoRatio: VideoType = {
  short: { width: 9, height: 16 } as AspectRatio,
  long: { width: 16, height: 9 } as AspectRatio,
}

@ObservedV2
class ScreeanResolution {
  @Trace isAutoResolution: boolean
  @Trace resolutionValue: number

  constructor(isAutoResolution: boolean, resolutionValue: number) {
    this.isAutoResolution = isAutoResolution
    this.resolutionValue = resolutionValue
  }
}

@ObservedV2
class TimeoutItem {
  @Trace itemName: string
  @Trace isCheck: boolean
  @Trace remainTime: number = 0

  constructor(itemName: string, isCheck: boolean) {
    this.itemName = itemName
    this.isCheck = isCheck
  }
}

@ComponentV2
export struct DetailMaskLayer {
  breakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint())!;
  @Param @Require videoDetailMaskVM: ShortDramaDetailItemVM;
  @Param @Require playControl: PlayController;
  @Param @Require playerSession: PlaySession;
  @Local isHover: boolean = false;
  @Local storage: MyStorage = MyStorage.instance();
  @Local isShowSetSpeed: boolean = false
  @Local isShowPlaySettingSheet: boolean = false
  @Local showControl: boolean = true;
  @Local bulletVM: BulletVM = new BulletVM()
  @Local rowsNum: number = 2;
  @Local notOpacity: number = 80;
  @Local danMuSpeed: string = '适中';
  @Local danMuSize: string = '适中';
  @Local isShowBulletSettingSheet: boolean = false
  @Local isShowScreenSettingSheet: boolean = false
  @Local currentPlaySettingTab: string = ''
  @Local isShowBullet: boolean = true
  @Local bonusAgree: boolean = true
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, 'userInfo', () => new UserInfoModel())!
  @Local bonus: number = this.userInfo.bonus
  @Local processController: ProcessController | undefined = undefined
  @Local locked: boolean = true
  @Local currentColorMode: ColorMode = AppStorageV2.connect(ColorMode, 'colorMode', () => new ColorMode('跟随系统'))!
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  @Local screanResolution: ScreeanResolution =
    AppStorageV2.connect(ScreeanResolution, () => new ScreeanResolution(false, 480))!
  @Local isTimeoutSet: boolean = false;
  @Local timeoutStateManager: TimeoutStateManager = TimeoutStateManager.getInstance();
  @Local globalTimeoutState: GlobalTimeoutState = AppStorageV2.connect(GlobalTimeoutState, 'globalTimeoutState',
    () => new GlobalTimeoutState())!;
  @Local timeItems: TimeoutItem[] =
    [new TimeoutItem('不开启', true), new TimeoutItem('播完当集', false), new TimeoutItem('15分钟', false),
      new TimeoutItem('30分钟', false), new TimeoutItem('60分钟', false), new TimeoutItem('自定义', false)];
  @Local displayTime: string = '';
  private time: TextCascadePickerRangeContent[] = []
  private timeoutInterval: number = -1

  startTimeoutCountdown(minutes: number, itemName: string) {
    if (this.timeoutInterval !== -1) {
      clearInterval(this.timeoutInterval)
    }
    const totalSeconds = minutes * 60
    this.timeoutStateManager.setRemainTime(totalSeconds)
    this.timeoutStateManager.setIsCheck(true)
    this.timeoutStateManager.setItemName(itemName)
    this.displayTime = this.timeoutStateManager.formatTime(totalSeconds)
    this.globalTimeoutState.expireTime = Date.now() + (totalSeconds * 1000)
    this.globalTimeoutState.itemName = itemName
    this.globalTimeoutState.isActive = true
    this.timeoutStateManager.saveState()
    this.timeoutInterval = setInterval(() => {
      const remainTime = this.timeoutStateManager.getRemainTime()
      if (remainTime > 0) {
        this.timeoutStateManager.setRemainTime(remainTime - 1)
        this.displayTime = this.timeoutStateManager.formatTime(this.timeoutStateManager.getRemainTime())
        if (this.timeoutStateManager.getRemainTime() <= 0) {
          clearInterval(this.timeoutInterval)
          this.timeoutInterval = -1
          this.navigateToDetailPage()
        }
      }
    }, 1000)
  }

  navigateToDetailPage() {
    this.clearTimeoutCountdown()
    if (this.currentColorMode.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) {
      WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' });
    } else {
      WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6ffffff' });
    }
    this.playControl.pause();
    appRouter.push({
      builderName: NAV_PAGE_NAME.DramaDetailInfoPage.name, params: {
        dramaInfo: this.videoDetailMaskVM.dramaInfo,
        currentIndex: this.playControl.curentIndex,
        changeIndex: (index: number) => {
          this.playControl.changeIndex(index);
        }
      }
    });
  }

  clearTimeoutCountdown() {
    if (this.timeoutInterval !== -1) {
      clearInterval(this.timeoutInterval)
      this.timeoutInterval = -1
    }
    this.timeoutStateManager.clearTimeout()
    this.timeoutStateManager.clearState()
    this.globalTimeoutState.isActive = false
    this.globalTimeoutState.expireTime = 0
    this.globalTimeoutState.itemName = ''
    this.timeItems.forEach((item: TimeoutItem) => {
      item.isCheck = item.itemName === '不开启'
      item.remainTime = 0
    })
    this.displayTime = ''
    this.unregisterEpisodeEndListener()
    this.playControl.autoPlay = true
  }

  clearTimeoutCountdownWithoutPersist() {
    if (this.timeoutInterval !== -1) {
      clearInterval(this.timeoutInterval)
      this.timeoutInterval = -1
    }
    this.timeoutStateManager.clearTimeout()
    this.timeItems.forEach((item: TimeoutItem) => {
      item.isCheck = item.itemName === '不开启'
      item.remainTime = 0
    })
    this.displayTime = ''
    this.unregisterEpisodeEndListener()
    this.playControl.autoPlay = true
  }

  private episodeEndListener: AVPlayerListener = {
    onEnded: () => {
      hilog.info(DOMAIN, TAG, 'Episode ended, navigate to detail page and pause autoplay')
      this.playControl.autoPlay = false
      this.navigateToDetailPage()
    }
  }

  registerEpisodeEndListener(): void {
    this.playerSession.registerListener(this.episodeEndListener)
  }

  unregisterEpisodeEndListener(): void {
    this.playerSession.unregisterListener(this.episodeEndListener)
  }

  formatTime(seconds: number): string {
    const hours = Math.floor(seconds / 3600)
    const minutes = Math.floor((seconds % 3600) / 60)
    const secs = seconds % 60
    return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(secs).padStart(2, '0')}`
  }

  recoverTimeout() {
    const manager = this.timeoutStateManager
    let hasActive = manager.hasActiveTimeout()
    let remainTime = manager.getRemainTime()
    let itemName = manager.getItemName()
    if (!hasActive && this.globalTimeoutState.isActive && this.globalTimeoutState.expireTime > Date.now()) {
      let remainMs = this.globalTimeoutState.expireTime - Date.now()
      remainTime = Math.ceil(remainMs / 1000)
      itemName = this.globalTimeoutState.itemName
      hasActive = true
      manager.setRemainTime(remainTime)
      manager.setIsCheck(true)
      manager.setItemName(itemName)
    }
    if (hasActive && this.globalTimeoutState.expireTime > Date.now()) {
      this.displayTime = manager.formatTime(remainTime)
      this.timeItems.forEach((item: TimeoutItem) => {
        item.isCheck = item.itemName === itemName
        if (item.itemName === itemName) {
          item.remainTime = remainTime
        }
      })
      if (this.timeoutInterval === -1) {
        this.startTimeoutCountdown(remainTime / 60, itemName)
      }
    }
  }

  private foldStatusChange1: Callback<display.FoldStatus> = (data: display.FoldStatus) => {
    this.getHover();
  };
  onSpeedSet: Function = (speed: number) => {
    this.playControl.setSpeed(speed)
  }
  onBulletSet: Function = (isOn: boolean) => {
    this.isShowBullet = isOn
    Preferences.updateData('isShowBullet', isOn)
  }
  onClear: Function = (isOn: boolean) => {
    this.showControl = !isOn
    Preferences.updateData('showControl', isOn)
  }

  @Monitor('isShowBulletSettingSheet')
  resetBulletSetting() {
    if (this.isShowBulletSettingSheet) {
      this.rowsNum = this.bulletVM.storage.setting.get('setting')?.rowsNum!
      this.notOpacity = this.bulletVM.storage.setting.get('setting')?.notOpacity!
      this.danMuSpeed = this.bulletVM.storage.setting.get('setting')?.danMuSpeed!
      this.danMuSize = this.bulletVM.storage.setting.get('setting')?.danMuSize!
    }
  }

  @Monitor('showControl')
  setScreen() {
    WindowManager.setVideoFullScreen(!this.showControl, videoRatio.short.width, videoRatio.short.height)
  }

  @Monitor('bonus')
  bonusChange() {
    this.userInfo.bonus = this.bonus
  }

  @Monitor('userInfo.isVip')
  vipChange() {
    this.videoDetailMaskVM.isLocked = !this.userInfo.isVip
  }

  @Monitor('globalTimeoutState.isActive')
  onGlobalTimeoutChange() {
    if (this.globalTimeoutState.isActive) {
      this.recoverTimeout()
    } else {
      this.clearTimeoutCountdown()
    }
  }

  recover() {
    WindowManager.setVideoFullScreen(false, videoRatio.short.width, videoRatio.short.height)
  }

  async aboutToAppear() {
    this.getHover()
    try {
      display.on('foldStatusChange', this.foldStatusChange1);
    } catch (exception) {
      hilog.error(0x0000, TAG, 'Failed to register onFoldStatusChange callback. Code: ' + JSON.stringify(exception));
    }
    let avPlayer = this.playerSession.getAVPlayer()
    if (avPlayer) {
      this.processController = new ProcessController(avPlayer)
    }
    if (!this.bulletVM.storage.setting.has('setting')) {
      this.bulletVM.storage.setting.set('setting', new BulletSettingItem())
    }
    this.rowsNum = this.bulletVM.storage.setting.get('setting')?.rowsNum!
    this.notOpacity = this.bulletVM.storage.setting.get('setting')?.notOpacity!
    this.danMuSpeed = this.bulletVM.storage.setting.get('setting')?.danMuSpeed!
    this.danMuSize = this.bulletVM.storage.setting.get('setting')?.danMuSize!
    this.playControl.id = this.videoDetailMaskVM.dramaInfo.id
    this.playControl.isVip = this.userInfo.isVip
    TimeoutPersistence.init(getContext(this))
    this.timeoutStateManager.setDramaId(this.playControl.id)
    if (this.timeoutStateManager.restoreTimeout(this.playControl.id)) {
      this.recoverTimeout()
    }
    if (this.videoDetailMaskVM.isLocked) {
      if (this.userInfo.isVip) {
        this.locked = false
        this.videoDetailMaskVM.isLocked = false
      }
    }
    if (this.locked) {
      this.playControl.pause()
    }
    for (let i = 0; i < 24; i++) {
      let children: TextCascadePickerRangeContent[] = []
      for (let j = (i === 0 ? 1 : 0); j < 60; j++) {
        children.push({ text: `${String(j).padStart(2, '0')}分钟` })
      }
      this.time.push({ text: `${String(i).padStart(2, '0')}小时`, children: children })
    }
  }

  aboutToDisappear(): void {
    this.clearTimeoutCountdownWithoutPersist()
    WindowManager.setVideoFullScreen(false, videoRatio.short.width, videoRatio.short.height)
    try {
      display.off('foldStatusChange', this.foldStatusChange1);
    } catch (exception) {
      hilog.error(0x0000, TAG, 'Failed to unregister onFoldStatusChange callback. Code: ' + JSON.stringify(exception));
    }
  }

  getHover() {
    try {
      let orientation: display.Orientation = display.getDefaultDisplaySync().orientation;
      if (display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_HALF_FOLDED &&
        (orientation === display.Orientation.LANDSCAPE || orientation === display.Orientation.LANDSCAPE_INVERTED)
      ) {
        this.isHover = true;
        hilog.info(0x0000, TAG, `success in hover`);
      } else {
        this.isHover = false;
        hilog.info(0x0000, TAG, `fail in hover`);
      }
    } catch (error) {
      hilog.error(0x0000, TAG, `onFoldStatusChange catch error, code: ${error.code}, message: ${error.message}`);
    }
  }

  onBack() {
    PromptActionClass.setParam(new Params('是否退出投屏？', [{
      content: '是', action: () => {
        PromptActionClass.closeDialog()
        CastService.getInstance().endCasting()
      }
    }, {
      content: '否', action: () => {
        PromptActionClass.closeDialog()
      }
    }
    ]));
    PromptActionClass.setOptions({ alignment: DialogAlignment.Center, maskColor: $r('sys.color.mask_fourth') });
    PromptActionClass.openDialog()
  }

  build() {
    Column() {
      this.headerBuilder()
      Stack({ alignContent: Alignment.BottomEnd }) {
        if (CastService.getInstance().castStatusModel.isCasting) {
          this.castControlBuilder()
        } else {
          if (this.videoDetailMaskVM.isLocked) {
            LockedLayer({
              onUnLocked: () => {
                Logger.info(TAG, `onUnlocked index${this.playControl.curentIndex}`)
                this.playControl.play()
                this.locked = false
                this.videoDetailMaskVM.isLocked = false
              }
            })
              .onAppear(() => {
                this.playControl.pause()
              })
          }

          this.bulletBuilder()

          this.sideBuilder()

          // bottom
          Stack({ alignContent: Alignment.Bottom }) {
            Column() {
              this.introductionBuilder()
              Row() {
                VideoDesLayer({
                  dramaInfo: this.videoDetailMaskVM.dramaInfo,
                  playController: this.playControl
                })
              }
              .width('100%')
              .height(52)
            }
            .width('100%')

            if (!this.showControl) {
              Stack()
                .width('100%')
                .height('100%')
                .onClick(() => {
                  this.showControl = true;
                })
            }
          }
        }
      }
      .width('100%')
      .height(`calc(100% - ${56}vp)`)
      .onVisibleAreaChange([0], (isExpanding: boolean, currentRatio: number) => {
        if (isExpanding && this.videoDetailMaskVM.isLocked) {
          this.playControl.pause()
        } else if (isExpanding && !this.videoDetailMaskVM.isLocked) {
          this.playControl.play()
        }
      })
    }
    .onClick(() => {
      if (!this.videoDetailMaskVM.isLocked) {
        if (this.bulletVM.isPause) {
          this.bulletVM.startBullet()
          this.playControl.play()
        } else {
          this.bulletVM.pauseBullet()
          this.playControl.pause()
        }
      }
    })
  }

  @Builder
  castControlBuilder() {
    Stack({ alignContent: Alignment.Bottom }) {
      CastingLayer({
        title: `第${this.playControl.curentIndex + 1}集`,
        castService: CastService.getInstance(),
        onPlayNext: () => {
          if (this.playControl.curentIndex > 9) {
            this.getUIContext().showAlertDialog({
              title: '提示',
              message: '当前视频解锁后，可投屏观看？',
              autoCancel: true,
              alignment: DialogAlignment.Center,
              buttons: [{
                value: '知道了',
                action: () => {
                  console.info('Callback when the first button is clicked');
                }
              }]
            })
          } else {
            this.playControl.changeIndex(this.playControl.curentIndex + 1);
          }
        },
        onPlayPre: () => {
          if (this.playControl.curentIndex > 0) {
            this.playControl.changeIndex(this.playControl.curentIndex - 1);
          }
        },
        onBack: () => {
          this.onBack();
        }
      })
        .width('100%')
        .height('100%')
        .zIndex(100)
        .padding({ top: 36 });
      VideoDesLayer({
        dramaInfo: this.videoDetailMaskVM.dramaInfo,
        playController: this.playControl,
        isLocked: (index: number): boolean => {
          return this.isLocked(index);
        }
      })
        .width('100%')
        .height(52)
        .zIndex(100);
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  introductionBuilder() {
    Stack({ alignContent: Alignment.Bottom }) {
      Row() {
        Column() {
          Row() {
            Text(this.videoDetailMaskVM.dramaInfo.name)
              .fontSize(this.fontModel.getFg(16))
              .fontWeight(500)
              .fontColor('#fff')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.MARQUEE });
            Column() {
              SymbolGlyph($r('sys.symbol.chevron_right'))
                .fontSize(this.fontModel.getFg(16))
                .fontColor([$r('sys.color.white')])
            }
            .width(16)
            .height(16)
            .justifyContent(FlexAlign.Center)
          }
          .accessibilityText(`点击进入${this.videoDetailMaskVM.dramaInfo.name}剧集详情页`)
          .width(252)
          .onClick(() => {
            if (this.currentColorMode.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) {
              WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' });
            } else {
              WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6ffffff' });
            }
            this.playControl.pause();
            appRouter.push({
              builderName: NAV_PAGE_NAME.DramaDetailInfoPage.name, params: {
                dramaInfo: this.videoDetailMaskVM.dramaInfo,
                currentIndex: this.playControl.curentIndex,
                changeIndex: (index: number) => {
                  this.playControl.changeIndex(index);
                }
              }
            });
          })

          Text(`第${this.videoDetailMaskVM.currentSerial}集` + ' ' +
            this.videoDetailMaskVM.dramaInfo.description)
            .width(252)
            .height(16)
            .fontSize(this.fontModel.getFg(12))
            .fontWeight(400)
            .fontColor('rgba(255, 255, 255, 0.6)')
            .maxLines(1)
            .margin({ top: 2 })
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }
        .width(252)
        .height(this.fontModel.getDesFg(39));
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Start)
      .padding({ left: 16, right: 16 })
      .visibility(this.showControl ? Visibility.Visible : Visibility.Hidden)
      .animation({ duration: 300, curve: Curve.Smooth })

      if (this.playerSession.avPlayer?.isReady) {
        ProcessBar({ avPlayer: this.playerSession.avPlayer })
          .hitTestBehavior(HitTestMode.Transparent);
      }
    }
  }

  @Builder
  sideBuilder() {
    Side({
      videoDes: this.videoDetailMaskVM,
      playControl: this.playControl
    })
      .zIndex(1)
      .position({ bottom: this.isHover ? 66 : 126, right: 8 })
      .visibility(this.showControl ? Visibility.Visible : Visibility.Hidden)
      .animation({ duration: 300, curve: Curve.Smooth })
  }

  @Builder
  bulletBuilder() {
    BulletLayer({ bulletVM: this.bulletVM })
      .position({ top: '15%' })
      .visibility(this.isShowBullet ? Visibility.Visible : Visibility.Hidden)
      .animation({ duration: 300, curve: Curve.Smooth })
  }

  @Builder
  headerBuilder() {
    Row() {
      Row() {
        Image(getMedia('app.media.detail_back'))
          .accessibilityText('返回')
          .height(40)
          .width(40)
          .onClick(() => {
            this.recover();
            appRouter.back(true, {
              params: {
                id: this.videoDetailMaskVM.dramaInfo.id,
                curIndex: this.playControl.curentIndex
              } as ParamsModel
            });
            return true;
          });
      }
      .height(56)
      .layoutWeight(1);

      Row({ space: 10 }) {
        Row() {
          Image(getMedia('app.media.speed'))
            .width(22)
            .height(22);
          Text(this.storage.selectSpeed)
            .fontSize(this.fontModel.getFg(16))
            .fontWeight(500)
            .fontColor('#fff')
            .margin({ left: 5 });
        }
        .accessibilityGroup(true)
        .accessibilityText(`倍速设置，当前为${this.storage.selectSpeed}倍速`)
        .width(92)
        .height(40)
        .backgroundColor('rgba(0, 0, 0, 0.05)')
        .borderRadius(20)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.isShowSetSpeed = !this.isShowSetSpeed;
        })
        .bindSheet($$this.isShowSetSpeed, this.setSpeedBuilder(), {
          height: 340,
          showClose: false,
          preferType: SheetType.BOTTOM,
          enableHoverMode: true
        });

        CastPicker({ isLocked: this.videoDetailMaskVM.isLocked });

        Image(getMedia('app.media.four'))
          .accessibilityText('播放设置')
          .width(40)
          .height(40)
          .onClick(() => {
            this.isShowPlaySettingSheet = !this.isShowPlaySettingSheet;
          })
          .bindSheet($$this.isShowPlaySettingSheet, this.playSettingSheetBuilder(), {
            height: SheetSize.FIT_CONTENT,
            showClose: false,
            preferType: SheetType.CENTER,
            enableHoverMode: true,
            mode: SheetMode.EMBEDDED
          });
      }
      .height(56);
    }
    .height(56)
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 16, right: this.isHover ? 32 : 16 })
  }

  @Builder
  setSpeedBuilder() {
    Column() {
      Row() {
        Text('倍速设置')
          .height(27)
          .fontSize(fp2pxUtil(20))
          .fontWeight(700)
          .fontColor($r('sys.color.font_primary'))
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontSize(fp2pxUtil(24))
            .fontColor([$r('sys.color.icon_primary')])
        }
        .accessibilityText('退出')
        .width(40)
        .height(40)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.isShowSetSpeed = !this.isShowSetSpeed
        })
      }
      .width(328)
      .height(56)
      .margin({ top: 16 })
      .justifyContent(FlexAlign.SpaceBetween)

      ForEach(
        reverseSpeed,
        (item: string) => {
          Row() {
            Text(item === '1.0x' ? (item + '（默认）') : item)
              .fontSize(fp2pxUtil(16))
              .fontColor(this.storage.selectSpeed === item ? '#EC6E45' : $r('sys.color.font_primary'))
            if (this.storage.selectSpeed === item) {
              Column() {
                Image(getMedia('app.media.speed_select'))
                  .width(19.5)
                  .height(12.5)
              }
              .width(24)
              .height(24)
            }
          }
          .accessibilityText(`设置为${item}倍速`)
          .width(328)
          .height(48)
          .justifyContent(this.storage.selectSpeed === item ? FlexAlign.SpaceBetween : FlexAlign.Start)
          .onClick(() => {
            this.storage.selectSpeed = item
            this.onSpeedSet(speedArr[speeds.indexOf(item)])
          })
        },
        (speed: string) => speed
      )
    }
    .height(340)
  }

  @Builder
  playSettingSheetBuilder() {
    Column() {
      Row() {
        Image(getMedia('app.media.handle'))
          .width(48)
          .height(4)
          .margin({ top: 8, left: 24 })
          .onClick(() => {
            this.isShowPlaySettingSheet = !this.isShowPlaySettingSheet
          })
      }
      .width(96)
      .height(16)

      Row() {
        if (this.currentPlaySettingTab !== '') {
          buttonItem($r('sys.symbol.chevron_backward'), () => {
            this.currentPlaySettingTab = ''
          })
        }
        Text(this.currentPlaySettingTab === '' ? '播放设置' :
          (this.currentPlaySettingTab === 'bullet' ? '弹幕设置' :
            (this.currentPlaySettingTab === 'screen' ? '画面设置' : '定时关闭')))
          .width(232)
          .height(27)
          .fontSize(fp2pxUtil(20))
          .fontWeight(700)
          .margin({ left: 8, right: 8 })
        if (this.currentPlaySettingTab === '') {
          buttonItem($r('sys.symbol.checkmark'), () => {
            this.isShowPlaySettingSheet = !this.isShowPlaySettingSheet
          })
        } else if (this.currentPlaySettingTab === 'bullet') {
          buttonItem($r('sys.symbol.checkmark'), () => {
            this.bulletVM.bulletComments = []
            this.bulletVM.xTrans = []
            let bulletSettingItem: BulletSettingItem = new BulletSettingItem()
            bulletSettingItem.rowsNum = this.rowsNum
            bulletSettingItem.notOpacity = this.notOpacity
            bulletSettingItem.danMuSpeed = this.danMuSpeed
            bulletSettingItem.danMuSize = this.danMuSize
            this.bulletVM.storage.setting.set('setting', bulletSettingItem)
            this.currentPlaySettingTab = ''
          })
        } else if (this.currentPlaySettingTab === 'screen') {
          buttonItem($r('sys.symbol.checkmark'), () => {
            this.currentPlaySettingTab = ''
          })
        } else if (this.currentPlaySettingTab === 'timeout') {
          buttonItem($r('sys.symbol.xmark'), () => {
            this.currentPlaySettingTab = ''
          })
        } else {
          Blank()
        }
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 8 })

      if (this.currentPlaySettingTab === '') {
        PlaySetting({
          isShowBullet: this.isShowBullet,
          onSpeedSet: this.onSpeedSet,
          onBulletSet: this.onBulletSet,
          bulletVM: this.bulletVM,
          openBulletSetting: () => {
            this.currentPlaySettingTab = 'bullet'
          },
          openScreenSetting: () => {
            this.currentPlaySettingTab = 'screen'
          },
          openReportSetting: () => {
            appRouter.push({ builderName: NAV_PAGE_NAME.ReportPage.name })
          },
          openTimeoutSetting: () => {
            this.currentPlaySettingTab = 'timeout'
          },
          onClear: this.onClear
        })
      } else if (this.currentPlaySettingTab === 'bullet') {
        this.bulletSettingContent()
      } else if (this.currentPlaySettingTab === 'screen') {
        this.screenSettingContent()
      } else if (this.currentPlaySettingTab === 'timeout') {
        this.timeoutSettingContent()
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }

  @Builder
  bulletSettingContent() {
    Column() {
      BulletSetting({
        rowsNum: this.rowsNum,
        notOpacity: this.notOpacity,
        danMuSpeed: this.danMuSpeed,
        danMuSize: this.danMuSize,
        setRowsNum: (set: number) => {
          this.rowsNum = set
        },
        setNotOpacity: (set: number) => {
          this.notOpacity = set
        },
        setDanMuSpeed: (set: string) => {
          this.danMuSpeed = set
        },
        setDanMuSize: (set: string) => {
          this.danMuSize = set
        }
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 32 })
  }

  @Builder
  screenSettingContent() {
    Column() {
      Row() {
        Text('自动切换画质')
          .fontWeight(500)
          .fontSize(fp2pxUtil(16))
        Toggle({ type: ToggleType.Switch, isOn: $$this.screanResolution.isAutoResolution })
      }
      .height(56)
      .width('100%')
      .borderRadius(16)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 8 })
      .padding({ left: 12, right: 12 })

      Row() {
        Text('分辨率')
          .fontSize(fp2pxUtil(14))
        Row() {
          this.resolutionItem(360)
          this.resolutionItem(480)
          this.resolutionItem(720)
          this.resolutionItem(1080)
        }
        .width('85%')
        .height(36)
        .justifyContent(FlexAlign.SpaceBetween)
        .borderRadius(20)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .height(64)
      .width('100%')
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 32 })
  }

  @Builder
  resolutionItem(resolution: number) {
    Row() {
      Text(`${resolution}p`)
        .fontWeight(500)
        .fontSize(fp2pxUtil(14))
        .fontColor(this.screanResolution.resolutionValue === resolution ? $r('sys.color.font_primary') :
          $r('sys.color.font_secondary'))
    }
    .justifyContent(FlexAlign.Center)
    .width('25%')
    .height('100%')
    .borderRadius(18)
    .backgroundColor(this.screanResolution.resolutionValue === resolution ? $r('sys.color.comp_background_list_card') :
      'transparent')
    .onClick(() => {
      this.screanResolution.resolutionValue = resolution
    })
  }

  isLocked(index: number): boolean {
    if (this.userInfo.isVip) {
      return false
    }
    if (!(ShortDramaDetailListVM.instance.data.getData(index) as DetailVideoData).videoMask.isLocked) {
      return false
    }
    return true
  }

  @Builder
  timeoutSettingContent() {
    Column() {
      ForEach(this.timeItems, (item: TimeoutItem) => {
        this.timeoutItem(item)
      })
    }
    .padding({
      left: 16,
      right: 16,
      top: 8,
      bottom: 76
    })
  }

  @Builder
  timeoutItem(item: TimeoutItem) {
    Row() {
      if (item.isCheck && item.remainTime > 0) {
        Text(this.displayTime)
          .fontSize(16)
          .fontColor('#EC6E45')
          .fontWeight(500)
      } else {
        Text(item.itemName)
          .fontColor(item.isCheck ? '#EC6E45' : $r('sys.color.font_primary'))
          .fontWeight(500)
          .fontSize(16)
      }
      Blank()
      if (item.isCheck) {
        SymbolGlyph($r('sys.symbol.checkmark'))
          .fontSize(24)
          .fontColor(['#EC6E45'])
      }
    }
    .width('100%')
    .height(56)
    .onClick(() => {
      if (item.itemName === '自定义') {
        this.getUIContext().showTextPickerDialog({
          range: this.time,
          selectedTextStyle: { color: '#EC6E45' },
          acceptButtonStyle: { fontColor: '#EC6E45' },
          cancelButtonStyle: { fontColor: $r('sys.color.font_primary') },
          onAccept: (value: TextPickerResult) => {
            const selectedText = value.value
            const hourMatch = selectedText[0].match(/(\d+)小时/)
            const minuteMatch = selectedText[1].match(/(\d+)分钟/)
            const hours = hourMatch ? parseInt(hourMatch[1]) : 0
            const minutes = minuteMatch ? parseInt(minuteMatch[1]) : 0
            const totalMinutes = hours * 60 + minutes
            if (totalMinutes > 0) {
              this.timeItems.forEach((timeoutItem: TimeoutItem) => {
                timeoutItem.isCheck = timeoutItem === item
              })
              item.remainTime = totalMinutes * 60
              this.startTimeoutCountdown(totalMinutes, item.itemName)
              this.currentPlaySettingTab = ''
            }
          },
          onCancel: () => {
          },
        })
      } else if (item.itemName === '不开启') {
        this.clearTimeoutCountdown()
        this.currentPlaySettingTab = ''
      } else if (item.itemName === '播完当集') {
        this.clearTimeoutCountdown()
        this.timeItems.forEach((timeoutItem: TimeoutItem) => {
          timeoutItem.isCheck = timeoutItem === item
        })
        this.currentPlaySettingTab = ''
        this.playControl.autoPlay = false
        this.timeoutStateManager.setIsCheck(true)
        this.timeoutStateManager.setItemName(item.itemName)
        this.globalTimeoutState.isActive = true
        this.globalTimeoutState.itemName = item.itemName
        this.registerEpisodeEndListener()
      } else {
        this.timeItems.forEach((timeoutItem: TimeoutItem) => {
          timeoutItem.isCheck = timeoutItem === item
        })
        let minutes = 0
        if (item.itemName === '15分钟') {
          minutes = 15
        } else if (item.itemName === '30分钟') {
          minutes = 30
        } else if (item.itemName === '60分钟') {
          minutes = 60
        }
        item.remainTime = minutes * 60
        this.startTimeoutCountdown(minutes, item.itemName)
        this.currentPlaySettingTab = ''
      }
    })
  }
}