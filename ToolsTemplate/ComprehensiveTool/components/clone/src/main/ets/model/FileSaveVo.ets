import { FileType } from '../common/Constant'

export interface FileSaveVo {
  path: string
  offset: number,
  data: ArrayBuffer,
  type:FileType
}