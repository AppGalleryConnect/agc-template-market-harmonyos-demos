import { promptAction } from '@kit.ArkUI';
import { picker } from '@kit.CoreFileKit';
import fs from '@ohos.file.fs';
import fileIo from '@ohos.file.fs';
import fileUri from '@ohos.file.fileuri';
import {
  TranslationConfig, BaiduDocumentTranslation
} from 'baidu_translate';
import { util } from '@kit.ArkTS';
import { UploadStatus, UploadedFileInfo } from '../types/DocumentTranslateTypes';
import { http } from '@kit.NetworkKit';
import { DocumentTextExtractor } from '../utils/DocumentTextExtractor';
import { TranslationDataStore } from '../utils/TranslationDataStore';
import { FileUtils } from '../utils/FileUtils';
import { pdfService, pdfViewManager } from '@kit.PDFKit';

export interface TranslationCompleteResult {
  fileName: string;
  originalText: string;
  translatedText: string;
  sourceLang: string;
  targetLang: string;
  downloadUrl?: string;
  originalFileUri?: string;
}

interface LanguagePair {
  source: string;
  target: string;
}

interface TranslationResult {
  url: string;
  text: string;
  detectedFrom?: string;
  detectedTo?: string;
}

interface PollResult {
  url: string;
  detectedFrom: string;
  detectedTo: string;
}

@ObservedV2
export class DocumentTranslateViewModel {
  @Trace uploadedFiles: UploadedFileInfo[] = [];
  @Trace showUploadSheet: boolean = false;
  @Trace showTranslatingDialog: boolean = false;
  @Trace translationProgress: number = 0;
  @Trace translationStep: string = 'recognizing';
  // 语言选择：只支持中英互译
  @Trace sourceLanguage: string = 'zh'; // 'zh' 或 'en'
  @Trace targetLanguage: string = 'en'; // 'zh' 或 'en'

  maxFiles: number = 1;
  private uploadTimers: Map<string, number> = new Map();
  private pausedUploads: Set<string> = new Set();
  private documentTranslator: BaiduDocumentTranslation | null = null;
  onTranslationComplete?: (result: TranslationCompleteResult) => void;

  async selectFile(): Promise<void> {
    this.showUploadSheet = false;

    try {
      const documentPicker = new picker.DocumentViewPicker();
      const selectOptions = new picker.DocumentSelectOptions();
      selectOptions.maxSelectNumber = this.maxFiles - this.uploadedFiles.length;
      selectOptions.fileSuffixFilters = ['.doc', '.docx', '.pdf'];

      const result = await documentPicker.select(selectOptions);

      if (result && result.length > 0) {
        for (const uri of result) {
          const fileInfo = await this.getFileInfo(uri);
          if (fileInfo) {
            this.uploadedFiles.push(fileInfo);
            this.startUpload(fileInfo);
          }
        }
      }
    } catch (err) {
      promptAction.showToast({ message: '选择文件失败' });
    }
  }

  deleteFile(index: number): void {
    const file = this.uploadedFiles[index];
    const timerId = this.uploadTimers.get(file.uri);
    if (timerId !== undefined) {
      clearInterval(timerId);
      this.uploadTimers.delete(file.uri);
    }
    this.pausedUploads.delete(file.uri);
    this.uploadedFiles.splice(index, 1);
  }

  reupload(): void {
    this.uploadTimers.forEach((timerId) => {
      clearInterval(timerId);
    });
    this.uploadTimers.clear();
    this.pausedUploads.clear();
    this.uploadedFiles = [];
  }

  toggleUploadPause(file: UploadedFileInfo): void {
    if (file.status === UploadStatus.UPLOADING) {
      file.status = UploadStatus.PAUSED;
      this.pausedUploads.add(file.uri);
      file.uploadSpeed = '已暂停';

      const timerId = this.uploadTimers.get(file.uri);
      if (timerId !== undefined) {
        clearInterval(timerId);
        this.uploadTimers.delete(file.uri);
      }
    } else if (file.status === UploadStatus.PAUSED) {
      file.status = UploadStatus.UPLOADING;
      this.pausedUploads.delete(file.uri);
      this.startUpload(file);
    }
  }

  private startUpload(_file: UploadedFileInfo): void {
    // 进度动画由组件内部控制，这里不需要做任何事情
  }

  formatBytes(bytes: number): string {
    return FileUtils.formatBytes(bytes);
  }

  private async getFileInfo(uri: string): Promise<UploadedFileInfo | null> {
    try {
      const file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
      const stat = fileIo.statSync(file.fd);
      const filename = new fileUri.FileUri(uri).name;
      const sizeStr = FileUtils.formatBytes(stat.size);
      fileIo.closeSync(file);

      const fileInfo: UploadedFileInfo = {
        name: filename,
        size: sizeStr,
        uri: uri,
        sizeInBytes: stat.size,
        uploadedBytes: 0,
        progress: 0,
        status: UploadStatus.UPLOADING,
        uploadSpeed: '0KB/s'
      };
      return fileInfo;
    } catch (err) {
      return null;
    }
  }

  // 交换源语言和目标语言
  swapLanguages(): void {
    const temp = this.sourceLanguage;
    this.sourceLanguage = this.targetLanguage;
    this.targetLanguage = temp;
  }

  // 获取语言显示名称
  getLanguageDisplayName(langCode: string): string {
    return langCode === 'zh' ? '中文' : '英文';
  }

  async translateDocument(): Promise<void> {
    const file = this.validateFileForTranslation();
    if (!file) {
      return;
    }

    try {
      this.initializeTranslationUI();

      // 复制原始文件到缓存目录（用于预览页面切换显示原文）
      const originalCachePath = await this.copyOriginalFileToCache(file);

      // 使用用户选择的语言
      const languages: LanguagePair = {
        source: this.sourceLanguage,
        target: this.targetLanguage
      };

      const result = await this.performDocumentTranslation(file, languages);
      await this.handleTranslationSuccess(file, result.url, result.text, languages, originalCachePath);
    } catch (error) {
      this.handleTranslationError(error);
    }
  }

  // 复制原始文件到缓存目录
  private async copyOriginalFileToCache(file: UploadedFileInfo): Promise<string> {
    let srcFile: fs.File | undefined;
    let destFile: fs.File | undefined;
    try {
      const context = getContext(this);
      const cacheDir = context.cacheDir;
      const ext = file.name.toLowerCase().endsWith('.pdf') ? 'pdf' : 'docx';
      const cachePath = `${cacheDir}/original_${Date.now()}.${ext}`;

      srcFile = fs.openSync(file.uri, fs.OpenMode.READ_ONLY);
      const stat = fs.statSync(srcFile.fd);
      const buffer = new ArrayBuffer(stat.size);
      fs.readSync(srcFile.fd, buffer);

      destFile = fs.openSync(cachePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.writeSync(destFile.fd, buffer);

      return cachePath;
    } catch (error) {
      return '';
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

  private validateFileForTranslation(): UploadedFileInfo | null {
    if (this.uploadedFiles.length === 0) {
      promptAction.showToast({ message: '请先上传文档' });
      return null;
    }

    const file = this.uploadedFiles[0];
    if (file.status !== UploadStatus.COMPLETED) {
      promptAction.showToast({ message: '请等待文件上传完成' });
      return null;
    }

    return file;
  }

  private initializeTranslationUI(): void {
    this.showTranslatingDialog = true;
    this.translationProgress = 0;
    this.translationStep = 'recognizing';
  }

  private async performDocumentTranslation(
    file: UploadedFileInfo,
    languages: LanguagePair
  ): Promise<TranslationResult> {
    this.ensureTranslatorInitialized();
    const base64Content = await this.readFileAsBase64(file.uri);
    await this.updateProgress(0, 30, 'recognizing', 1000);

    const requestId = await this.submitTranslationTask(file, base64Content, languages);
    await this.updateProgress(30, 50, 'translating', 3000);

    const pollResult = await this.pollTranslationResult(requestId);
    await this.updateProgress(50, 100, 'translating', 500);

    const isPdf = file.name.toLowerCase().endsWith('.pdf');
    const translatedText = await this.downloadTranslatedText(pollResult.url, isPdf);

    return {
      url: pollResult.url,
      text: translatedText,
      detectedFrom: pollResult.detectedFrom,
      detectedTo: pollResult.detectedTo
    };
  }

  private ensureTranslatorInitialized(): void {
    if (!this.documentTranslator) {
      const config: TranslationConfig = {
        appId: '',// TODO: 替换为真实的 APP_ID
        secretKey: '', // TODO: 替换为真实的 SECRET_KEY
        apiKey: '' // TODO: 替换为真实的API_KEY
      };
      this.documentTranslator = new BaiduDocumentTranslation(config);
    }
  }

  private async submitTranslationTask(
    file: UploadedFileInfo,
    base64Content: string,
    languages: LanguagePair
  ): Promise<number> {
    this.translationStep = 'submitting';
    const fileFormat = file.name.endsWith('.pdf') ? 'pdf' : 'docx';

    const submitResponse = await this.documentTranslator!.submitTranslation({
      from: languages.source,
      to: languages.target,
      input: {
        content: base64Content,
        format: fileFormat,
        filename: file.name,
        modelType: 'llm'
      },
      output: {
        format: fileFormat
      }
    });

    if (submitResponse.code !== 0) {
      throw new Error(`提交翻译任务失败：${submitResponse.msg || '未知错误'}`);
    }

    const requestId = submitResponse.data?.requestId;
    if (!requestId) {
      throw new Error('提交翻译任务失败：未获取到任务ID');
    }

    return requestId as number;
  }

  private async pollTranslationResult(requestId: number): Promise<PollResult> {
    const progressResponse = await this.documentTranslator!.pollTranslationResult(requestId, 120, 5000);

    if (!progressResponse || !progressResponse.data) {
      throw new Error('查询翻译结果失败：返回数据无效');
    }

    const status = progressResponse.data?.status;
    const reason = progressResponse.data?.reason;

    if (status === 2) {
      throw new Error(`翻译失败：${reason || '未知原因'}`);
    }

    const translatedFileUrl = progressResponse.data?.fileSrcUrl || '';
    const detectedFrom = progressResponse.data?.from || '';
    const detectedTo = progressResponse.data?.to || '';

    if (!translatedFileUrl) {
      throw new Error('翻译完成但未获取到下载链接');
    }

    return {
      url: translatedFileUrl,
      detectedFrom: detectedFrom,
      detectedTo: detectedTo
    };
  }

  private async downloadTranslatedText(translatedFileUrl: string, isPdf: boolean = false): Promise<string> {
    this.translationStep = 'downloading';

    if (!translatedFileUrl || translatedFileUrl.trim().length === 0) {
      return '未获取到译文下载链接，请重试。';
    }

    try {
      const translatedText = await this.downloadAndExtractText(translatedFileUrl, isPdf);

      if (!translatedText || translatedText.trim().length === 0) {
        return '译文内容为空，请下载文档查看。';
      }

      return translatedText;
    } catch (error) {
      return '译文下载失败，请重试或下载文档查看。';
    }
  }

  private async handleTranslationSuccess(
    file: UploadedFileInfo,
    translatedFileUrl: string,
    translatedText: string,
    languages: LanguagePair,
    originalCachePath: string = ''
  ): Promise<void> {
    // 先提取原文，再关闭对话框
    this.translationStep = 'extracting';
    const originalText = await this.extractOriginalText(file);

    this.showTranslatingDialog = false;

    const dataStore = TranslationDataStore.getInstance();
    dataStore.setTranslationData(translatedFileUrl, translatedText, file.name);
    dataStore.setOriginalText(originalText);
    dataStore.setOriginalFileUri(file.uri);
    dataStore.setOriginalPdfCachePath(originalCachePath);

    if (this.onTranslationComplete) {
      this.onTranslationComplete({
        fileName: file.name,
        originalText: originalText,
        translatedText: translatedText.substring(0, 500) + '...',
        sourceLang: languages.source,
        targetLang: languages.target,
        downloadUrl: '',
        originalFileUri: file.uri
      });
    } else {
      promptAction.showToast({ message: '翻译完成，但无法跳转到预览页面' });
    }
  }

  // 提取原文文本
  private async extractOriginalText(file: UploadedFileInfo): Promise<string> {
    const isPdf = file.name.toLowerCase().endsWith('.pdf');

    // PDF文件不支持文本提取，返回空字符串，预览页面会使用PDF预览
    if (isPdf) {
      return '';
    }

    try {
      const context = getContext(this);
      const cacheDir = context.cacheDir;
      return await DocumentTextExtractor.extractFromDocx(file.uri, cacheDir);
    } catch (error) {
      return '原文提取失败，请查看原文档。';
    }
  }

  private handleTranslationError(error: Error | Object): void {
    this.showTranslatingDialog = false;

    let errorMessage = '翻译失败，请重试';
    if (error instanceof Error) {
      errorMessage = this.getErrorMessage(error);
    }

    promptAction.showToast({ message: errorMessage, duration: 3000 });
  }

  private getErrorMessage(error: Error): string {
    // 如果错误信息已经是中文，直接返回
    if (error.message && /[\u4e00-\u9fa5]/.test(error.message)) {
      return error.message;
    }
    if (error.message.includes('timeout')) {
      return '翻译超时，请检查网络连接后重试';
    }
    if (error.message.includes('network')) {
      return '网络连接失败，请检查网络后重试';
    }
    if (error.message.includes('Failed to get request ID')) {
      return '提交翻译任务失败，请重试';
    }
    return '翻译失败，请重试';
  }

  private async updateProgress(from: number, to: number, step: string, duration: number): Promise<void> {
    const steps = 20;
    const increment = (to - from) / steps;
    const delay = duration / steps;

    for (let i = 0; i <= steps; i++) {
      this.translationProgress = Math.floor(from + increment * i);
      this.translationStep = step;
      await new Promise<void>((resolve) => setTimeout(resolve, delay));
    }
  }

  private async readFileAsBase64(uri: string): Promise<string> {
    let file: fs.File | undefined;
    try {
      try {
        file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      } catch (e) {
        const context = getContext(this);
        const cacheDir = context.cacheDir;
        const fileName = 'temp_doc_' + new Date().getTime();
        const cachePath = `${cacheDir}/${fileName}`;

        const srcFile = fs.openSync(uri, fs.OpenMode.READ_ONLY);
        fs.copyFileSync(srcFile.fd, cachePath);
        fs.closeSync(srcFile);

        file = fs.openSync(cachePath, fs.OpenMode.READ_ONLY);
      }

      if (!file) {
        throw new Error('Failed to open file');
      }

      const stat = fs.statSync(file.fd);
      const buffer = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, buffer);

      const base64Helper = new util.Base64Helper();
      const uint8Array = new Uint8Array(buffer);
      const base64String = base64Helper.encodeToStringSync(uint8Array);

      return base64String;
    } catch (error) {
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error(`Read file as base64 failed: ${JSON.stringify(error)}`);
      }
    } finally {
      if (file) {
        fs.closeSync(file);
      }
    }
  }

  // 下载文件
  private async downloadFile(url: string): Promise<ArrayBuffer> {
    if (!url || url.trim().length === 0) {
      throw new Error('Download URL is empty');
    }

    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.ARRAY_BUFFER,
        connectTimeout: 60000,
        readTimeout: 60000
      });

      if (response.responseCode !== http.ResponseCode.OK) {
        throw new Error(`Download failed with code: ${response.responseCode}`);
      }

      const resultBuffer = response.result as ArrayBuffer;
      if (!resultBuffer || resultBuffer.byteLength === 0) {
        throw new Error('Downloaded file is empty');
      }

      return resultBuffer;
    } finally {
      try {
        httpRequest.destroy();
      } catch (e) {
        // 忽略销毁错误
      }
    }
  }

  // 根据URL判断文件扩展名
  private getFileExtFromUrl(url: string, isPdf: boolean): string {
    const urlLower = url.toLowerCase();
    if (urlLower.includes('.pdf')) {
      return 'pdf';
    }
    if (urlLower.includes('.docx') || urlLower.includes('.doc')) {
      return 'docx';
    }
    return isPdf ? 'pdf' : 'docx';
  }

  // 保存文件到缓存目录
  private saveToCache(buffer: ArrayBuffer, fileExt: string): string {
    const context = getContext(this);
    const cacheDir: string = context.cacheDir;
    const fileName = `translated_${Date.now()}.${fileExt}`;
    const filePath = `${cacheDir}/${fileName}`;

    let file: fs.File | undefined;
    try {
      file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.writeSync(file.fd, buffer);
      return filePath;
    } finally {
      if (file) {
        try {
          fs.closeSync(file);
        } catch (e) {
          // 忽略关闭错误
        }
      }
    }
  }

  // 从文件提取文本
  private async extractTextFromFile(filePath: string, fileExt: string): Promise<string> {
    try {
      const context = getContext(this);
      const cacheDir = context.cacheDir;

      let extractedText = '';
      if (fileExt === 'pdf') {
        extractedText = await DocumentTextExtractor.extractFromPdf(filePath);
      } else {
        extractedText = await DocumentTextExtractor.extractFromDocx(filePath, cacheDir);
      }

      if (!extractedText || extractedText.trim().length === 0) {
        throw new Error('提取的文本内容为空');
      }
      return extractedText;
    } catch (error) {
      return '译文内容提取失败，请下载文档查看完整内容。\n\n点击下方"立即下载"按钮下载译文文档。';
    }
  }

  private async downloadAndExtractText(url: string, isPdf: boolean = false): Promise<string> {
    try {
      // 下载文件
      const resultBuffer = await this.downloadFile(url);

      // 判断文件扩展名
      const fileExt = this.getFileExtFromUrl(url, isPdf);

      // 保存到缓存
      const filePath = this.saveToCache(resultBuffer, fileExt);

      // 提取文本
      return await this.extractTextFromFile(filePath, fileExt);
    } catch (error) {
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error(`Download failed: ${JSON.stringify(error)}`);
      }
    }
  }

  async loadPdfForPreview(
    pdfController: pdfViewManager.PdfController,
    onLoadingChange: (loading: boolean) => void,
    onReadyChange: (ready: boolean) => void
  ): Promise<void> {
    const dataStore = TranslationDataStore.getInstance();
    const downloadUrl = dataStore.getDownloadUrl();

    if (!downloadUrl) {
      return;
    }

    onLoadingChange(true);
    let httpRequest: http.HttpRequest | undefined;
    let file: fs.File | undefined;

    try {
      const context = getContext(this);
      const cacheDir = context.cacheDir;
      const pdfFileName = `preview_${Date.now()}.pdf`;
      const pdfFilePath = `${cacheDir}/${pdfFileName}`;

      httpRequest = http.createHttp();
      const response = await httpRequest.request(downloadUrl, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.ARRAY_BUFFER,
        connectTimeout: 60000,
        readTimeout: 60000
      });

      if (response.responseCode !== http.ResponseCode.OK) {
        throw new Error(`下载失败，错误码：${response.responseCode}`);
      }

      const resultBuffer = response.result as ArrayBuffer;
      if (!resultBuffer || resultBuffer.byteLength === 0) {
        throw new Error('下载的文件为空');
      }

      file = fs.openSync(pdfFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.writeSync(file.fd, resultBuffer);
      fs.closeSync(file);
      file = undefined;

      dataStore.setPdfCachePath(pdfFilePath);

      const loadResult: pdfService.ParseResult = await pdfController.loadDocument(pdfFilePath);
      if (loadResult === pdfService.ParseResult.PARSE_SUCCESS) {
        onReadyChange(true);
      } else {
        throw new Error(`PDF加载失败，错误码：${loadResult}`);
      }
    } catch (error) {
      onReadyChange(false);
    } finally {
      onLoadingChange(false);

      if (httpRequest) {
        try {
          httpRequest.destroy();
        } catch (e) {
        }
      }

      if (file) {
        try {
          fs.closeSync(file);
        } catch (e) {
        }
      }
    }
  }

  async downloadTranslatedFileToLocal(fileName: string): Promise<void> {
    const dataStore = TranslationDataStore.getInstance();
    const downloadUrl = dataStore.getDownloadUrl();

    if (!downloadUrl || downloadUrl.trim().length === 0) {
      promptAction.showToast({ message: '暂无下载链接' });
      return;
    }

    try {
      const saveUri = await this.selectSaveLocation(fileName);
      if (!saveUri) {
        return;
      }

      const isPdfFile = fileName.toLowerCase().endsWith('.pdf');
      const pdfCachePath = dataStore.getPdfCachePath();

      // 优先从缓存复制PDF文件
      if (isPdfFile && pdfCachePath && fs.accessSync(pdfCachePath)) {
        await this.copyFromCache(pdfCachePath, saveUri);
        return;
      }

      // 从网络下载文件
      await this.downloadFromNetwork(downloadUrl, saveUri);
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : '下载失败';
      promptAction.showToast({ message: errorMsg, duration: 3000 });
    }
  }

  // 选择保存位置
  private async selectSaveLocation(fileName: string): Promise<string | null> {
    const isPdfFile = fileName.toLowerCase().endsWith('.pdf');
    const originalExt = isPdfFile ? '.pdf' : '.docx';
    const baseName = fileName.replace(/\.[^.]+$/, '');

    const documentSaver = new picker.DocumentSaveOptions();
    documentSaver.newFileNames = [`${baseName}_translated${originalExt}`];

    const documentPicker = new picker.DocumentViewPicker();
    const saveResult = await documentPicker.save(documentSaver);

    if (!saveResult || saveResult.length === 0) {
      promptAction.showToast({ message: '已取消下载' });
      return null;
    }

    return saveResult[0];
  }

  // 从缓存复制文件
  private async copyFromCache(cachePath: string, saveUri: string): Promise<void> {
    promptAction.showToast({ message: '正在保存...' });
    let srcFile: fs.File | undefined;
    let destFile: fs.File | undefined;
    try {
      srcFile = fs.openSync(cachePath, fs.OpenMode.READ_ONLY);
      destFile = fs.openSync(saveUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      const stat = fs.statSync(srcFile.fd);
      const buffer = new ArrayBuffer(stat.size);
      fs.readSync(srcFile.fd, buffer);
      fs.writeSync(destFile.fd, buffer);
      promptAction.showToast({ message: '下载成功！' });
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

  // 从网络下载文件
  private async downloadFromNetwork(downloadUrl: string, saveUri: string): Promise<void> {
    promptAction.showToast({ message: '正在下载...' });
    let httpRequest: http.HttpRequest | undefined;
    let destFile: fs.File | undefined;
    try {
      httpRequest = http.createHttp();
      const response = await httpRequest.request(downloadUrl, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.ARRAY_BUFFER,
        connectTimeout: 60000,
        readTimeout: 60000
      });

      if (response.responseCode !== http.ResponseCode.OK) {
        throw new Error(`下载失败，错误码：${response.responseCode}`);
      }

      const resultBuffer = response.result as ArrayBuffer;
      if (!resultBuffer || resultBuffer.byteLength === 0) {
        throw new Error('下载的文件为空');
      }

      destFile = fs.openSync(saveUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.writeSync(destFile.fd, resultBuffer);
      promptAction.showToast({ message: '下载成功！' });
    } finally {
      if (httpRequest) {
        try {
          httpRequest.destroy();
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
}
