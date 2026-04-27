import { ErrorEvent, MessageEvents, worker } from '@kit.ArkTS';
import { MP4Parser } from '@ohos/mp4parser';

// 创建 worker 线程端口
const workerPort = worker.workerPort;

// 使用命名类型，避免内联对象字面量类型
interface WorkerMsg {
  id: number;
  k: 'ffmpeg' | 'clip' | 'merge';
  cmd?: string;
  start?: string;
  end?: string;
  input?: string;
  output?: string;
  txt?: string;
  out?: string;
}

interface WorkerReply {
  id: number;
  code: number;
}

// 接收主线程消息（JSON 字符串），解析后执行对应任务
workerPort.onmessage = (e: MessageEvents): void => {
  let payload: string = e.data;
  let codeToSend = -1;
  try {
    const msg = JSON.parse(payload) as WorkerMsg;
    if (msg.k === 'ffmpeg') {
      const cmd = msg.cmd!;
      MP4Parser.ffmpegCmd(cmd, {
        callBackResult: (code: number) => {
          codeToSend = code;
          const reply: WorkerReply = { id: msg.id, code: codeToSend };
          workerPort.postMessage(JSON.stringify(reply));
        }
      });
      return;
    }
    if (msg.k === 'clip') {
      const start = msg.start!;
      const end = msg.end!;
      const input = msg.input!;
      const output = msg.output!;
      MP4Parser.videoClip(start, end, input, output, {
        callBackResult: (code: number) => {
          codeToSend = code;
          const reply: WorkerReply = { id: msg.id, code: codeToSend };
          workerPort.postMessage(JSON.stringify(reply));
        }
      });
      return;
    }
    if (msg.k === 'merge') {
      const txt = msg.txt!;
      const out = msg.out!;
      MP4Parser.videoMultMerge(txt, out, {
        callBackResult: (code: number) => {
          codeToSend = code;
          const reply: WorkerReply = { id: msg.id, code: codeToSend };
          workerPort.postMessage(JSON.stringify(reply));
        }
      });
      return;
    }
    // 未知任务类型
    const reply: WorkerReply = { id: msg.id, code: codeToSend };
    workerPort.postMessage(JSON.stringify(reply));
  } catch (err) {
    const fallback: WorkerReply = { id: -1, code: codeToSend };
    workerPort.postMessage(JSON.stringify(fallback));
  }
}

// worker 线程错误回调
workerPort.onerror = (err: ErrorEvent) => {}