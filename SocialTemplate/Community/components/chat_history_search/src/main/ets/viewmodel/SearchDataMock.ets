import { ContactSearchModel } from './ContactSearchModel';
import { ConversationCacheModel } from './ConversationCacheModel';

export class SearchDataMock {
  static allMessageList: ConversationCacheModel[] = []
  static allContactList: ContactSearchModel[] = []

  static addContact(userId: string, nickName: string, avatarUrl: string) {
    if (SearchDataMock.allContactList.filter((item) => item.searchUserId === userId).length === 0) {
      SearchDataMock.allContactList.push(new ContactSearchModel(userId, nickName, avatarUrl));
    }
  }
}