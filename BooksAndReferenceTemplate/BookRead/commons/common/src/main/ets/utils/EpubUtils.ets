import { Constants } from '../constant/Constants';
import { GlobalContext } from '../comp/GlobalContext';
import { FileUtils } from './FileUtils';
import { fileIo } from '@kit.CoreFileKit';

export class EpubUtils {
  public static readEpubFile(filename: string, outputPath: string): string {
    // 本地调试使用，从 rawfile 文件中获取 epub 文件
    const filePath = filename + Constants.EPUB_FILE_SUFFIX;
    const rawByte: Uint8Array = GlobalContext.getContext().resourceManager.getRawFileContentSync(filePath);
    const zipname: string = filename + Constants.ZIP_FILE_SUFFIX;
    const inputPath: string = outputPath + Constants.FILE_SPLIT + zipname;
    const unZipPath: string = outputPath + Constants.FILE_SPLIT + filename + Constants.FILE_SPLIT;
    // 将文件写入沙箱
    FileUtils.writeFile(inputPath, rawByte.buffer);
    // 解压文件
    FileUtils.unzipFile(inputPath, unZipPath);
    return unZipPath;
  }

  public static async loadEpubFileFromNetwork(epubId: string, epubUrl: string, outputPath: string): Promise<string> {
    // 下载文件
    if (!fileIo.accessSync(outputPath)) {
      fileIo.mkdir(outputPath);
    }

    const zipname: string = epubId + Constants.ZIP_FILE_SUFFIX;
    const inputPath: string = outputPath + Constants.FILE_SPLIT + zipname;
    const unZipPath: string = outputPath + Constants.FILE_SPLIT + epubId + Constants.FILE_SPLIT;
    if (fileIo.accessSync(unZipPath)) {
      return unZipPath;
    } else {
      await FileUtils.downloadFile(epubUrl, inputPath);
      // 解压文件
      await FileUtils.unzipFile(inputPath, unZipPath);
    }
    return unZipPath
  }
}