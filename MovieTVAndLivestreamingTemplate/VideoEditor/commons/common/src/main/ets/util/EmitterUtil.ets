import emitter from '@ohos.events.emitter';

const TAG: string = 'EmitterUtil';

/**
 * 线程间通信
 */
export class EmitterUtil {
  static on<T>(eventId: string, callback: Callback<emitter.GenericEventData<T>>): void {
    try {
      emitter.on(eventId, callback);
    }catch (e) {
    }
  }

  static off<T>(eventId: string, callback: Callback<emitter.GenericEventData<T>>): void {
    try {
      emitter.off(eventId, callback);
    }catch (error) {
    }
  }

  static once<T>(eventId: string, callback: Callback<emitter.GenericEventData<T>>): void {
    try {
      emitter.once(eventId, callback);
    }catch (error) {
    }
  }

  static emit<T>(eventId: string, data?: emitter.GenericEventData<T>) {
    try {
      emitter.emit(eventId, data);
    }catch (error) {
    }
  }
}