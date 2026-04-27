import { ValuesBucket } from '@kit.ArkData'
import { TransferType } from '../common/Constant'

export interface FileDo extends ValuesBucket {
  id: number
  name: string
  uri: string
  size: number
  type: string
  time: string
  tranType: TransferType //传输类型
  deviceName: string //设备名称
  deviceImg: string //设备头像
}