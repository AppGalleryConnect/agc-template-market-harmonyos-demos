/**
 * @usage: 用于配置云盘备份设置的页面。提供备份相关的开关设置，包括"自动备份相册"和"使用流量备份"两个主要配置项。
 * 每个配置项都使用Toggle开关组件进行状态控制，支持用户自定义备份行为。页面通过HeaderView组件提供标准的导航栏，包含返回按钮和页面标题。
 * @layout: 页面采用垂直布局（Column），顶部是HeaderView导航栏组件，包含返回按钮和"设置"标题。
 * 主体内容区域包含一个白色背景的设置卡片（Column），内部垂直排列两个设置项行（Row）：
 * 每行左侧是设置项文字描述，右侧是Toggle开关组件，行内采用SpaceBetween对齐方式。
 * @constraints: HeaderView组件的样式和行为不可修改。
 * @isGen: true
 * @fileType: page
 * @domain: 云存储,
 * @zhName: 备份设置页面
 * @component: OHPage,HeaderView
 * @image: screenshot/backup/set_backup.jpg
 */

import { Constants, EmitterUtil, GlobalContext, HeaderView, PermissionUtil, TCLogger } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';
import { BackupSetUpVM } from '../viewModel/BackupSetUpVM';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { common, Permissions } from '@kit.AbilityKit';
import { PersistenceV2, promptAction } from '@kit.ArkUI';
import { BackupVM } from '../viewModel/BackupVM';

@Builder
export function BackupSetUpPageBuilder() {
  BackupSetUp()
}

PersistentStorage.persistProp('traffic', true);

@ComponentV2
export struct BackupSetUp {
  logTag: string = 'BackupSetUp';
  @Local backupVM: BackupVM = PersistenceV2.connect(BackupVM, () => new BackupVM())!;
  @Local backupSetUpVM: BackupSetUpVM = PersistenceV2.connect(BackupSetUpVM, () => new BackupSetUpVM())!;

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      }
    })
  }

  checkPermissionGrant() {
    PermissionUtil.checkPermissionGrant('ohos.permission.CAMERA').then((res) => {
      if (res === -1) {
        promptAction.openCustomDialog({
          builder: () => {
            this.CustomDialog('尚未开启本应用相机权限，是否前往设置', () => {
              // todo 跳转应用设置页面
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
            this.backupSetUpVM.dialogId = id
          })
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
            this.backupSetUpVM.isAutoBackup = false
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

  aboutToAppear(): void {
    this.backupSetUpVM.isAutoBackup = this.backupVM.turnActivation
  }

  back() {
    let eventData: emitter.EventData = {
      data: {
        isAutoBackup: this.backupSetUpVM.isAutoBackup
      }
    }
    EmitterUtil.emit('backToBackup', eventData)
  }

  aboutToDisappear(): boolean | void {
    this.back()
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      Column() {
        HeaderView({
          title: $r('app.string.setting_up'),
          clickBackBtn: () => {
            this.back()
            phoneRouterControl.popPage();
          }
        })
          .margin({ top: 24 })

      }
      .width(Constants.FULL_SIZE)
      .backgroundColor('#FFFFFF')

      Column() {
        Column() {
          Row() {
            Text('自动备份相册')
            Toggle({ type: ToggleType.Switch, isOn: $$this.backupSetUpVM.isAutoBackup })
              .size({ width: 36, height: 20 })
              .selectedColor($r('sys.color.comp_background_emphasize'))
              .onChange((isOn: boolean) => {
                if (isOn) {
                  let permissionsList: Array<Permissions> = ['ohos.permission.CAMERA'];
                  PermissionUtil.reqPermissionsFromUser(permissionsList).then(() => {
                    this.backupSetUpVM.isAutoBackup = isOn
                  }).catch((err: BusinessError) => {
                    this.checkPermissionGrant()
                    TCLogger.error(this.logTag, `checkPermissions error: ${JSON.stringify(err)}`);
                  })
                } else {
                  this.backupSetUpVM.isAutoBackup = false
                }
              })
          }
          .height('50%')
          .width('100%')
          .padding({ left: 16, right: 16 })
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)

          Row() {
            Text('使用流量备份')
            Toggle({ type: ToggleType.Switch, isOn: this.backupSetUpVM.traffic })
              .size({ width: 36, height: 20 })
              .selectedColor($r('sys.color.comp_background_emphasize'))
              .onChange((isOn: boolean) => {
                this.backupSetUpVM.traffic = isOn
              })
          }
          .height('50%')
          .width('100%')
          .padding({ left: 16, right: 16 })
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
        }.backgroundColor('#FFFFFF').borderRadius(16).height(120).width('100%')
      }.padding({ top: 16, left: 16, right: 16 })

    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.comp_background_gray'))
  }
}