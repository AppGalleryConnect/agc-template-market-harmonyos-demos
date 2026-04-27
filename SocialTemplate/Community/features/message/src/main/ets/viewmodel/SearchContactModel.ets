import { MockAccountSingleModel } from 'common';
import { SearchContactTypeEnum } from '../utils/MessageEnum';

@ObservedV2
export class SearchContactModel extends MockAccountSingleModel {
  @Trace searchType: SearchContactTypeEnum = SearchContactTypeEnum.CHAT_TYPE_NICK_NAME;
  @Trace lightArr: string[] = [];
  @Trace normalArr: string[] = [];
}