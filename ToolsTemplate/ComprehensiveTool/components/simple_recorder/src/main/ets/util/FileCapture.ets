import { fileIo } from '@kit.CoreFileKit';
import { Logger } from '../util/Logger';

const TAG = 'FileCapture';
const SEND_SIZE: number = 640;

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
    Logger.error(TAG, 'init start ');
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
      let count = 0;
      while (SEND_SIZE === fileIo.readSync(this.mFile.fd, buf, {
        offset: offset,
      }) && this.mIsReadFile) {
        this.mDataCallBack(buf);
        ++count;
        await sleep(10);
        offset = offset + SEND_SIZE;
      }
    } catch (e) {
      Logger.error(TAG, 'read file error ' + e);
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
      Logger.error(TAG, 'read file error ' + e);
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
      Logger.error(TAG, 'read file error ' + e);
    }
  }

  isIsWriting() {
    return this.mIsWriting;
  }
}
;

function sleep(ms: number): Promise<void> {
  return new Promise<void>((resolve) => {
    const timer = setTimeout(() => {
      clearTimeout(timer);
      resolve();
    }, ms);
  });
}