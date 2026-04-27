import { UserEventItem } from '../model/UserEventModel';

export class RemindEventDispatcher {
  static scheduleCallback?: () => void;
  static birCallback?: () => void;
  static remCallback?: () => void;
  static todoCallback?: () => void;
  static eventChangeCallback?: (userEventInfo:UserEventItem) => void;
  static eventDeleteCallback?: (userEventInfo:UserEventItem) => void;

  static dispatchToEventChange(userEventInfo:UserEventItem) {
    if (RemindEventDispatcher.eventChangeCallback) {
      RemindEventDispatcher.eventChangeCallback(userEventInfo);
    }
  }

  static dispatchToEventDelete(userEventInfo:UserEventItem) {
    if (RemindEventDispatcher.eventDeleteCallback) {
      RemindEventDispatcher.eventDeleteCallback(userEventInfo);
    }
  }

  static dispatchToSchedule() {
    if (RemindEventDispatcher.scheduleCallback) {
      RemindEventDispatcher.scheduleCallback();
    }
  }
  static dispatchTobBir() {
    if (RemindEventDispatcher.birCallback) {
      RemindEventDispatcher.birCallback();
    }
  }
  static dispatchTobRem() {
    if (RemindEventDispatcher.remCallback) {
      RemindEventDispatcher.remCallback();
    }
  }
  static dispatchTodo() {
    if (RemindEventDispatcher.todoCallback) {
      RemindEventDispatcher.todoCallback();
    }
  }
}