/**
 * @usage: 作品详情页面,用户从作品列表页点击某个作品后跳转到此页面查看详情和播放音频。
 * 展示音频作品的详细信息(标题、时长、大小、格式等),提供音频播放、进度控制、播放模式切换、
 * 保存到相册等功能。支持播放/暂停、进度拖动、循环模式切换等操作。
 * @layout: 页面采用NavDestination导航容器包裹Column垂直布局,顶部为WorkDetailHeader头部组件,
 * 中间为音频信息展示区域(音频封面、标题、时长等),下方为CustomProgressBar进度条组件,
 * 底部为播放控制按钮区域(播放/暂停、循环模式、保存等按钮)。页面背景色为深色主题。
 * @constraints: 需要音频播放权限。保存到相册需要存储权限。播放器在页面销毁时需要释放资源。
 * 支持列表循环、单曲循环、随机播放等播放模式。
 * @domain: 音频编辑
 * @zhName: 作品详情页面
 * @isGen: true
 * @fileType: page
 * @subPage: 
 * @component: WorkDetailHeader,CustomProgressBar,CustomToast
 * @image: screenshots/audioWorkList/workDetail.jpg
 */
import { phoneRouterControl } from 'oh_router'
import { MusicParam } from 'common_view'
import { WorkDetailHeader } from '../components/WorkDetailHeader'
import { CustomProgressBar } from '../components/CustomProgressBar'
import { CustomToast } from '../components/CustomToast'
import { WorkDetailViewModel } from '../viewmodel/WorkDetailViewModel'
import { AudioInfo } from '../model/AudioInfo'
import { PlayMode } from '../model/PlayMode'
import { TimeFormatter } from '../util/TimeFormatter'
import { common } from '@kit.AbilityKit'
import { BarVM } from 'common'

phoneRouterControl.registerPageBuilder('WorkDetailPage', wrapBuilder(WorkDetailPageBuilder))

@Builder
export function WorkDetailPageBuilder(params: object) {
  WorkDetailPage()
}

@ComponentV2
export struct WorkDetailPage {
  // ViewModel
  private viewModel: WorkDetailViewModel = new WorkDetailViewModel()
  // UI状态
  @Local currentAudio: AudioInfo = new AudioInfo()
  @Local isPlaying: boolean = false
  @Local currentTime: number = 0
  @Local showInfoDialog: boolean = false
  @Local isSaving: boolean = false
  @Local toastMessage: string = ''
  @Local showToast: boolean = false
  @Local playMode: PlayMode = PlayMode.LIST_LOOP

  private toastTimer?: number

  aboutToDisappear(): void {
    this.viewModel.release()
    if (this.toastTimer) {
      clearTimeout(this.toastTimer)
    }
  }

  // 显示自定义Toast
  showCustomToast(message: string): void {
    this.toastMessage = message
    this.showToast = true

    // 清除之前的定时器
    if (this.toastTimer) {
      clearTimeout(this.toastTimer)
    }

    // 2秒后自动隐藏
    this.toastTimer = setTimeout(() => {
      this.showToast = false
    }, 2000)
  }

  // 初始化ViewModel
  async initViewModel(): Promise<void> {
    // 先设置回调
    this.viewModel.setOnPlayStateChanged((isPlaying: boolean) => {
      this.isPlaying = isPlaying
    })

    this.viewModel.setOnTimeChanged((time: number) => {
      this.currentTime = time
    })

    this.viewModel.setOnDurationChanged((duration: number) => {
      this.currentAudio.duration = duration
    })

    this.viewModel.setOnAudioChanged((audio: AudioInfo) => {
      this.currentAudio = audio
    })

    this.viewModel.setOnError((message: string) => {
      this.showCustomToast(message)
    })

    this.viewModel.setOnToast((message: string) => {
      this.showCustomToast(message)
    })

    this.viewModel.setOnSaveStateChanged((isSaving: boolean) => {
      this.isSaving = isSaving
    })

    this.viewModel.setOnPlayModeChanged((playMode: PlayMode) => {
      this.playMode = playMode
    })

    // 再初始化播放器，传入context
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext
    await this.viewModel.init(context)
  }

  // 事件处理
  backHandle = () => {
    phoneRouterControl.popPage()
  }
  infoHandle = () => {
    this.showInfoDialog = true
  }
  togglePlay = () => {
    this.viewModel.togglePlay()
  }
  playPrevious = () => {
    this.viewModel.playPrevious()
  }
  playNext = () => {
    this.viewModel.playNext()
  }
  toggleRepeat = () => {
    this.viewModel.togglePlayMode()
  }
  saveAudio = () => {
    this.viewModel.saveCurrentAudio()
  }
  handleSliderChange = (time: number) => {
    this.viewModel.setSliderChanging(true)
    this.currentTime = time
    this.viewModel.seekTo(time)
    this.viewModel.setSliderChanging(false)
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          // CD光盘图片
          Stack() {
            // CD光盘 - 从上到下的渐变：黑色 -> 青绿色 -> 黑色
            Column()
              .width(300)
              .height(300)
              .borderRadius(150)
              .linearGradient({
                angle: 180,
                colors: [
                  ['#000000', 0.0],
                  ['#023B38', 0.5],
                  ['#000000', 1.0]
                ]
              })

            // 内圈
            Column()
              .width(230)
              .height(230)
              .borderRadius(115)
              .border({
                width: 2,
                color: '#003A36'
              })

            // 中心孔
            Circle()
              .width(50)
              .height(50)
              .fill('#0A0D1E')
          }
          .margin({ top: 160 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#0A0D1E')
        .justifyContent(FlexAlign.Start)

        Column(){
          // 顶部导航栏
          WorkDetailHeader({
            title: this.currentAudio.title,
            onBackClick: this.backHandle,
            onInfoClick: this.infoHandle
          })

          // 底部播放控制区域
          Column() {
            // 自定义Toast（在进度条上方24px）
            Row() {
              CustomToast({
                message: this.toastMessage,
                visible: this.showToast
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .margin({ bottom: 24 })

            // 进度条
            Row() {
              Text(TimeFormatter.formatTime(this.currentTime))
                .fontSize(12)
                .fontColor('#999999')

              CustomProgressBar({
                currentTime: this.currentTime,
                duration: this.currentAudio.duration,
                onSeek: this.handleSliderChange
              })
                .layoutWeight(1)
                .margin({ left: 12, right: 12 })

              Text(TimeFormatter.formatTime(this.currentAudio.duration))
                .fontSize(12)
                .fontColor('#999999')
            }
            .width('100%')
            .margin({ bottom: 32 })

            // 播放控制按钮
            Row() {
              // 播放模式按钮
              Image(this.playMode === PlayMode.SINGLE_LOOP ?
                $r('app.media.icon_replay') : $r('app.media.icon_orderPlay'))
                .width(24)
                .height(24)
                .fillColor('#FFFFFF')
                .onClick(() => {
                  this.toggleRepeat()
                })

              Blank().layoutWeight(1)

              // 上一首按钮
              Image($r('app.media.icon_playPre'))
                .width(24)
                .height(24)
                .fillColor('#FFFFFF')
                .onClick(() => {
                  this.playPrevious()
                })

              Blank().layoutWeight(1)

              // 播放/暂停按钮
                Image(this.isPlaying ? $r('app.media.icon_pause') : $r('app.media.icon_play'))
                  .width(48)
                  .height(48)
                  .fillColor('#FFFFFF')
                  .onClick(() => {
                    this.togglePlay()
                  })

              Blank().layoutWeight(1)

              // 下一首按钮
              Image($r('app.media.icon_playNext'))
                .width(24)
                .height(24)
                .fillColor('#FFFFFF')
                .onClick(() => {
                  this.playNext()
                })

              Blank().layoutWeight(1)

              // 下载按钮
              Image($r('app.media.icon_download'))
                .width(24)
                .height(24)
                .fillColor('#FFFFFF')
                .opacity(this.isSaving ? 0.5 : 1.0)
                .onClick(() => {
                  if (!this.isSaving) {
                    this.saveAudio()
                  }
                })
            }
            .width('100%')
            .padding({ left: 24, right: 24 })
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 40 })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .height('100%')
        .padding({
          top: BarVM.instance.staBarH
        })

        // 音频信息弹窗
        if (this.showInfoDialog) {
          Column() {
            Column() {
              // 标题
              Text('音频信息')
                .fontSize(20)
                .fontColor('#FFFFFF')
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 32 })

              // 信息列表
              Column({ space: 16 }) {
                // 文件名
                Row() {
                  Text('文件名：')
                    .fontSize(14)
                    .fontColor('rgba(255,255,255,0.6)')
                    .width(70)
                  Text(this.currentAudio.title)
                    .fontSize(14)
                    .fontColor('rgba(255,255,255,0.8)')
                    .layoutWeight(1)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .width('100%')
                .alignItems(VerticalAlign.Top)

                // 时长
                Row() {
                  Text('时长：')
                    .fontSize(14)
                    .fontColor('rgba(255,255,255,0.6)')
                    .width(70)
                  Text(TimeFormatter.formatTime(this.currentAudio.duration))
                    .fontSize(14)
                    .fontColor('rgba(255,255,255,0.8)')
                }
                .width('100%')

                // 格式
                Row() {
                  Text('格式：')
                    .fontSize(14)
                    .fontColor('rgba(255,255,255,0.6)')
                    .width(70)
                  Text(this.currentAudio.format)
                    .fontSize(14)
                    .fontColor('rgba(255,255,255,0.8)')
                }
                .width('100%')

                // 大小
                Row() {
                  Text('大小：')
                    .fontSize(14)
                    .fontColor('rgba(255,255,255,0.6)')
                    .width(70)
                  Text(this.currentAudio.size)
                    .fontSize(14)
                    .fontColor('rgba(255,255,255,0.8)')
                }
                .width('100%')

                // 路径
                Row() {
                  Text('路径：')
                    .fontSize(14)
                    .fontColor('rgba(255,255,255,0.6)')
                    .width(70)
                  Text(this.currentAudio.path)
                    .fontSize(12)
                    .fontColor('rgba(255,255,255,0.8)')
                    .layoutWeight(1)
                    .maxLines(3)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .lineHeight(18)
                }
                .width('100%')
                .alignItems(VerticalAlign.Top)
              }
              .width('100%')
              .margin({ bottom: 32 })

              // 确认按钮
              Text('确认')
                .width('100%')
                .textAlign(TextAlign.Center)
                .height(44)
                .backgroundColor('rgba(0,0,0,0)')
                .border({
                  width: 1,
                  color: '#01FCEA',
                  radius: 22
                })
                .fontColor('#01FCEA')
                .fontSize(16)
                .onClick(() => {
                  this.showInfoDialog = false
                })
            }
            .width('85%')
            .padding(24)
            .backgroundColor('#2C3E50')
            .borderRadius(16)
          }
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.6)')
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.showInfoDialog = false
          })
        }
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
    .onReady(async (context) => {
      // 先初始化ViewModel
      await this.initViewModel()

      // 再加载音频信息
      let param = context.pathInfo.param as MusicParam
      this.viewModel.loadAudioInfo(
        param.uri || '',
        param.title || '',
        param.duration || 0,
        param.size || '',
        param.format || '',
        param.path || ''
      )
    })
  }
}
