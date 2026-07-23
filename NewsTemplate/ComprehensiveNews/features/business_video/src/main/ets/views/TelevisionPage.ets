import { emitter } from '@kit.BasicServicesKit'
import { CommonConstants, RouterUtils, VideoType, EventEnum } from 'lib_common'
import { AvModel } from 'lib_news_api'
import { VideoCard, VideoNetworkModel, VideoNetworkSetting } from 'module_swipeplayer'
import { TelevisionLikeView } from '../components/TelevisionLikeView'
import { TelevisionViewModel } from '../viewmodels/TelevisionViewModel'

@ComponentV2
export struct TelevisionPage {
  // tab页面的index
  @Param index: number = 3
  // 视频页里面的头部tabIndex
  @Param currentTabIndex: VideoType = VideoType.TELEVISION;
  @Local vm: TelevisionViewModel = new TelevisionViewModel(this.getUIContext())

  @Monitor('currentTabIndex', 'vm.tabModel.selectedIndex')
  async selectedIndexChange() {
    emitter.emit(EventEnum.STOP_VIDEO_PLAY)
  }

  aboutToAppear(): void {
    this.vm.requestTelevision()
  }

  aboutToDisappear(): void {
    this.vm.destroyListener()
  }

  @Builder
  televisionList() {
    Column({ space: 16 }) {
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Text(this.vm.getTitle())
          .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
        Row({ space: 4 }) {
          Text('节目单')
            .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_primary'))
          SymbolGlyph($r('sys.symbol.list_bullet'))
            .fontColor([$r('sys.color.font_primary')])
            .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
        }
        .onClick(() => {
          this.vm.openProgram()
        })
      }

      List({ space: 24 }) {
        ForEach(this.vm.televisionList, (item: AvModel, index: number) => {
          ListItem() {
            Stack() {
              Image(item.coverUrl)
                .objectFit(ImageFit.Fill)
              Column()
                .width('100%')
                .height('100%')
                .borderRadius('50%')
                .border({
                  width: this.vm.televisionIndex === index ? 4 : 0,
                  color: '#5C79D9',
                })
            }
            .width(56)
            .height(56)
            .clip(true)
            .borderRadius('50%')
            .onClick(() => {
              this.vm.setIndex(index, item)

            })
          }
        }, (item: AvModel) => item.id)
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
  }

  build() {
    Column() {
      Refresh({ refreshing: $$this.vm.isRefreshing }) {
        List({ space: 24 }) {
          ListItem() {
            Column({ space: 16 }) {
              if (!this.vm.loading) {
                VideoCard({
                  currentIndex: 0,
                  index: 0,
                  videoData: this.vm.detailData,
                  isShown: true,
                  videoNetwork: this.vm.networkModel as VideoNetworkModel,
                  videoNetworkSetting: this.vm.settingInfo.network as VideoNetworkSetting,
                  currentBreakpoint: this.vm.breakPointModel.currentBreakpoint,
                  videoCardPlayerController: this.vm.videoCardPlayerController,
                  isFromDetailCard: true,
                  enablePip: false,
                  isHideSlide: true,
                  isLandscape: false,
                  pathStack: RouterUtils.getStack(),
                  fullScreenIcon: $r('app.media.ic_sys_full_screen'),
                  isNeedMuteIcon: true,
                  isNeedRelease: false,
                  isMute: this.vm.isMute,
                  onMute: (value) => {
                    this.vm.setMute(value)
                  },
                  playerStateCallback: (state: string) => {
                    if (state === 'playing') {
                      this.vm.stopPip()
                    }
                  },
                })
              }
            }
            .width(CommonConstants.FULL_PERCENT)
            .aspectRatio(this.vm.videoBoxAspectRatio)
            .borderRadius(16)
            .clip(true)
          }

          ListItem() {
            this.televisionList()
          }

          ListItem() {
            TelevisionLikeView()
          }
        }
        .layoutWeight(1)
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