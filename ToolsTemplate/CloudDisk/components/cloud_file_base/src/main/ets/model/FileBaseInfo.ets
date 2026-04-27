// 文件基础信息
@ObservedV2
export class FileBaseInfo {
  // 文件id
  fileId: number = 0
  // 父文件id
  parentFileId: number = 0
  // 文件类型
  fileType: FileBaseType = FileBaseType.OTHER
  // 文件大小
  fileSize: string = ''
  // 文件名称
  @Trace name: string = ''
  // 文件创建时间
  createTime: string = ''
  // 是否已收藏
  @Trace isCollected: boolean = false
  // 是否隐私空间
  isPrivate: boolean = false
  // 是否过期
  expire: boolean = false
  // 有效期
  usefullTime: string = ''
  // 提取码
  getCode: string = ''
  // 资源路径
  downloadUrl: string = ''
  // 缩略图
  @Trace thumbnailUrl: string = ''
  // 文件尺寸
  resolution: string = ''
  // 文件更新时间
  updateTime: string = ''
  // 本地路径
  path: string = ''
  // 子文件列表
  @Trace contentList: FileBaseInfo[] = []
  // 过期时间，0-未设置，-1-永久有效
  @Trace expireTime: number = 0

  // 删除后缀
  removeFileBaseExtension(): string {
    if (!this.name) {
      return this.name;
    }

    const lastIndex = this.name.lastIndexOf('.');
    if (lastIndex <= 0) {
      return this.name;
    }
    return this.name.substring(0, lastIndex);
  }

  // 获取分享过期时间
  checkShareExpireTime(): string {
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

  // 获取分享过期时间颜色
  checkShareExpireTimeColor(): ResourceColor {
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
  changeTimeBy(content: string) {
    if (content.length === 0) {
      this.expireTime = 0
      return
    }

    // 永久有效
    if (content.includes('永久')) {
      this.expireTime = -1
      return
    }

    // 7天
    if (content.includes('7')) {
      const sevenDaysMs = 7 * 24 * 60 * 60 * 1000
      this.expireTime = Date.now() + sevenDaysMs
      return
    }

    // 14天
    if (content.includes('14')) {
      const sevenDaysMs = 14 * 24 * 60 * 60 * 1000
      this.expireTime = Date.now() + sevenDaysMs
      return
    }

    // 30天
    const sevenDaysMs = 30 * 24 * 60 * 60 * 1000
    this.expireTime = Date.now() + sevenDaysMs
  }

  // 序列化为 JSON 友好对象（JSON.stringify 会自动调用 toJSON）
  toJSON(): FileBaseInfoPlain {
    return {
      fileId: this.fileId,
      fileType: this.fileType,
      fileSize: this.fileSize,
      name: this.name,
      createTime: this.createTime,
      isCollected: this.isCollected,
      isPrivate: this.isPrivate,
      expire: this.expire,
      usefullTime: this.usefullTime,
      contentList: this.contentList.map((c) => c.toJSON()),
      expireTime: this.expireTime,
      parentFileId: this.parentFileId,
      downloadUrl: this.downloadUrl,
      thumbnailUrl: this.thumbnailUrl,
      path: this.path,
      updateTime: this.updateTime,
      resolution: this.resolution
    }
  }

  // 从 JSON 字符串反序列化为 FileBaseInfo 实例
  static fromJSON(json: string): FileBaseInfo {
    const obj = JSON.parse(json) as FileBaseInfoPlain
    return FileBaseInfo.fromPlain(obj)
  }

  // 从普通对象构建 FileBaseInfo（支持嵌套 contentList）
  static fromPlain(obj: Partial<FileBaseInfoPlain>): FileBaseInfo {
    const baseInfo = new FileBaseInfo()

    baseInfo.fileType = obj.fileType ?? FileBaseType.OTHER
    baseInfo.name = obj.name ?? ''
    baseInfo.createTime = obj.createTime ?? ''
    baseInfo.fileId = obj.fileId ?? 0
    baseInfo.fileSize = obj.fileSize ?? ''
    baseInfo.isCollected = obj.isCollected ?? false
    baseInfo.isPrivate = obj.isPrivate ?? false
    baseInfo.expire = obj.expire ?? false
    baseInfo.usefullTime = obj.usefullTime ?? ''
    baseInfo.expireTime = obj.expireTime ?? 0
    baseInfo.parentFileId = obj.parentFileId ?? 0
    baseInfo.downloadUrl = obj.downloadUrl ?? ''
    baseInfo.thumbnailUrl = obj.thumbnailUrl ?? ''
    baseInfo.resolution = obj.resolution ?? ''
    baseInfo.updateTime = obj.updateTime ?? ''
    baseInfo.path = obj.path ?? ''

    const list = obj.contentList ?? []
    baseInfo.contentList = list.map((c) => FileBaseInfo.fromPlain(c))

    return baseInfo
  }
}

// 云盘文件类型
export enum FileBaseType {
  // 全部
  ALL = 0,

  // 图片
  PICTURE = 1,

  // 视频
  VIDEO = 2,

  // 文件
  FILE = 3,

  // 音频
  AUDIO = 4,

  // 其他
  OTHER = 5,

  // 文件夹
  DIRECTOR = 6,

  // 隐私空间
  PRIVATESPACE = 7,
}

// 与 FileInfo 对应的可序列化结构类型
export interface FileBaseInfoPlain {
  fileId: number
  fileType: FileBaseType
  fileSize: string
  name: string
  createTime: string
  isCollected: boolean
  isPrivate: boolean
  expire: boolean
  usefullTime: string
  contentList: FileBaseInfoPlain[]
  expireTime: number
  parentFileId: number
  downloadUrl: string
  thumbnailUrl: string
  resolution: string
  updateTime: string
  path: string
}