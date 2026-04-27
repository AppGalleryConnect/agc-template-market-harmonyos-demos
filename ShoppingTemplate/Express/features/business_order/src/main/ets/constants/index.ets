import { ParcelStatus } from 'lib_foundation';
import { INodeItem } from '../models/Model';

export const FILTER_OPTIONS: SelectOption[] = [
  { value: '全部' }, { value: '待取件' }, { value: '待入柜' }, { value: '已取件' },
  { value: '运送中' }, { value: '派送中' }, { value: '待签收' }, { value: '已签收' }, { value: '已取消' },
]

export const nodeListData: INodeItem[] = [
  {
    image: $r('app.media.ic_host'),
    selectedImage: $r('app.media.ic_host_selected'),
    status: ParcelStatus.AWAITING_PICKUP,
  },
  {
    image: $r('app.media.ic_pending_locker'),
    selectedImage: $r('app.media.ic_pending_locker_selected'),
    status: ParcelStatus.PENDING_LOCKER,
  },
  {
    image: $r('app.media.ic_host'),
    selectedImage: $r('app.media.ic_host_selected'),
    status: ParcelStatus.COLLECTED,
  },
  {
    image: $r('app.media.ic_yun'),
    selectedImage: $r('app.media.ic_yun_selected'),
    status: ParcelStatus.IN_TRANSIT,
  },
  {
    image: $r('app.media.ic_send'),
    selectedImage: $r('app.media.ic_send_selected'),
    status: ParcelStatus.DELIVERY,
  },
  {
    image: $r('app.media.ic_delivery'),
    selectedImage: $r('app.media.ic_delivery_selected'),
    status: ParcelStatus.OUT_FOR_DELIVERY,
  },
  {
    image: $r('app.media.ic_get'),
    selectedImage: $r('app.media.ic_get_selected'),
    status: ParcelStatus.DELIVERED,
  },
]

// mock收件人手机号
export const MOCK_RECEIVER_PHONE = '12345678900';

// 当前面板所属高度
export enum DetentsType {
  MIN = 0,
  MID = 1,
  MAX = 2
}