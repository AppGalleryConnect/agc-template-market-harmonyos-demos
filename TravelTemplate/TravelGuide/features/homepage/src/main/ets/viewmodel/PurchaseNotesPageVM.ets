import { phoneRouterControl } from 'oh_router';
import {
  reserveLimit,
  checkInPolicy,
  groupNotes,
  assuranceTips,
  bookingTravelNotes,
  breachClauseContent
} from '../common/mock/TourDetailMockData'
import { tableItem, tableContent } from 'common_travel_guide'

@ObservedV2
export class PurchaseNotesPageVM {
  @Trace reserveLimitList: tableItem[] = reserveLimit;
  @Trace checkInPolicyList: tableItem[] = checkInPolicy;
  @Trace groupNotesList: tableItem[] = groupNotes;
  @Trace bookingTravelNotesList: tableItem[] = bookingTravelNotes;
  @Trace assuranceTipsList: tableItem[] = assuranceTips;
  @Trace breachClauseContentList: tableContent[] = breachClauseContent


  //返回上一级
  backPage() {
    phoneRouterControl.popPage()
  }
}
