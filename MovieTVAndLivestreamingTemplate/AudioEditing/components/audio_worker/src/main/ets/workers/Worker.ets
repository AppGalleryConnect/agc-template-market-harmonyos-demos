import { ErrorEvent, MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { WorkersController } from '../../../../Index';
import { ACTION, AmpParamBody, MsgBody } from '../model/MsgModel';
import process from '@ohos.process'
import { fileIo } from '@kit.CoreFileKit';

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;
const TAG = 'workerPort'
/**
 * Defines the event handler to be called when the worker thread receives a message sent by the host thread.
 * The event handler is executed in the worker thread.
 *
 * @param event message data
 */

const maxBuffer: number = 100 * 1024 * 1024 //文件最大读取字节数
//跳帧系数，默认是1秒所包含的帧数大小的间隔
const SKIP_SECOND: number = 1
const maxTime: number = 60 * 60 //将波形图尺寸约束再60分钟以内

workerPort.onmessage = (event: MessageEvents) => {

  const msgBody = event.data as MsgBody
  switch (msgBody.action) {
    case ACTION.START:
      action(msgBody, 'onStart')
      break;
    case ACTION.END:
      //获取下一步执行函数
      let funcName: string =
        workerPort.callGlobalCallObjectMethod(msgBody.workerId.toString(), 'getNextAction', 100) as string

      //先恢复下一步执行函数，避免下一步执行函数结束后线程被杀死，无法恢复下一步执行函数
      workerPort.callGlobalCallObjectMethod(msgBody.workerId.toString(), 'resetTask', 100)
      //再调用下一步执行函数
      action(msgBody, funcName)
      break;
    case ACTION.COMPUTE_AMPLITUDES:
      computeAmplitudes(msgBody)
      break
    default:
      break;
  }
};

/**
 * Defines the event handler to be called when the worker receives a message that cannot be deserialized.
 * The event handler is executed in the worker thread.
 *
 * @param event message data
 */
workerPort.onmessageerror = (event: MessageEvents) => {
};

/**
 * Defines the event handler to be called when an exception occurs during worker execution.
 * The event handler is executed in the worker thread.
 *
 * @param event error message
 */
workerPort.onerror = (event: ErrorEvent) => {
};


//执行
function action(msgBody: MsgBody, funcName: string) {
  try {
    //此处为调用调用宿主线程函数，最大等待时间为5000ms，如果宿主线程函数超出此时间则会跳过此调用，
    //本业务后续可修改为分片渲染
    workerPort.callGlobalCallObjectMethod(msgBody.workerId.toString(), funcName, 5000)
    workerPort.postMessage({
      status: 0,
      msg: '任务调用执行成功',
      workerId: msgBody.workerId,
      acton: msgBody.action
    })
  } catch (error) {
    // 异常处理
    workerPort.postMessage({
      status: -1,
      msg: 'worker: error code is ' + error.code + ' error message is ' + error.message,
      workerId: msgBody.workerId,
    })
  }
}

/*
   * 从pcm文件中根据一定的跳帧规则获取一定数量的帧数组
   * 分片加载，解决内存申请过大崩溃的bug
   * MaxBuffer:每次读取的最大字节数
   * maxReadBuffer：最大读取字节数，
   *              用MaxBuffer相对每帧所占字节数的整数倍数，然后再乘以每帧所占字节数就可得到低于MaxBuffer的最大读取字节数，
   *              防止断帧
   */
function computeAmplitudes(msgBody: MsgBody) {
  const amplitudes: number[] = [];
  const paramStr = msgBody?.params || ''
  if (paramStr) {
    const params = JSON.parse(paramStr) as AmpParamBody
    let maxReadBuffer = Math.floor(maxBuffer / params.bytesPerFrame) * params.bytesPerFrame
    const size = params.size
    const allToatalFrames = size / params.bytesPerFrame //总共多少帧
    let skipFrames = SKIP_SECOND * params.sampleRate
    if (allToatalFrames > (maxTime * params.sampleRate)) {
      skipFrames = Math.floor(allToatalFrames / (maxTime * params.sampleRate)) * params.sampleRate
    }
    const file = fileIo.openSync(params.pcmPath)
    try {
      for (let i = 0; i < size; i = i + maxReadBuffer) {
        const leftSize = size - i //计算剩余字节数
        if (leftSize < maxReadBuffer) {
          maxReadBuffer = leftSize
        }

        const buffer = new ArrayBuffer(maxReadBuffer)
        fileIo.readSync(file.fd, buffer, { offset: i, length: maxReadBuffer })

        const dataView = new DataView(buffer)
        //计算总帧数
        const totalFrames = buffer.byteLength / params.bytesPerFrame

        // 3. 遍历每帧，解析所有声道并取平均振幅
        for (let frameIdx = 0; frameIdx < totalFrames; frameIdx += skipFrames) {
          const frameOffset = frameIdx * params.bytesPerFrame; // 当前帧的起始字节偏移
          let totalAmp = 0; // 所有声道的振幅总和

          // 循环读取当前帧内的所有声道
          for (let channelIdx = 0; channelIdx < params.channelLayout; channelIdx++) {
            // 计算当前声道在帧内的字节偏移：声道索引 × 每个采样点字节数
            const channelOffset = frameOffset + (channelIdx * params.bytesPerSample);

            // 读取当前声道的F32LE采样值（-1.0~1.0）
            const sample = dataView.getFloat32(channelOffset, true);
            // 累加当前声道的振幅（取绝对值，0~1）
            totalAmp += Math.abs(sample);
          }

          // 计算当前帧的平均振幅（总和 ÷ 声道数）
          const avgAmp = totalAmp / params.channelLayout;
          amplitudes.push(avgAmp);
        }

      }
    } catch (e) {
      fileIo.close(file.fd)
    } finally {
      fileIo.close(file.fd)
    }
  }

  workerPort.postMessage({
    status: 0,
    msg: '计算成功',
    workerId: msgBody.workerId,
    acton: msgBody.action,
    data: JSON.stringify(amplitudes)
  })

}