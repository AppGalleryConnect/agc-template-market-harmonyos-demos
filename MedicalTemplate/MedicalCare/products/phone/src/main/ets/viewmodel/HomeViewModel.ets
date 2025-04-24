import { BaseViewModel } from 'common'
import BannerInfo from '../model/BannerInfo'

@ObservedV2
export default class HomeViewModel extends BaseViewModel {
  @Trace bannerList: BannerInfo[] = []

  public loadData() {
    this.bannerList.push({
      id: '1',
      resource: 'app.media.bg_banner1'
    }, {
      id: '2',
      resource: 'app.media.bg_banner2'
    })
  }
}