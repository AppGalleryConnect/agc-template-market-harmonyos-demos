import { preferences } from '@kit.ArkData';
import { UIAbility } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { window } from '@kit.ArkUI';
import { lang, util } from '@kit.ArkTS';


export class Preferences {
  static dataPreferences: preferences.Preferences | null = null

  static createPreferences(context: Context) {
    let options: preferences.Options = { name: 'myStore' };
    Preferences.dataPreferences = preferences.getPreferencesSync(context, options);
  }

  static writeData(key: string, value: boolean): boolean {
    if (Preferences.dataPreferences) {
      try {
        Preferences.dataPreferences.putSync(key, value);
      } catch (e) {
        console.error(`Failed to putSync. Code:${(e as BusinessError).code}, message:${(e as BusinessError).message}`);
      }
      try {
        Preferences.dataPreferences.flush((err: BusinessError) => {
          if (err) {
            console.error(`Failed to flush. Code:${err.code}, message:${err.message}`);
            return;
          }
          console.info('Succeeded in flushing.');
        })
      } catch (e) {
        console.error(`Failed to flush. Code:${(e as BusinessError).code}, message:${(e as BusinessError).message}`);
      }
      return true
    } else {
      return false
    }
  }

  static readData(key: string): boolean | undefined {
    let val = Preferences.dataPreferences?.getSync(key, true);
    if(val === true){
      return true
    }else{
      return false
    }
  }

  static updateData(key: string, value: boolean){
    let observer = (key: string) => {
      console.info('The key' + key + 'changed.');
    }
    try {
      Preferences.dataPreferences?.on('change', observer);
    } catch (e) {
      console.error(`Failed to register observer. Code:${(e as BusinessError).code}, message:${(e as BusinessError).message}`);
    }
    try {
      Preferences.dataPreferences?.put(key, value, (err: BusinessError) => {
        if (err) {
          console.error(`Failed to put the value of 'startup'. Code:${err.code},message:${err.message}`);
          return;
        }
        console.info("Succeeded in putting the value of 'startup'.");
        if (Preferences.dataPreferences !== null) {
          Preferences.dataPreferences.flush((err: BusinessError) => {
            if (err) {
              console.error(`Failed to flush. Code:${err.code}, message:${err.message}`);
              return;
            }
            console.info('Succeeded in flushing.');
          })
        }
      })
    } catch (e) {
      console.error(`Failed to put data. Code:${(e as BusinessError).code}, message:${(e as BusinessError).message}`);
    }
  }
}
