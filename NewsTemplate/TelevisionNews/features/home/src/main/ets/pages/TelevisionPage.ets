import { Constants, NavHeaderTitleBar, RouterUtils } from 'lib_common'
import { AvModel } from 'lib_tv_apis'
import {
  VideoCard, VideoNetworkModel,
} from 'module_swipeplayer'
import { TelevisionLikeView } from '../components/TelevisionLikeView'
import { TvSearch } from '../components/TvSearch'
import { TelevisionViewModel } from '../viewmodels/TelevisionViewModel'

@ComponentV2
export struct TelevisionPage {
  // tab页面的index
  @Param index: number = 0
  @Local vm: TelevisionViewModel = new TelevisionViewModel(this.getUIContext())

  @Monitor('index')
  tabIndexChange() {
    this.vm.tabIndexChange()
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
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
        Row({ space: 4 }) {
          Text('节目单')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_primary'))
          SymbolGlyph($r('sys.symbol.list_bullet'))
            .fontColor([$r('sys.color.font_primary')])
            .fontSize(16)
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
                  color: '#EB5544',
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
      NavHeaderTitleBar({ hasBackButton: false, title: '电视' })
      TvSearch({ videoCardPlayerController: this.vm.videoCardPlayerController })
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
                  enableAVSession: true,
                  enableCastPlay: true,
                  videoNetwork: this.vm.networkModel as VideoNetworkModel,
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
                })
              }
            }
            .width(Constants.FULL_PERCENT)
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
      .layoutWeight(1)
      .onRefreshing(() => {
        this.vm.refreshData()
      })
    }
    .backgroundColor($r('sys.color.background_primary'))
    .width(Constants.FULL_PERCENT)
    .height(Constants.FULL_PERCENT)
    .padding({
      left: Constants.PADDING_L,
      right: Constants.PADDING_L,
    })
  }
}