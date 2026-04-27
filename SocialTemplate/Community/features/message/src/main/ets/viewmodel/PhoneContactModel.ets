import { Constants, GlobalContext, MOCK_ACCOUNT_LIST } from 'common';
import { CMChatFactory, CMChatFriendCheckResult } from 'instant_messaging';

@ObservedV2
export class ContactSingleModel extends CMChatFriendCheckResult {
  @Trace buttonNormalTitle: string = '已添加';
  @Trace buttonLightTitle: string = '添加';
}

@ObservedV2
export class PhoneContactModel {
  @Trace localContactMap: Map<string, ContactSingleModel[]> = new Map();
  @Trace pageTitle: string = '手机联系人添加';
  private collator = new Intl.Collator('en-US', { sensitivity: 'base' });

  async setContactStatus() {
    const memberIds = new Set(MOCK_ACCOUNT_LIST.map(item => item.userId));
    let result = await CMChatFactory.instance.checkFriend(Array.from(memberIds));
    let contactList: ContactSingleModel[] = [];
    for (let index = 0; index < result.length; index++) {
      const element = result[index];
      let contact = new ContactSingleModel();
      contact.userId = element.userId;
      contact.nickName = Constants.getMockNickName(element.userId);
      contact.avatarUrl = Constants.getMockAvatar(element.userId);
      contact.isFriend = element.isFriend;
      contactList.push(contact);
    }

    this.getGroupedContacts(contactList);
  }

  /**
   * 添加好友
   */
  async addFriend(contact: ContactSingleModel) {
    if (contact.isFriend) {
      return;
    }

    let result = await CMChatFactory.instance.addFriend(contact.userId, contact.nickName);
    if (result.resultCode === 0) {
      GlobalContext.getUIContext().getPromptAction().showToast({
        message: '添加成功'
      })
      contact.isFriend = true;
    } else {
      GlobalContext.getUIContext().getPromptAction().showToast({
        message: '添加失败'
      })
    }
  }

  // 分组排序处理函数
  private getGroupedContacts(contactList: ContactSingleModel[]) {
    const sortedContacts = this.sortContactsByNickname(contactList);
    this.localContactMap = this.groupContacts(sortedContacts);
  }

  // 排序函数
  private sortContactsByNickname(contactList: ContactSingleModel[]) {
    return contactList.sort((a, b) => this.collator.compare(a.nickName, b.nickName));
  }

  private groupContacts(contacts: ContactSingleModel[]) {
    const grouped: Map<string, ContactSingleModel[]> = new Map();

    contacts.forEach(contact => {
      const firstChar = contact.nickName.charAt(0).toUpperCase();
      // 按首字母分组（非字母字符归为“#”组）
      const groupKey = /[A-Z]/.test(firstChar) ? firstChar : '#';

      if (!grouped.get(groupKey)) {
        grouped.set(groupKey, []);
      }

      (grouped.get(groupKey) as ContactSingleModel[]).push(contact);
    });

    return grouped;
  }
}

