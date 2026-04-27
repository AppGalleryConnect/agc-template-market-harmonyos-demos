import { LISTMODE, MusicListView, MusicListViewController, MusicParam, MusicViewModel } from 'common_view';
import { audio } from '@kit.AudioKit';
import { phoneRouterControl } from 'oh_router';
import { RouterMap } from 'common';
import { AudioAdjustPageBuilder } from '../view/AudioAdjustPage';
import { AudioEditPageBuilder } from '../view/AudioEditPage';
import { AudioSynthesisPageBuilder } from '../view/AudioSynthesisPage';
import { AudioUtil } from 'audio_common/src/main/ets/util/AudioUtil';
import { common } from '@kit.AbilityKit';
import { FileUtil, ProgressDialogVM } from 'audio_common';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { media } from '@kit.MediaKit';
import { getFormatSize, parseSizeToNumber } from '../util/CommonUtil';
import { AudioFormatConversionPageBuilder } from '../view/AudioFormatConversionPage';
import { MusicLibraryViewModel } from '../viewmodel/MusicLibraryViewModel';
import { WorkersController } from 'audio_worker';
import { changeToPcm } from '../model/AudioStreamInfoModel';

const TAG = 'MusicLibraryComponent'
const maxFileSize = 1174 * 1024 * 1024 // 1174MB 转换为字节
const maxDuration = 65 * 60 * 1000 // 65分钟转换为毫秒
const minDuration = 10 * 1000 //10秒

@ComponentV2
export struct MusicLibraryComponent {
  clickStatus: boolean = false
  @Param pageType: string = ''
  @Param listMode: LISTMODE = 'click' //列表操作模式，默认单选模式
  @Param musicListViewController: MusicListViewController = new MusicListViewController()
  @Param isSearchPage?: boolean = false
  @Event changeSelected: (res: MusicViewModel[]) => void = (res: MusicViewModel[]) => {
  }
  @Local selectedMusicList: MusicViewModel[] = [] //选中的音频列表，用于合成功能
  @Local activeIndex: number = 0
  context = this.getUIContext().getHostContext() as common.UIAbilityContext
  fileUtil = new FileUtil(this.context as common.UIAbilityContext)
  maxSelectCount: number = 5 //最多选择5个
  vm: MusicLibraryViewModel = new MusicLibraryViewModel()
  //列表单击事件
  musicItemOnclick = (item: MusicViewModel) => {
    // 检查文件大小是否超过限制
    if (parseSizeToNumber(item.size) > maxFileSize) {
      this.getUIContext().getPromptAction().showToast({
        message: `音频文件不能超过1GB`,
        duration: 3000
      })
      return
    }
    if (item.duration > maxDuration || minDuration > item.duration) {

      // 删除已复制的文件
      this.getUIContext().getPromptAction().showToast({
        message: `音频时长不能低于10秒或超过1小时`,
        duration: 3000
      })
      return
    }
    if (this.clickStatus) {
      this.getUIContext().getPromptAction().showToast({
        message: '已有任务在执行，请等待任务结束后在操作!'
      })
      return
    }
    this.clickStatus = true;
    const param = {
      'targetFilePath': item.sourcePath,
      'label': item.title,
      'fileName': item.title,
      'item': item,
      'sourcePath': item.sourcePath,
      'channelLayout': 2,
      'sampleRate': 2,
      'duration': item.duration,
      'title': item.title + '.' + item.format,
      'pageType': this.pageType,
      'format': item.format,
      'sampleFormat': audio.AudioSampleFormat.SAMPLE_FORMAT_F32LE //固定采样格式，跟pcm转码命令对应


    } as Record<string, string | number | MusicViewModel>
    switch (this.pageType) {
      case 'audioAdjustSpeed':
        this.jumpSpeedPage(item)
        break;
      case 'audioAdjustTone':
        this.jumpSpeedPage(item)
        break;
      case 'audioNoiseReduction':
        this.jumpPage(RouterMap.AUDIO_ADJUST_PAGE, wrapBuilder(AudioAdjustPageBuilder), param)
        break;
      case 'audioConversion':
        this.jumpFormatPage(item)
        break;
      default:
        this.jumpEditPage(item)
    }
  }

  jumpPage(pageName: string, builder: WrappedBuilder<[Object]>,
    param?: Record<string, string | number | MusicViewModel | MusicViewModel[]>) {
    this.clickStatus = false;
    phoneRouterControl.jumpPage({
      pageName,
      builder,
      param,
      onPop: (popInfo: PopInfo) => {
        let result = popInfo.result as MusicViewModel[]
        if (pageName === 'AudioSynthesisPage' && result) {
          this.selectedMusicList = [...result];
          this.musicListViewController.filterSelect()
        }
        phoneRouterControl.popLastPage()
      }
    })
  }

  jumpSpeedPage(item: MusicViewModel) {
    let excuteFunc = (item: MusicViewModel) => {
      let callBack = (pcmPath: string, channelLayout: number, sampleRate: number) => {
        this.clickStatus = false;
        this.vm.onComplete()
        if (this.vm.isCancel) { //点击取消不跳转页面
          this.vm.isCancel = false
          return
        }
        phoneRouterControl.jumpPage({
          pageName: RouterMap.AUDIO_ADJUST_SPEED_PAGE,
          builder: wrapBuilder(AudioAdjustPageBuilder),
          onPop: () => {
            phoneRouterControl.popLastPage()
          },
          param: {
            'path': pcmPath,
            'sourcePath': item.sourcePath,
            'channelLayout': channelLayout,
            'sampleRate': sampleRate,
            'duration': item.duration,
            'title': item.title + '.' + item.format,
            'pageType': this.pageType,
            'format': item.format,
            'label': item.title,
            'sampleFormat': audio.AudioSampleFormat.SAMPLE_FORMAT_F32LE //固定采样格式，跟pcm转码命令对应

          } as Record<string, string | number>
        })
      }

      let errorBack = () => {
        this.clickStatus = false
        this.vm.release()
        this.vm.progressDialogVM?.closeDialog()
      }
      changeToPcm(getContext(this), item.sourcePath, callBack, errorBack)
    }
    this.workerMethod(excuteFunc, item)
  }

  jumpEditPage(item: MusicViewModel) {
    let excuteFunc = (item: MusicViewModel) => {
      let callBack = (pcmPath: string, channelLayout: number, sampleRate: number) => {
        this.clickStatus = false
        this.vm.onComplete() //直接调用完成方法
        if (this.vm.isCancel) {
          this.vm.isCancel = false
          return
        }
        phoneRouterControl.jumpPage({
          pageName: RouterMap.AUDIO_EDIT_PAGE,
          builder: wrapBuilder(AudioEditPageBuilder),
          onPop: () => {
            phoneRouterControl.popLastPage()
          },
          param: {
            'path': pcmPath,
            'sourcePath': item.sourcePath,
            'channelLayout': channelLayout,
            'sampleRate': sampleRate,
            'duration': item.duration,
            'title': item.title + '.' + item.format,
            'sampleFormat': audio.AudioSampleFormat.SAMPLE_FORMAT_F32LE //固定采样格式，跟pcm转码命令对应
          } as Record<string, string | number>
        })
      }
      let errorBack = () => {
        this.clickStatus = false
        this.vm.release()
        this.vm.progressDialogVM?.closeDialog()
        this.getUIContext().getPromptAction().showToast({
          message: '文件加载失败，请检查文件。'
        })
      }
      changeToPcm(getContext(this), item.sourcePath, callBack, errorBack)
    }
    this.workerMethod(excuteFunc, item)
  }

  jumpFormatPage(item: MusicViewModel) {
    this.clickStatus = false;
    if (this.vm.isCancel) { //点击取消不跳转页面
      this.vm.isCancel = false
      return
    }
    phoneRouterControl.jumpPage({
      pageName: RouterMap.AUDIO_FORMAT_CONVERSION_PAGE,
      builder: wrapBuilder(AudioFormatConversionPageBuilder),
      onPop: () => {
        phoneRouterControl.popLastPage()
      },
      param: {
        'sourcePath': item.sourcePath,
        'duration': item.duration,
        'title': item.title,
        'format': item.format,
        'size': item.size

      } as Record<string, string | number>
    })
  }

  workerMethod(excuteFunc: ((item: MusicViewModel) => void) | undefined, item: MusicViewModel) {
    this.vm.musicVM = item
    this.vm.excuteFunc = excuteFunc

    if (this.vm.taskStatus) {
      this.getUIContext().getPromptAction().showToast({
        message: '当前加载任务正在进行中，请勿重复点击。'
      })
      return
    }
    this.vm.taskStatus = true


    this.vm.workerId = WorkersController.createWorker(this.vm)
    if (this.vm.workerId < 0) {
      this.getUIContext().getPromptAction().showToast({
        message: '已有任务在执行，请等待任务结束后在操作!'
      })
      this.vm.taskStatus = false //重置状态
      this.clickStatus = false;
      return
    }


    WorkersController.startTask(this.vm.workerId)
    this.vm.openProgressDialog()
  }

  //列表多选事件
  musicItemOnChange = (item: MusicViewModel, checkBoxStatus: boolean) => {
    if (checkBoxStatus) {
      // 选中：检查是否超过最大数量
      if (this.selectedMusicList.length >= this.maxSelectCount) {
        // 超过最大数量，取消选中并提示
        item.setCheckBoxStatus(false)
        this.getUIContext().getPromptAction().showToast({
          message: `最多只能选择${this.maxSelectCount}个音频`,
          duration: 2000
        })
        return
      }
      // 添加到选中列表
      if (!this.selectedMusicList.some(music => music.sourcePath === item.sourcePath)) {
        this.selectedMusicList.push(item)
      }
    } else {
      // 取消选中：从列表中移除
      this.selectedMusicList = this.selectedMusicList.filter(music => music.sourcePath !== item.sourcePath)
    }
    this.changeSelected(this.selectedMusicList)
  }
  selectAudio = async (audioSelectResult: Array<string>) => {
    const musicDir = this.fileUtil.getAudioCacheDir()
    const allowedFormats = ['mp3', 'aac', 'm4a', 'wav'] // 允许的音频格式


    for (let index = 0; index < audioSelectResult.length; index++) {

      const uri = audioSelectResult[index];
      const format = this.fileUtil.splitFilePath(uri)[2]
      let fileName = decodeURIComponent(this.fileUtil.splitFilePath(uri)[1]).replace(/\s+/g, '')
      let fileUriObject = new fileUri.FileUri(uri);
      // 直接获取沙箱路径
      let sandboxPath = fileUriObject.path;
      const fileInfo = await fileIo.stat(fileUriObject.path)
      // 检查格式是否在允许的列表中
      if (!allowedFormats.includes(format.toLowerCase())) {
        this.getUIContext().getPromptAction().showToast({
          message: `请导入mp3/aac/m4a/wav格式的音频`,
          duration: 3000
        })
        return
      }

      // 检查文件大小是否超过限制
      if (fileInfo.size > maxFileSize) {
        this.getUIContext().getPromptAction().showToast({
          message: `音频文件不能超过1GB`,
          duration: 3000
        })
        return
      }

      const path = musicDir + fileName + '.' + format
      const fd = fileIo.openSync(uri).fd
      try {
        // 创建AVMetadataExtractor对象。
        let avMetadataExtractor: media.AVMetadataExtractor = await media.createAVMetadataExtractor();
        // // 获取rawfile目录下资源文件描述符，设置fdSrc属性。
        avMetadataExtractor.fdSrc = { fd: fd }
        const avMetaData = await avMetadataExtractor.fetchMetadata()
        let title = fileName
        let duration = Number(avMetaData.duration)

        // 检查音频时长是否超过限制
        if (duration > maxDuration || minDuration > duration) {
          fileIo.closeSync(fd)
          // 删除已复制的文件
          this.getUIContext().getPromptAction().showToast({
            message: `音频时长不能低于10秒或超过1小时`,
            duration: 3000
          })
          return
        }

        await FileUtil.copyFileToDestPath(uri, path)
        let size = getFormatSize(fileInfo.size)
        const musicParam: MusicParam = {
          uri: uri,
          title: title,
          duration: duration,
          size: size,
          format: format,
          path: path
        }
        this.musicListViewController.addData(musicParam, 'music')
      } catch (e) {
        fileIo.closeSync(fd)
      } finally {
        fileIo.closeSync(fd)
      }

    }
  }
  progressDialogVM: ProgressDialogVM = new ProgressDialogVM(this.getUIContext());

  aboutToAppear(): void {
    this.vm.progressDialogVM = this.progressDialogVM
  }

  build() {
    Column() {
      MusicListView({
        musicItemOnclick: this.musicItemOnclick,
        musicItemOnChange: this.musicItemOnChange,
        selectedMusicList: this.selectedMusicList,
        musicListViewController: this.musicListViewController,
        listMode: this.listMode,
        isSearchPage: this.isSearchPage,
        activeIndexChange: (index: number) => {
          this.activeIndex = index
        }
      }).padding({ bottom: 78 })


      Row() {
        if (this.activeIndex === 0 && !this.isSearchPage) {
          Text('导入')
            .layoutWeight(1)
            .height(40)
            .borderRadius(20)
            .backgroundColor(this.listMode === 'click' ? '#01FCEA' : Color.Transparent)
            .border({ width: 1, color: '#01FCEA' })
            .halfLeading(true)
            .textAlign(TextAlign.Center)
            .fontSize(16)
            .fontColor(this.listMode === 'click' ? '#000000' : '#01FCEA')
            .onClick(() => {
              AudioUtil.select(this.context, this.selectAudio)
            })
        }

        if (this.listMode !== 'click') {
          Divider().width(16).height(1)
          Text('确认')
            .layoutWeight(1)
            .height(40)
            .borderRadius(20)
            .backgroundColor('#01FCEA')
            .border({ width: 1, color: '#01FCEA' })
            .halfLeading(true)
            .textAlign(TextAlign.Center)
            .fontSize(16)
            .fontColor('#000000')
            .onClick(() => {
              if (this.selectedMusicList.length < 2) {
                this.getUIContext().getPromptAction().showToast({
                  message: '请至少选择2个音频',
                  duration: 2000
                })
                return
              }

              // 检查所有选中音频的格式是否一致
              const formats = this.selectedMusicList.map(item => item.format)
              const firstFormat = formats[0]
              const allSameFormat = formats.every(format => format === firstFormat)

              if (!allSameFormat) {
                this.getUIContext().getPromptAction().showToast({
                  message: '请选择相同格式',
                  duration: 2000
                })
                return
              }
              let totalSize = 0
              let totalDuration = 0
              for (let index = 0; index < this.selectedMusicList.length; index++) {

                const uri = this.selectedMusicList[index];
                totalSize += parseSizeToNumber(uri.size)
                totalDuration += uri.duration
              }


              // 检查文件大小是否超过限制
              if (totalSize > maxFileSize) {
                this.getUIContext().getPromptAction().showToast({
                  message: `音频文件不能超过1GB`,
                  duration: 3000
                })
                return
              }
              // 跳转到合成页面，传递选中的音频列表
              this.jumpPage(RouterMap.AUDIO_SYNTHESIS_PAGE, wrapBuilder(AudioSynthesisPageBuilder), {
                'selectedMusicList': this.selectedMusicList
              } as Record<string, MusicViewModel[]>)
            })
        }
      }.position({ bottom: 28 }).width('100%').padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Center)
    }.height('100%')

  }
}