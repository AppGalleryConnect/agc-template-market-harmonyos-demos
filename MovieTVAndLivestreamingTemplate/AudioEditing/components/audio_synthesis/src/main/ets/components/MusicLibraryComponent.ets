import { MusicListView, MusicListViewController } from 'common_view';
import { common } from '@kit.AbilityKit';
import { FileUtil, MusicViewModel, ProgressDialogVM } from 'audio_common';

const maxFileSize = 1174 * 1024 * 1024 // 1174MB 转换为字节

@ComponentV2
export struct MusicLibraryComponent {
  clickStatus: boolean = false
  @Param isSearchPage?: boolean = false
  @Param selectedMusicList: MusicViewModel[] = [] //选中的音频列表，用于合成功能
  @Local selectedMusicListTemp: MusicViewModel[] = [] //选中的音频列表，用于合成功能
  @Param musicListViewController: MusicListViewController = new MusicListViewController()
  @Local activeIndex: number = 0
  @Event confirmCallback: (res: MusicViewModel[]) => void = (res: MusicViewModel[]) => {
  }
  context = this.getUIContext().getHostContext() as common.UIAbilityContext
  fileUtil = new FileUtil(this.context as common.UIAbilityContext)
  maxSelectCount: number = 5 //最多选择5个
  //列表单击事件
  musicItemOnclick = (item: MusicViewModel) => {
  }
  //列表多选事件
  musicItemOnChange = (item: MusicViewModel, checkBoxStatus: boolean) => {
    if (checkBoxStatus) {
      // 选中：检查是否超过最大数量
      if (this.selectedMusicListTemp.length >= this.maxSelectCount) {
        // 超过最大数量，取消选中并提示
        item.setCheckBoxStatus(false)
        this.getUIContext().getPromptAction().showToast({
          message: `最多只能选择${this.maxSelectCount}个音频`,
          duration: 2000
        })
        return
      }
      // 添加到选中列表
      if (!this.selectedMusicListTemp.some(music => music.sourcePath === item.sourcePath)) {
        this.selectedMusicListTemp.push(item)
      }
    } else {
      // 取消选中：从列表中移除
      this.selectedMusicListTemp = this.selectedMusicListTemp.filter(music => music.sourcePath !== item.sourcePath)
    }
  }
  progressDialogVM: ProgressDialogVM = new ProgressDialogVM(this.getUIContext());

  parseSizeToNumber(formattedSize: string): number {
    if (!formattedSize) {
      return 0;
    }

    let value = 0;
    if (formattedSize.indexOf('KB') !== -1) {
      value = value * 1024;
    } else if (formattedSize.indexOf('MB') !== -1) {
      value = value * 1024 * 1024;
    }
    return value
  }

  aboutToAppear(): void {
    this.selectedMusicListTemp = [...this.selectedMusicList];
  }

  build() {
    Column() {
      MusicListView({
        musicItemOnclick: this.musicItemOnclick,
        musicItemOnChange: this.musicItemOnChange,
        musicListViewController: this.musicListViewController,
        listMode: 'checkBox',
        selectedMusicList: this.selectedMusicListTemp,
        activeIndexChange: (index: number) => {
          this.activeIndex = index
        }
      }).padding({ bottom: 78 })


      Row() {

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
            if (this.selectedMusicListTemp.length < 2) {
              this.getUIContext().getPromptAction().showToast({
                message: '请至少选择2个音频',
                duration: 2000
              })
              return
            }

            // 检查所有选中音频的格式是否一致
            const formats = this.selectedMusicListTemp.map(item => item.format)
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
            for (let index = 0; index < this.selectedMusicListTemp.length; index++) {
              const uri = this.selectedMusicListTemp[index];
              totalSize += this.parseSizeToNumber(uri.size)
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
            this.confirmCallback(this.selectedMusicListTemp)
          })
      }.position({ bottom: 28 }).width('100%').padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Center)
    }.height('100%')
  }
}