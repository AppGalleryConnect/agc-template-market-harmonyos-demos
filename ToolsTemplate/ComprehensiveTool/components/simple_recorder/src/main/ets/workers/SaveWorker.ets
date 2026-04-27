import {  MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { extractToPCM } from '../util/ConvertUtil';
import { SaveWorkerParm } from '../model/Index';


const workerPort: ThreadWorkerGlobalScope = worker.workerPort;


workerPort.onmessage = (event: MessageEvents) => {
  const parm = event.data as SaveWorkerParm;
  extractToPCM(parm.filePath, parm.pcmPath).then(() => {
    workerPort.postMessage('0');
  })
    .catch(() => {
      workerPort.postMessage('1');
    });
};






