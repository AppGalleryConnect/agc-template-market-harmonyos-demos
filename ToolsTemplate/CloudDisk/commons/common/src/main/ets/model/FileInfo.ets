/**
 * @fileType: common
 * @zhName: 文件信息模型类
 */
import { TimeUtil } from '../util/TimeUtil'

// 文件信息
@ObservedV2
export class FileInfo {
  // 文件id
  fileId: number = 0
  // 父文件id
  parentFileId: number = 0
  // 文件类型
  fileType: FileType = FileType.Other
  // 文件大小
  fileSize: string = ''
  // 文件尺寸
  resolution?: string = ''
  // 文件名称
  @Trace name: string = ''
  // 文件创建时间
  createTime: string = ''
  // 文件更新时间
  updateTime: string = ''
  // 本地路径
  path: string = ''
  // 是否已收藏
  @Trace isCollected: boolean = false
  // 是否已删除
  isDeleted: boolean = false
  // 是否隐私空间
  isPrivate: boolean = false
  // 资源路径
  downloadUrl: string = ''
  // 缩略图
  @Trace thumbnailUrl: string = ''
  // 时长
  duration: string = ''
  // 是否过期
  expire: boolean = false
  // 有效期
  usefullTime: string = ''
  // 提取码
  getCode: string = ''
  // 子文件列表
  @Trace contentList: FileInfo[] = []
  // 是否勾选
  @Trace isChecked: boolean = false
  // 文件描述
  @Trace des: string = ''
  // 进度
  @Trace progress: number = 0
  // 文件字节大小
  @Trace fileSizeByte: number = 0
  // 进度描述
  @Trace progressDes: string = ''
  // 传输速度
  @Trace speed: string = ''
  // 是否会员
  @Trace vipStatus: boolean = false
  // 是否停止
  @Trace isStop: boolean = false
  // 是否完成状态
  @Trace isCompleted: boolean = false
  // 上传成功失败
  @Trace isSucceed: boolean = false
  // 过期时间，0-未设置，-1-永久有效
  @Trace expireTime: number = 0
  //删除剩余时间
  @Trace deletetime: number = 0

  // 删除后缀
  removeFileExtension(): string {
    if (!this.name) {
      return this.name;
    } // 空字符串直接返回

    const lastDotIndex = this.name.lastIndexOf('.');
    if (lastDotIndex <= 0) {
      return this.name;
    }
    return this.name.substring(0, lastDotIndex);
  }

  // 获取过期时间
  checkExpireTime(): string {
    if (this.expireTime === -1) {
      return '永久有效'
    }
    const currentTime: number = Date.now()
    if (this.expireTime === 2) {
      if (currentTime > this.expireTime) {
        return '已过期'
      }
    }

    if (this.expireTime === 3) {
      return '已取消分享'
    }

    const days: number = Math.round((this.expireTime - currentTime) / (24 * 60 * 60 * 1000))
    return days.toString() + '天后过期'

  }

  // 回收站删除事件
  checkFileDeleteTime(): string {
    if (this.deletetime === 0) {
      return this.createTime
    }

    return TimeUtil.formatDate(this.deletetime, TimeUtil.PATTERN_DATE_TIME_CN)
  }

  // 获取回收站内容
  checkRecycleBinText(): string {
    const dif = Date.now() - this.deletetime
    const days: number = 7 - Math.round(dif / (24 * 60 * 60 * 1000))
    if (days > 0) {
      return days.toString() + '天后删除'
    }

    return ''
  }

  // 获取过期时间
  checkExpireTimeColor(): ResourceColor {
    // 未设置
    if (this.expireTime === 0) {
      return '#4C000000'
    }

    // 永久有效
    if (this.expireTime === -1) {
      return '#2FAFFF'
    }

    const currentTime: number = Date.now()
    if (currentTime > this.expireTime) {
      return '#99000000'
    }

    return '#4C000000'
  }

  // 根据文本内容修改时间戳
  changeTimeBy(value: string) {
    if (value.length === 0) {
      this.expireTime = 0
      return
    }

    // 永久有效
    if (value.includes('永久')) {
      this.expireTime = -1
      return
    }

    // 7天
    if (value.includes('7')) {
      const sevenDaysMs = 7 * 24 * 60 * 60 * 1000
      this.expireTime = Date.now() + sevenDaysMs
      return
    }

    // 14天
    if (value.includes('14')) {
      const sevenDaysMs = 14 * 24 * 60 * 60 * 1000
      this.expireTime = Date.now() + sevenDaysMs
      return
    }

    // 30天
    const sevenDaysMs = 30 * 24 * 60 * 60 * 1000
    this.expireTime = Date.now() + sevenDaysMs
  }

  constructor(fileType: FileType = 0, name: string = '', time: string = '') {
    this.fileType = fileType
    this.name = name
    this.createTime = time
  }

  // 序列化为 JSON 友好对象（JSON.stringify 会自动调用 toJSON）
  toJSON(): FileInfoPlain {
    return {
      fileId: this.fileId,
      fileType: this.fileType,
      fileSize: this.fileSize,
      name: this.name,
      createTime: this.createTime,
      updateTime: this.updateTime,
      path: this.path,
      isCollected: this.isCollected,
      isDeleted: this.isDeleted,
      isPrivate: this.isPrivate,
      downloadUrl: this.downloadUrl,
      duration: this.duration,
      expire: this.expire,
      usefullTime: this.usefullTime,
      getCode: this.getCode,
      contentList: this.contentList.map((c) => c.toJSON()),
      isChecked: this.isChecked,
      des: this.des,
      progress: this.progress,
      fileSizeByte: this.fileSizeByte,
      progressDes: this.progressDes,
      speed: this.speed,
      vipStatus: this.vipStatus,
      isStop: this.isStop,
      isCompleted: this.isCompleted,
      isSucceed: this.isSucceed,
      expireTime: this.expireTime,
      deletetime: this.deletetime,
      parentFileId: this.parentFileId,
      thumbnailUrl: this.thumbnailUrl
    }
  }

  // 从 JSON 字符串反序列化为 FileInfo 实例
  static fromJSON(json: string): FileInfo {
    const obj = JSON.parse(json) as FileInfoPlain
    return FileInfo.fromPlain(obj)
  }

  // 更新fileId信息
  private static updateFileIdInfos(target: FileInfo, obj: Partial<FileInfoPlain>) {
    target.fileId = obj.fileId ?? 0
    target.updateTime = obj.updateTime ?? ''
    target.path = obj.path ?? ''
    target.fileSize = obj.fileSize ?? ''
    target.isCollected = obj.isCollected ?? false
    target.isDeleted = obj.isDeleted ?? false
    target.isPrivate = obj.isPrivate ?? false
    target.downloadUrl = obj.downloadUrl ?? ''
    target.duration = obj.duration ?? ''
  }

  // 更新时间信息
  private static changeTimeInfos(lastObj: FileInfo, origin: Partial<FileInfoPlain>) {
    lastObj.expire = origin.expire ?? false
    lastObj.usefullTime = origin.usefullTime ?? ''
    lastObj.getCode = origin.getCode ?? ''
    lastObj.isChecked = origin.isChecked ?? false
    lastObj.des = origin.des ?? ''
    lastObj.progress = origin.progress ?? 0
    lastObj.fileSizeByte = origin.fileSizeByte ?? 0
    lastObj.progressDes = origin.progressDes ?? ''
    lastObj.speed = origin.speed ?? ''
  }

  // 更新其他信息
  private static updateOtherInfos(target: FileInfo, origin: Partial<FileInfoPlain>) {
    target.vipStatus = origin.vipStatus ?? false
    target.isStop = origin.isStop ?? false
    target.isCompleted = origin.isCompleted ?? false
    target.isSucceed = origin.isSucceed ?? false
    target.expireTime = origin.expireTime ?? 0
    target.deletetime = origin.deletetime ?? 0
    target.parentFileId = origin.parentFileId ?? 0
    target.thumbnailUrl = origin.thumbnailUrl ?? ''
  }

  // 从普通对象构建 FileInfo（支持嵌套 contentList）
  static fromPlain(obj: Partial<FileInfoPlain>): FileInfo {
    const fi = new FileInfo(
      (obj.fileType ?? FileType.Other) as FileType,
      obj.name ?? '',
      obj.createTime ?? ''
    )

    FileInfo.updateFileIdInfos(fi,obj)
    FileInfo.changeTimeInfos(fi,obj)
    FileInfo.updateOtherInfos(fi, obj)


    const list = obj.contentList ?? []
    fi.contentList = list.map((c) => FileInfo.fromPlain(c))

    return fi
  }
}

// 云盘文件类型
export enum FileType {
  All = 0,
  Picture = 1,
  Video = 2,
  File = 3,
  Audio = 4,
  Other = 5,
  Director = 6, // 文件夹
  PrivateSpace = 7, // 隐私空间
}

// 与 FileInfo 对应的可序列化结构类型
export interface FileInfoPlain {
  fileId: number
  fileType: FileType
  fileSize: string
  name: string
  createTime: string
  updateTime: string
  path: string
  isCollected: boolean
  isDeleted: boolean
  isPrivate: boolean
  downloadUrl: string
  thumbnailUrl: string
  duration: string
  expire: boolean
  usefullTime: string
  getCode: string
  contentList: FileInfoPlain[]
  isChecked: boolean
  des: string
  progress: number
  fileSizeByte: number
  progressDes: string
  speed: string
  vipStatus: boolean
  isStop: boolean
  isCompleted: boolean
  isSucceed: boolean
  expireTime: number
  deletetime: number
  parentFileId: number
}