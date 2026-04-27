/**
 * 文件：feature/src/main/ets/utils/StreamFileReader.ets
 * 流式文件读取器
 * 解决大文件一次性加载导致的内存溢出问题
 * 采用分片流式读取，避免将整个文件加载到内存中
 */

import { fileIo } from '@kit.CoreFileKit';
import { ChunkItem } from '../model/ChunkItem';
import { FileChunk } from '../model/FileChunk';
import { FileVo } from '../model/FileVo';

/**
 * 流式文件读取器类
 * 提供分片读取大文件的能力，避免内存溢出
 */
export class FileReaderService {
  private file: fileIo.File | null = null;
  private fileSize: number = 0;
  private currentPosition: number = 0;
  private chunkSize: number;
  private totalChunks: number = 0; // 总分片数
  private currentChunkIndex: number = 0;

  /**
   * 构造函数
   * @param chunkSize 分片大小，默认1MB
   */
  constructor(chunkSize: number = 1024 * 1024) {
    this.chunkSize = chunkSize;
  }

  /**
   * 打开文件进行流式读取
   * @param fileVo 文件信息对象
   * @returns Promise<boolean> 是否成功打开文件
   * @throws Error 文件打开失败时抛出异常
   */
  openFile(fileVo: FileVo) {
    try {
      // 打开文件
      this.file = fileIo.openSync(fileVo.uri, fileIo.OpenMode.READ_ONLY);

      // 获取文件大小
      const stat = fileIo.statSync(this.file.fd);
      this.fileSize = stat.size;

      // 计算总分片数
      this.totalChunks = Math.ceil(this.fileSize / this.chunkSize);

      // 重置读取位置
      this.currentPosition = 0;
      this.currentChunkIndex = 0;
      return true;
    } catch (error) {
      console.error('打开文件失败:', error);
      this.closeFile();
      throw new Error(`文件打开失败: ${error}`);
    }
  }

  /**
   * 读取下一个文件分片
   * @returns Promise<FileChunk | null> 文件分片数据，如果已读取完毕则返回null
   * @throws Error 读取失败时抛出异常
   */
  readNextChunk(): ChunkItem | null {
    if (!this.file || this.currentPosition >= this.fileSize) {
      return null;
    }

    try {
      // 计算当前分片的实际大小
      const remainingBytes = this.fileSize - this.currentPosition;
      const actualChunkSize = Math.min(this.chunkSize, remainingBytes);

      // 创建缓冲区
      const buffer = new ArrayBuffer(actualChunkSize);


      const bytesRead = fileIo.readSync(this.file.fd, buffer, {
        offset: this.currentPosition,
        length: actualChunkSize,
      });

      if (bytesRead !== actualChunkSize) {
        throw new Error(`读取字节数不匹配: 期望 ${actualChunkSize}, 实际 ${bytesRead}`);
      }

      // 更新读取位置
      this.currentPosition += bytesRead;

      // 创建分片对象
      const chunk: ChunkItem = {
        index: this.currentChunkIndex,
        data: buffer,
        size: bytesRead,
        isLast: this.currentPosition >= this.fileSize,
      };

      this.currentChunkIndex++;

      return chunk;
    } catch (error) {
      console.error('读取文件分片失败:', error);
      throw new Error(`读取文件分片失败: ${error}`);
    }
  }

  /**
   * 读取指定索引的文件分片
   * @param chunkIndex 分片索引
   * @returns Promise<FileChunk | null> 文件分片数据
   * @throws Error 读取失败时抛出异常
   */
  async readChunkByIndex(chunkIndex: number): Promise<ChunkItem | null> {
    if (!this.file || chunkIndex < 0 || chunkIndex >= this.totalChunks) {
      return null;
    }

    try {
      // 计算分片的起始位置
      const startPosition = chunkIndex * this.chunkSize;
      const remainingBytes = this.fileSize - startPosition;
      const actualChunkSize = Math.min(this.chunkSize, remainingBytes);

      // 创建缓冲区
      const buffer = new ArrayBuffer(actualChunkSize);

      const bytesRead = fileIo.readSync(this.file.fd, buffer, {
        offset: this.currentPosition,
        length: actualChunkSize,
      });

      if (bytesRead !== actualChunkSize) {
        throw new Error(`读取字节数不匹配: 期望 ${actualChunkSize}, 实际 ${bytesRead}`);
      }

      // 创建分片对象
      const chunk: ChunkItem = {
        index: chunkIndex,
        data: buffer,
        size: bytesRead,
        isLast: startPosition + bytesRead >= this.fileSize,
      };

      console.log(`随机读取分片 ${chunk.index + 1}/${this.totalChunks}, 大小: ${chunk.size} bytes`);

      return chunk;
    } catch (error) {
      console.error('读取指定分片失败:', error);
      throw new Error(`读取指定分片失败: ${error}`);
    }
  }

  /**
   * 获取文件信息
   * @returns 文件信息对象
   */
  getFileInfo(): FileChunk {
    return {
      fileSize: this.fileSize,
      totalChunks: this.totalChunks,
      chunkSize: this.chunkSize,
      currentPosition: this.currentPosition,
    };
  }

  /**
   * 重置读取位置到文件开头
   */
  reset(): void {
    this.currentPosition = 0;
    this.currentChunkIndex = 0;
  }

  /**
   * 检查是否还有更多分片可读取
   * @returns boolean 是否还有更多分片
   */
  hasMoreChunks(): boolean {
    return this.currentPosition < this.fileSize;
  }

  /**
   * 关闭文件
   */
  closeFile(): void {
    if (this.file) {
      try {
        fileIo.closeSync(this.file.fd);
      } catch (error) {
        console.error('关闭文件失败:', error);
      } finally {
        this.file = null;
        this.fileSize = 0;
        this.currentPosition = 0;
        this.totalChunks = 0;
        this.currentChunkIndex = 0;
      }
    }
  }

  /**
   * 析构函数，确保文件被正确关闭
   */
  destroy(): void {
    this.closeFile();
  }
}

