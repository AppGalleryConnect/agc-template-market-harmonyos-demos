import { BarVM, EmitterUtil, GlobalContext, MockService, PermissionUtil, RouterMap, TCLogger } from 'common';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { BackupSetUpPageBuilder } from '../../../../Index';
import { BackupStatus, BackupVM } from '../viewModel/BackupVM';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { BackStatus } from 'clouddisk_backup_status';
import deviceInfo from '@ohos.deviceInfo';
import { common, Permissions } from '@kit.AbilityKit';
import { PersistenceV2, promptAction } from '@kit.ArkUI';

interface FileMockInfo {
  fileId: number,
  parentFileId: number,
  fileName: string,
  fileType: number,
  fileSize?: string,
  createTime: string,
  updateTime?: string,
  path?: string,
  downloadUrl?: string,
  duration?: string,
  childFiles?: FileMockInfo[],
  thumbnailUrl?: string
}

/**
 * @usage: 用于展示云盘备份功能的主页面。包含备份状态显示（BackupStatus枚举：Start、Complete）、备份开关控制、备份进度展示等核心功能。
 * 关键数据结构包括BackupVM视图模型，包含turnActivation（备份开关状态）、backupStatus（备份状态）等属性。
 * 页面根据turnActivation状态显示不同UI：未开启时显示"一键开启"按钮，开启后根据backupStatus显示"备份中"或"备份已完成"状态。
 * @layout: 页面采用垂直布局（Column），顶部是标题栏（Row），包含"备份"标题（左对齐）和设置图标（右对齐）。
 * 下方根据备份状态条件渲染不同内容：未开启备份时显示提示行（Row，左对齐图标和文字，右对齐开启按钮）；
 * 已开启时显示备份状态卡片（Row，左侧备份信息Column垂直排列，右侧"查看相册"按钮右对齐）。
 * @constraints: BackupVM中的turnActivation和backupStatus状态不允许直接修改，需通过beginProgress()方法控制备份流程；
 * 备份状态卡片的背景色和圆角样式不可修改。
 * @isGen: true
 * @fileType: page
 * @domain: 云存储,
 * @zhName: 云存储备份页面
 * @component: OHPage,BackStatus
 * @image: screenshot/backup.jpg
 */
@ComponentV2
export struct Backup {
  logTag: string = 'Backup';
  @Param pageConfig?: OHPageConfig = undefined
  @Local backupVM: BackupVM = PersistenceV2.connect(BackupVM, () => new BackupVM())!;
  @Consumer('currentIndexTab') currentIndexTab: number = 0;
  @Consumer('tabController') tabsController: TabsController = new TabsController();

  aboutToAppear(): void {
    EmitterUtil.on('backToBackup', (eventData: emitter.EventData) => {
      this.backupVM.turnActivation = eventData.data?.isAutoBackup as boolean
    })
  }

  aboutToDisappear(): void {
    EmitterUtil.off('backToBackup', (eventData: emitter.EventData) => {
    })
  }

  backUpDocument() {
    let marketName = deviceInfo.marketName;
    let mockInfoBackup: FileMockInfo = {
      fileId: 10007,
      fileName: marketName,
      fileType: 6,
      fileSize: '3.3MB',
      createTime: '2024-06-20 10:20:18',
      updateTime: this.backupVM.backupDateTime,
      path: `/我的文件/${marketName}`,
      parentFileId: 0,
      childFiles: [
        {
          fileId: 10051,
          fileName: 'screenshot_20251027_151657.jpg',
          fileType: 1,
          fileSize: '405KB',
          createTime: '2024-06-20 10:20:18',
          updateTime: this.backupVM.backupDateTime,
          path: '/文件/screenshot_20251027_151657.jpg',
          downloadUrl: 'media/screenshot_20251027_151657.jpg',
          thumbnailUrl: 'screenshot_20251027_151657',
          parentFileId: 10007
        },
        {
          fileId: 10052,
          fileName: 'tang潮.txt',
          fileType: 3,
          fileSize: '15.1KB',
          createTime: '2024-06-22 14:30:00',
          updateTime: this.backupVM.backupDateTime,
          path: '/文件/tang潮.txt',
          downloadUrl: 'document/tang潮.txt',
          parentFileId: 10007
        },
        {
          fileId: 10053,
          fileName: '一样一样还好吧要好好抱抱你妈妈_202510111535_27242.txt',
          fileType: 3,
          fileSize: '15.1KB',
          createTime: '2024-06-25 10:00:00',
          updateTime: this.backupVM.backupDateTime,
          path: '/文件/一样一样还好吧要好好抱抱你妈妈_202510111535_27242.txt',
          downloadUrl: 'document/一样一样还好吧要好好抱抱你妈妈_202510111535_27242.txt',
          parentFileId: 10007
        }]
    }

    MockService.fileResult = [...MockService.fileResult, mockInfoBackup]
    MockService.backUpCurrentFileList()
  }

  private async pickAvatarFromAlbum() {
    this.currentIndexTab = 2
    this.tabsController.changeIndex(2);
  }

  checkPermissionGrant() {
    PermissionUtil.checkPermissionGrant('ohos.permission.CAMERA').then((res) => {
      if (res === -1) {
        promptAction.openCustomDialog({
          builder: () => {
            this.CustomDialog('尚未开启本应用相机权限，是否前往设置', () => {
              let context = getContext(this) as common.UIAbilityContext;
              context.startAbility({
                bundleName: 'com.huawei.hmos.settings',
                abilityName: 'com.huawei.hmos.settings.MainAbility',
                uri: 'application_info_entry',
                parameters: {
                  pushParams: 'com.huawei.clouddisk'  // 替换为实际应用包名
                }
              });
            })
          },
          alignment: DialogAlignment.Bottom,
          width: '90%'
        })
          .then((id) => {
            this.backupVM.dialogId = id
          })
      } else {
        this.backupVM.beginProgress()
      }
    })
  }

  private CustomDialog(msg: ResourceStr, sureAction: () => void) {
    GlobalContext.getUIContext().showAlertDialog({
      message: msg,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      buttons: [
        {
          value: '取消',
          action: () => {
          }
        },
        {
          value: '确定',
          action: () => {
            sureAction()
          }
        }
      ]
    })

  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      pageConfig: this.pageConfig,
    })

  }

  // 页面内容渲染
  @Builder
  render() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Row() {
          Text('备份')
            .fontSize($r('sys.float.Title_M'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))

          Image($r('app.media.ic_setup')).width(24).height(24)
            .onClick(() => {
              if (this.backupVM.backupStatus === BackupStatus.Start) {
                this.backupVM.pauseProgress()
                this.backupVM.backupStatus = BackupStatus.Pause
              }
              phoneRouterControl.jumpPage({
                pageName: RouterMap.BACK_UP_SETUP_PAGE,
                builder: wrapBuilder(BackupSetUpPageBuilder)
              })
            })
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: 15, bottom: 15 })
        .width('100%')

        if (this.backupVM.turnActivation) {
          if (this.backupVM.backupStatus === BackupStatus.Start || this.backupVM.backupStatus === BackupStatus.Pause) {
            Row() {
              Column() {
                Row() {
                  Image($r('app.media.ic_backup_success'))
                    .width(16)
                    .height(16)
                  Text('自动备份已开启，相册备份中').fontSize(14).fontColor('#444444').margin({ left: 4 })
                }.width('100%').justifyContent(FlexAlign.Start)

                Row() {
                  Text(`最近备份日期：${this.backupVM.backupDate}`).fontColor('#999EA2').fontSize(12)
                }.padding({ left: 20 }).justifyContent(FlexAlign.Start).width('100%')
                .margin({ top: 4 })
              }.justifyContent(FlexAlign.Start).layoutWeight(1)

              Text('查看相册').fontSize(14).fontColor('#2FAFFF')
                .onClick(() => {
                  this.pickAvatarFromAlbum()
                })
            }
            .padding({ left: 12, right: 12 })
            .backgroundColor('#E4E7EB')
            .borderRadius(12)
            .height(62)
            .justifyContent(FlexAlign.SpaceBetween)
          } else {
            Row() {
              Column() {
                Row() {
                  Image($r('app.media.ic_backup_success'))
                    .width(16)
                    .height(16)
                  Text('自动备份已开启，相册备份已完成').fontSize(14).fontColor('#444444').margin({ left: 4 })
                }.width('100%').justifyContent(FlexAlign.Start)

                Row() {
                  Text(`最近备份日期：${this.backupVM.backupDate}`).fontColor('#999EA2').fontSize(12)
                }.padding({ left: 20 }).justifyContent(FlexAlign.Start).width('100%')
                .margin({ top: 4 })
              }.justifyContent(FlexAlign.Start).layoutWeight(1)

              Text('查看相册').fontSize(14).fontColor('#2FAFFF')
                .onClick(() => {
                  this.pickAvatarFromAlbum()
                })
            }
            .padding({ left: 12, right: 12 })
            .backgroundColor('#E4E7EB')
            .borderRadius(12)
            .height(62)
            .justifyContent(FlexAlign.SpaceBetween)
          }

        } else {
          Row() {
            Image($r('app.media.ic_not_backup'))
              .width(16)
              .height(16)
            Text('未开启备份').fontSize(14).fontColor('rgba(0, 0, 0, 0.4)').margin({ left: 4 }).layoutWeight(1)
            Text('一键开启').fontSize(14).fontColor('#2FAFFF').onClick(() => {
              let permissionsList: Array<Permissions> = ['ohos.permission.CAMERA'];
              PermissionUtil.reqPermissionsFromUser(permissionsList).then(() => {
                if (this.backupVM.backupStatus === BackupStatus.Complete) {
                  promptAction.showToast({ message: '已备份完成' })
                  return
                }
                this.backupVM.turnActivation = true
                this.backupVM.backupStatus = BackupStatus.Start
                this.backupVM.beginProgress()
                this.backUpDocument()
              }).catch((err: BusinessError) => {
                this.checkPermissionGrant()
                TCLogger.error(this.logTag, `checkPermissions error: ${JSON.stringify(err)}`);
              })
            })
          }.padding({ left: 12, right: 12 }).backgroundColor('#E4E7EB').borderRadius(12).height(44)
        }


        if (this.backupVM.turnActivation) {
          BackStatus({
            backupProgress: this.backupVM.backupProgress,
            backupDateTime: this.backupVM.backupDateTime,
            backupStatus: this.backupVM.backupStatus,
            beginProgress: () => {
              this.backupVM.beginProgress()
            },
            pauseProgress: () => {
              this.backupVM.pauseProgress()
            },
            pickAvatarFromAlbum: () => {
              this.pickAvatarFromAlbum()
            },
            onValueChange: (val) => {
              let permissionsList: Array<Permissions> = ['ohos.permission.CAMERA'];
              PermissionUtil.reqPermissionsFromUser(permissionsList).then(() => {
                this.backupVM.backupStatus = val
              }).catch((err: BusinessError) => {
                TCLogger.error(this.logTag, `checkPermissions error: ${JSON.stringify(err)}`);
              })
            },
          })
        }

      }
      .backgroundColor($r('sys.color.background_secondary'))
      .backgroundImageSize(ImageSize.FILL)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .height('100%')
      .padding({
        left: 16,
        right: 16,
        top: BarVM.instance.aiBarH,
        bottom: BarVM.instance.aiBarH
      })
    }
  }
}