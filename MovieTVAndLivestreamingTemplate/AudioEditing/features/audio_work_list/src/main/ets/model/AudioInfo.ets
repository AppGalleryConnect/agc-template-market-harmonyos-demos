/**
 * 音频信息模型
 */
export class AudioInfo {
  uri: string = ''
  title: string = ''
  duration: number = 0
  size: string = ''
  format: string = ''
  path: string = ''

  constructor(
    uri?: string,
    title?: string,
    duration?: number,
    size?: string,
    format?: string,
    path?: string
  ) {
    this.uri = uri || ''
    this.title = title || ''
    this.duration = duration || 0
    this.size = size || ''
    this.format = format || ''
    this.path = path || ''
  }
}
