import { BusinessError } from '@kit.BasicServicesKit';
import { FileOperationUtil } from './FileOperationUtil';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { FileType, GlobalContext, TCLogger, TimeUtil } from 'common';
import { fileIo as fs, picker } from '@kit.CoreFileKit';
import { DocumentType, UploadFileStatus } from 'common';
import { promptAction } from '@kit.ArkUI';

export class FileSelectPickerUtil {
  private readonly logTag: string = 'FileSelectPickerUtil'
  private localUploadFileUtil: FileOperationUtil = new FileOperationUtil();
  private documentTypeArray: Array<DocumentType> = [
    DocumentType.PDF,
    DocumentType.TXT,
    DocumentType.DOCX,
    DocumentType.PPTX,
    DocumentType.XLSX,
    DocumentType.DOC,
    DocumentType.DOCX,
    DocumentType.AUDIO
  ];
  // 上传进度接口对象
  progressUtil: (uploadFileStatus: UploadFileStatus) => void = (uploadFileStatus: UploadFileStatus) => {
  }

  // 设置通知进度变化
  public setProgressUtil(progressUtil: (uploadFileStatus: UploadFileStatus) => void) {
    this.progressUtil = progressUtil
  }

  constructor() {
    this.localUploadFileUtil.setProgressUtil((res: UploadFileStatus) => {
      TCLogger.info(this.logTag, `Progressing in uploading file, result: ${JSON.stringify(res)}`);
      // 上报进度
      this.progressUtil(res);
    });
  }

  // 文件传输界面再试上传至云测
  public upload(fileUri: string): Promise<UploadFileStatus> {
    return new Promise((resolve, reject) => {
      // 解决中文文件名乱码
      fileUri = decodeURIComponent(fileUri)
      TCLogger.info(this.logTag, `pick file ${fileUri}`);
      let fileName = fileUri.split('/').pop() as string;
      TCLogger.info(this.logTag, `file name ${fileName}`);
      let fileType: string = fileName.split('.')[fileName.split('.').length - 1];
      // 时间戳
      let timestamp: string =
        `${TimeUtil.getCurDate(TimeUtil.PATTERN_DATE_DEFAULT)}${TimeUtil.getCurTime(TimeUtil.PATTERN_TIME_MS)}`;
      let cacheFile =
        GlobalContext.getUIAbilityContext().cacheDir + '/' + fileName.split(`.${fileType}`)[0] + '_' + timestamp + '.' +
          fileType;
      TCLogger.info(this.logTag, `cacheFile ${cacheFile}`);
      this.localUploadFileUtil.copyFile(fileUri, cacheFile, fileName).then(res => {
        TCLogger.info(this.logTag, `Succeeded in uploading file, result: ${JSON.stringify(res)}`);
        if (res) {
          // 上传至云存储默认实例
          this.localUploadFileUtil.uploadFile(
            cacheFile,
            `media/${fileName}`,
            fileUri).then((res: UploadFileStatus) => {
            TCLogger.info(this.logTag, `Succeeded in uploading file, result: ${JSON.stringify(res)}`);
            // 文件类型
            res.fileSuffix = FileSelectPickerUtil.getFileType(fileType)
            if (res.fileSuffix !== FileType.Picture && res.fileSuffix !== FileType.Video) {
              // 删除cache目录临时文件
              fs.unlink(cacheFile).catch((err: BusinessError) => {
                TCLogger.info(this.logTag, `Failed to unlink, code: ${err.code}, message: ${err.message}.`);
              });
            }
            // 创建时间
            res.createTime =
              `${TimeUtil.getCurDate(TimeUtil.PATTERN_DATE_HYPHEN)} ${TimeUtil.getCurTime(TimeUtil.PATTERN_TIME_COLON)}`;
            // 回调上传结果
            resolve(res);
          });
        } else {
          promptAction.showToast({
            message: '上传失败，文件为空或文件大于1GB',
          })
        }
      });
    });
  }

  // 文件传输界面再试上传至云测
  public uploadFailedFile(fileUri: string, fileName: string): Promise<UploadFileStatus> {
    return new Promise((resolve, reject) => {
      // 解决中文文件名乱码
      fileUri = decodeURIComponent(fileUri)
      TCLogger.info(this.logTag, `pick file ${fileUri}`);
      TCLogger.info(this.logTag, `file name ${fileName}`);
      let fileType: string = fileName.split('.')[fileName.split('.').length - 1];
      // 时间戳
      let timestamp: string =
        `${TimeUtil.getCurDate(TimeUtil.PATTERN_DATE_DEFAULT)}${TimeUtil.getCurTime(TimeUtil.PATTERN_TIME_MS)}`;
      let cacheFile =
        GlobalContext.getUIAbilityContext().cacheDir + '/' + fileName.split(`.${fileType}`)[0] + '_' + timestamp + '.' +
          fileType;
      TCLogger.info(this.logTag, `cacheFile ${cacheFile}`);
      this.localUploadFileUtil.copyFile(fileUri, cacheFile, fileName).then(res => {
        TCLogger.info(this.logTag, `Succeeded in uploading file, result: ${JSON.stringify(res)}`);
        if (res) {
          // 上传至云存储默认实例
          this.localUploadFileUtil.uploadFile(
            cacheFile,
            `media/${fileName}`,
            fileUri, false).then((res: UploadFileStatus) => {
            TCLogger.info(this.logTag, `Succeeded in uploading file, result: ${JSON.stringify(res)}`);
            // 文件类型
            res.fileSuffix = FileSelectPickerUtil.getFileType(fileType)
            if (res.fileSuffix !== FileType.Picture && res.fileSuffix !== FileType.Video) {
              // 删除cache目录临时文件
              fs.unlink(cacheFile).catch((err: BusinessError) => {
                TCLogger.info(this.logTag, `Failed to unlink, code: ${err.code}, message: ${err.message}.`);
              });
            }
            // 创建时间
            res.createTime =
              `${TimeUtil.getCurDate(TimeUtil.PATTERN_DATE_HYPHEN)} ${TimeUtil.getCurTime(TimeUtil.PATTERN_TIME_COLON)}`;
            // 回调上传结果
            resolve(res);
          });
        } else {
          promptAction.showToast({
            message: '上传失败，文件为空',
          })
        }
      });
    });
  }

  // 上传指定文件至云侧
  public uploadMedia(): Promise<string> {
    return new Promise((resolve, reject) => {
      this.selectPhoto().then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
        let fileUri = photoSelectResult.photoUris[0];
        resolve(fileUri)
      }).catch((err: BusinessError) => {
        TCLogger.info(this.logTag, `Failed to upload file, code: ${err.code}, message: ${err.message}`);
        reject(err)
      })
    });
  }

  /**
   * @throws photoViewPicker select throws
   */
  private selectPhoto(): Promise<photoAccessHelper.PhotoSelectResult> {
    // 使用photoAccessHelper选择指定的文件
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE; // 过滤选择媒体文件类型为IMAGE_VIDEO_TYPE
    photoSelectOptions.maxSelectNumber = 1; // 选择媒体文件的最大数目
    let photoViewPicker = new photoAccessHelper.PhotoViewPicker();
    return photoViewPicker.select(photoSelectOptions);
  }

  /**
   * 选择文档文件
   */
  public uploadDocumentFile(): Promise<string> {
    return new Promise((resolve, reject) => {
      let documentPicker = new picker.DocumentViewPicker(getContext());
      documentPicker
        .select({
          maxSelectNumber: 1,
          fileSuffixFilters: this.getFileSuffixArray(),
        })
        .then((documentSelectResult: Array<string>) => {
          TCLogger.info(this.logTag,
            'DocumentViewPicker.select successfully, uri: ' + JSON.stringify(documentSelectResult));
          if (documentSelectResult.length === 0) {
            TCLogger.info(this.logTag, `pick document file failed, documentSelectResult is empty`);
            return;
          }
          let filePath: string = documentSelectResult[0];
          resolve(filePath)
        })
        .catch((err: BusinessError) => {
          TCLogger.error(this.logTag, 'DocumentViewPicker.select failed with err: ' + JSON.stringify(err));
          reject(err)
        });
    })
  }

  /**
   * 文件类型
   */
  private getFileSuffixArray(): Array<string> {
    let fileSuffixArray: Array<string> = [];
    for (let documentType of this.documentTypeArray) {
      switch (documentType) {
        case DocumentType.PDF: {
          fileSuffixArray.push('文档|.pdf');
          break;
        }
        case DocumentType.TXT: {
          fileSuffixArray.push('文档|.txt');
          break;
        }
        case DocumentType.DOC: {
          fileSuffixArray.push('文档|.doc');
          break;
        }
        case DocumentType.DOCX: {
          fileSuffixArray.push('文档|.docx');
          break;
        }

        case DocumentType.XLS: {
          fileSuffixArray.push('文档|.xls');
          break;
        }
        case DocumentType.XLSX: {
          fileSuffixArray.push('文档|.xlsx');
          break;
        }
        case DocumentType.PPT: {
          fileSuffixArray.push('文档|.ppt');
          break;
        }
        case DocumentType.PPTX: {
          fileSuffixArray.push('文档|.pptx');
          break;
        }
        case DocumentType.AUDIO: {
          fileSuffixArray.push('文档|.mp3');
          fileSuffixArray.push('文档|.flac');
          fileSuffixArray.push('文档|.ape');
          fileSuffixArray.push('文档|.wav');
          fileSuffixArray.push('文档|.m4a');
          break;
        }
        default: {
          break;
        }
      }
    }
    return fileSuffixArray;
  }

  /**
   * 获取文件类型
   */
  public static getFileType(fileType: string): number {
    fileType = fileType.toLowerCase();
    let tmpType: number = 0;
    switch (fileType) {
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'bmp':
      case 'webp':
      case 'svg':
      case 'ico':
      case 'psd':
      case 'ai':
      case 'eps':
      case 'raw':
      case 'tif':
      case 'tiff':
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'bmp':
        tmpType = FileType.Picture
        break
      case 'mp4':
      case 'avi':
      case 'mkv':
      case 'mov':
      case 'flv':
      case 'wmv':
      case 'webm':
        tmpType = FileType.Video
        break
      case 'mp3':
      case 'flac':
      case 'ape':
      case 'wav':
      case 'm4a':
        tmpType = FileType.Audio
        break
      default:
        tmpType = FileType.File
        break;
    }
    return tmpType;
  }
}