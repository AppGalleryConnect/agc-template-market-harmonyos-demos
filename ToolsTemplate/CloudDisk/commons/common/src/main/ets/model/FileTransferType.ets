import { FileInfo, FileType } from './FileInfo'

/**
 * 文件传输类
 */
@ObservedV2
export class FileTransferProgressingType {
  // 文件信息
  @Trace fileInfo: FileInfo = new FileInfo(0, '', '')
  // 上传文件列表更新下标
  @Trace uploadFileIndex: number = 0
  // 更新状态
  @Trace isUpdateUploadFile: number = 0

  constructor(fileInfo: FileInfo, uploadFileIndex: number, isUpdateUploadFile: number) {
    this.fileInfo = fileInfo
    this.uploadFileIndex = uploadFileIndex
    this.isUpdateUploadFile = isUpdateUploadFile
  }

  // fileInfo、uploadFileIndex、isUpdateUploadFile均被@Trace装饰，能够监听变化
  @Monitor('fileInfo', 'uploadFileIndex', 'isUpdateUploadFile')
  onChange(monitor: IMonitor) {
    monitor.dirty.forEach((path: string) => {
      console.info(`${path} change from ${monitor.value(path)?.before} to ${monitor.value(path)?.now}`);
    })
  }
}

/**
 * fileId保存类型
 */
@ObservedV2
export class FileIdSaveType {
  // 文件id
  @Trace index: number = 0;
  // 文件名
  @Trace fileId: number = 0;

  constructor(index: number, fileId: number) {
    this.index = index
    this.fileId = fileId
  }
}

/**
 * 更新进行中文件状态
 */
@ObservedV2
export class FileTransferProgressingStatus {
  // 更新数组的下标
  @Trace index: number = 0
  // fileId保存成数组
  @Trace fileIdList: Array<FileIdSaveType> = []
  // 文件传输文件下标
  @Trace transferIndex: number = 0
  // 是否新添加
  @Trace isNewAdd: boolean = false
}

/**
 * 进行中的文件类型
 */
@ObservedV2
export class ProgressingFileType {
  @Trace id: number = 0
  @Trace name: string = ''
  @Trace img: ResourceStr = ''
  @Trace fileType: FileType = FileType.Other
  @Trace progress: number = 0
  @Trace progressDes: string = ''
  @Trace speed: string = ''
  @Trace vipStatus: boolean = false
  @Trace isStop: boolean = false
  @Trace path: string = ''

  toJSON(): ProgressingFileTypePlain {
    return {
      id: this.id,
      name: this.name,
      img: this.img,
      fileType: this.fileType,
      progress: this.progress,
      progressDes: this.progressDes,
      speed: this.speed,
      vipStatus: this.vipStatus,
      isStop: this.isStop,
      path: this.path
    }
  }

  // 从 JSON 字符串反序列化为 FailedFileType 实例
  static fromJSON(json: string): ProgressingFileType {
    const obj = JSON.parse(json) as ProgressingFileTypePlain
    return ProgressingFileType.fromPlain(obj)
  }

  // 从普通对象构建 FailedFileType
  static fromPlain(obj: Partial<ProgressingFileTypePlain>): ProgressingFileType {
    const fi = new ProgressingFileType()
    fi.img = obj.img ?? ''
    fi.fileType = obj.fileType ?? FileType.Other
    fi.id = obj.id ?? 0
    fi.name = obj.name ?? ''
    fi.progress = obj.progress ?? 0
    fi.progressDes = obj.progressDes ?? ''
    fi.speed = obj.speed ?? ''
    fi.vipStatus = obj.vipStatus ?? false
    fi.isStop = obj.isStop ?? false
    fi.path = obj.path ?? ''
    return fi
  }
}

/**
 * 进行中文件辅助类
 */
export interface ProgressingFileTypePlain {
  id: number
  name: string
  img: ResourceStr
  fileType: FileType
  progress: number
  progressDes: string
  speed: string
  vipStatus: boolean
  isStop: boolean
  path: string
}

/**
 * 任务失败文件类型
 */
@ObservedV2
export class FailedFileType {
  @Trace name: string = ''
  @Trace img: ResourceStr = ''
  @Trace des: string = ''
  @Trace isRetry: boolean = false
  @Trace path: string = ''
  // 滑动x坐标
  @Trace x: number = 0

  toJSON(): FailedFileTypePlain {
    return {
      name: this.name,
      img: this.img,
      des: this.des,
      isRetry: this.isRetry,
      path: this.path
    }
  }

  // 从 JSON 字符串反序列化为 FailedFileType 实例
  static fromJSON(json: string): FailedFileType {
    const obj = JSON.parse(json) as FailedFileTypePlain
    return FailedFileType.fromPlain(obj)
  }

  // 从普通对象构建 FailedFileType
  static fromPlain(obj: Partial<FailedFileTypePlain>): FailedFileType {
    const fi = new FailedFileType()
    fi.path = obj.path ?? ''
    fi.name = obj.name ?? ''
    fi.des = obj.des ?? ''
    fi.img = obj.img ?? ''
    fi.isRetry = obj.isRetry ?? false
    return fi
  }
}

export interface FailedFileTypePlain {
  name: string
  img: ResourceStr
  des: string
  isRetry: boolean
  path: string
}

/**
 * 上传文件状态类
 */
export interface UploadFileStatus {
  // 文件名称
  fileName: string;

  // 文件的原路径
  filePath: string;

  // 文件后缀
  fileSuffix: FileType;

  // 文件大小
  fileSize: number;

  // 创建时间
  createTime: string;

  // 状态码
  code: UploadFileStatusCode;

  // 传输进度
  progress: number;

  // 开始时间
  startTime: number;

  // 传输时间
  progressTime: number;

  // vip状态
  vipStatus: boolean;

  // 缓存路径
  cachePath: string;
}

/**
 * 上传文件状态码
 */
export enum UploadFileStatusCode {
  SUCCESS = '000200',
  FAILED = '000401',
  PROGRESSING = '000100'
}

/**
 * 下载文件状态类
 */
export interface DownloadFileStatus {
  // 文件名称
  fileName: string;

  // 文件的原路径
  filePath: string;

  // 文件后缀
  fileSuffix: FileType;

  // 文件大小
  fileSize: number;

  // 创建时间
  createTime: string;

  // 状态码
  code: DownloadFileStatusCode;

  // 传输进度
  progress: number;

  // 开始时间
  startTime: number;

  // 传输时间
  progressTime: number;

  // vip状态
  vipStatus: boolean;
}

/**
 * 下载文件状态码
 */
export enum DownloadFileStatusCode {
  SUCCESS = '000200',
  FAILED = '000401',
  PROGRESSING = '000100'
}

/**
 * 文档类型枚举
 */
export enum DocumentType {
  PDF,
  TXT,
  DOC,
  DOCX,
  XLS,
  XLSX,
  PPT,
  PPTX,
  AUDIO,
}
