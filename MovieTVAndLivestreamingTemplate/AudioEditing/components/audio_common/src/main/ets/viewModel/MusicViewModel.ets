import { parsePath } from '../util/CommonUtil'

@ObservedV2
export class MusicViewModel {
  uri: string = '' //文件uri,音乐库中全局唯一，作品集中该数据为空
  title: string = '' //音频名称
  duration: number = 0 //时长 毫秒
  size: string = '0KB' //KB
  format: string = '' //格式
  sourcePath: string = '' //音频源文件文件沙箱路径
  pcmName: string = '' //uri名称，用来设置pcm码文件名称

  @Trace checkBoxStatus: boolean = false //列表元素选中状态，作品数据使用

  constructor(uri: string, title: string, duration: number, size: string, format: string, path: string) {
    this.uri = uri
    this.title = title
    this.duration = duration
    this.size = size
    this.format = format
    this.sourcePath = path
    this.pcmName = parsePath(uri, 0)
  }

  setCheckBoxStatus(status: boolean) {
    this.checkBoxStatus = status
  }

  setTitle(title: string) {
    this.title = title
  }
}