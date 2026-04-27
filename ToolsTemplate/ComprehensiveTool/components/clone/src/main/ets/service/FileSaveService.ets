import { MessageEvents, worker } from '@kit.ArkTS';
import { WorkerMessageType } from '../common/Constant';
import { FileSaveVo } from '../model/FileSaveVo';
import { FileTransferCallback } from '../model/FileTransferCallback';
import { CloneFile, WorkerMessage } from '../model/WorkerMessage';
import { common } from '@kit.AbilityKit';
import { contact } from '@kit.ContactsKit';

export class FileSaveService {
  private fileWorker = new worker.ThreadWorker('../workers/FileWorker.ets');
  private callback: FileTransferCallback = {}
  public onCloneFile: (cloneFile: CloneFile) => void = () => {
  }

  constructor() {
    this.fileWorker.onmessage = (event: MessageEvents) => {
      const data = event.data as WorkerMessage;
      switch (data.type) {
        case WorkerMessageType.SAVE_FILE:
          this.handleSaveFileCallback(data.data as string)
          break;
        case WorkerMessageType.SEND_CLONE_FILE:
          this.onCloneFile(data.data as CloneFile)
          break;
        default:
          break;
      }
    }
  }

  saveFile(context: common.UIAbilityContext, fileSaveVo: FileSaveVo) {
    this.fileWorker.postMessage({
      type: WorkerMessageType.SAVE_FILE,
      data: fileSaveVo,
      context,
    } as WorkerMessage, [fileSaveVo.data])
  }

  saveContact(context: common.UIAbilityContext, list:contact.Contact[]){

  }

  getCloneFile(context: common.UIAbilityContext) {
    this.fileWorker.postMessage({
      type: WorkerMessageType.GET_CLONE_FILE,
      data: '',
      context,
    } as WorkerMessage)
  }

  private handleSaveFileCallback(data: string) {
    if (data === 'success') {
      if (this.callback.onSuccess) {
        this.callback.onSuccess()
      }
    } else {
      if (this.callback.onError) {
        this.callback.onError(data)
      }
    }
  }
}

export const fileSaveService = new FileSaveService()