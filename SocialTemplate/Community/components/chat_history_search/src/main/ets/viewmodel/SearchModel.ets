import { SearchHistoryModel } from './SearchHistoryModel';
import { PersistenceV2 } from '@kit.ArkUI';
import { ChatContentSingleModel, ChatTypeEnum } from 'chat_base';
import { ContactSearchModel } from './ContactSearchModel';
import { SearchDataMock } from './SearchDataMock';
import { SearchModelManager } from '../util/SearchModelManager';
import { CollectDataManager } from 'chat_history_collection';
import { ConversationCacheModel } from './ConversationCacheModel';

@ObservedV2
export class SearchModel {
  @Trace searchHistory: SearchHistoryModel = PersistenceV2.connect(SearchHistoryModel, () => new SearchHistoryModel())!;
  @Trace messageSRList: ChatContentSingleModel[] = [];
  @Trace collectSRList: ChatContentSingleModel[] = [];
  @Trace friendSRList: ContactSearchModel[] = [];
  @Trace searchParUserId?: string;
  @Trace searchParGroupId?: string;
  @Trace selectTabIndex: number = 0;
  @Trace searching: boolean = false;
  @Trace loading: boolean = false;
  @Trace selectDate: Date | undefined = undefined;
  @Trace searchText: string = '';
  searchTextChangeListener?: (searchText: string) => void;
  searchMessageFromCloud?: (searchKey: string, userId?: string, groupId?: string,
    startDate?: number) => ChatContentSingleModel[] | PromiseLike<ChatContentSingleModel[]>
  searchContactFromCloud?: (searchKey: string) => ContactSearchModel[] | PromiseLike<ContactSearchModel[]>

  constructor(userId: string, groupId?: string) {
    if (userId && userId.length > 0) {
      this.searchParUserId = userId;
    } else if (groupId && groupId.length > 0) {
      this.searchParGroupId = groupId;
    }
  }

  getSearchResult(userId?: string, groupId?: string) {
    if (this.searchText?.length > 0) {
      this.messageSRList = [];
      this.collectSRList = [];
      this.friendSRList = [];
      this.loading = true;
      new Promise<void>((res, rej) => {
        setTimeout(async () => {
          //聊天记录搜索
          await this.getMessageSearchResult(this.searchText, userId, groupId);
          if (!this.isSearchUserOrGroup()) {
            //收藏搜索
            this.getCollectSearchResult(this.searchText, userId, groupId);
            //联系人搜索
            await this.getFriendSearchResult(this.searchText);
          }
          this.loading = false;
          res();
        }, 100)
      }).then(() => {
        this.loading = false;
      }).finally(() => {
        this.loading = false;
      })
    }
  }

  getSearchResultWithDate(start: number, userId?: string, groupId?: string) {
    this.messageSRList = [];
    this.collectSRList = [];
    this.friendSRList = [];
    //聊天记录搜索
    this.loading = true;
    new Promise<void>((res, rej) => {
      setTimeout(async () => {
        if (SearchModelManager.getSearchModel() === 1 && this.searchMessageFromCloud) {
          let msgList = await this.searchMessageFromCloud('', userId, groupId, start)
          this.messageSRList.push(...msgList);
        } else {
          this.searchMessageWithDate(start, userId, groupId);
        }
        this.loading = false;
        res();
      }, 100)
    }).then(() => {
      this.loading = false;
    }).finally(() => {
      this.loading = false;
    })
  }

  /**
   * 聊天记录搜索 - 字符串匹配
   * @param searchKey
   * @param userId
   * @param groupId
   */
  async getMessageSearchResult(searchKey: string, userId?: string, groupId?: string) {
    if (SearchModelManager.getSearchModel() === 1 && this.searchMessageFromCloud) {
      let msgList = await this.searchMessageFromCloud(searchKey, userId, groupId, 0)
      this.messageSRList.push(...msgList);
    } else {
      SearchDataMock.allMessageList.forEach((item) => {
        if (userId || groupId) {
          if ((userId && item.userId !== userId) || (groupId && item.groupID !== groupId)) {
            return;
          }
        }
        let curSearchList = item.allCachedMsgList.filter((item_) => {
          return (item_.chatType !== ChatTypeEnum.CHAT_GROUP_TIPS) &&
            (item_.textElem.toLowerCase().includes(searchKey.toLowerCase()) ||
              (item_.locationName && item_.locationName.toLowerCase().includes(searchKey.toLowerCase())));
        })
        curSearchList = curSearchList.sort((a, b) => {
          return b.timestamp - a.timestamp;
        })
        this.messageSRList.push(...curSearchList)
      }, (item: ConversationCacheModel) => item.userId + item.groupID)
    }
  }

  /**
   * 收藏记录搜索 - 字符串匹配
   * @param searchKey
   * @param userId
   * @param groupId
   */
  getCollectSearchResult(searchKey: string, userId?: string, groupId?: string) {
    let collectList = CollectDataManager.getInstance().getCollectData().filter((item) => {
      if (userId || groupId) {
        if ((userId && item.userId !== userId) || (groupId && item.groupId !== groupId)) {
          return false;
        }
      }

      return item.textElem.toLowerCase().includes(searchKey.toLowerCase()) ||
        (item.locationName && item.locationName.toLowerCase().includes(searchKey.toLowerCase()));
    })
    collectList = collectList.sort((a, b) => {
      return b.timestamp - a.timestamp;
    })
    this.collectSRList = collectList;
  }

  /**
   * 好友搜索 - 字符串匹配
   * @param searchKey
   * @param userId
   * @param groupId
   */
  async getFriendSearchResult(searchKey: string) {
    if (SearchModelManager.getSearchModel() === 1 && this.searchContactFromCloud) {
      this.friendSRList = await this.searchContactFromCloud(searchKey);
    } else {
      this.friendSRList = SearchDataMock.allContactList.filter((item) => {
        return item.searchNickName.toLowerCase().includes(searchKey.toLowerCase());
      })
    }
  }

  /**
   * 聊天记录搜索 - 开始时间匹配
   * @param searchKey
   * @param userId
   * @param groupId
   */
  searchMessageWithDate(start: number, userId?: string, groupId?: string) {
    let endTime = (start + (24 * 60 * 60 * 1000 - 1)); //结束时间为当天结束时间点比如 2025-12-15 23：59：59：999 具体到毫秒
    SearchDataMock.allMessageList.forEach((item) => {
      if (userId || groupId) {
        if ((userId && item.userId !== userId) || (groupId && item.groupID !== groupId)) {
          return;
        }
      }
      let curSearchList = item.allCachedMsgList.filter((item_) => {
        return (item_.timestamp * 1000) >= start && (item_.timestamp * 1000) < endTime &&
          item_.chatType !== ChatTypeEnum.CHAT_GROUP_TIPS;
      })
      curSearchList = curSearchList.sort((a, b) => {
        return b.timestamp - a.timestamp;
      })
      this.messageSRList.push(...curSearchList)
    }, (item: ConversationCacheModel) => item.userId + item.groupID)
  }

  getSearchData(): Array<ChatContentSingleModel | ContactSearchModel> {
    return this.selectTabIndex === 0 ? this.messageSRList :
      this.selectTabIndex === 1 ? this.collectSRList : this.friendSRList;
  }

  isSearchUserOrGroup(): boolean {
    return (this.searchParUserId !== undefined && this.searchParUserId.length > 0) ||
      (this.searchParGroupId !== undefined && this.searchParGroupId.length > 0);
  }

  setOnSearchTextChangeListener(listener: (searchText: string) => void) {
    this.searchTextChangeListener = listener;
  }

  callSearchTextChange() {
    this.searchTextChangeListener?.(this.searchText);
  }
}