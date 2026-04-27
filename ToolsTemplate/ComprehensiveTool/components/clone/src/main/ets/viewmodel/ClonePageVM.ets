import { getInstance } from '../common/CommonRoute';
import { ConnectionVo } from '../model/ConnectionVo';
import { picker } from '@kit.CoreFileKit';
import { TcpCallback } from '../model/TcpCallback';
import { TcpClient } from '../service/TcpClient';
import { abilityAccessCtrl, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../common/Constant'
import { checkAccessToken } from '../utils/Permission';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';

@ObservedV2
export class ClonePageVM {
  private static _instance: ClonePageVM

  public static get instance() {
    if (!ClonePageVM._instance) {
      ClonePageVM._instance = new ClonePageVM();
    }
    return ClonePageVM._instance;
  }

  // 获取权限
  getPermission(context: Context) {
    const permissions: Array<Permissions> =
      ['ohos.permission.WRITE_CONTACTS', 'ohos.permission.READ_CONTACTS', 'ohos.permission.READ_IMAGEVIDEO',
        'ohos.permission.WRITE_IMAGEVIDEO'];
    abilityAccessCtrl.createAtManager()
      .requestPermissionsFromUser(context, permissions)
      .then((data: PermissionRequestResult) => {
        console.log(JSON.stringify(data))
      })
      .catch((err: BusinessError) => {
        console.log(JSON.stringify(err))
      });
  }

  // 检测权限
  async checkAccessToken() {
    let res = -1
    const permissions: Array<Permissions> =
      ['ohos.permission.WRITE_CONTACTS', 'ohos.permission.READ_CONTACTS', 'ohos.permission.READ_IMAGEVIDEO',
        'ohos.permission.WRITE_IMAGEVIDEO'];
    for (let i = 0; i < permissions.length; i++) {
      res = await checkAccessToken(permissions[i])
    }
    if (res === 0) {
      return true
    } else {
      promptAction.showToast({ message: '请授权联系人读写权限，图片视频读写权限！' })
      return false
    }
  }

  // 处理扫码结果
  handleScanResult(scanData: string) {
    try {
      const connectionVo = JSON.parse(scanData) as ConnectionVo;
      if (connectionVo.type === 'tcp_connection') {
        TcpClient.init(connectionVo, {
          onConnected: () => {
            getInstance().pushPathByName('FileUploadPage', true)
          },
        } as TcpCallback)
      }
    } catch (error) {
      Logger.error('解析二维码数据失败:', error);
    }
  }

  // 拉起picker
  pickerSelect() {
    const docSel = new picker.DocumentSelectOptions();
    const docPic = new picker.DocumentViewPicker();
    docPic.select(docSel).then(async (documentSelectResult: Array<string>) => {
      if (documentSelectResult.length <= 0) {
        return
      }
      getInstance().pushPathByName('AirdropPage', documentSelectResult)
    })
  }
}
