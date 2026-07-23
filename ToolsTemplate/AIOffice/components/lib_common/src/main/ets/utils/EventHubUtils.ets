import { common } from '@kit.AbilityKit';
import { EventEnum } from '../constants/EventEnum';
import { GlobalContext } from './GlobalContext';

/**
 * EventHub线程通信
 */
export class EventHubUtils {
  private eventHub: common.EventHub = GlobalContext.getContext().eventHub;
  private static instance: EventHubUtils;

  public static getInstance(): EventHubUtils {
    if (!EventHubUtils.instance) {
      EventHubUtils.instance = new EventHubUtils();
    }
    return EventHubUtils.instance;
  }

  public emit(eventKey: EventEnum | string, ...args: Object[]) {
    this.eventHub.emit(eventKey, ...args);
  }

  public on(eventKey: EventEnum | string, callback: Function) {
    this.eventHub.on(eventKey, callback);
  }

  public off(eventKey: EventEnum | string, callback?: Function) {
    this.eventHub.off(eventKey, callback);
  }
}
