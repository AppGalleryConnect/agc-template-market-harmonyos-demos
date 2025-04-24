import { ReservationRecord, UserInfo } from '../model/CommonInterface';
import { Type } from '@kit.ArkUI';

// 用户数据
@ObservedV2
export class UserState {
  @Trace isLogin: boolean = false;
  @Trace userInfo: UserInfo = new UserInfo();
  @Type(ReservationRecord)
  @Trace recordList: ReservationRecord[] = []
}


@ObservedV2
export class SearchHistory {
  @Trace historyList: string[] = [];
}

export class Suggestion {
  date: Date = new Date()
  title: string = ''
  image?: string[] = []
}


@ObservedV2
export class SuggestionList {
  @Type(Suggestion)
  @Trace suggestionList: Suggestion[] = [];
}