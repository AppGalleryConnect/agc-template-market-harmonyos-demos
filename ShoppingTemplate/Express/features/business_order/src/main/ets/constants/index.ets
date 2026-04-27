import { INodeItem } from '../components/CommonTimeLine';

export const selectData: SelectOption[] = [
  { value: '全部' }, { value: '待取件' }, { value: '已揽件' }, { value: '运送中' }, { value: '派送中' },
  { value: '已签收' }, { value: '已取消' },
]


export const nodeListData: INodeItem[] = [
  {
    image: $r('app.media.ic_host'),
    selectedImage: $r('app.media.ic_host_selected'),
    text: '待取件',
    time: '',
    description: '',
  },
  {
    image: $r('app.media.ic_lan'),
    selectedImage: $r('app.media.ic_lan_selected'),
    text: '已揽件',
    time: '',
    description: '',
  },
  {
    image: $r('app.media.ic_yun'),
    selectedImage: $r('app.media.ic_yun_selected'),
    text: '运送中',
    time: '',
    description: '',
  },
  {
    image: $r('app.media.ic_send'),
    selectedImage: $r('app.media.ic_send_selected'),
    text: '派送中',
    time: '',
    description: '',
  },
  {
    image: $r('app.media.ic_get'),
    selectedImage: $r('app.media.ic_get_selected'),
    text: '已签收',
    time: '',
    description: '',
  },
]