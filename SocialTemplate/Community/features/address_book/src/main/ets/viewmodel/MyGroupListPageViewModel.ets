import {
  CMChatFactory, CMChatGroupInfo,
  CMChatGroupMemberInfo } from 'instant_messaging';

// 群列表viewmodel
@ObservedV2
export class MyGroupListPageViewModel {
  // 类型
  @Trace groupRelationShip: GroupRelationShip = GroupRelationShip.CREATE
  // 群列表
  @Trace groupList: CMChatGroupInfo[] = []
  // 内容为空
  @Trace contentIsEmpty: boolean = false

  // 初始化类型
  initialWithRelationShip(groupRelationShip: number) {
    this.groupRelationShip = groupRelationShip % 3
    this.getJoinedGroupList()
  }

  @Computed
  get navTitle(): string {
    if (this.groupRelationShip === GroupRelationShip.CREATE) {
      return '我创建的群'
    }

    if (this.groupRelationShip === GroupRelationShip.MANAGER) {
      return '我管理的群'
    }

    return '我加入的群'
  }

  // 获取已加入的群列表
  async getJoinedGroupList() {
    let result: CMChatGroupInfo[] =
      await CMChatFactory.instance.getJoinedGroupList();
    
    // 过滤内容
    let filterList: CMChatGroupInfo[] = []
    for (let index = 0; index < result.length; index++) {
      const element: CMChatGroupInfo = result[index];
      if (this.groupRelationShip === GroupRelationShip.CREATE && element.role !== 400) {
        // 我创建的群，但非群主
        continue
      }

      if (this.groupRelationShip === GroupRelationShip.MANAGER && element.role !== 300) {
        // 我管理的群，但非管理员
        continue
      }

      element.memberInfoList = (await CMChatFactory.instance.getGroupMemberList(element.groupId, 0, 0)).memberInfoList
      element.memberAvatarList = this.parseGroupAvatars(element.memberInfoList);
      filterList.push(element)
    }
    // 时间逆序
    this.groupList = filterList.sort((a, b) => {
      return b.createTime - a.createTime
    })

    this.contentIsEmpty = (this.groupList.length === 0)
  }

  // 解析群成员列表
  private parseGroupAvatars(memberInfoList: CMChatGroupMemberInfo[]): string[][] {
    let count = 0;
    let groupAvatars: string[][] = [];
    for (let index = 0; index < memberInfoList.length; index++) {
      const element = memberInfoList[index];
      let itemAvatar: string[] = groupAvatars[count] ?? [];
      itemAvatar.push(element.avatarUrl);
      groupAvatars[count] = itemAvatar;

      if (memberInfoList.length < 5) {
        if (memberInfoList.length === 3) {
          if (index === 0) {
            count++;
          }
        }
        if (itemAvatar.length >= 2) {
          count++;
        }
      } else {
        if (memberInfoList.length === 5) {
          if (index === 1) {
            count++;
          }
        } else if (memberInfoList.length === 7) {
          if (index === 0) {
            count++;
          }
        } else if (memberInfoList.length === 8) {
          if (index === 1) {
            count++;
          }
        }
        if (itemAvatar.length >= 3) {
          count++;
        }
      }
      if (index >= 8) {
        break;
      }
    }
    return groupAvatars;
  }
}

// 群关系类型
export enum GroupRelationShip {
  // 创建
  CREATE = 0,

  // 管理
  MANAGER = 1,

  // 加入
  JOIN = 2,
}