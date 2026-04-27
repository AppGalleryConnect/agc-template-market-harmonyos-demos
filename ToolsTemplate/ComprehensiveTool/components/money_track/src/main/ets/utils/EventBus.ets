import { common } from '@kit.AbilityKit';
import { contextUtil } from './ContextUtil';

export enum EventKey {
  GLOBAL_REFRESH_EVENT = 'globalRefreshEvent',
}

export class EventBus {
  private _eventHub: common.EventHub = (
    contextUtil.getContext() as common.UIAbilityContext
  ).eventHub;
  private static _instance: EventBus;

  public static get instance(): EventBus {
    if (!EventBus._instance) {
      EventBus._instance = new EventBus();
    }
    return EventBus._instance;
  }

  public emit(eventKey: EventKey | string, ...args: Object[]) {
    this._eventHub.emit(eventKey, ...args);
  }

  public on(eventKey: string, callback: Function) {
    this._eventHub.on(eventKey, callback);
  }

  public off(eventKey: string, callback?: Function) {
    this._eventHub.off(eventKey, callback);
  }
}
