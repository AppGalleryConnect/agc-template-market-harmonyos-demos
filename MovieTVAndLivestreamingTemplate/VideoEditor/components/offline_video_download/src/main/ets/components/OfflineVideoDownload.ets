import { window } from '@kit.ArkUI';
import { VideoInfo } from '../CommonConstants';
import { VideoDownloadVM } from '../viewmodels/VideoDownloadVM';
import { BarVM, VideoBackPressUtils } from 'video_common';

/**
 * @usage: 用于展示离线视频下载和播放组件。支持视频下载进度显示、播放控制、
 横竖屏切换、播放进度控制和窗口尺寸自适应功能
 * @layout: 组件整体采用垂直布局（Column），包含视频信息卡片和视频播放区域，
 播放区域使用Stack布局包含XComponent视频播放器和底部控制栏，支持横竖屏模式切换
 * @constraints: vm 视频下载管理器；videoState 播放状态控制；isPlaying 播放状态；
 isCached 缓存状态；currentCachePercent 下载进度；mXcomponentController 视频控制器
 * @zhName: 离线视频下载
 * @fileType: component
 * @isGen: true
 * @subPage:
 * @component:
 */

@ComponentV2
export struct OfflineVideoDownload {
  vm: VideoDownloadVM = new VideoDownloadVM(this.getUIContext());
  @Param @Require videoInfo: VideoInfo
  @Param isEditMode: boolean = false; // 是否处于编辑模式
  @Param isDarkMode: boolean = false; // 是否处于深色背景
  @Consumer('isScreenLand') isScreenLand: boolean = false;
  @Consumer('isInPlayStatus') isInPlayStatus: boolean = false;
  onLandBackPress: (() => boolean) | undefined = undefined

  @Monitor('vm.isLandscape')
  async onStrChange(monitor: IMonitor) {
    let size: Size = { width: 0, height: 0 };
    try {
      let windowClass = await window.getLastWindow(getContext());
      let properties = windowClass.getWindowProperties();
      this.isScreenLand = this.vm.isLandscape
      size = {
        width: properties.windowRect.width,
        height: properties.windowRect.height
      }
    } catch (error) {}
    this.vm.getWindowSizeChange(size)
    this.vm.getVideoSize()

    if (this.vm.isLandscape) {
      this.isInPlayStatus = true;
      this.onLandBackPress = () => {
        this.clickBack()
        return true
      }
      VideoBackPressUtils.addBackPressCb(this.onLandBackPress)
    }

  }

  // 界面初始化函数
  async aboutToAppear() {
  }

  // 界面销毁函数
  async aboutToDisappear() {
    this.isScreenLand = false
    await this.vm.aboutToDisappear();
  }

  clickBack() {
    this.isInPlayStatus = false;
    if (!!this.onLandBackPress) {
      VideoBackPressUtils.removeBackPressCb(this.onLandBackPress)
    }
    this.onLandBackPress = undefined;

    this.isScreenLand = this.vm.isLandscape
    this.vm.initAVPlayer();
    //返回时如果之前是下载，则退出继续保持下载，否则继续暂停下载
    if (this.vm.isPlaying) { //之前是暂停下载状态
      this.vm.pause();
      if (this.vm.videoInfo) {
        this.vm.videoInfo.isDownloading = false;
      }
    } else {
      this.vm.play();
      if (this.vm.videoInfo) {
        this.vm.videoInfo.isDownloading = true;
      }
    }
    this.vm.zoomVideo('zoomOut')
    this.vm.videoState.isPlaying = false
  }

  build() {
    Column() {
      if (!this.vm.videoState.isPlaying) {
        this.listBuilder()
      }

      Stack({ alignContent: Alignment.Top }) {
        Row() {
          // 当播放的是非音频时，加载XComponent控件
          XComponent({
            id: 'componentId' + this.videoInfo.id,
            type: 'surface',
            controller: this.vm.mXcomponentController
          })
            .onLoad(async () => {
              await this.vm.init(this.videoInfo);
              // 加载完成后调用初始化播放器函数
              this.vm.initAVPlayer();
            })
            .renderFit(this.vm.isLandscape ? RenderFit.RESIZE_CONTAIN : RenderFit.RESIZE_FILL)
            .width('100%')
            .aspectRatio(this.vm.ratio)
            .onAreaChange((oldValue: Area, newValue: Area) => {
              let currentHeight = newValue.height; // 获取当前高度
            })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .position({ x: 0, y: 0 })
        .attributeModifier(this.vm.modifier)
        .zIndex(this.vm.modifier.isTop ? 999 : 0)

        Column() {
          Row() {
            Row() {
              Image($r('app.media.ic_arrow_left'))
                .width(8)
                .objectFit(ImageFit.Contain)
                .fillColor('#fff')
            }
            .margin({ top: this.getMarginTop() })
            .width(24)
            .height(24)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.clickBack()
            })
          }.width('100%')

          this.playBuilder()
        }
        .height('100%')
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .height('100%')
      .visibility(this.vm.videoState.isPlaying && this.vm.videoName === this.vm.videoState.videoName ?
      Visibility.Visible : Visibility.Hidden)
    }
    .height(!this.vm.videoState.isPlaying ? 60 :
      this.vm.videoState.isPlaying && this.vm.videoName === this.vm.videoState.videoName ? '100%' : 0)
    .margin({ bottom: this.vm.videoState.isPlaying ? 0 : 16 })
  }

  getMarginTop() {
    if (this.isScreenLand) {
      return 16
    }
    if (this.isInPlayStatus) {
      return BarVM.instance.staBarH + 16
    } else {
      return 0
    }
  }

  @Builder
  listBuilder1() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      // 显示视频缩略图
      Image(this.videoInfo.thumbnail)
        .width(100)
        .height(60)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)

      // 时长标签
      Text(this.vm.videoDuration)
        .fontSize(10)
        .fontColor('#fff')
        .padding({
          left: 4,
          right: 4,
          top: 2,
          bottom: 2
        })
        .borderRadius(4)
        .margin({ right: 4, bottom: 4 })

      // 可播放蒙层
      if (!this.vm.videoInfo?.isCached && this.vm.videoInfo?.sizeCurrent !== '0K') {
        Column() {
          Image($r('app.media.icon_play'))
            .width(16)
            .height(16)
            .fillColor('#fff')
          Text('可播放').fontSize(9).fontColor('#fff').margin({ top: 2 })
        }
        .backgroundColor('rgba(0,0,0,0.6)')
        .width(100)
        .height(60)
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
      }

    }
    .onClick(async () => {
      // 编辑模式下禁用点击
      if (this.isEditMode) {
        return;
      }
      this.vm.play('playing');
      //点击播放视频不用关心之前是否处于下载状态，即this.vm.isPlaying状态
    })
  }

  @Builder
  listBuilder21() {
    Text(this.videoInfo.name)
      .fontSize(15)
      .fontColor(this.isDarkMode ? 'rgba(255, 255, 255, 0.80)' : '#000')
      .textAlign(TextAlign.Center)

    if (!this.vm.videoInfo?.isCached) {
      Row() {
        Progress({ value: 0, total: 100, type: ProgressType.Linear })
          .color($r('sys.color.comp_background_emphasize'))
          .backgroundColor($r('sys.color.comp_background_secondary'))
          .value(this.vm.videoInfo?.currentCachePercent)
          .width('100%')
      }
    }
  }

  @Builder
  listBuilder22() {
    Row() {
      //下载内存进度
      Text((this.vm.videoInfo?.isCached ? '' : this.vm.videoInfo?.sizeCurrent + '/') + this.vm.videoSize + 'M')
        .fontColor(this.isDarkMode ? 'rgba(255, 255, 255, 0.60)' : 'rgba(0, 0, 0, 0.60)')
        .fontSize(12)

      // 下载状态和速度
      Column() {
        Text(this.vm.videoInfo?.isCached ? '已完成' :
          this.vm.videoInfo?.isDownloading ? this.vm.getFormattedDownloadSpeed() :
            this.vm.videoInfo?.sizeCurrent === '0K' ? '等待中' : '已暂停')
          .fontSize(12)
          .fontColor(this.isDarkMode ? 'rgba(255, 255, 255, 0.60)' : 'rgba(0, 0, 0, 0.60)')
      }
      .alignItems(HorizontalAlign.End)

    }.width('100%').justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  listBuilder2() {
    Column() {
      this.listBuilder21()
      this.listBuilder22()
    }
    .width('calc(100% - 100vp)')
    .height('100%')
    .padding({ left: 12 })
    .justifyContent(FlexAlign.SpaceEvenly)
    .alignItems(HorizontalAlign.Start)
    .onClick(async () => {
      // 编辑模式和已缓存状态禁用点击
      if (this.isEditMode || this.vm.videoInfo?.isCached) {
        return;
      }

      if (this.vm.isPlaying) {
        this.vm.play();
        if (this.vm.videoInfo) {
          this.vm.videoInfo.isDownloading = true;
        }
      } else {
        this.vm.pause();
        this.vm.initAVPlayer();
        if (this.vm.videoInfo) {
          this.vm.videoInfo.isDownloading = false;
        }
      }
      this.vm.isPlaying = !this.vm.isPlaying;
    })
  }

  @Builder
  listBuilder() {
    Row() {
      this.listBuilder1()
      this.listBuilder2()

    }.width('100%').height(60).justifyContent(FlexAlign.SpaceEvenly)
  }

  @Builder
  playBuilder() {
    Row() {
      // 根据状态不同设置播放暂停图标显示
      Image(!this.vm.videoState.playStatus ? $r('app.media.icon_play') : $r('app.media.icon_pause'))
        .fillColor('#fff')
        .width(24)
        .aspectRatio(1)
        .onClick(() => {
          if (!this.vm.videoState.playStatus) {
            this.vm.play('continue');
            this.vm.videoState.playStatus = true;
          } else {
            this.vm.pause();
            this.vm.videoState.playStatus = false;
          }
        })
      Row() {
        Text(this.vm.currentTime)
          .fontSize(15)
          .width(50)
          .textAlign(TextAlign.Center)
          .fontColor('rgba(255, 255, 255, 0.85)')
        Slider({
          value: this.vm.setValue,
          min: 0,
          max: 100,
          step: 1,
          style: SliderStyle.OutSet
        })
          .blockColor(Color.Grey)
          .trackColor($r('sys.color.comp_background_secondary'))
          .showSteps(true)
          .showTips(false)
          .width('calc(100% - 100vp)')
          .onChange((value: number, mode: SliderChangeMode) => {
            if (mode === SliderChangeMode.End) {
              this.vm.avPlayer?.seek((value / 100) * this.vm.duration, 0);
            }
          })
        Text(this.vm.durationTimeText)
          .fontSize(15)
          .width(50)
          .textAlign(TextAlign.Center)
          .fontColor('rgba(255, 255, 255, 0.85)')
      }.width('calc(100% - 48vp)')

      // 根据状态不同设置播放暂停图标显示
      Image(this.vm.isLandscape ? $r('app.media.zoomIn_icon') : $r('app.media.zoomOut_icon'))
        .fillColor('#fff')
        .width(24)
        .aspectRatio(1)
        .onClick(() => {
          if (this.vm.isLandscape) {
            this.vm.zoomVideo('zoomOut')
          } else {
            this.vm.zoomVideo('zoomIn')
          }
        })
    }.width('100%')
    .padding({ left: 10, right: 10 })
    .alignItems(VerticalAlign.Center)
  }
}