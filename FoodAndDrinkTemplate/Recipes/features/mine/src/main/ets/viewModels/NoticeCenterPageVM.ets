import { getMyNoticeList, Notice } from 'network';
import { RouterMap, RouterModule } from 'commonlib';
import { Decimal } from '@kit.ArkTS';
import { NoticeTypeEnum } from '../model/Index';

@ObservedV2
export class NoticeCenterPageVM {
  @Trace noticeList: Notice[] = [];

  getMyNoticeList() {
    getMyNoticeList().then(res => {
      if (res.status === 200) {
        this.noticeList = res.data;
      }
    })
  }

  jumpUrl(item: Notice) {
    if (item.type === NoticeTypeEnum.RECIPE) {
      RouterModule.push(RouterMap.DISHES, { 'id': item.id } as Record<string, number>)
    } else {
      RouterModule.push(RouterMap.NOTICE_DETAIL_PAGE,
        { 'title': item.title, 'subTitle': item.subTitle } as Record<string, string>)
    }
  }

  getFmtTime(time: number) {
    let date = new Date().getTime() - time
    if (date > 3600000) {
      return '1小时前'
    } else if (date > 60000) {
      try {
        return `${new Decimal(date).div(60000).toFixed(0).toString()}分钟前`
      } catch (error) {
        return '几分钟前'
      }
    } else {
      return '刚刚'
    }
  }
}