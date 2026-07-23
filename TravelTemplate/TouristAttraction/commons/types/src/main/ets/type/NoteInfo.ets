export class NoteInfo {
  noteId: number = 0
  name: string = ''
  banner: ResourceStr = ''
  banners: ResourceStr[] = []
  detail: string = ''
  createTime: string = ''
  location: string = ''
  thumbsup: number = 0
  // 攻略标签 1:最新  2：最热
  tag:number=0
}