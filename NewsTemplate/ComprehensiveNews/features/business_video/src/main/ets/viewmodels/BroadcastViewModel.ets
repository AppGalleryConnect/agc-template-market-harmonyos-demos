import { common } from '@kit.AbilityKit';
import { emitter } from '@kit.BasicServicesKit';
import { AudioUtils, AVSessionUtils, broadcastSize, CardSizeConstants } from 'lib_av_details';
import { BaseViewModel, GlobalContextUtils } from 'lib_common';
import { AvModel, HomeServiceApi } from 'lib_news_api';
import { AudioConstants, MediaController, AudioService, EventMap } from 'module_audioplayer';
import { BroadcastExtra, BroadcastExtraModel } from '../models/BroadcastModel';

@ObservedV2
export class BroadcastViewModel extends BaseViewModel {
  @Trace broadcastList: AvModel[] = []
  @Trace broadcastExtraList: AvModel[] = []
  @Trace currentPage: number = 0;
  @Trace currentIndex: number = 10;
  @Trace broadcastIndex: number = 0;
  @Trace currentTabIndex: number = 0
  @Trace isRefreshing: boolean = false
  DESTROY_TIME: number = 200
  extraBroadcast: BroadcastExtraModel[] = [
    {
      id: BroadcastExtra.HOT,
      title: '热门点播',
    },
    {
      id: BroadcastExtra.RECOMMEND,
      title: '今日推荐',
    },
  ]
  context: UIContext

  constructor(context: UIContext) {
    super()
    this.context = context
  }

  @Monitor('settingInfo.network.enableAudioSub')
  enableAudioSubChange() {
    if (!this.settingInfo.network.enableAudioSub) {
      this.pause()
      this.destroySubWindow()
    }
  }

  @Monitor('userInfoModel.isLogin')
  loginStatusChange() {
    if (!this.userInfoModel.isLogin) {
      this.pause()
      this.destroySubWindow()
      AudioService.destroySession(this.context.getHostContext() as common.UIAbilityContext)
    }
  }

  /*
   * 初始化广播数据
   * */
  public async requestBroadcast() {
    this.broadcastList = await HomeServiceApi.queryBroadcastList(this.currentIndex, this.currentPage)
    this.initAudioPlayer()
  }

  public initAudioPlayer() {
    MediaController.initAudioList(GlobalContextUtils.globalUIAbilityContext)
    MediaController.setAudioList(AudioUtils.adaptation(this.broadcastList[this.broadcastIndex]))
    MediaController.setAlbumId(this.broadcastList[this.broadcastIndex].id)
  }

  /*
   * 初始化广播猜你喜欢数据
   * */
  async requestBroadcastLike(id: BroadcastExtra) {
    this.broadcastExtraList =
      id === BroadcastExtra.HOT ? await HomeServiceApi.queryBroadcastHot() :
        await HomeServiceApi.queryBroadcastRecommend()
  }

  // 销毁应用中其他AVSession
  public async destroyOtherSession(): Promise<void> {
    await AVSessionUtils.destroyVideoSession()
    await AVSessionUtils.destroyReaderSession()
  }

  public setIndex(index: number) {
    this.broadcastIndex = index
  }

  public async refreshData() {
    this.isRefreshing = true
    this.broadcastList = await HomeServiceApi.queryBroadcastList(this.currentIndex, this.currentPage)
    this.isRefreshing = false
  }

  public currentPlayBroadcast() {
    return this.broadcastList[this.broadcastIndex]
  }

  public getAlbumId() {
    return this.broadcastList[this.broadcastIndex].id
  }

  public destroySubWindow() {
    AudioService.destroySubWindow(AudioConstants.AUDIO_SUB_NAME)
  }

  public createSubWindow() {
    AudioService.createSubWindow(this.context)
  }

  public pause() {
    MediaController.pause()
  }

  public destroyEmitter() {
    emitter.off(EventMap.ON_SUB_WINDOW)
  }

  /**
   * 广播卡片根据断点改变大小
   * */
  @Computed
  get getBroadcastSize() {
    return broadcastSize.getValue(this.breakPointModel.currentBreakpoint) ?? CardSizeConstants.xlSize
  }
}