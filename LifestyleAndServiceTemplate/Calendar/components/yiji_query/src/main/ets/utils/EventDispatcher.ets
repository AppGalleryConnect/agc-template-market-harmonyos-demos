import { LuckyDays } from '../model/Model'
export class EventDispatcher {
  static onCellClick?: (lunarInfo: LuckyDays) => void;
  static dispatchTo(lunarInfo: LuckyDays) {
    if (EventDispatcher.onCellClick) {
      EventDispatcher.onCellClick(lunarInfo);
    }
  }
}