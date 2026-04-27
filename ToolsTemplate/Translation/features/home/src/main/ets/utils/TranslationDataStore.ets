/**
 * 翻译数据全局存储
 */
export class TranslationDataStore {
  private static instance: TranslationDataStore;
  private downloadUrl: string = '';
  private translatedText: string = '';
  private originalText: string = ''; // 原文文本
  private fileName: string = '';
  private pdfCachePath: string = ''; // PDF缓存文件路径
  private originalPdfCachePath: string = ''; // 原文PDF缓存路径
  private originalFileUri: string = ''; // 原始文件URI

  private constructor() {
  }

  static getInstance(): TranslationDataStore {
    if (!TranslationDataStore.instance) {
      TranslationDataStore.instance = new TranslationDataStore();
    }
    return TranslationDataStore.instance;
  }

  //设置翻译数据
  setTranslationData(downloadUrl: string, translatedText: string, fileName: string): void {
    this.downloadUrl = downloadUrl;
    this.translatedText = translatedText;
    this.fileName = fileName;
  }

  //设置原文文本
  setOriginalText(text: string): void {
    this.originalText = text;
  }

  //获取原文文本
  getOriginalText(): string {
    return this.originalText;
  }

  //获取下载链接
  getDownloadUrl(): string {
    return this.downloadUrl;
  }

  //获取译文文本
  getTranslatedText(): string {
    return this.translatedText;
  }

  //获取文件名
  getFileName(): string {
    return this.fileName;
  }

  //设置PDF缓存路径
  setPdfCachePath(path: string): void {
    this.pdfCachePath = path;
  }

  //获取PDF缓存路径
  getPdfCachePath(): string {
    return this.pdfCachePath;
  }

  //设置原文PDF缓存路径
  setOriginalPdfCachePath(path: string): void {
    this.originalPdfCachePath = path;
  }

  //获取原文PDF缓存路径
  getOriginalPdfCachePath(): string {
    return this.originalPdfCachePath;
  }

  //设置原始文件URI
  setOriginalFileUri(uri: string): void {
    this.originalFileUri = uri;
  }

  //获取原始文件URI
  getOriginalFileUri(): string {
    return this.originalFileUri;
  }

  //清除数据
  clear(): void {
    this.downloadUrl = '';
    this.translatedText = '';
    this.originalText = '';
    this.fileName = '';
    this.pdfCachePath = '';
    this.originalPdfCachePath = '';
    this.originalFileUri = '';
  }
}
