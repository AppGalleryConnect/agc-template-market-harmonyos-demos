import { fileIo } from '@kit.CoreFileKit';
import { BusinessError, zlib } from '@kit.BasicServicesKit';

import { util } from '@kit.ArkTS';

import { rcp } from '@kit.RemoteCommunicationKit';
import { GlobalContext } from '../comp/GlobalContext';
import { TCLogger } from '../comp/TCLogger';

const ZIP_OPTIONS: zlib.Options = {
  level: zlib.CompressLevel.COMPRESS_LEVEL_DEFAULT_COMPRESSION
};

/**
 * 文件操作
 */
export class FileUtils {
  public static writeFile(path: string, data: ArrayBuffer | string) {
    try {
      let file = fileIo.openSync(path, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
      fileIo.writeSync(file.fd, data);
    } catch (e) {
      TCLogger.error('failed to write file');
    }
  }

  public static copyFile(src: string, dst: string) {
    try {
      let srcFile = fileIo.openSync(src, fileIo.OpenMode.READ_WRITE);
      let dstFile = fileIo.openSync(dst, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
      fileIo.copyFile(srcFile.fd, dstFile.fd);
    } catch (e) {
      TCLogger.error('failed to copy file');
    }
  }

  public static readRawfile(path: string): string {
    const rawByte: Uint8Array = GlobalContext.getContext().resourceManager.getRawFileContentSync(path);
    return FileUtils.uint8ArrayToString(rawByte);
  }

  public static async unzipFile(inputPath: string, outPutPath: string): Promise<void> {
    if (!fileIo.accessSync(outPutPath)) {
      fileIo.mkdirSync(outPutPath);
    }

    try {
      await zlib.decompressFile(inputPath, outPutPath, ZIP_OPTIONS)
    } catch (errData) {
      TCLogger.error('failed to unzip file');
    }
  }

  // 字节流转成可理解的字符串
  public static uint8ArrayToString(array: Uint8Array): string {
    let textDecoderOptions: util.TextDecoderOptions = {
      fatal: false,
      ignoreBOM: true
    }
    let decodeToStringOptions: util.DecodeToStringOptions = {
      stream: false
    }
    let textDecoder = util.TextDecoder.create('utf-8', textDecoderOptions);
    let retStr = textDecoder.decodeToString(array, decodeToStringOptions);
    return retStr;
  }

  public static async downloadFile(url: string, localPath: string) {
    // 创建下载目录
    if (!fileIo.accessSync(localPath)) {
      fileIo.openSync(localPath, fileIo.OpenMode.CREATE);
    }

    let downloadToFile: rcp.DownloadToFile = {
      kind: 'file',
      file: localPath
    }

    const fd = fileIo.openSync(localPath, fileIo.OpenMode.READ_WRITE);
    try {
      // 创建一个HTTP会话，其中请求配置包括传输超时设置和安全配置（配置可自定义）
      const session = rcp.createSession({
        requestConfiguration: {
          transfer: { timeout: { connectMs: 10000, transferMs: 10000, inactivityMs: 10000 } },
        }
      });
      const rsp: rcp.Response = await session.downloadToFile(url, downloadToFile);
      fileIo.closeSync(fd);
      TCLogger.info(`Succeeded in getting the response ${rsp}`)
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      TCLogger.error(`Invoke downloadFile failed, code is ${err.code}, message is ${err.message}`);
    }
  }
}