import { OperateType } from 'commonlib'

export enum PhotoType {
  Beautification = 0,
  Collage = 1
}

export interface PhotoOperateParam {
  photoType: PhotoType
  operateType: OperateType
  filterName?: string
}