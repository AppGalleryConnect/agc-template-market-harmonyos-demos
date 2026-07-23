import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '@agctemplate/utils';

const TAG = 'TimeoutPersistence'

export interface TimeoutState {
  dramaId: string
  itemName: string
  expireTime: number
  isActive: boolean
  createdAt: number
}

export class TimeoutPersistence {
  private static preferences: preferences.Preferences | null = null

  static init(context: Context): void {
    if (!TimeoutPersistence.preferences) {
      let options: preferences.Options = { name: 'timeoutStore' }
      TimeoutPersistence.preferences = preferences.getPreferencesSync(context, options)
    }
  }

  private static getStorageKey(dramaId: string): string {
    return `timeout_${dramaId}`
  }

  static saveTimeoutState(dramaId: string, state: TimeoutState): void {
    if (!TimeoutPersistence.preferences) {
      Logger.error(TAG, 'Preferences not initialized')
      return
    }
    try {
      let stateJson = JSON.stringify(state)
      TimeoutPersistence.preferences.putSync(TimeoutPersistence.getStorageKey(dramaId), stateJson)
      TimeoutPersistence.preferences.flush((err: BusinessError) => {
        if (err) {
          Logger.error(TAG, `Failed to flush. Code: ${err.code}, message: ${err.message}`)
        }
      })
    } catch (error) {
      let errMsg = error instanceof Error ? error.message : String(error)
      Logger.error(TAG, `Failed to save timeout state: ${errMsg}`)
    }
  }

  static loadTimeoutState(dramaId: string): TimeoutState | null {
    if (!TimeoutPersistence.preferences) {
      Logger.error(TAG, 'Preferences not initialized')
      return null
    }
    try {
      let stateJson = TimeoutPersistence.preferences.getSync(TimeoutPersistence.getStorageKey(dramaId), '')
      if (typeof stateJson === 'string' && stateJson !== '') {
        let state = JSON.parse(stateJson) as TimeoutState
        if (state && typeof state.dramaId === 'string' && typeof state.expireTime === 'number') {
          return state
        }
      }
      return null
    } catch (error) {
      let errMsg = error instanceof Error ? error.message : String(error)
      Logger.error(TAG, `Failed to load timeout state: ${errMsg}`)
      TimeoutPersistence.clearTimeoutState(dramaId)
      return null
    }
  }

  static clearTimeoutState(dramaId: string): void {
    if (!TimeoutPersistence.preferences) {
      return
    }
    try {
      TimeoutPersistence.preferences.deleteSync(TimeoutPersistence.getStorageKey(dramaId))
      TimeoutPersistence.preferences.flush((err: BusinessError) => {
        if (err) {
          Logger.error(TAG, `Failed to flush after delete. Code: ${err.code}, message: ${err.message}`)
        }
      })
    } catch (error) {
      let errMsg = error instanceof Error ? error.message : String(error)
      Logger.error(TAG, `Failed to clear timeout state: ${errMsg}`)
    }
  }
}