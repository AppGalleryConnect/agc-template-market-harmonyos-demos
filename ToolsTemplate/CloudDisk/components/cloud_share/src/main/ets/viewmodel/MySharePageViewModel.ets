import { display } from '@kit.ArkUI';
import { FileBaseCheckViewModel, FileBaseInfo } from 'cloud_file_base';
import { OperationItemType } from 'cloud_operation_item';

@ObservedV2
export class MySharePageViewModel {
  @Trace fileTypeIndex: number = 0
  @Trace isShowList: boolean[] = [false, false, false]
  fileTypeTitles: string[] = ['全部', '分享有效', '分享过期']
  @Trace tabListVM: FileBaseCheckViewModel[] = [
    new FileBaseCheckViewModel(),
    new FileBaseCheckViewModel(),
    new FileBaseCheckViewModel()
  ]
  // 跳转文件详情
  checkShareDetail: (fileBaseInfo: FileBaseInfo) => void = () => {
  }
  // 内边距
  contentPadding: Padding | Length | LocalizedPadding = 0

  constructor(allFileList: FileBaseInfo[], contentPadding: Padding | Length | LocalizedPadding = 0) {
    allFileList.forEach((item, index) => {
      this.tabListVM[0].fileList.push(item)
      if (index < 15) {
        item.expireTime = -1
        this.tabListVM[1].fileList.push(item)
      } else {
        item.expireTime = 2
        this.tabListVM[2].fileList.push(item)
      }
    })

    this.contentPadding = contentPadding
  }

  private static getDeviceWidth() {
    // 获取屏幕宽度和高度（单位：px）
    let displayInfo = display.getDefaultDisplaySync();
    // 转换为vp单位
    return px2vp(displayInfo.width);
  }

  static getButtonWidth() {
    let screenWidthVp = MySharePageViewModel.getDeviceWidth()
    return (screenWidthVp - 16 * 2 - 12) / 2
  }

  public static getAllOperation(fileList: FileBaseInfo[], currentIndex: number): OperationItemType[] {
    if (fileList.length > 1) {
      return [OperationItemType.CANCELSHARE]
    }

    const fileInfo: FileBaseInfo = fileList[0]
    if (fileInfo.expireTime === 2) {
      return [OperationItemType.CANCELSHARE, OperationItemType.SHARE]
    }

    if (fileInfo.expireTime === 3) {
      return [OperationItemType.SHARE]
    }

    return [OperationItemType.CANCELSHARE,
      OperationItemType.COPYLINK]
  }
  // 再次分享
  shareAgain: (fileBaseInfo: FileBaseInfo) => void = () => {
  }
}
