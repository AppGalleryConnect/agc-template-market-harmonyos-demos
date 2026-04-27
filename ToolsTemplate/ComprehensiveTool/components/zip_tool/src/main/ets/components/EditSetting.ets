import { CustomContentDialog } from '@kit.ArkUI'
import { FileType, WorkerMessageType } from '../common/Constant'
import { CompressedFile, WorkerMessage, WorkerSend } from '../model/ZipModel'
import { deleteZipDocument, getFolderList, getStoragePath, moveFile, rename, reSave } from '../utils/CompressUtil'
import { MoveBuilder } from './MoveBuilder'
import { RenameCustomDialog } from './RenameCustomDialog'
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { CompressPageVM } from '../viewmodel/CompressPageVM'

@ComponentV2
export struct EditSetting {
  vm: CompressPageVM = CompressPageVM.instance
  @Param fileList: CompressedFile[] = []
  @Param selectedIdList: string[] = []
  @Param originFolderPath: string = ''
  @Param currentFolderPath: string = ''
  @Param needFreshCount: number = 0
  @Local isSelectedFile: boolean = false
  @Local isSingleSelected: boolean = true
  @Local isAllSelect: boolean = false
  @Local labelWidth: string = '20%'
  @Local fileName: string = ''
  @Local folderList: CompressedFile[] = []
  @Local directory: string[] = []
  @Local moveDialogPath: string = ''
  @Local directoryStructure: string = '...'
  @Event onChange: () => void = () => {
  }
  @Event onAllSelect: (isAllSelect: boolean) => void = () => {
  }

  @Monitor('needFreshCount')
  onFileChange() {
    this.init()
  }

  deleteDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.deleteContentBuilder();
      },
    }),
  })
  renameDialogController: CustomDialogController = new CustomDialogController({
    builder: RenameCustomDialog({
      fileName: this.fileName,
      cancel: () => {
        this.onRenameCancel();
      },
      confirm: (name: string) => {
        this.onRenameConfirm(name);
      },
    }),
  })
  moveDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.moveContentBuilder();
      },
    }),
  })

  toDirectory(name: string) {
    this.directoryStructure += `/${name}`
    this.directory.push(name)
    this.moveDialogPath = `${this.moveDialogPath}/${name}`
    this.folderList = getFolderList(this.moveDialogPath)
  }

  goBack() {
    const directoryIndex = this.directoryStructure.lastIndexOf('/')
    if (directoryIndex !== -1) {
      this.directoryStructure = this.directoryStructure.slice(0, directoryIndex)
    }
    const index = this.moveDialogPath.lastIndexOf('/')
    if (index !== -1) {
      this.moveDialogPath = this.moveDialogPath.slice(0, index)
      this.folderList = getFolderList(this.moveDialogPath)
      this.directory.pop()
    }
  }

  onRenameCancel() {
    this.renameDialogController.close()
  }

  onRenameConfirm(name: string) {
    const compressedFile = this.fileList.find((compressedFile) => {
      return compressedFile.id === this.selectedIdList[0]
    })
    if (!compressedFile) {
      return
    }
    let newName = name + compressedFile.format
    rename(this.currentFolderPath, newName, compressedFile.name)
    this.renameDialogController.close()
    this.onChange()
  }

  onMoveConfirm() {
    let moveToFilePath = ''
    const index = this.directoryStructure.indexOf('/')
    if (index === -1) {
      moveToFilePath = this.originFolderPath
    } else {
      const path = this.directoryStructure.slice(index)
      moveToFilePath = this.originFolderPath + path
    }
    this.fileList.forEach((data) => {
      this.selectedIdList.forEach((id) => {
        if (data.id === id) {
          const filePath = `${this.currentFolderPath}/${data.name}`
          moveFile(data.type, data.name, filePath, moveToFilePath)
        }
      })
    })
    this.directory = []
    this.directoryStructure = '...'
    this.folderList = []
    this.moveDialogController?.close()
    this.onChange()
  }

  aboutToAppear(): void {
    this.init()
  }

  init() {
    const count = this.selectedIdList.length
    if (count === this.fileList.length && count !== 0) {
      this.isAllSelect = true
    } else {
      this.isAllSelect = false
    }
    if (count > 0) {
      this.isSelectedFile = true
      if (count === 1) {
        this.isSingleSelected = true
        this.labelWidth = '20%'
      } else {
        this.isSingleSelected = false
        this.labelWidth = '25%'
      }
    } else {
      this.isSelectedFile = false
      this.labelWidth = '20%'
    }
  }

  build() {
    Row() {
      if (this.isSingleSelected || !this.isSelectedFile) {
        this.labelBuilder($r('sys.symbol.selector'), '重命名', () => {
          if (this.isSelectedFile && this.isSingleSelected) {
            const selectedFile = this.fileList.find((compressedFile) => {
              return compressedFile.id === this.selectedIdList[0]
            })
            if (!selectedFile) {
              return
            }
            this.fileName = selectedFile.label
            this.renameDialogController.open()
          } else {
            promptAction.showToast({ message: '请勾选文件！' })
          }
        })
      }
      this.labelBuilder($r('sys.symbol.arrow_right_folder_circle'), '移动到', () => {
        if (this.isSelectedFile) {
          this.moveDialogPath = this.originFolderPath
          this.folderList = getFolderList(this.originFolderPath)
          this.moveDialogController?.open()
        } else {
          promptAction.showToast({ message: '请勾选文件！' })
        }
      })
      this.labelBuilder($r('sys.symbol.save'), '另存为', async () => {
        if (!this.isSelectedFile) {
          promptAction.showToast({ message: '请勾选文件！' })
          return
        }
        if (!this.isSingleSelected) {
          promptAction.showToast({ message: '一次只能保存一个文件！' })
          return
        }
        const file = this.fileList.find((compressedFile) => {
          return compressedFile.id === this.selectedIdList[0]
        })
        if (file) {
          if (file.type === FileType.FOLDER) {
            promptAction.showToast({ message: '文件夹不支持保存！' })
            return
          }
          const path = `${this.currentFolderPath}/${file.name}`
          const uris = await getStoragePath(file.name)
          const workerSend: WorkerSend = {
            filePath: path,
            uris,
          };
          this.vm.zipWorker.postMessage({
            type: WorkerMessageType.SAVE,
            data: JSON.stringify(workerSend),
          } as WorkerMessage);
        }
      })
      if (this.isAllSelect) {
        this.labelBuilder($r('sys.symbol.xmark_circle'), '取消全选', () => {
          this.onAllSelect(false)
        })
      } else {
        this.labelBuilder($r('sys.symbol.checkmark_circle'), '全选', () => {
          this.onAllSelect(true)
        })
      }
      this.labelBuilder($r('sys.symbol.trash'), '删除', () => {
        if (this.isSelectedFile) {
          this.deleteDialogController.open()
        } else {
          promptAction.showToast({ message: '请勾选文件！' })
        }
      })
    }
    .height(80)
    .padding({ bottom: 28 })
    .backgroundColor($r('sys.color.background_primary'))
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  labelBuilder(icon: Resource, label: string, func: Function) {
    Column({ space: 4 }) {
      SymbolGlyph(icon)
        .fontSize(24)

      Text(label)
        .fontSize($r('sys.float.Caption_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Regular)
    }
    .width(this.labelWidth)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      func()
    })
  }

  @Builder
  deleteContentBuilder(): void {
    Column() {
      Row() {
        Text('删除后将无法恢复，是否删除')
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Regular)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Row() {
        Row() {
          Text('取消')
        }
        .width('50%')
        .height(40)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.deleteDialogController.close()
        })

        Row() {
          Button('确认')
            .width('100%')
            .height(40)
            .backgroundColor('#E4480C')
        }
        .width('50%')
        .height(40)
        .onClick(() => {
          deleteZipDocument(this.currentFolderPath, this.fileList, this.selectedIdList)
          this.deleteDialogController.close()
          this.onChange()
        })
      }
      .margin({ top: 28 })
    }
    .width('100%')
  }

  @Builder
  moveContentBuilder() {
    MoveBuilder({
      folderList: this.folderList,
      directory: this.directory,
      directoryStructure: this.directoryStructure,
      onCancel: () => {
        this.directory = []
        this.directoryStructure = '...'
        this.folderList = []
        this.moveDialogController.close()
      },
      onConfirm: () => {
        this.onMoveConfirm()
      },
      toDirectory: (name) => {
        this.toDirectory(name)
      },
      goBack: () => {
        this.goBack()
      },
    })
  }
}
