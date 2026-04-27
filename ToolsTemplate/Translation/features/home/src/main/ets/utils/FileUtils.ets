/**
 * 文件操作工具类
 * 统一管理文件大小格式化、Base64转换等常用文件操作
 */
import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';
import { SecureRandomUtils } from 'common';

export class FileUtils {
  /**
   * 格式化字节数为可读的文件大小字符串
   */
  static formatBytes(bytes: number): string {
    if (bytes < 1024) {
      return bytes + 'B';
    } else if (bytes < 1024 * 1024) {
      return (bytes / 1024).toFixed(1) + 'KB';
    } else {
      return (bytes / (1024 * 1024)).toFixed(1) + 'MB';
    }
  }

  /**
   * 读取文件并转换为Base64字符串
   */
  static async readFileAsBase64(uri: string, context?: common.UIAbilityContext): Promise<string> {
    // 先确定要读取的文件路径
    let filePath = uri;
    let needCleanup = false;

    // 检查是否需要复制到缓存
    try {
      fs.accessSync(uri);
    } catch (e) {
      // 文件无法直接访问，需要复制到缓存
      if (!context) {
        throw new Error('无法打开文件，且未提供上下文用于缓存');
      }
      filePath = await FileUtils.copyToCache(uri, context, 'temp_file_' + new Date().getTime());
      needCleanup = true;
    }

    // 读取文件
    let file: fs.File | undefined;
    try {
      file = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
      const stat = fs.statSync(file.fd);
      const buffer = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, buffer);

      // 转换为Base64
      const base64Helper = new util.Base64Helper();
      const uint8Array = new Uint8Array(buffer);
      return base64Helper.encodeToStringSync(uint8Array);
    } catch (error) {
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error(`读取文件为Base64失败: ${JSON.stringify(error)}`);
      }
    } finally {
      if (file) {
        try {
          fs.closeSync(file);
        } catch (e) {
          // 忽略关闭文件时的错误
        }
      }
      // 清理临时文件
      if (needCleanup) {
        FileUtils.safeDeleteFile(filePath);
      }
    }
  }

  /**
   * 复制文件到缓存目录
   */
  static async copyToCache(
    uri: string,
    context: common.UIAbilityContext,
    fileName?: string
  ): Promise<string> {
    let srcFile: fs.File | undefined;
    try {
      const cacheDir = context.cacheDir;
      // 使用安全随机数生成文件名
      const randomNum = SecureRandomUtils.getRandomNumber(10000);
      const targetFileName = fileName || `temp_${Date.now()}_${Math.floor(randomNum)}`;
      const cachePath = `${cacheDir}/${targetFileName}`;

      // 打开源文件并复制
      srcFile = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      fs.copyFileSync(srcFile.fd, cachePath);

      return cachePath;
    } catch (error) {
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error(`复制文件到缓存失败: ${JSON.stringify(error)}`);
      }
    } finally {
      if (srcFile) {
        try {
          fs.closeSync(srcFile);
        } catch (e) {
          // 忽略关闭文件时的错误
        }
      }
    }
  }

  /**
   * 获取文件大小（字节数）
   */
  static getFileSize(uri: string): number {
    let file: fs.File | undefined;
    try {
      file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      const stat = fs.statSync(file.fd);
      return stat.size;
    } catch (error) {
      throw new Error(`获取文件大小失败: ${JSON.stringify(error)}`);
    } finally {
      if (file) {
        try {
          fs.closeSync(file);
        } catch (e) {
          // 忽略关闭文件时的错误
        }
      }
    }
  }

  /**
   * 获取文件扩展名
   */
  static getFileExtension(fileName: string): string {
    if (!fileName) {
      return '';
    }

    const lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex === -1 || lastDotIndex === fileName.length - 1) {
      return '';
    }

    return fileName.substring(lastDotIndex).toLowerCase();
  }

  /**
   * 检查文件是否存在
   */
  static fileExists(path: string): boolean {
    try {
      fs.accessSync(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  /**
   * 删除文件（安全删除，不抛出异常）
   */
  static safeDeleteFile(path: string): boolean {
    try {
      if (FileUtils.fileExists(path)) {
        fs.unlinkSync(path);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /**
   * 清理缓存目录中的临时文件
   */
  static cleanTempFiles(context: common.UIAbilityContext, prefix: string): number {
    try {
      const cacheDir = context.cacheDir;
      const files = fs.listFileSync(cacheDir);
      let deletedCount = 0;

      for (const file of files) {
        if (file.startsWith(prefix)) {
          const filePath = `${cacheDir}/${file}`;
          if (FileUtils.safeDeleteFile(filePath)) {
            deletedCount++;
          }
        }
      }

      return deletedCount;
    } catch (e) {
      return 0;
    }
  }
}
