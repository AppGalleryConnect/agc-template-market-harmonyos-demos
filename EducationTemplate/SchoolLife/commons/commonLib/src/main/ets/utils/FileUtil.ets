import fs from '@ohos.file.fs';
import { BusinessError } from '@kit.BasicServicesKit';
import hilog from '@ohos.hilog';

class FileUtil {
  public readonly USER_IMAGE = 'USER_IMAGE.jpg';

  public async copyFile(srcFilePath: string, newFileName: string): Promise<string | undefined> {
    let file: fs.File = null!;
    try {
      file = fs.openSync(srcFilePath, fs.OpenMode.READ_ONLY);
      let imagePath = `${getContext().filesDir}/${newFileName}`;
      fs.copyFileSync(file.fd, imagePath);
      return 'file://' + imagePath;
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      hilog.error(0x0000, 'FileUtil', 'Failed to copy file, error: ', err.message);
      return undefined;
    } finally {
      fs.closeSync(file);
    }
  }
}

const fileUtil = new FileUtil();
export { fileUtil as FileUtil };