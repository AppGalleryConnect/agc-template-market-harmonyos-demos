import { commonToast } from './Toast';
import { call } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { scanBarcode, scanCore } from '@kit.ScanKit';
import { Context } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction } from '@kit.ArkUI';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { ServiceList, ServiceListInfo } from '../model/CommonInterface';

/*
 * 拉起拨号盘进行拨号
 * */
export function startCallDialog(phone: string): void {
  call.makeCall(phone ?? '022-1234567', (err: BusinessError) => {
    if (err) {
      console.error(`Failed to make call. Code is ${err.code}, Message is ${err.message}`);
      return;
    }
    console.info('Succeeded in making call.');
  })
  commonToast.hide()
}

/*
 * 默认扫码
 * */
export function scanBarCode(context: Context) {
  // 定义扫码参数options
  let options: scanBarcode.ScanOptions = {
    scanTypes: [scanCore.ScanType.ALL],
    enableMultiMode: true,
    enableAlbum: true,
  };
  try {
    // 可调用getContext接口获取当前页面关联的UIAbilityContext
    scanBarcode.startScanForResult(context, options).then((result: scanBarcode.ScanResult) => {
      // 解析码值结果跳转应用服务页
      hilog.info(0x0001, '[Scan CPSample]',
        `Succeeded in getting ScanResult by promise with options, result is ${JSON.stringify(result)}`);
      promptAction.showToast({ message: JSON.stringify(result) })
    }).catch((error: BusinessError) => {
      hilog.error(0x0001, '[Scan CPSample]',
        `Failed to get ScanResult by promise with options. Code:${error.code}, message: ${error.message}`);
    });
  } catch (error) {
    hilog.error(0x0001, '[Scan CPSample]',
      `Failed to start the scanning service. Code:${error.code}, message: ${error.message}`);
  }
}

/*
 * 相册picker
 * */

export async function getPictureFromAlbum() {
  // 拉起相册，选择图片
  let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
  photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
  photoSelectOptions.maxSelectNumber = 1;
  let photoPicker = new photoAccessHelper.PhotoViewPicker();
  let photoSelectResult: photoAccessHelper.PhotoSelectResult = await photoPicker.select(photoSelectOptions);
  return photoSelectResult.photoUris[0]
}

/*
 * 细化服务
 * */

export function refineServices(categoryList: ServiceListInfo[]) {
  let refineServicesArray: ServiceList[] = []
  categoryList.forEach((item) => {
    item.serviceList.forEach((value) => refineServicesArray.push(value))
  })
  return refineServicesArray
}