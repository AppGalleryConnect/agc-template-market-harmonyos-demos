import { PreferenceUtil } from 'common';

// 移动网络下上传/下载
export class DownLoadNetworkPriceViewModel {
  // 开关状态
  isOpen: boolean = false

  setDownLoadNetworkPrice(status: boolean) {
    this.isOpen = status;
    PreferenceUtil.getInstance().put('DownLoadNetworkPrice', status)
  }

  getDownLoadNetworkPrice() {
    return this.isOpen = PreferenceUtil.getInstance().get('DownLoadNetworkPrice', false) as boolean
  }
}
