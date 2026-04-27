import { AudioSaveHeader, FileUtil, ProgressDialogVM } from 'audio_common'
import { WorkersController } from 'audio_worker'
import { AudioCropView } from '../view/AudioCropView'
import { AudioEditViewModel } from '../viewModel/AudioEditViewModel'
import { fileIo } from '@kit.CoreFileKit'
import { common } from '@kit.AbilityKit'

const TAG = 'AudioCropPage'

@ComponentV2
export struct AudioCropPage {
  @Param musicTitle: string = ''
  @Param pcmPath: string = '' //pcm路径
  @Param sourcePath: string = '' //源文件路径
  @Param channelLayout: number = 0 //声道数量
  @Param sampleRate: number = 0 //采样率
  @Param duration: number = 0 //音频时长（毫秒）
  @Param sampleFormat: number = 0 //音频时长（毫秒）
  @Local audioEditViewModel: AudioEditViewModel = new AudioEditViewModel()
  fileUti = new FileUtil(this.getUIContext().getHostContext() as common.UIAbilityContext)
  progressDialogVM: ProgressDialogVM = new ProgressDialogVM(this.getUIContext());
  @Param resultCallBack: (outPath: string) => void = (outPath: string) => {
  }
  @Param backHandle: () => void = () => {

  }
  onChange = (startTime: number, endTime: number) => {
    this.audioEditViewModel.setStartTime(startTime)
    this.audioEditViewModel.setEndTime(endTime)
  }
  saveHandle = () => {
    if (this.audioEditViewModel.taskStatus) {
      this.getUIContext().getPromptAction().showToast({
        message: '当前剪裁任务正在进行中，请勿重复点击。'
      })
      return
    }
    this.audioEditViewModel.taskStatus = true
    if (this.audioEditViewModel.workerId < 0 || !WorkersController.hasWorker(this.audioEditViewModel.workerId)) {
      this.audioEditViewModel.workerId = WorkersController.createWorker(this.audioEditViewModel)
      if (this.audioEditViewModel.workerId < 0) {
        this.getUIContext().getPromptAction().showToast({
          message: '已有任务在执行，请等待任务结束后在操作!'
        })
      }
    }
    this.audioEditViewModel.tempSourcePath = this.fileUti.copyFilePath(this.sourcePath)
    const pathArr = this.fileUti.splitFilePath(this.sourcePath)
    this.audioEditViewModel.outPath =
      this.fileUti.getAudioOutDir() + this.fileUti.generateUniquePathname('音频剪辑-'+this.musicTitle)
    this.audioEditViewModel.logPath = this.fileUti.getLogOutPath()
    WorkersController.startTask(this.audioEditViewModel.workerId)
    this.audioEditViewModel.openProgressDialog()
  }

  aboutToAppear(): void {
    this.audioEditViewModel.musicTitle = this.musicTitle
    this.audioEditViewModel.setStartTime(0)
    this.audioEditViewModel.setEndTime(this.duration / 1000)
    this.audioEditViewModel.resultCallBack = this.resultCallBack
    this.audioEditViewModel.progressDialogVM = this.progressDialogVM
  }

  build() {
    NavDestination() {
      Column() {
        AudioSaveHeader({
          saveHandle: this.saveHandle,
          title: '音频剪辑',
          backHandle: this.backHandle
        }).margin({ top: 8 }).padding({ left: 16, right: 16 })
        AudioCropView({
          pcmPath: this.pcmPath,
          channelLayout: this.channelLayout,
          sampleRate: this.sampleRate,
          duration: this.duration,
          musicTitle: this.musicTitle,
          onChange: this.onChange
        })
      }.width('100%').height('100%')
      .backgroundColor('#0A0D1E')
    }.hideTitleBar(true).width('100%').height('100%')
    .onBackPressed(() => {
      this.backHandle()
      return true
    })
  }
}