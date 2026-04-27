import { IQQOpenApi, OpenApiConfig, QQOpenApiFactory, ShareResultType } from '@tencent/qq-open-sdk';
import { QqShareContent, QqShareData, ShareOptions } from '../model/Model';
import { promptAction } from '@kit.ArkUI';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { MockService } from 'common';
import { FileListSelectViewVM } from 'clouddisk_file_select';

/**
 * QQ分享
 * 实际业务请填写实际appid
 */
export class QqShareViewModel {
  static appId = 102803516
  private static _instance: QqShareViewModel
  private static qqOpenApi: IQQOpenApi
  shareData: QqShareData = new QqShareData()
  fileListSelectViewVM = new FileListSelectViewVM(MockService.shareFileList)
  public initQqShare(): IQQOpenApi {
    if (!QqShareViewModel.qqOpenApi) {
      let openApiOption: OpenApiConfig = {
        forceEnableWeb: false,
        autoHandleAuthResult: true,
      }

      QqShareViewModel.qqOpenApi =
        QQOpenApiFactory.createApi(QqShareViewModel.appId, openApiOption)
    }
    return QqShareViewModel.qqOpenApi
  }

  static get instance() {
    if (!QqShareViewModel._instance) {
      QqShareViewModel._instance = new QqShareViewModel()
    }
    return QqShareViewModel._instance
  }

  /*
   * 需要根据业务获取实际签名
   * */
  public genSign(appId: string | number, shareDataStr: string, timestamp: number, nonce: number) {
    let totalStr = `POSTconnect.qq.com/share?appid=${appId}&nonce=${nonce}&ts=${timestamp}&${shareDataStr}`
    return '业务签名'
  }

  public handleShareInfo(qrCodeInfo:ShareOptions) {
    /*
     * 生成时间戳并计算签名
     * */
    let timeStamp = Date.parse(new Date().toString()) / 1000
    let rand = cryptoFramework.createRandom();
    // 设置生成随机数的字节长度为1
    let randData = rand.generateRandomSync(1);
    // 自定义范围(0-10之内)
    let result: number = randData.data[0] / 255;
    let nonce = Math.floor(result * 100000000 + 100)
    let shareContent: QqShareContent = {
      msgStyle: 0,
      title: qrCodeInfo.title,
      url: '',
      pictureUrl: qrCodeInfo.coverUrl as string,
    }
    let shareDataSign = this.genSign(QqShareViewModel.appId, qrCodeInfo.title, timeStamp, nonce)
    this.shareData.timestamp = timeStamp
    this.shareData.shareJson = JSON.stringify(shareContent)
    this.shareData.nonce = nonce
    this.shareData.shareJsonSign = shareDataSign
  }

  public async share(qrCodeInfo:ShareOptions) {
    this.handleShareInfo(qrCodeInfo)
    let result = await QqShareViewModel.qqOpenApi.share(2, this.shareData);
    switch (result.resultType) {
      case ShareResultType.Success: {
        MockService.addFileListToTargetList(this.fileListSelectViewVM.getAllSelected(), MockService.shareFileList)
        promptAction.showToast({ message: '分享成功' })
      }
        break
      case ShareResultType.Cancel: {
        MockService.addFileListToTargetList(this.fileListSelectViewVM.getAllSelected(), MockService.shareFileList)
        let msg: string = result.message ?? '用户取消分享'
        promptAction.showToast({ message: msg })
      }
        break
      case ShareResultType.Error: {
        MockService.addFileListToTargetList(this.fileListSelectViewVM.getAllSelected(), MockService.shareFileList)
        let msg: string = result.message ?? '分享失败'
        promptAction.showToast({ message: msg })
      }
        break
    }
  }
}
