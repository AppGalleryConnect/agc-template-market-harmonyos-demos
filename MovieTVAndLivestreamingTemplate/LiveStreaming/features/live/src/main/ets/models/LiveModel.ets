import { AppStorageV2 } from '@kit.ArkUI'

//直播数据
interface LiveData {
  audienceNum: number //累计观看人数
  likeNum: number //点赞
  incomeNum: number //收益
  addFansNum: number //新增粉丝
  bulletNum: number //弹幕数量
  bossNum: number //付费人数
}

export interface LiveMsg {
  id: string
  cover: ResourceStr
  title: string
  streamer: string
  category: string
  status: string
  watching: number
  avatar: ResourceStr
  location: string
  nickname: string
  data: LiveData
  liveTime: number
}

@ObservedV2
export class LiveMsgModel {
  @Trace id: string
  @Trace cover: ResourceStr
  @Trace title: string
  @Trace streamer: string
  @Trace category: string
  @Trace status: string
  @Trace watching: number
  @Trace avatar: ResourceStr
  @Trace location: string
  @Trace nickname: string
  @Trace data: LiveData
  @Trace liveTime: number
  private static _instance: LiveMsgModel;

  constructor(item: LiveMsg) {
    this.id = item.id
    this.cover = item.cover
    this.title = item.title
    this.streamer = item.streamer
    this.category = item.category
    this.status = item.status
    this.watching = item.watching
    this.avatar = item.avatar
    this.location = item.location
    this.nickname = item.nickname
    this.data = item.data
    this.liveTime = item.liveTime
  }

  public static get instance() {
    if (!LiveMsgModel._instance) {
      LiveMsgModel._instance = AppStorageV2.connect(LiveMsgModel, '_instance', () => new LiveMsgModel({
        id: '30',
        cover: $r('app.media.live_cover'),
        title: '看会儿CS再打瓦瓦瓦瓦瓦瓦瓦瓦瓦瓦瓦瓦瓦瓦',
        streamer: '玩机器Machine',
        category: 'CS2',
        status: 'online',
        watching: 5340,
        avatar: $r('app.media.avatar'),
        location: '',
        nickname: '我叫李苏苏',
        data: {
          audienceNum: 124000,
          likeNum: 124000,
          incomeNum: 22520,
          addFansNum: 300,
          bulletNum: 3000,
          bossNum: 200
        },
        liveTime: 0
      }))!;
    }
    return LiveMsgModel._instance;
  }
}