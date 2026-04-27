import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';
import zlib from '@ohos.zlib';
import { BusinessError } from '@kit.BasicServicesKit';
import { HtmlEntityDecoder } from './HtmlEntityDecoder';
import { SecureRandomUtils } from 'common';

interface CopyUriResult {
  actualFilePath: string;
  tempFilePath: string | null;
}

export class DocumentTextExtractor {
  /**
   * 从PDF提取文本
   */
  static async extractFromPdf(_filePath: string): Promise<string> {
    throw new Error('PDF_TEXT_EXTRACTION_NOT_SUPPORTED');
  }

  /**
   * 从DOCX提取文本
   */
  static async extractFromDocx(filePath: string, cacheDir: string): Promise<string> {
    let xmlFile: fs.File | null = null;
    let tempFilePath: string | null = null;
    try {
      const randomNum = SecureRandomUtils.getRandomNumber(10000);
      const extractDir = DocumentTextExtractor.createExtractDir(cacheDir, randomNum);

      // 如果是URI格式，先复制到缓存目录
      const copyResult = DocumentTextExtractor.copyUriFileIfNeeded(filePath, cacheDir, randomNum);
      tempFilePath = copyResult.tempFilePath;
      const actualFilePath = copyResult.actualFilePath;

      // 解压并查找document.xml
      await DocumentTextExtractor.decompressDocx(actualFilePath, extractDir);
      const documentXmlPath = DocumentTextExtractor.findDocumentXml(extractDir);

      // 读取并解析XML
      xmlFile = fs.openSync(documentXmlPath, fs.OpenMode.READ_ONLY);
      const xmlContent = DocumentTextExtractor.readXmlContent(xmlFile);
      const extractedText = DocumentTextExtractor.extractTextFromXml(xmlContent);

      return DocumentTextExtractor.formatExtractedText(extractedText);
    } catch (error) {
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error(`Extract text failed: ${JSON.stringify(error)}`);
      }
    } finally {
      DocumentTextExtractor.cleanupResources(xmlFile, tempFilePath);
    }
  }

  // 创建解压目录
  private static createExtractDir(cacheDir: string, randomNum: number): string {
    const extractDir = `${cacheDir}/extract_${Date.now()}_${Math.floor(randomNum)}`;
    try {
      fs.mkdirSync(extractDir);
    } catch (e) {
      throw new Error('Failed to create extract directory');
    }
    return extractDir;
  }

  // 如果是URI格式，复制文件到缓存目录
  private static copyUriFileIfNeeded(
    filePath: string,
    cacheDir: string,
    randomNum: number
  ): CopyUriResult {
    const needsCopy = filePath.startsWith('file://') ||
    filePath.startsWith('content://') ||
    filePath.includes('docs/storage');

    if (!needsCopy) {
      const result: CopyUriResult = { actualFilePath: filePath, tempFilePath: null };
      return result;
    }

    const tempPath = `${cacheDir}/temp_docx_${Date.now()}_${Math.floor(randomNum)}.docx`;
    DocumentTextExtractor.copyFile(filePath, tempPath);
    const result: CopyUriResult = { actualFilePath: tempPath, tempFilePath: tempPath };
    return result;
  }

  // 复制文件
  private static copyFile(srcPath: string, destPath: string): void {
    let srcFile: fs.File | undefined;
    let destFile: fs.File | undefined;
    try {
      srcFile = fs.openSync(srcPath, fs.OpenMode.READ_ONLY);
      const stat = fs.statSync(srcFile.fd);
      const buffer = new ArrayBuffer(stat.size);
      fs.readSync(srcFile.fd, buffer);

      destFile = fs.openSync(destPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.writeSync(destFile.fd, buffer);
    } finally {
      if (srcFile) {
        try {
          fs.closeSync(srcFile);
        } catch (e) {
        }
      }
      if (destFile) {
        try {
          fs.closeSync(destFile);
        } catch (e) {
        }
      }
    }
  }

  // 查找document.xml文件
  private static findDocumentXml(extractDir: string): string {
    const documentXmlPath = DocumentTextExtractor.findFileRecursively(extractDir, 'document.xml');
    if (!documentXmlPath) {
      throw new Error('document.xml not found');
    }
    if (!fs.accessSync(documentXmlPath)) {
      throw new Error('document.xml not accessible');
    }
    return documentXmlPath;
  }

  // 读取XML文件内容
  private static readXmlContent(xmlFile: fs.File): string {
    const stat = fs.statSync(xmlFile.fd);
    const buffer = new ArrayBuffer(stat.size);
    fs.readSync(xmlFile.fd, buffer);

    const decoder = util.TextDecoder.create('utf-8');
    return decoder.decodeToString(new Uint8Array(buffer), { stream: false });
  }

  // 格式化提取的文本
  private static formatExtractedText(extractedText: string): string {
    if (extractedText.length === 0) {
      throw new Error('No text extracted');
    }
    return extractedText;
  }

  // 清理资源
  private static cleanupResources(xmlFile: fs.File | null, tempFilePath: string | null): void {
    if (xmlFile) {
      try {
        fs.closeSync(xmlFile);
      } catch (e) {
      }
    }
    if (tempFilePath) {
      try {
        fs.unlinkSync(tempFilePath);
      } catch (e) {
      }
    }
  }

  private static extractTextFromXml(xmlContent: string): string {
    // 使用更宽松的正则匹配 <w:t> 标签，支持各种属性格式
    // 例如: <w:t>, <w:t xml:space="preserve">, <w:t/> 等
    let textMatches = xmlContent.match(/<w:t(?:\s[^>]*)?>([^<]*)<\/w:t>/g);
    if (!textMatches || textMatches.length === 0) {
      // 尝试匹配自闭合标签或其他格式
      textMatches = xmlContent.match(/<w:t[^>]*>[\s\S]*?<\/w:t>/g);
    }
    if (!textMatches || textMatches.length === 0) {
      return '';
    }

    // 按段落提取文本，保持段落结构
    const paragraphs = xmlContent.match(/<w:p(?:\s[^>]*)?>[\s\S]*?<\/w:p>/g);
    let extractedText = '';

    if (paragraphs && paragraphs.length > 0) {
      for (let para of paragraphs) {
        // 提取段落内所有 <w:t> 标签的文本
        const paraTexts = para.match(/<w:t(?:\s[^>]*)?>([^<]*)<\/w:t>/g);
        if (paraTexts && paraTexts.length > 0) {
          let paraText = paraTexts
            .map(t => {
              // 移除开始和结束标签，只保留文本内容
              const textContent = t.replace(/<w:t(?:\s[^>]*)?>/g, '').replace(/<\/w:t>/g, '');
              return textContent;
            })
            .join('');
          paraText = HtmlEntityDecoder.decode(paraText).trim();
          if (paraText.length > 0) {
            extractedText += paraText + '\n\n';
          }
        }
      }
    } else {
      // 如果没有段落标签，直接提取所有文本
      let textParts: string[] = [];
      for (let match of textMatches) {
        let text = match.replace(/<w:t(?:\s[^>]*)?>/g, '').replace(/<\/w:t>/g, '');
        text = HtmlEntityDecoder.decode(text);
        if (text.trim().length > 0) {
          textParts.push(text);
        }
      }
      extractedText = textParts.join(' ');
    }
    return extractedText.trim();
  }

  private static async decompressDocx(zipFilePath: string, outputDir: string): Promise<void> {
    return new Promise((resolve, reject) => {
      const options: zlib.Options = {
        level: zlib.CompressLevel.COMPRESS_LEVEL_DEFAULT_COMPRESSION
      };
      try {
        zlib.decompressFile(zipFilePath, outputDir, options, (errData: BusinessError) => {
          if (errData) {
            reject(new Error(`Decompress failed: ${errData.message}`));
            return;
          }
          resolve();
        });
      } catch (err) {
        const errMsg = err as BusinessError;
        reject(new Error(`Decompress exception: ${errMsg.message}`));
      }
    });
  }

  private static findFileRecursively(dir: string, targetName: string): string | null {
    try {
      const files = fs.listFileSync(dir);
      for (const file of files) {
        const fullPath = `${dir}/${file}`;
        if (file === targetName) {
          return fullPath;
        }
        if (fs.statSync(fullPath).isDirectory()) {
          const found = DocumentTextExtractor.findFileRecursively(fullPath, targetName);
          if (found) {
            return found;
          }
        }
      }
    } catch (e) {
    }
    return null;
  }
}
