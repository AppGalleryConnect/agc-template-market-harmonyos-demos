import { MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { WorkerMessageType } from '../common/Constant';
import { WorkerGet, WorkerMessage, WorkerSend } from '../model/ZipModel';
import { fileIo as fs } from '@kit.CoreFileKit';
import { Compress, Config7z, Uncompress } from '@ohos/oh7zip';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { reSave, writeToSandbox } from '../utils/CompressUtil';

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;

/**
 * Defines the event handler to be called when the worker thread receives a message sent by the host thread.
 * The event handler is executed in the worker thread.
 *
 * @param event message data
 */
workerPort.onmessage = (event: MessageEvents) => {
  let data = event.data as WorkerMessage;
  const workerSend = JSON.parse(data.data as string) as WorkerSend
  if (data.type === WorkerMessageType.COMPRESS) {
    workerCompress(workerSend)
  } else if (data.type === WorkerMessageType.DECOMPRESS) {
    workerDeCompress(workerSend)
  } else {
    reSave(workerSend.filePath!, workerSend.uris!)
  }
};

async function workerCompress(data: WorkerSend) {
  await writeToSandbox(data.sandboxFilePath!, data.documentSelectResult!);
  compress(data.sandboxFilePath!, data.filePath!, data.currentFolderPath!, data.name!)
}

async function workerDeCompress(data: WorkerSend) {
  await writeToSandbox(data.sandboxFilePath!, data.documentSelectResult!);
  decompress(data.filePath!, data.sandboxFilePath!, data.currentFolderPath!, data.name!)
}

// 压缩
function compress(inFile: string, dirPath: string, path: string, format: string) {
  let outFile = dirPath + `.${format}`
  fs.access(outFile).then((res: boolean) => {
    if (res) {
      outFile = dirPath + `(1).${format}`
    }
    let compress: Compress = new Compress()
    let config: Config7z = {
      src: inFile,
      dst: outFile,
      fmt: format,
    }
    compress.compressAsync(config).then((result) => {
      const workerGet: WorkerGet = {
        dirPath,
        path,
      }
      workerPort.postMessage({
        type: WorkerMessageType.COMPRESS,
        data: JSON.stringify(workerGet)
      } as WorkerMessage)
    })
  }).catch((err: BusinessError) => {
    UtilLog.info('compress error = ' + JSON.stringify(err));
  })
}

// 解压缩
function decompress(outFile: string, dirPath: string, currentFolderPath: string, name: string) {
  const inFile = dirPath + `/${decodeURI(name)}`
  let uncompress: Uncompress = new Uncompress()
  let config: Config7z = {
    src: inFile,
    dst: outFile,
    pwd: 'test_7z',
  }
  uncompress.extractAsync(config).then((result) => {
    const workerGet: WorkerGet = {
      dirPath: inFile,
      path: currentFolderPath,
    }
    workerPort.postMessage({
      type: WorkerMessageType.DECOMPRESS,
      data: JSON.stringify(workerGet)
    } as WorkerMessage)
  })
}