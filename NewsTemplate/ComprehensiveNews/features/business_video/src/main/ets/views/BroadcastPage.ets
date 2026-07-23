import { AudioUtils, AvRouter } from 'lib_av_details'
import { CommonConstants, NewsEnum, TabBarType, VideoType } from 'lib_common'
import { AvModel } from 'lib_news_api'
import { MediaController, AudioPlayer, AudioItem } from 'module_audioplayer'
import { BroadcastLikeView } from '../components/BroadcastLikeView'
import { BroadcastExtraModel } from '../models/BroadcastModel'
import { BroadcastViewModel } from '../viewmodels/BroadcastViewModel'

@ComponentV2
export struct BroadcastPage {
  // tab页面的index
  @Param index: number = 5
  // 视频页里面的头部tabIndex
  @Param currentTabIndex: VideoType = VideoType.BROADCAST;
  @Local vm: BroadcastViewModel = new BroadcastViewModel(this.getUIContext())
  private avRouter: AvRouter = new AvRouter(this.getUIContext())

  aboutToAppear(): void {
    this.vm.requestBroadcast()
  }

  @Monitor('currentTabIndex', 'vm.tabModel.selectedIndex')
  selectedIndexChange() {
    if (this.vm.tabModel.selectedIndex === TabBarType.VIDEO && this.currentTabIndex === VideoType.BROADCAST) {
      this.vm.destroySubWindow()
    } else {
      // 非广播页面，开启广播小窗
      if (this.vm.settingInfo.network.enableAudioSub) {
        this.vm.createSubWindow()
      } else {
        this.vm.pause()
      }
    }
  }

  @Builder
  broadcastList() {
    List({ space: 24 }) {
      ForEach(this.vm.broadcastList, (item: AvModel, index: number) => {
        ListItem() {
          Stack() {
            Image(item.coverUrl)
              .objectFit(ImageFit.Fill)
            Column()
              .width('100%')
              .height('100%')
              .borderRadius('50%')
              .border({
                width: MediaController.isSameCurrentPlay(item.id) ? 4 : 0,
                color: '#5C79D9',
              })
          }
          .width(56)
          .height(56)
          .clip(true)
          .borderRadius('50%')
          .onClick(() => {
            this.vm.setIndex(index)
            MediaController.setAudioList(AudioUtils.adaptation(this.vm.currentPlayBroadcast()))
            MediaController.setAlbumId(this.vm.getAlbumId())
          })
        }
      }, (item: AvModel) => item.id)
    }
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  build() {
    Column() {
      Refresh({ refreshing: $$this.vm.isRefreshing }) {
        List({ space: 24 }) {
          ListItem() {
            Column({ space: 12 }) {
              Column() {
                Column() {
                  AudioPlayer({
                    audioGroupIndex: this.vm.broadcastIndex,
                    hasOperation: false,
                    fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
                    onAudioTitle: (audioInfo: AudioItem) => {
                      const params: Record<string, string | NewsEnum> = {
                        'id': audioInfo.id,
                        'type': NewsEnum.Broadcast,
                      }
                      this.avRouter.pushToAvDetails(params,
                        'broadcast_audio_tb')
                    },
                    preAction: () => {
                      return this.vm.destroyOtherSession();
                    },
                  })
                }
                .width('100%')
                .padding(16)
                .borderRadius(16)
                .backgroundColor($r('sys.color.comp_background_secondary'))
              }
              .backgroundColor($r('sys.color.background_primary'))
              .id('broadcast_audio_tb')

              this.broadcastList()
            }
          }

          ForEach(this.vm.extraBroadcast, (item: BroadcastExtraModel, index: number) => {
            ListItem() {
              BroadcastLikeView({
                extraInfo: item,
              })
                .padding({ bottom: index === this.vm.extraBroadcast.length - 1 ? 100 : 0})
            }
          }, (item: BroadcastExtraModel, index: number) => item.id + index)
        }
        .height(CommonConstants.FULL_PERCENT)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      }
      .onRefreshing(() => {
        this.vm.refreshData()
      })
    }
    .backgroundColor($r('sys.color.background_primary'))
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .padding({
      left: CommonConstants.PADDING_L,
      top: this.vm.windowModel.windowTopPadding + 56,
      right: CommonConstants.PADDING_L,
    })
  }
}