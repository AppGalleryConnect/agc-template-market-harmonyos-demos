import { ShareKinds } from '../model/Model';

export const secondShareList:ShareKinds[] = [
  {
    id:'wechat',
    icon:'app.media.share_wechat',
    name:'微信',
  },
  {
    id:'wechat_feed',
    icon:'app.media.wechat_feed',
    name:'朋友圈',
  },
  {
    id:'qq',
    icon:'app.media.qq',
    name:'QQ',
  },
  {
    id:'save',
    icon:'app.media.save',
    name:'保存图片',
  }
]

export const firstShareList:ShareKinds[][] = [
  [
    {
      id:'wechat',
      icon:'app.media.share_wechat',
      name:'微信',
    },
    {
      id:'qq',
      icon:'app.media.qq',
      name:'QQ',
    },
    {
      id:'copy_link',
      icon:'app.media.copy_link_tow',
      name:'复制链接',
    }
  ]
]