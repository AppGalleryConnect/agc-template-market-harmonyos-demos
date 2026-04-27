/**
 * 图片翻译辅助工具类
 */
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { CameraTranslateViewModel } from '../viewmodel/CameraTranslateViewModel';
import { TranslateDetailViewModel } from '../viewmodel/TranslateDetailViewModel';
import { phoneRouterControl } from 'oh_router';
import { RouterMap } from 'common';
import { TranslateDetailPageBuilder } from '../views/TranslateDetailPage';

export class ImageTranslateHelper {
  // 翻译图片
  static async translateImage(
    imageUri: string,
    sourceLanguage: string,
    targetLanguage: string,
    vm: CameraTranslateViewModel
  ): Promise<void> {
    try {
      // 解析图片路径
      const actualImagePath = await ImageTranslateHelper.resolveImagePath(imageUri);

      // 读取图片数据
      const buffer = ImageTranslateHelper.readImageFile(actualImagePath);

      // 压缩图片（如果需要）
      const finalBuffer = await ImageTranslateHelper.compressImageIfNeeded(buffer, actualImagePath);

      // 执行翻译
      const success = await vm.translateImage(finalBuffer, actualImagePath, sourceLanguage, targetLanguage);

      if (success) {
        ImageTranslateHelper.handleTranslateSuccess(vm, finalBuffer, actualImagePath, sourceLanguage, targetLanguage);
      } else {
        ImageTranslateHelper.handleTranslateError(vm.errorMessage);
      }
    } catch (error) {
      const errorMsg = (error as BusinessError);
      promptAction.showToast({
        message: `读取图片失败: ${errorMsg.message || '未知错误'}, code: ${errorMsg.code || 'N/A'}`
      });
    }
  }

  // 解析图片路径
  private static async resolveImagePath(imageUri: string): Promise<string> {
    let actualImagePath = imageUri;

    // 如果是file URI，转换为路径
    if (actualImagePath.startsWith('file://')) {
      actualImagePath = new fileUri.FileUri(actualImagePath).path;
    }

    // 检查是否是目录
    const stat = fileIo.statSync(actualImagePath);
    if (stat.isDirectory()) {
      const foundImagePath = await ImageTranslateHelper.findImageInDirectory(imageUri);
      if (foundImagePath) {
        return foundImagePath;
      }
      throw new Error('目录中没有找到图片文件');
    }

    return actualImagePath;
  }

  // 递归查找目录中的图片文件
  private static async findImageInDirectory(dirPath: string, depth: number = 0): Promise<string | null> {
    if (depth > 3) {
      return null;
    }

    const files: string[] = await fileIo.listFile(dirPath);

    // 先查找图片文件
    for (const fileName of files) {
      const fullPath = dirPath + '/' + fileName;
      const lowerName = fileName.toLowerCase();

      if (lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg') || lowerName.endsWith('.png')) {
        return fullPath;
      }
    }

    // 递归查找子目录
    for (const fileName of files) {
      const fullPath = dirPath + '/' + fileName;
      try {
        const fileStat = fileIo.statSync(fullPath);
        if (fileStat.isDirectory()) {
          const result = await ImageTranslateHelper.findImageInDirectory(fullPath, depth + 1);
          if (result) {
            return result;
          }
        }
      } catch (e) {
        // 忽略访问错误
      }
    }

    return null;
  }

  // 读取图片文件
  private static readImageFile(imagePath: string): ArrayBuffer {
    let file: fileIo.File | undefined;
    try {
      file = fileIo.openSync(imagePath, fileIo.OpenMode.READ_ONLY);
      const fileStat = fileIo.statSync(file.fd);

      if (fileStat.size === 0) {
        throw new Error('图片文件为空');
      }

      const buffer = new ArrayBuffer(fileStat.size);
      const readLen = fileIo.readSync(file.fd, buffer);

      if (readLen === 0) {
        throw new Error('读取图片失败');
      }

      return buffer;
    } finally {
      if (file) {
        fileIo.closeSync(file);
      }
    }
  }

  // 压缩图片（如果需要）
  private static async compressImageIfNeeded(buffer: ArrayBuffer, imagePath: string): Promise<ArrayBuffer> {
    const maxSize = 1 * 1024 * 1024; // 1MB
    if (buffer.byteLength <= maxSize) {
      return buffer;
    }

    try {
      const compressedBuffer = await ImageTranslateHelper.compressImage(buffer);
      ImageTranslateHelper.saveCompressedImage(compressedBuffer, imagePath);
      return compressedBuffer;
    } catch (e) {
      return buffer;
    }
  }

  // 压缩图片
  private static async compressImage(buffer: ArrayBuffer): Promise<ArrayBuffer> {
    try {
      const imageSource = image.createImageSource(buffer);
      const imageInfo = await imageSource.getImageInfo();

      // 计算缩放后的尺寸（最大2048px）
      const maxDimension = 2048;
      let targetWidth = imageInfo.size.width;
      let targetHeight = imageInfo.size.height;

      if (targetWidth > maxDimension || targetHeight > maxDimension) {
        const scale = Math.min(maxDimension / targetWidth, maxDimension / targetHeight);
        targetWidth = Math.floor(targetWidth * scale);
        targetHeight = Math.floor(targetHeight * scale);
      }

      // 创建缩放后的PixelMap
      const decodingOptions: image.DecodingOptions = {
        desiredSize: { width: targetWidth, height: targetHeight },
        desiredPixelFormat: 3
      };
      const pixelMap = await imageSource.createPixelMap(decodingOptions);

      // 压缩
      const packingOpt: image.PackingOption = { format: 'image/jpeg', quality: 50 };
      const imagePacker = image.createImagePacker();
      const compressedData = await imagePacker.packToData(pixelMap, packingOpt);

      pixelMap.release();
      return compressedData;
    } catch (err) {
      return buffer;
    }
  }

  // 保存压缩后的图片
  private static saveCompressedImage(buffer: ArrayBuffer, imagePath: string): void {
    let compressedFile: fileIo.File | undefined;
    try {
      compressedFile = fileIo.openSync(imagePath, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.TRUNC);
      fileIo.writeSync(compressedFile.fd, buffer);
    } catch (e) {
      // 忽略写入错误
    } finally {
      if (compressedFile) {
        fileIo.closeSync(compressedFile);
      }
    }
  }

  // 处理翻译成功
  private static handleTranslateSuccess(
    vm: CameraTranslateViewModel,
    finalBuffer: ArrayBuffer,
    actualImagePath: string,
    sourceLanguage: string,
    targetLanguage: string
  ): void {
    const actualSourceLang = vm.detectedSourceLanguage || sourceLanguage;
    const actualTargetLang = vm.actualTargetLanguage || targetLanguage;

    // 更新翻译详情数据
    TranslateDetailViewModel.instance.updateDetail({
      sourceLanguageName: ImageTranslateHelper.getLanguageName(actualSourceLang),
      targetLanguageName: ImageTranslateHelper.getLanguageName(actualTargetLang),
      sourceText: vm.recognizedText,
      translatedText: vm.translatedText,
      imageBuffer: finalBuffer,
      imagePath: actualImagePath,
      sourceLanguageCode: actualSourceLang,
      targetLanguageCode: actualTargetLang
    });

    // 设置重新翻译的回调函数
    ImageTranslateHelper.setupRetranslateCallback(vm, finalBuffer, actualImagePath);

    // 跳转到详情页
    phoneRouterControl.jumpPage({
      pageName: RouterMap.TRANSLATE_DETAIL_PAGE,
      builder: wrapBuilder(TranslateDetailPageBuilder)
    });
  }

  // 设置重新翻译回调
  private static setupRetranslateCallback(
    vm: CameraTranslateViewModel,
    finalBuffer: ArrayBuffer,
    actualImagePath: string
  ): void {
    TranslateDetailViewModel.instance.onRetranslate = async (sourceLang: string, targetLang: string) => {
      const retranslateSuccess = await vm.translateImage(finalBuffer, actualImagePath, sourceLang, targetLang);

      if (retranslateSuccess) {
        const retranslateActualSourceLang = vm.detectedSourceLanguage || sourceLang;
        const retranslateActualTargetLang = vm.actualTargetLanguage || targetLang;

        TranslateDetailViewModel.instance.updateDetail({
          sourceLanguageName: ImageTranslateHelper.getLanguageName(retranslateActualSourceLang),
          targetLanguageName: ImageTranslateHelper.getLanguageName(retranslateActualTargetLang),
          sourceText: vm.recognizedText,
          translatedText: vm.translatedText,
          imageBuffer: finalBuffer,
          imagePath: actualImagePath,
          sourceLanguageCode: retranslateActualSourceLang,
          targetLanguageCode: retranslateActualTargetLang
        });
      }
    };
  }

  // 处理翻译错误
  private static handleTranslateError(errorMessage: string): void {
    let errorMsg = errorMessage || '翻译失败';
    if (errorMsg.includes('Timeout') || errorMsg.includes('timeout')) {
      errorMsg = '网络请求超时，请检查网络连接后重试';
    }
    promptAction.showToast({
      message: errorMsg,
      duration: 3000
    });
  }

  // 获取语言名称
  static getLanguageName(code: string): string {
    const languageMap: Record<string, string> = {
      'zh': '中文',
      'en': '英文'
    };
    return languageMap[code] || code;
  }
}
