import { BaseViewModel } from 'lib_common';
import { MessageServiceApi, BriefMsgInfo } from 'lib_news_api';
import { messageMenuList } from '../constants/Constants';
import { MineMsgMenuItem, MineMsgMenuType } from '../types/Types';

@ObservedV2
export class MessageViewModel extends BaseViewModel {
  @Trace menuInfoList: MineMsgMenuItem[] = messageMenuList
    .map(v => new MineMsgMenuItem(v))
    .filter(v => {
      if (this.isLogin) {
        return true;
      }
      return v.type === MineMsgMenuType.System;
    });

  constructor() {
    super();
    this.queryAllBriefInfo();
    this.setPopEvent();
  }

  queryAllBriefInfo() {
    this.queryBriefCommentReplyInfo();
    this.queryBriefMessageInfo();
    this.queryBriefFanInfo();
    this.queryBriefSystemInfo();
  }

  queryBriefCommentReplyInfo() {
    MessageServiceApi.queryBriefCommentReply().then((resp: BriefMsgInfo) => {
      this.assignValue(MineMsgMenuType.Comment, resp);
    })
  }

  queryBriefMessageInfo() {
    MessageServiceApi.queryBriefIM().then((resp: BriefMsgInfo) => {
      this.assignValue(MineMsgMenuType.IM, resp);
    })
  }

  queryBriefFanInfo() {
    MessageServiceApi.queryBriefNewFans().then((resp: BriefMsgInfo) => {
      this.assignValue(MineMsgMenuType.Fan, resp);
    });
  }

  queryBriefSystemInfo() {
    MessageServiceApi.queryBriefSystemInfo().then((resp: BriefMsgInfo) => {
      this.assignValue(MineMsgMenuType.System, resp);
    })
  }

  assignValue(type: MineMsgMenuType, value: BriefMsgInfo) {
    const menu = this.menuInfoList.find(v => v.type === type);
    if (menu) {
      menu.allUnreadCount = value.allUnreadCount;
      menu.receiveTime = value.receiveTime;
      menu.latestNews = value.latestNews;
    }
  }

  setAllRead() {
    if (this.isLogin) {
      MessageServiceApi.setAllRead().then(() => {
        this.queryAllBriefInfo();
      })
    } else {
      MessageServiceApi.setSystemRead().then(() => {
        this.queryBriefSystemInfo();
      })
    }
  }

  setPopEvent() {
    this.menuInfoList.forEach((v: MineMsgMenuItem) => {
      if (v.type === MineMsgMenuType.Comment) {
        v.routerOnPop = () => {
          this.queryBriefCommentReplyInfo()
        }
      } else if (v.type === MineMsgMenuType.IM) {
        v.routerOnPop = () => {
          this.queryBriefMessageInfo()
        }
      } else if (v.type === MineMsgMenuType.Fan) {
        v.routerOnPop = () => {
          this.queryBriefFanInfo()
        }
      } else {
        v.routerOnPop = () => {
          this.queryBriefSystemInfo()
        }
      }
    })
  }

  @Computed
  get isLogin() {
    return this.userInfoModel.isLogin;
  }

  @Computed
  get allowClean() {
    return this.menuInfoList.some(v => v.allUnreadCount !== 0);
  }
}