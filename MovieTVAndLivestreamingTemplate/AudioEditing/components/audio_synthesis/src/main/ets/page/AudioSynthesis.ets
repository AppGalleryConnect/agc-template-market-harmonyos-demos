import { MusicListView } from '../components/MusicListView'
import { MusicViewModel } from '../viewModel/MusicViewModel';
import { AudioSynthesisHeader } from '../components/AudioSynthesisHeader';
import { FileUtil, ProgressDialogInfo, ProgressDialogVM } from 'audio_common';
import { common } from '@kit.AbilityKit';
import { WorkersController } from 'audio_worker';
import { AudioSynthesisViewModel } from '../viewModel/AudioSynthesisViewModel';
import { MusicLibraryComponent } from '../components/MusicLibraryComponent';
import { MusicListViewController } from 'common_view';

const TAG = 'AudioSynthesis'

@ComponentV2
export struct AudioSynthesis {
  @Param backHandle: () => void = () => {
  }
  @Param selectedMusicList: MusicViewModel[] = [] //选中的音频列表，用于合成功能
  @Local audioSynthesisViewModel: AudioSynthesisViewModel = new AudioSynthesisViewModel()
  fileUti = new FileUtil(this.getUIContext().getHostContext() as common.UIAbilityContext)
  context = getContext(this) as common.UIAbilityContext
  fileUtil = new FileUtil(this.context)
  @Param resultCallBack: (outPath: string) => void = (outPath: string) => {
  }
  uiContext = this.getUIContext()
  @Local progressDialogVM: ProgressDialogVM = new ProgressDialogVM(this.uiContext)
  @Local dialogState: ProgressDialogInfo = new ProgressDialogInfo()
  @Local isShow: boolean = false;
  @Local sheetHeight: string = '80%';
  musicListViewController = new MusicListViewController()
  musicItemOnclick = (item: MusicViewModel) => {
  }
  //列表多选事件
  musicItemOnChange = (item: MusicViewModel, checkBoxStatus: boolean) => {
    // 合成页面不需要处理选中状态变化
  }

  private convertToKB(size: string): number {
    // 提取数值和单位
    const sizeValue = parseFloat(size);
    const unit = size.replace(/[0-9.]/g, '').trim().toUpperCase(); // 提取单位并转换为大写

    // 根据单位进行转换
    switch (unit) {
      case 'B':
        return sizeValue; // 字节直接返回
      case 'KB':
        return sizeValue * 1024; // KB转为字节
      case 'MB':
        return sizeValue * 1024 * 1024; // MB转为字节
      case 'GB':
        return sizeValue * 1024 * 1024 * 1024; // GB转为字节
      case 'TB':
        return sizeValue * 1024 * 1024 * 1024 * 1024; // TB转为字节
      default:
        return 0; // 未知单位返回0
    }
  }

  /**
   * 音频合成
   */
  private audioMerge() {
    if (this.selectedMusicList.length < 2) {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: '至少需要2个音频才能合成',
          duration: 2000
        })
      } catch (error) {
      }
      return
    }

    if (this.selectedMusicList.length > 5) {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: '最多支持合成5个音频',
          duration: 2000
        })
      } catch (error) {
      }
      return
    }

    // 检查音频总大小是否超过1174M
    const maxSize = 1174 * 1024 * 1024 // 1174M 转换为字节
    let totalSize = 0
    for (const music of this.selectedMusicList) {
      totalSize += this.convertToKB(music.size)
    }
    if (totalSize > maxSize) {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: `音频总大小不能超过1GB`,
          duration: 2000
        })
      } catch (error) {
      }
      return
    }

    if (this.audioSynthesisViewModel.taskStatus) {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: '当前合成任务正在进行中，请勿重复点击。',
          duration: 2000
        })
      } catch (error) {
      }
      return
    }

    this.audioSynthesisViewModel.taskStatus = true

    // 创建或获取 Worker
    if (this.audioSynthesisViewModel.workerId < 0 ||
      !WorkersController.hasWorker(this.audioSynthesisViewModel.workerId)) {
      this.audioSynthesisViewModel.workerId = WorkersController.createWorker(this.audioSynthesisViewModel)
      if (this.audioSynthesisViewModel.workerId < 0) {
        try {
          this.getUIContext().getPromptAction().showToast({
            message: '已有任务在执行，请等待任务结束后再操作!',
            duration: 2000
          })
        } catch (error) {
        }
        this.audioSynthesisViewModel.taskStatus = false
        return
      }
      this.dialogState.progressTitle = '音频合成中...'
      this.dialogState.cancel = () => {
        this.audioSynthesisViewModel.cancekTask()
        this.getUIContext().getPromptAction().showToast({
          message: '音频合成已取消',
          duration: 3000
        })
      }
      this.dialogState.logoFilePath = this.fileUtil.getLogOutPath()
      this.dialogState.fileTime = 0
      this.dialogState.completeValue = 0
      this.progressDialogVM.openDialog(this.dialogState)
    }

    // 获取所有音频文件路径
    this.audioSynthesisViewModel.audioFiles = this.selectedMusicList.map(item => item.sourcePath)

    // 设置输出路径
    this.audioSynthesisViewModel.outPath =
      this.fileUti.getAudioOutDir() + '音频合成-' + this.fileUti.getRandom() + '.' + this.selectedMusicList[0].format

    // 设置日志路径
    this.audioSynthesisViewModel.logPath = this.fileUti.getLogOutPath()

    // 设置完成回调
    this.audioSynthesisViewModel.resultCallBack = (outPath: string) => {
      this.onMergeComplete(outPath)
    }

    // 启动 Worker 任务
    WorkersController.startTask(this.audioSynthesisViewModel.workerId)
  }

  /**
   * 合成完成回调
   */
  private onMergeComplete(outputPath: string) {
    // 关闭进度弹窗
    this.progressDialogVM.closeDialog()

    // 调用外部回调
    this.resultCallBack(outputPath)
  }

  @Builder
  myBuilder() {
    Column() {
      MusicLibraryComponent({
        selectedMusicList:this.selectedMusicList,
        musicListViewController: this.musicListViewController,
        confirmCallback:(res: MusicViewModel[])=>{
          this.selectedMusicList.length = 0;
          res.forEach((item)=>{
            this.selectedMusicList.push(item)
          })
          this.isShow = false
        }
      }).layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }

  build() {
    NavDestination() {
      Column() {
        AudioSynthesisHeader({
          title: '音频合成',
          backHandle: this.backHandle
        }).margin({ top: 8 }).padding({ left: 16, right: 16 })
        Row() {
          Row() {
            Image($r('app.media.music_icon')).width(28)
            Text('点击导入音乐').fontSize(16).margin({ left: 12 }).fontColor('rgba(255, 255, 255, 1)')
          }

          Image($r('app.media.right_icon')).width(20)
        }
        .width('calc(100% - 32vp)')
        .height(56)
        .backgroundColor('rgba(255, 255, 255, 0.1)')
        .borderRadius(16)
        .padding({ left: 16, right: 8 })
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
          this.isShow = true
        })

        MusicListView({
          musicItemOnclick: this.musicItemOnclick,
          musicItemOnChange: this.musicItemOnChange,
          listMode: 'move',
          selectedMusicList: this.selectedMusicList
        })
        Row() {
          Text('合成')
            .width('100%')
            .height(40)
            .borderRadius(20)
            .backgroundColor('#01FCEA')
            .halfLeading(true)
            .textAlign(TextAlign.Center)
            .fontSize(16)
            .fontColor('#000000')
            .enabled(!this.audioSynthesisViewModel.taskStatus)
            .onClick(() => {
              this.audioMerge()
            })
        }.position({ bottom: 28 }).width('100%').padding({ left: 16, right: 16 })
        .justifyContent(FlexAlign.Center)
      }.backgroundColor('#0A0D1E')
      .bindSheet($$this.isShow, this.myBuilder(), {
        height: this.sheetHeight,
        backgroundColor: '#202E3E',
      })
    }
    .hideTitleBar(true)
  }
}