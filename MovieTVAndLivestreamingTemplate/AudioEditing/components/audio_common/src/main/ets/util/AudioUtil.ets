import { picker } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'AudioUtil'

export class AudioUtil {
  static select(context: common.Context, callBack: (audioSelectResult: Array<string>) => void) {
    try {
      let audioSelectOptions = new picker.AudioSelectOptions();
      let audioPicker = new picker.AudioViewPicker(context);
      audioPicker.select(audioSelectOptions).then((audioSelectResult: Array<string>) => {
        callBack(audioSelectResult)
      }).catch((err: BusinessError) => {
      });
    } catch (error) {
      let err: BusinessError = error as BusinessError;
    }
  }

  static async save(context: common.Context, nameArr: string[]) {
    try {
      let audioSaveOptions = new picker.AudioSaveOptions();
      audioSaveOptions.newFileNames = nameArr;
      let audioPicker = new picker.AudioViewPicker(context);
      return await audioPicker.save(audioSaveOptions)
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      return []
    }
  }
}