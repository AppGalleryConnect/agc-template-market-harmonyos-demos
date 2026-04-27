import { i18n } from '@kit.LocalizationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CMChatFactory, CMChatFriendInfo } from 'instant_messaging';

const TAG: string = 'AddressBookPageViewModel'

// 联系人viewmodel
@ObservedV2
export class AddressBookPageViewModel {
  // 置顶三项
  toppingItems: ContactToppingItem[] = [
    { title: '我创建的群', image: $r('app.media.group_create') },
    { title: '我管理的群', image: $r('app.media.group_manager') },
    { title: '我加入的群', image: $r('app.media.group_joined') }
  ]
  // 好友列表
  @Trace friendList: CMChatFriendInfo[] = []
  // 选择索引
  @Trace selectIndex: number = -1;
  // 滑动控制器
  scroller: Scroller = new Scroller();

  constructor() {
    this.getFriendList()
  }

  // 获取好友列表
  async getFriendList() {
    const friendList: CMChatFriendInfo[] = await CMChatFactory.instance.getFriendList();
    this.friendList = friendList

    // 监听好友变化
    CMChatFactory.instance.addFriendshipListener({
      onFriendListAdded: (list: CMChatFriendInfo[]) => {
        this.friendListAdded(list)
      },
      onFriendListDeleted: (userids: string[]) => {
        this.friendListDeleted(userids)
      },
      onFriendInfoChanged: (list: CMChatFriendInfo[]) => {
        this.friendInfoChanged(list)
      },
    })
  }

  @Computed
  get friendGroupList(): FriendGroup[] {
    return this.getCityAlphaList(this.friendList);
  }

  @Computed
  get alphaIndexList(): string[] {
    return this.friendGroupList.map(item => item.name)
  }

  handleScrollIndex(start: number) {
    this.selectIndex = start;
  }

  handleAlphaSelect(tabIndex: number) {
    this.scroller.scrollToIndex(tabIndex);
  }

  private getCityAlphaList(friendList: CMChatFriendInfo[]): FriendGroup[] {
    let transliterator = i18n.Transliterator.getInstance('Any-Latn;Latin-Ascii');
    const resultMap: Record<string, CMChatFriendInfo[]> = {}
    for (const item of friendList) {
      const result: string = transliterator.transform(item.nickName);
      const alpha = result[0].toUpperCase();
      if (resultMap[alpha]) {
        resultMap[alpha].push(item)
      } else {
        resultMap[alpha] = [item]
      }
    }
    return Object.keys(resultMap).map((name) => {
      return {
        name: name,
        list: resultMap[name],
      } as FriendGroup
    }).sort((a, b) => a.name.charCodeAt(0) - b.name.charCodeAt(0))
  }

  // 好友添加
  private friendListAdded(list: CMChatFriendInfo[]) {
    hilog.info(0x0000, TAG, '%{public}s', `friend list added ${list.length} count`);
    let result = Array.from(this.friendList)
    list.forEach(item => {
      result.push(item)
    })
    this.friendList = result
  }

  // 通过用户id列表删除好友
  private friendListDeleted(userids: string[]) {
    hilog.info(0x0000, TAG, '%{public}s', 'friend list delete list ' + userids.join(','));
    const ids: Set<string> = new Set(userids)
    let result: CMChatFriendInfo[] = []
    let deleteCount: number = 0
    this.friendList.forEach((item) => {
      if (!ids.has(item.userId)) {
        result.push(item)
      } else {
        deleteCount++
      }
    })

    if (deleteCount === 0) {
      hilog.info(0x0000, TAG, '%{public}s', `friend list not found`);
      return
    }

    this.friendList = result
  }

  // 好友信息变换
  private friendInfoChanged(list: CMChatFriendInfo[]) {
    list.forEach(item => {
      for (let i = 0; i < this.friendList.length; i++) {
        const element = this.friendList[i];
        if (item.userId === element.userId) {
          hilog.info(0x0000, TAG, '%{public}s',
            `friend info changed from ${(element.friendRemark.length > 0) ? element.friendRemark :
            element.nickName} to ${item.friendRemark}`);
          element.friendRemark = item.friendRemark
          break
        }
      }
    })
  }
}

// 联系人指定项
export interface ContactToppingItem {
  title: string,
  image: Resource
}

// 好友分组
export interface FriendGroup {
  name: string;
  list: CMChatFriendInfo[];
}