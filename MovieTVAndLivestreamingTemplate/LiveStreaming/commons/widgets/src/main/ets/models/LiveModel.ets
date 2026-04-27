import { getMedia } from '@agctemplate/resources'

export interface LiveCard {
  id: string
  cover: ResourceStr
  title: string
  streamer: string
  category: string
  status: string
  watching: number
  avatar: ResourceStr
}

export class LiveCardModel {
  id: string
  cover: ResourceStr
  title: string
  streamer: string
  category: string
  status: string
  watching: number
  avatar: ResourceStr

  constructor(item: LiveCard) {
    this.id = item.id
    this.cover = item.cover
    this.title = item.title
    this.streamer = item.streamer
    this.category = item.category
    this.status = item.status
    this.watching = item.watching
    this.avatar = item.avatar
  }
}

export const cardsData: Array<LiveCard> = [
  {
    id: '1',
    cover: getMedia('app.media.cover_3'),
    title: '旅行vlog直播',
    watching: 10000,
    category: '旅游',
    streamer: 'Leo在路上',
    status: '1',
    avatar: getMedia('app.media.likes')
  } as LiveCard,
  {
    id: '2',
    cover: getMedia('app.media.cover_4'),
    title: '新版本BOSS速通',
    watching: 16666,
    category: '维京传奇',
    streamer: '暴躁桃子',
    avatar: getMedia('app.media.image_yu')
  } as LiveCard,
  {
    id: '3',
    cover: getMedia('app.media.cover_1'),
    title: '游戏冲榜',
    watching: 18100,
    category: '王者荣耀',
    streamer: '轩哥开黑',
    avatar: getMedia('app.media.image_labubu')
  } as LiveCard,
  {
    id: '4',
    cover: getMedia('app.media.cover_2'),
    title: '美食速递',
    watching: 666,
    category: '美食',
    streamer: '小雅吃',
    avatar: getMedia('app.media.avatar')
  } as LiveCard,
  {
    id: '5',
    cover: getMedia('app.media.cover_2'),
    title: '外卖盲盒挑战',
    watching: 1800,
    category: '美食',
    streamer: '姜姜吃不胖',
    avatar: getMedia('app.media.avatar')
  } as LiveCard,
  {
    id: '6',
    cover: getMedia('app.media.cover_4'),
    title: '弹唱网友点歌',
    watching: 1314,
    category: '唱歌',
    streamer: '吉他老张',
    avatar: getMedia('app.media.celebrate')
  } as LiveCard,
  {
    id: '7',
    cover: getMedia('app.media.cover_3'),
    title: '监狱跑刀',
    watching: 78787878,
    category: '三角洲行动',
    streamer: '老飞鱼66',
    avatar: getMedia('app.media.image_hui')
  } as LiveCard,
  {
    id: '8',
    cover: getMedia('app.media.cover_3'),
    title: 'Excel函数速成',
    watching: 1919,
    category: '学习',
    streamer: '职场小达人',
    avatar: getMedia('app.media.likes')
  } as LiveCard,
  {
    id: '9',
    cover: getMedia('app.media.cover_4'),
    title: '15分钟燃脂训练',
    watching: 999,
    category: '运动',
    streamer: '健身小熊',
    avatar: getMedia('app.media.image_ti')
  } as LiveCard,
  {
    id: '10',
    cover: getMedia('app.media.cover_1'),
    title: '学生党闭眼入评测',
    watching: 114514,
    category: '数码',
    streamer: '赛博阿力',
    avatar: getMedia('app.media.presents')
  } as LiveCard
]