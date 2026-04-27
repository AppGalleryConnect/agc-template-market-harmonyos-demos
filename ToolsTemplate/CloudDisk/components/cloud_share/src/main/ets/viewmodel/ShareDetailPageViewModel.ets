import { FileBaseInfo } from 'cloud_file_base';
import { display } from '@kit.ArkUI';
import { ShareDetailRowViewInfoViewModel } from './ShareDetailRowViewInfoViewModel';

@ObservedV2
export class ShareDetailPageViewModel {
  @Trace shareExtureInfoVM: ShareDetailRowViewInfoViewModel = new ShareDetailRowViewInfoViewModel()
  blockUsefullTime: (id: number, value: string | Resource) => void = (id: number, value: string | Resource) => {
    let result = value as Resource
    getContext().resourceManager.getStringValue(result.id)
      .then((values: string) => {
        console.log('RowView----转换结果:', values);
        this.shareExtureInfoVM.usefullTime = values
        this.shareExtureInfoVM.usefullTimeId = id
        this.fileInfo.changeTimeBy(values)
      })
      .catch((error: Error) => {
        console.error('转换失败:', error);
      });
  }

  // 再次分享
  shareAgains: (fileBaseInfo: FileBaseInfo) => void = () => {
  }
  // 有效期修改
  changeExpiretime: (fileBaseInfo: FileBaseInfo,
    blockUsefullTime: (id: number, value: string | Resource) => void, usefullTimeId?: number) => void = () => {
  }
  // 文件信息
  fileInfo: FileBaseInfo
  // 内边距
  contentPadding: Padding | Length | LocalizedPadding

  constructor(fileInfo: FileBaseInfo,
    contentPadding: Padding | Length | LocalizedPadding = 0) {
    this.fileInfo = fileInfo
    this.contentPadding = contentPadding
  }

  private static getDeviceWidth() {
    // 获取屏幕宽度和高度（单位：px）
    let displayInfo = display.getDefaultDisplaySync();
    // 转换为vp单位
    return px2vp(displayInfo.width);
  }

  static getButtonWidth() {
    let screenWidthVp = ShareDetailPageViewModel.getDeviceWidth()
    return (screenWidthVp - 16 * 2 - 12) / 2
  }
}