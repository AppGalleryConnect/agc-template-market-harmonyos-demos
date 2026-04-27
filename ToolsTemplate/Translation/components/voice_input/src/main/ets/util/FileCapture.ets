/**
 * 文件流采集工具类
 * 用于流式读取音频文件并推送到ASR引擎
 */
import { fileIo } from '@kit.CoreFileKit';

const SEND_SIZE: number = 640; // 每次读取640字节

export class FileCapture {
  private mIsWriting: boolean = false;
  private mFilePath: string = '';
  private mFile: fileIo.File | null = null;
  private mIsReadFile: boolean = true;
  private mDataCallBack: ((data: ArrayBuffer) => void) | null = null;

  public setFilePath(filePath: string) {
    this.mFilePath = filePath;
  }

  async init(dataCallBack: (data: ArrayBuffer) => void): Promise<void> {
    if (this.mDataCallBack !== null) {
      return;
    }
    this.mDataCallBack = dataCallBack;
    if (!fileIo.accessSync(this.mFilePath)) {
      return;
    }
  }

  async start(): Promise<void> {
    try {
      if (this.mIsWriting || this.mDataCallBack === null) {
        return;
      }
      this.mIsWriting = true;
      this.mIsReadFile = true;
      this.mFile = fileIo.openSync(this.mFilePath, fileIo.OpenMode.READ_ONLY);
      const buf: ArrayBuffer = new ArrayBuffer(SEND_SIZE);
      let offset: number = 0;

      // 循环读取文件并推送数据
      while (SEND_SIZE === fileIo.readSync(this.mFile.fd, buf, {
        offset: offset,
      }) && this.mIsReadFile) {
        this.mDataCallBack(buf);
        await sleep(10); // 每10ms推送一次
        offset = offset + SEND_SIZE;
      }
    } catch (e) {
    } finally {
      this.mIsWriting = false;
      if (this.mFile !== null) {
        fileIo.closeSync(this.mFile);
      }
    }
  }

  stop() {
    if (!this.mDataCallBack) {
      return;
    }
    try {
      this.mIsReadFile = false;
    } catch (e) {
    }
  }

  release() {
    if (!this.mDataCallBack) {
      return;
    }
    try {
      this.mDataCallBack = null;
      this.mIsReadFile = false;
    } catch (e) {
    }
  }

  isIsWriting() {
    return this.mIsWriting;
  }
}

function sleep(ms: number): Promise<void> {
  return new Promise<void>((resolve) => {
    const timer = setTimeout(() => {
      clearTimeout(timer);
      resolve();
    }, ms);
  });
}
