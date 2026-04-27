import { common } from '@kit.AbilityKit';
import { CustomContentDialog } from '@kit.ArkUI';
import { CompressPageVM } from '../viewmodel/CompressPageVM';
import { buildNewFolder, getFolderList, readCompressedFile } from '../utils/CompressUtil';
import { CompressedFile } from '../model/ZipModel';
import { shareData } from '../utils/BaseUtil';
import { EditSetting } from '../components/EditSetting';
import { NoneData } from '../components/NoneData';
import { RenameCustomDialog } from '../components/RenameCustomDialog';
import { BuildCustomDialog } from '../components/BuildCustomDialog';
import { compressedFormat, FileType } from '../common/Constant';
import { TitleBar } from '../components/TitleBar';
import { MoveBuilder } from '../components/MoveBuilder';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { MAX_FREE_USE_TIME } from 'module_base';

@Builder
export function CompressPageBuilder() {
  CompressPage();
}

@ComponentV2
struct CompressPage {
  vm: CompressPageVM = CompressPageVM.instance
  context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext
  dialogController: CustomDialogController = new CustomDialogController({
    builder: RenameCustomDialog({
      fileName: this.vm.fileName,
      cancel: () => {
        this.onCancel()
      },
      confirm: (name: string) => {
        this.onConfirm(name)
      },
    }),
  })
  buildDialogController: CustomDialogController = new CustomDialogController({
    builder: BuildCustomDialog({
      fileName: this.vm.folderName,
      cancel: () => {
        this.onBuildCancel()
      },
      confirm: (name: string) => {
        this.onBuildConfirm(name)
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

  @Computed
  get isCanUse() {
    return this.vm.isMember || (!this.vm.isMember && this.vm.usedCount.count < MAX_FREE_USE_TIME)
  }

  onBuildCancel() {
    this.vm.folderName = ''
    this.buildDialogController.close()
  }

  onBuildConfirm(name: string) {
    this.vm.folderName = name
    const res = buildNewFolder(this.vm.currentFolderPath, this.vm.folderName)
    if (!res) {
      promptAction.showToast({ message: '文件夹已经存在！' })
      return
    }
    this.vm.clearSelected()
    this.vm.fileList = readCompressedFile(this.vm.currentFolderPath)
    promptAction.showToast({ message: '创建成功！' })
    this.buildDialogController.close()
  }

  onCancel() {
    this.dialogController?.close()
  }

  onConfirm(name: string) {
    if (this.vm.checkName(name)) {
      this.vm.fileName = name
      this.dialogController?.close()
    } else {
      promptAction.showToast({ message: '请输入文件名！' })
    }
  }

  onMoveConfirm() {
    let moveToFilePath = ''
    const index = this.vm.directoryStructure.indexOf('/')
    if (index === -1) {
      moveToFilePath = this.vm.originFolderPath
    } else {
      const path = this.vm.directoryStructure.slice(index)
      moveToFilePath = this.vm.originFolderPath + path
    }
    this.vm.selectedFolderPath = moveToFilePath
    this.moveDialogController?.close()
  }

  aboutToAppear(): void {
    this.vm.clear()
    this.vm.init(this.context)
  }

  build() {
    NavDestination() {
      TitleBar({
        name: `${this.vm.titleBarName}文件`,
        isEdit: this.vm.isEdit,
        onEdit: (isClear) => {
          if (isClear) {
            this.vm.needFreshCount = 0
            this.vm.selectedIdList = []
            this.vm.fileList.forEach((data) => {
              data.isSelected = false
            })
          }
          this.vm.isEdit = !this.vm.isEdit
        },
        onSetting: () => {
          this.vm.showSetting = !this.vm.showSetting
        },
      })
      Stack() {
        Column() {
          Column() {
            if (this.vm.fileList.length <= 0 && this.vm.directory.length <= 0) {
              NoneData()
            } else {
              this.ListBuilder()
            }

            this.ButtonBuilder()
          }
          .width('100%')
          .height(this.vm.isEdit ? 'calc(100% - 108vp)' : 'calc(100% - 56vp)')
          .padding({ left: 16, right: 16 })

          if (this.vm.isEdit) {
            EditSetting({
              fileList: this.vm.fileList,
              originFolderPath: this.vm.originFolderPath,
              currentFolderPath: this.vm.currentFolderPath,
              selectedIdList: this.vm.selectedIdList,
              needFreshCount: this.vm.needFreshCount,
              onChange: () => {
                this.vm.needFreshCount = 0
                this.vm.fileList = readCompressedFile(this.vm.currentFolderPath)
                this.vm.selectedIdList = []
              },
              onAllSelect: (isAllSelect) => {
                this.vm.selectedIdList = []
                if (isAllSelect) {
                  this.vm.fileList.forEach((data) => {
                    data.isSelected = true
                    this.vm.selectedIdList.push(data.id)
                  })
                  this.vm.needFreshCount = this.vm.fileList.length
                } else {
                  this.vm.fileList.forEach((data) => {
                    data.isSelected = false
                  })
                  this.vm.needFreshCount = 0
                }
              },
            })
          }
        }

        this.settingBuilder()

        if (this.vm.loading) {
          Column() {
            LoadingProgress()
              .width(72)
              .height(72)
          }
          .width('100%')
          .height('calc(100% - 56vp)')
          .justifyContent(FlexAlign.Center)
        }
      }
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
  }

  @Builder
  ListBuilder() {
    List() {
      if (this.vm.directory.length > 0) {
        ListItem() {
          Row() {
            Image($r('app.media.file'))
              .width(43)
              .height(35)
              .margin({ right: 12 })
            Text('...')
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .onClick(() => {
            this.vm.goPageBack()
          })
        }
        .padding({
          top: 8,
          bottom: 8,
          left: 12,
          right: 12,
        })
        .margin({ bottom: 12 })
        .borderRadius(16)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
      }
      ForEach(this.vm.fileList, (data: CompressedFile, index: number) => {
        ListItem() {
          Row() {
            if (this.vm.isEdit) {
              Checkbox({ name: `checkbox${index}`, group: 'checkboxGroup' })
                .select(data.isSelected)
                .selectedColor($r('sys.color.comp_background_emphasize'))
                .shape(CheckBoxShape.ROUNDED_SQUARE)
                .margin({ right: 14 })
                .onChange((value: boolean) => {
                  const index = this.vm.selectedIdList.findIndex((id) => {
                    return data.id === id
                  })
                  if (value) {
                    data.isSelected = true
                    if (index === -1) {
                      this.vm.selectedIdList.push(data.id)
                      this.vm.needFreshCount += 1
                    }
                  } else {
                    data.isSelected = false
                    this.vm.selectedIdList.splice(index, 1)
                    this.vm.needFreshCount -= 1
                  }
                })
            }

            if (data.type === FileType.FOLDER) {
              Row() {
                Image($r('app.media.file'))
                  .width(43)
                  .height(35)
                  .margin({ right: 12 })

                Column() {
                  Text(data.name)
                    .fontSize($r('sys.float.Body_M'))
                    .fontColor($r('sys.color.font_primary'))
                    .fontWeight(FontWeight.Medium)
                    .margin({ bottom: 2 })

                  Text(`文件个数：${data.count}`)
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor($r('sys.color.font_secondary'))
                    .fontWeight(FontWeight.Regular)

                  Text(`Last edited:${data.updatedTime}`)
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor($r('sys.color.font_secondary'))
                    .fontWeight(FontWeight.Regular)
                }
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .onClick(() => {
                this.vm.toPageDirectory(data.name)
              })
            } else {
              Row() {
                Image(data.type === FileType.ZIP ? $r('app.media.ic_normal_compress') : $r('app.media.ic_file'))
                  .width(36)
                  .height(43)
                  .margin({ right: 12 })

                Column() {
                  Text(data.name)
                    .fontSize($r('sys.float.Body_M'))
                    .fontColor($r('sys.color.font_primary'))
                    .fontWeight(FontWeight.Medium)
                    .margin({ bottom: 2 })

                  Text(`大小：${data.size}`)
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor($r('sys.color.font_secondary'))
                    .fontWeight(FontWeight.Regular)
                }
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .onClick(() => {
                if (data.type === FileType.ZIP) {
                  return
                }
                this.vm.preview(this.context, data)
              })
            }
          }
          .width('100%')
        }
        .padding({
          top: 8,
          bottom: 8,
          left: 12,
          right: 12,
        })
        .margin({ bottom: 12 })
        .borderRadius(16)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
      }, (data: CompressedFile) => JSON.stringify(data))
    }
    .width('100%')
    .height('calc(100% - 56vp)')
    .scrollBar(BarState.Off)
  }

  @Builder
  ButtonBuilder() {
    if (!this.vm.isEdit) {
      Button({ type: ButtonType.Normal, stateEffect: true }) {
        Row() {
          SymbolGlyph($r('sys.symbol.decompress'))
            .fontSize(24)
            .fontColor([Color.White])
            .margin({ right: 8 })

          Text(`前往${this.vm.titleBarName}`)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Medium)
        }
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height(40)
      .backgroundColor(this.vm.titleBarName === '压缩' ? $r('sys.color.background_emphasize') :
        $r('sys.color.multi_color_03'))
      .borderRadius($r('sys.float.corner_radius_level10'))
      .margin({ bottom: 16 })
      .onClick(() => {
        if (this.isCanUse) {
          this.vm.pickerSelect()
        } else {
          this.getUIContext().getPromptAction().showToast({ message: '购买会员方可享受无限使用次数' })
        }
      })
      .bindSheet($$this.vm.isShow, this.configureBuilder(), {
        height: this.vm.titleBarName === '压缩' ? 400 : 240,
        preferType: SheetType.BOTTOM,
        backgroundColor: $r('sys.color.background_secondary'),
        title: { title: '设置' },
        shouldDismiss: (sheetDismiss: SheetDismiss) => {
          this.vm.selectedFolderPath = ''
          sheetDismiss.dismiss()
        },
      })
    }
  }

  @Builder
  configureBuilder() {
    Column() {
      if (this.vm.titleBarName === '压缩') {
        this.labelBuilder('压缩格式')

        Row({ space: 6 }) {
          ForEach(compressedFormat, (data: string) => {
            Row() {
              Text(data)
                .fontSize($r('sys.float.Body_M'))
                .fontColor(this.vm.selectedCompressedFormat === data ? $r('sys.color.font_on_primary') :
                  $r('sys.color.font_primary'))
                .fontWeight(FontWeight.Regular)
            }
            .width(76)
            .height(28)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.vm.selectedCompressedFormat === data ? $r('sys.color.comp_background_emphasize') :
              $r('sys.color.comp_background_tertiary'))
            .borderRadius(14)
            .onClick(() => {
              this.vm.selectedCompressedFormat = data
            })
          })
        }
        .width('100%')
        .margin({ top: 16, bottom: 12 })

        this.labelBuilder('压缩文件名')
        Row() {
          Text(this.vm.fileName)
            .fontSize($r('sys.float.Subtitle_M'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .height(40)
        .padding({ left: 16, right: 16 })
        .margin({ top: 8, bottom: 20 })
        .borderRadius(20)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.dialogController?.open()
        })
      }

      this.labelBuilder('自定义压缩目录')
      Row() {
        Text(this.vm.selectedFolderPath)
          .fontSize($r('sys.float.Subtitle_M'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .height(40)
      .padding({ left: 16, right: 16 })
      .margin({ top: 8, bottom: 20 })
      .borderRadius(20)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        this.vm.moveDialogPath = this.vm.originFolderPath
        this.vm.directoryStructure = '...'
        this.vm.moveDirectory = []
        this.vm.folderList = getFolderList(this.vm.originFolderPath)
        this.moveDialogController?.open()
      })

      Row() {
        Button('重置')
          .width(160)
          .height(40)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .fontColor($r('sys.color.font_primary'))
          .onClick(() => {
            this.vm.selectedFolderPath = ''
            this.vm.isShow = false
          })

        Button('完成')
          .width(160)
          .height(40)
          .onClick(() => {
            this.vm.isShow = false
            this.vm.loading = true
            if (this.vm.titleBarName === '压缩') {
              this.vm.compressFile()
            } else {
              this.vm.decompressFile()
            }
            this.vm.selectedFolderPath = ''
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16 })
  }

  @Builder
  labelBuilder(label: string) {
    Row() {
      Text(label)
        .fontSize($r('sys.float.Subtitle_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
  }

  @Builder
  settingBuilder() {
    if (this.vm.showSetting) {
      Column() {
        Column() {
          Row({ space: 9 }) {
            SymbolGlyph($r('sys.symbol.share'))
              .fontSize(20)

            Text('分享')
              .fontSize($r('sys.float.Subtitle_M'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
          }
          .width(192)
          .height(48)
          .onClick(() => {
            this.vm.showSetting = false
            if (this.vm.selectedIdList.length === 0) {
              promptAction.showToast({ message: '请选择需要分享的内容！' })
              return
            }
            if (this.vm.selectedIdList.length > 1) {
              promptAction.showToast({ message: '仅支持分享单个文件！' })
              return
            }
            const name = this.vm.fileList.find((compressedFile) => {
              return compressedFile.id === this.vm.selectedIdList[0]
            })!.name
            const path = `${this.vm.currentFolderPath}/${name}`
            shareData(this.context, path)
          })

          Divider().width(160).margin({ left: 32 })

          Row({ space: 9 }) {
            SymbolGlyph($r('sys.symbol.folder_badge_plus'))
              .fontSize(20)

            Text('新建文件夹')
              .fontSize($r('sys.float.Subtitle_M'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
              .onClick(() => {
                this.vm.folderName = ''
                this.buildDialogController?.open()
                this.vm.showSetting = false
              })
          }
          .width(192)
          .height(48)
        }
        .backgroundColor(Color.White)
        .borderRadius(20)
        .padding({
          top: 4,
          bottom: 4,
          left: 16,
          right: 16,
        })
        .position({ top: 0, right: 16 })
        .shadow({ radius: 2, type: ShadowType.BLUR })
      }
      .width('100%')
      .height('calc(100% - 56vp)')
      .onClick(() => {
        this.vm.showSetting = false
      })
    }
  }

  @Builder
  moveContentBuilder() {
    MoveBuilder({
      folderList: this.vm.folderList,
      directory: this.vm.moveDirectory,
      directoryStructure: this.vm.directoryStructure,
      onCancel: () => {
        this.vm.directory = []
        this.vm.directoryStructure = '...'
        this.vm.folderList = []
        this.moveDialogController.close()
      },
      onConfirm: () => {
        this.onMoveConfirm()
      },
      toDirectory: (name) => {
        this.vm.toDirectory(name)
      },
      goBack: () => {
        this.vm.goBack()
      },
    })
  }
}