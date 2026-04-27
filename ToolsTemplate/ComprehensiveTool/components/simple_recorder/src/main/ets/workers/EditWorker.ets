import { MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { MultipleWorkerParm } from '../model/Index';
import { multipleAudio } from '../util/ConvertUtil';

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;

workerPort.onmessage = (event: MessageEvents) => {
  const parm = event.data as MultipleWorkerParm;
  multipleAudio(parm.inputPath, parm.outputPath, parm.speed, parm.format, (code: number) => {
    workerPort.postMessage(code);
  });
};

