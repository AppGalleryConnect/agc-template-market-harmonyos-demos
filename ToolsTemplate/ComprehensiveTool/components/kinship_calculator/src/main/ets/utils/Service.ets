import { MessageEvents, worker } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';
import { WorkerDataMessage, WorkerMessage } from '../model/Worker';
import { setMapData } from './Map';
import { setCacheData } from './Cache';

export class FileService {
  private static fileWorker = new worker.ThreadWorker('../workers/FileWorker.ets')
  static context: common.UIAbilityContext | undefined = undefined

  static getFileData() {
    if (!FileService.context) {
      return
    }
    FileService.fileWorker.onmessage = (event: MessageEvents) => {
      const data = event.data as WorkerDataMessage
      setMapData(data.data)
      setCacheData(data.data)
    }

    FileService.fileWorker.postMessage({
      context: FileService.context,
    } as WorkerMessage)
  }
}