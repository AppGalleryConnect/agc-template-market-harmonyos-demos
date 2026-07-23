import { ShareAppType, ShareWay } from './ShareEnum';
import { ShareKinds } from './ShareParams';

export const unifiedShareList: ShareKinds[][] = [
  [
    {
      kindId: ShareAppType.WECHAT_SESSION,
      icon: $r('app.media.ic_wechat'),
      label: '微信',
    },
    {
      kindId: ShareAppType.WECHAT_TIMELINE,
      icon: $r('app.media.ic_wechat_timeline'),
      label: '朋友圈',
    },
    {
      kindId: ShareAppType.QQ,
      icon: $r('app.media.ic_qq'),
      label: 'QQ',
    },
    {
      kindId: ShareAppType.WEIBO,
      icon: $r('app.media.ic_weibo'),
      label: '微博',
    },
  ],
  [
    {
      kindId: ShareWay.POSTER,
      icon: $r('sys.symbol.picture_badge_arrow_down'),
      label: '生成海报',
    },
    {
      kindId: ShareWay.COPY_TO_PASTEBOARD,
      icon: $r('sys.symbol.link'),
      label: '复制链接',
    },
    {
      kindId: ShareWay.SYSTEM,
      icon: $r('sys.symbol.dot_radiowaves_left_and_right'),
      label: '系统分享',
    },
  ],
]

export const posterShareList: ShareKinds[] = [
  {
    kindId: ShareAppType.WECHAT_SESSION,
    icon: $r('app.media.ic_wechat'),
    label: '微信',
    isPoster: true,
  },
  {
    kindId: ShareAppType.WECHAT_TIMELINE,
    icon: $r('app.media.ic_wechat_timeline'),
    label: '朋友圈',
    isPoster: true,
  },
  {
    kindId: ShareAppType.WEIBO,
    icon: $r('app.media.ic_weibo'),
    label: '微博',
    isPoster: true,
  },
  {
    kindId: ShareWay.SAVE_TO_ALBUM,
    icon: $r('app.media.ic_public_save'),
    label: '保存图片',
    isPoster: true,
  },
]