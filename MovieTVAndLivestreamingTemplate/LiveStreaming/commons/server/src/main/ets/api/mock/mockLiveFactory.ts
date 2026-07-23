import { LiveInfoModel } from "../../bean/response/GetLiveInfoRes";
import { AudienceRes, MockAudienceFactory } from "./mockAudienceFactory";

class MockLiveFactory {
  uniqueId: number = 0;
  liveRepo: Map<string, LiveInfoModel> = new Map;
  watchedLives: Map<string, LiveInfoModel> = new Map
  mockAudienceFactor: MockAudienceFactory = new MockAudienceFactory()
  liveTitles: Array<string> = [
    '花瓣杯5V5总决赛',
    '直播间标题',
    '纵横中世纪欧洲大陆',
    '伏地魔',
    '软妹纸不会嗲~~超会玩游戏',
    'LOL'
  ]

  videoUrl = [
    'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/drama_video/2.m3u8', //此行配置竖屏视频进行调试
    'https://consumer.huawei.com/content/dam/huawei-cbg-site/cn/mkt/plp/new-phones/video/pocket-series.mp4' //此行配置横屏视频进行调试
  ]
  coverUrls = [
    'app.media.cover_1',
    'app.media.cover_2',
    'app.media.cover_3',
    'app.media.cover_4'
  ]

  constructor() {
    let index: number = 0;
    let streamers = this.mockAudienceFactor.getRandomAudienceIds(16)

    this.mockAudienceFactor.getAudienceById(streamers[0])!.nickName = 'Leo在路上';
    this.mockAudienceFactor.getAudienceById(streamers[1])!.nickName = '暴躁桃子';
    this.mockAudienceFactor.getAudienceById(streamers[2])!.nickName = '轩哥开黑';
    this.mockAudienceFactor.getAudienceById(streamers[3])!.nickName = '小雅吃';
    this.mockAudienceFactor.getAudienceById(streamers[4])!.nickName = '姜姜吃不胖';
    this.mockAudienceFactor.getAudienceById(streamers[5])!.nickName = '吉他老张';
    this.mockAudienceFactor.getAudienceById(streamers[6])!.nickName = '老飞鱼66';
    this.mockAudienceFactor.getAudienceById(streamers[7])!.nickName = '职场小达人';
    this.mockAudienceFactor.getAudienceById(streamers[8])!.nickName = '健身小熊';
    this.mockAudienceFactor.getAudienceById(streamers[9])!.nickName = '赛博阿力';

    this.liveRepo.set('1',
      {
        id: '1',
        url: this.videoUrl[index%this.videoUrl.length],
        cover: 'app.media.cover_3',
        title: '旅行vlog直播',
        streamer: this.mockAudienceFactor.getAudienceById(streamers[0]),
        audiences: this.mockAudienceFactor.getRandomAudienceArr(),
        category: '游戏',
        status: '直播中',
        watching: 1.3,
        watchTime: new Date,
        isSelectToDelete: false,
        preferType: index % 2
      })
    index++;
    this.liveRepo.set('2',
      {
        id: '2',
        url: this.videoUrl[index%this.videoUrl.length],
        cover: 'app.media.cover_4',
        title: '新版本BOSS速通',
        streamer: this.mockAudienceFactor.getAudienceById(streamers[1]),
        audiences: this.mockAudienceFactor.getRandomAudienceArr(),
        category: '游戏',
        status: '已结束',
        watching: 1.3,
        watchTime: new Date,
        isSelectToDelete: false,
        preferType: index % 2
      })
    index++;
    this.liveRepo.set('3',
      {
        id: '3',
        url: this.videoUrl[index%this.videoUrl.length],
        cover: 'app.media.cover_1',
        title: '游戏冲榜',
        streamer: this.mockAudienceFactor.getAudienceById(streamers[2]),
        audiences: this.mockAudienceFactor.getRandomAudienceArr(),
        category: '游戏',
        status: '直播中',
        watching: 1.3,
        watchTime: new Date,
        isSelectToDelete: false,
        preferType: index % 2
      })
    index++;
    this.liveRepo.set('4',
      {
        id: '4',
        url: this.videoUrl[index%this.videoUrl.length],
        cover: 'app.media.cover_2',
        title: '美食速递',
        streamer: this.mockAudienceFactor.getAudienceById(streamers[3]),
        audiences: this.mockAudienceFactor.getRandomAudienceArr(),
        category: '游戏',
        status: '直播中',
        watching: 1.3,
        watchTime: new Date,
        isSelectToDelete: false,
        preferType: index % 2
      })
    index++;
    this.liveRepo.set('5',
      {
        id: '5',
        url: this.videoUrl[index%this.videoUrl.length],
        cover: 'app.media.cover_2',
        title: '外卖盲盒挑战',
        streamer: this.mockAudienceFactor.getAudienceById(streamers[4]),
        audiences: this.mockAudienceFactor.getRandomAudienceArr(),
        category: '游戏',
        status: '直播中',
        watching: 1.3,
        watchTime: new Date,
        isSelectToDelete: false,
        preferType: index % 2
      })
    index++;
    this.liveRepo.set('6',
      {
        id: '6',
        url: this.videoUrl[index%this.videoUrl.length],
        cover: 'app.media.cover_4',
        title: '弹唱网友点歌',
        streamer: this.mockAudienceFactor.getAudienceById(streamers[5]),
        audiences: this.mockAudienceFactor.getRandomAudienceArr(),
        category: '游戏',
        status: '直播中',
        watching: 1.3,
        watchTime: new Date,
        isSelectToDelete: false,
        preferType: index % 2
      })
    index++;
    this.liveRepo.set('7',
      {
        id: '7',
        url: this.videoUrl[index%this.videoUrl.length],
        cover: 'app.media.cover_3',
        title: '监狱跑刀',
        streamer: this.mockAudienceFactor.getAudienceById(streamers[6]),
        audiences: this.mockAudienceFactor.getRandomAudienceArr(),
        category: '游戏',
        status: '直播中',
        watching: 1.3,
        watchTime: new Date,
        isSelectToDelete: false,
        preferType: index % 2
      })
    index++;
    this.liveRepo.set('8',
      {
        id: '8',
        url: this.videoUrl[index%this.videoUrl.length],
        cover: 'app.media.cover_3',
        title: 'Excel函数速成',
        streamer: this.mockAudienceFactor.getAudienceById(streamers[7]),
        audiences: this.mockAudienceFactor.getRandomAudienceArr(),
        category: '游戏',
        status: '直播中',
        watching: 1.3,
        watchTime: new Date,
        isSelectToDelete: false,
        preferType: index % 2
      })
    index++;
    this.liveRepo.set('9',
      {
        id: '9',
        url: this.videoUrl[index%this.videoUrl.length],
        cover: 'app.media.cover_4',
        title: '15分钟燃脂训练',
        streamer: this.mockAudienceFactor.getAudienceById(streamers[8]),
        audiences: this.mockAudienceFactor.getRandomAudienceArr(),
        category: '游戏',
        status: '直播中',
        watching: 1.3,
        watchTime: new Date,
        isSelectToDelete: false,
        preferType: index % 2
      })
    index++;
    this.liveRepo.set('10',
      {
        id: '10',
        url: this.videoUrl[index%this.videoUrl.length],
        cover: 'app.media.cover_1',
        title: '学生党闭眼入评测',
        streamer: this.mockAudienceFactor.getAudienceById(streamers[9]),
        audiences: this.mockAudienceFactor.getRandomAudienceArr(),
        category: '游戏',
        status: '直播中',
        watching: 1.3,
        watchTime: new Date,
        isSelectToDelete: false,
        preferType: index % 2
      })
    index++;
    this.liveRepo.set('11',
      {
        id: '11',
        url: this.videoUrl[index%this.videoUrl.length],
        cover: this.coverUrls[index%this.coverUrls.length],
        title: '花瓣杯5V5总决赛',
        streamer: this.mockAudienceFactor.getAudienceById(streamers[10]),
        audiences: this.mockAudienceFactor.getRandomAudienceArr(),
        category: '游戏',
        status: '直播中',
        watching: 1.3,
        watchTime: new Date,
        isSelectToDelete: false,
        preferType: index % 2
      })
    index++;
    this.liveRepo.set('12',
      {
        id: '12',
        url: this.videoUrl[index%this.videoUrl.length],
        cover: this.coverUrls[index%this.coverUrls.length],
        title: '直播间标题',
        streamer: this.mockAudienceFactor.getAudienceById(streamers[11]),
        audiences: this.mockAudienceFactor.getRandomAudienceArr(),
        category: '游戏',
        status: '已结束',
        watching: 1.3,
        watchTime: new Date,
        isSelectToDelete: false,
        preferType: index % 2
      })
    index++;
    this.liveRepo.set('13',
      {
        id: '13',
        url: this.videoUrl[index%this.videoUrl.length],
        cover: this.coverUrls[index%this.coverUrls.length],
        title: '纵横中世纪欧洲大陆',
        streamer: this.mockAudienceFactor.getAudienceById(streamers[12]),
        audiences: this.mockAudienceFactor.getRandomAudienceArr(),
        category: '游戏',
        status: '直播中',
        watching: 1.3,
        watchTime: new Date,
        isSelectToDelete: false,
        preferType: index % 2
      })
    index++;
    this.liveRepo.set('14',
      {
        id: '14',
        url: this.videoUrl[index%this.videoUrl.length],
        cover: this.coverUrls[index%this.coverUrls.length],
        title: '伏地魔',
        streamer: this.mockAudienceFactor.getAudienceById(streamers[13]),
        audiences: this.mockAudienceFactor.getRandomAudienceArr(),
        category: '游戏',
        status: '直播中',
        watching: 1.3,
        watchTime: new Date,
        isSelectToDelete: false,
        preferType: index % 2
      })
    index++;
    this.liveRepo.set('15',
      {
        id: '15',
        url: this.videoUrl[index%this.videoUrl.length],
        cover: this.coverUrls[index%this.coverUrls.length],
        title: '软妹纸不会嗲~~超会玩游戏',
        streamer: this.mockAudienceFactor.getAudienceById(streamers[14]),
        audiences: this.mockAudienceFactor.getRandomAudienceArr(),
        category: '游戏',
        status: '直播中',
        watching: 1.3,
        watchTime: new Date,
        isSelectToDelete: false,
        preferType: index % 2
      })
    index++;
    this.liveRepo.set('16',
      {
        id: '16',
        url: this.videoUrl[index%this.videoUrl.length],
        cover: this.coverUrls[index%this.coverUrls.length],
        title: 'LOL',
        streamer: this.mockAudienceFactor.getAudienceById(streamers[15]),
        audiences: this.mockAudienceFactor.getRandomAudienceArr(),
        category: '游戏',
        status: '直播中',
        watching: 1.3,
        watchTime: new Date,
        isSelectToDelete: false,
        preferType: index % 2
      })
    index++;
  }

  private random(min: number, max: number): number {
    return Math.floor(Math.random() * (max - min + 1) + min)
  }

  getLiveInfo(liveId: string): LiveInfoModel {
    console.info(`get dramaId:${liveId}`)
    if (this.liveRepo.has(liveId)) {
      return this.liveRepo.get(liveId)
    }
    return new LiveInfoModel()
  }

  getLives(): Array<string> {
    return this.liveTitles
  }

  getLiveByName(name: string): LiveInfoModel {
    let searchedLive: LiveInfoModel = undefined
    for (const value of this.liveRepo.values()) {
      if (value.title === name) {
        searchedLive = value
        break;
      }
    }
    return searchedLive
  }

  setWatched(liveId: string): void {
    if (this.liveRepo.has(liveId)) {
      let live = this.liveRepo.get(liveId)
      live!.watchTime = new Date
      this.watchedLives.set(liveId, live)
    }
  }

  getWatched(): Array<LiveInfoModel> {
    let watchedLives = []
    this.watchedLives.forEach(item => watchedLives.push(item))
    return watchedLives
  }

  // 删除收藏的直播记录
  removeWatched(ids: string[]): void {
    ids.forEach(item => {
      this.watchedLives.delete(item)
    })
  }

  // 删除所有收藏的直播记录
  removeAllWatched(): void {
    this.watchedLives = new Map
  }


  getFollower(ids: string[]): AudienceRes[] {
    return this.mockAudienceFactor.audienceData.filter(audience => ids.includes(audience.id))
  }

  getFollowing(ids: string[]): AudienceRes[] {
    return this.mockAudienceFactor.audienceData.filter(audience => ids.includes(audience.id))
  }

  getMyFollower(): string[] {
    return this.mockAudienceFactor.myFollower;
  }

  getMyFollowing(): string[] {
    return this.mockAudienceFactor.myFollowing
  }

  addMyFollowing(id: string): void {
    this.mockAudienceFactor.addMyFollowing(id)
  }

  getAudience(id: string): AudienceRes[] {
    return this.mockAudienceFactor.getAudience(id)
  }

  deleteMyFollowing(id: string): void {
    this.mockAudienceFactor.deleteMyFollowing(id)
  }
}

let liveFactor: MockLiveFactory = new MockLiveFactory()

export const getFeedLiveList = (): Array<LiveInfoModel> => {
  let lives: Array<LiveInfoModel> = []
  liveFactor.liveRepo.forEach((value: LiveInfoModel) => {
    lives.push(value)
  })
  return lives;
}

export const getLives = (): Array<string> => {
  return liveFactor.getLives()
}

export const getLiveByName = (name: string): LiveInfoModel => {
  return liveFactor.getLiveByName(name)
}

// 获取剧集信息
export const getLiveInfo = (liveId: string): LiveInfoModel => {
  return liveFactor.getLiveInfo(liveId)
}

// 获取收藏剧集信息
export const getWatched = (): Array<LiveInfoModel> => {
  return liveFactor.getWatched()
}

// 收藏剧集
export const setWatched = (liveId: string): void => {
  liveFactor.setWatched(liveId)
}

// 删除收藏的方法
export const removeWatched = (ids: string[]): void => {
  liveFactor.removeWatched(ids);
}

// 删除所有收藏的方法
export const removeAllWatched = (): void => {
  liveFactor.removeAllWatched();
}


export const getFollower = (ids: string[]): AudienceRes[] => {
  return liveFactor.getFollower(ids)
}

export const getFollowing = (ids: string[]): AudienceRes[] => {
  return liveFactor.getFollowing(ids)
}

export const getMyFollower = (): string[] => {
  return liveFactor.getMyFollower()
}

export const getMyFollowing = (): string[] => {
  return liveFactor.getMyFollowing()
}

export const addMyFollowing = (id: string): void => {
  liveFactor.addMyFollowing(id)
}

export const getAudience = (id: string): AudienceRes[] => {
  return liveFactor.getAudience(id)
}

export const deleteMyFollowing = (id: string): void => {
  liveFactor.deleteMyFollowing(id)
}

export class LiveRoom {
  streamer: Audience
  audience: Array<Audience>
}

class Audience {
  id: string
  avatar: string
  nickName: string
  bio: string
  followingCount: number
  followersCount: number
  likesCount: number
  gender: Gender
  isFollowing: boolean
  fans: Array<Audience>
  following: Array<Audience>
}

export enum Gender {
  Female = 0,
  Male = 1
}