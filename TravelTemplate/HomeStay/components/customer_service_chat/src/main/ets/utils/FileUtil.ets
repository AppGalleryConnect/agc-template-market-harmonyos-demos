import { fileIo as fs } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = '[FileUtils]';

/**
 * 文件处理类
 */
export class FileUtils {
  /**
   * 写入沙箱
   * @param uri
   * @param path
   * @returns 沙箱文件对应的uri
   */
  static copyImg2Sandbox(uri: string, context: Context): string {
    if (!uri) {
      return '';
    }
    // 解决中文文件名乱码
    const fileUri = decodeURIComponent(uri);
    let fileName = fileUri.split('/').pop() as string;
    let fileType: string = fileName.split('.')[fileName.split('.').length - 1];
    // 时间戳
    let timestamp: string = Date.now().toString()
    const cacheFile = context.cacheDir + '/' + fileName.split(`.${fileType}`)[0] + '_' + timestamp + '.' + fileType;
    let srcFile: fs.File | null = null;
    let dstFile: fs.File | null = null;
    try {
      srcFile = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      dstFile = fs.openSync(cacheFile, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.copyFileSync(srcFile.fd, dstFile.fd);
      return 'file://' + cacheFile;
    } catch (err) {
      hilog.error(0x0000, TAG, `fs.copyFileSync failed, error code=${err.code}, message=${err.message}`);
      return uri;
    } finally {
      if (srcFile) {
        fs.closeSync(srcFile);
      }
      if (dstFile) {
        fs.closeSync(dstFile);
      }
    }
  }
}
