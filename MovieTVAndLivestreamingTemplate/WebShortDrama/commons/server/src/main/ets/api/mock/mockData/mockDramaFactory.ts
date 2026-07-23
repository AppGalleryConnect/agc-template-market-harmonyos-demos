import { DramaInfo } from "../../../bean/common/DramaInfo";
import { ActorInfo, Drama, Episode } from "./bean";

class MockDramaFactory {
  uniqueId: number = 0;
  dramaRepo: Map<string, Drama> = new Map;
  favoriteDramas: Array<Drama> = []
  likeDramas: Array<Drama> = []
  tags: Array<string> = ['古装', '家庭', '年代', '穿越', '职场', '重生', '权谋', '情感', '悬疑', '搞笑']
  watchedDramas: Array<Drama> = []
  randNum1: number = 0
  randNum2: number = 0
  dramaNames: Array<string> = [
    '这次到你看我爱着别人',
    '千金驾到',
    '锦鲤萌宝闹大观园',
    '双生归来',
    '离开后，你才说爱我',
    '龙君的高冷女总裁'
  ]
  descriptions: Array<string> = [
    '一口气看完大结局，一部让你熬夜看完的短剧，怕你情绪把控不住 #轮到你看我爱别人短剧',
    '千亿富豪孙女留学归来，隐藏身份去一家小公司上班，却没想到有人 有人冒充她富豪身份，开启了绝地反击#大小姐驾到 #因为一个片段看了整部剧',
    '家境贫寒的林暖暖，因父亲外室一事在市集扬名，被县令夫人聘为其子卫恒卿的伴读。在卫府，她与卫恒卿从针锋相对到渐生情愫。后来林暖暖进宫伴读，历经公主府风波，被赐婚又退婚。最终两人在各种波折后喜结连理，还获封平阳公主与谷阳县令。',
    '凤鸣集团的总裁苏南烟一直在寻找失散多年的双胞胎妹妹沈秋雨，却在终于找到妹妹时，得知已成为人妻的妹妹这些年一直饱受欺凌，苏南烟为妹妹撑起了腰，帮她跟渣男离婚并拿到女儿的抚养权，沈秋雨的生活在姐姐的帮助下终于迎来了希望。',
    '贺启明因为林氏集团董事长的知遇之恩，与林氏签下三年合约，为林氏工作，助林氏上市，林董事长十分赏识贺启明，指婚他和自己的女儿林子萱。林子萱恩怨至极，总觉得贺启明是个废物，一心只相信自己的白月光李远，但李远其实是个没有工作能力又很贪心的骗子。最后贺启明掌管了龙跃集团，李远因为拿巨额回扣被警察带走，林氏集团破产。',
    '叶玄，一位英勇无畏的青年，以其超凡的武艺和坚定的意志，在江湖中闯出了赫赫威名。他拳打赵家嚣张跋扈的大少，以正义之名维护了弱小；又脚踩柳家蛮横无理的大舅哥，展现了不屈不挠的斗志'
  ]

  videoUrl = [
    'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/drama_video/3.m3u8',
    'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/drama_video/2.m3u8',
    'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/drama_video/3.m3u8'
  ]
  videoDuration = [
    30000,
    23720,
    29840
  ]
  coverUrls = [
    'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/pic1.png',
    'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/pic2.png',
    'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/pic3.png'
  ]
  actorList: Array<ActorInfo> = [
    {
      id: '1',
      name: '徐梦圆',
      avatar: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/woman1.png'
    },
    {
      id: '2',
      name: '何瑞聪',
      avatar: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/man1.png'
    }
    ,
    {
      id: '3',
      name: '何瑞聪',
      avatar: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/man2.png'
    }
    ,
    {
      id: '4',
      name: '何瑞聪',
      avatar: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/woman2.png'
    }
  ]

  constructor() {
    // 默认初始一些数据用来显示
    for (let i = 0; i < 3; i++) {
      let drama = this.getOneDrama()
      drama.isFavorite = true
      this.favoriteDramas.push(drama)
    }
    for (let i = 0; i < 3; i++) {
      let drama = this.getOneDrama()
      this.watchedDramas.push(drama)
    }
    for (let i = 0; i < 3; i++) {
      let drama = this.getOneDrama()
      drama.isLike = true
      this.likeDramas.push(drama)
    }
  }

  private random(min: number, max: number): number {
    return Math.floor(Math.random() * (max - min + 1) + min)
  }

  getActorList(dramaId: string): Array<ActorInfo> {
    let actorNum = this.random(0, 3)
    let actors: Array<ActorInfo> = []
    for (let i = 0; i < actorNum; i++) {
      actors.push(this.actorList[i])
    }
    return actors
  }

  getTags(): Array<string> {
    let tagNum = this.random(2, 3)
    let tags: Array<string> = []
    let tempTags = [...this.tags]
    for (let i = 0; i < tagNum; i++) {
      const randomIndex = this.random(0, tempTags.length - 1);
      const selected = tempTags.splice(randomIndex, 1)[0];
      tags.push(selected)
    }
    return tags
  }

  getDramaInfo(dramaId: string): Drama {
    console.info(`get dramaId:${dramaId}`)
    if (this.dramaRepo.has(dramaId)) {
      return this.dramaRepo.get(dramaId)
    }
    return new DramaInfo('')
  }

  getDramas(): Array<string> {
    return this.dramaNames
  }

  getDramaByName(name: string): Drama {
    let searchedDrama = undefined
    for (const value of this.dramaRepo.values()) {
      if (value.name === name) {
        searchedDrama = value
        break;
      }
    }
    return searchedDrama
  }

  getOneDrama(vip: boolean = false): Drama {
    let dramaId = 'drama_' + this.uniqueId++
    let randDrama = (this.randNum1++)%6
    let randIndex = (this.randNum2++)%6
    let drama: Drama = {
      id: dramaId,
      promotionalUrl: this.videoUrl[randIndex%3],
      coverUrl: this.coverUrls[randDrama%3],
      name: this.dramaNames[randDrama],
      description: this.descriptions[randDrama],
      totalCount: 80,
      curIndex: randIndex,
      latestUpdate: randIndex,
      category: this.getTags(),
      popular: '200万',
      actorInfo: this.getActorList(dramaId),
      isFavorite: false,
      favoriteCount: this.random(100, 200),
      isLike: false,
      likeCount: this.random(100, 200),
      isVip: vip,
      duration:this.videoDuration[randIndex%3],
    }
    this.dramaRepo.set(dramaId, drama)
    return drama;
  }

  setFavorite(dramaId: string): void {
    if (this.dramaRepo.has(dramaId)) {
      let dramaInfo: Drama = this.dramaRepo.get(dramaId)
      dramaInfo.isFavorite = true
      dramaInfo.favoriteCount++
      const index = this.favoriteDramas.findIndex(d => d.id === dramaId)
      if (index !== -1) {
        this.favoriteDramas.splice(index, 1)
      }
      this.favoriteDramas.unshift(dramaInfo)
    }
  }

  unsetFavorite(dramaId: string): void {
    if (this.dramaRepo.has(dramaId)) {
      let dramaInfo: Drama = this.dramaRepo.get(dramaId);
      dramaInfo.isFavorite = false;
      dramaInfo.favoriteCount--;
      const index = this.favoriteDramas.findIndex(d => d.id === dramaId);
      if (index !== -1) {
        this.favoriteDramas.splice(index, 1);
      }
    }
  }

  getFavorite(): Array<Drama> {
    return Array.from(this.favoriteDramas.values())
  }

  setMyWatchRecord(drama: Drama): void {
    this.watchedDramas.unshift(drama)
  }

  getMyWatchRecord(): Array<Drama> {
    return this.watchedDramas
  }

  unsetMyWatchRecord(dramaId: string): void {
    if (this.dramaRepo.has(dramaId)) {
      let index: number = -1
      this.watchedDramas.forEach((item) => {
        if (item.id === dramaId) {
          index = this.watchedDramas.indexOf(item)
        }
      })
      this.watchedDramas.splice(index, 1)
    }
  }

  setLike(dramaId: string): void {
    if (this.dramaRepo.has(dramaId)) {
      let dramaInfo: Drama = this.dramaRepo.get(dramaId)
      dramaInfo.isLike = true
      dramaInfo.likeCount++
      const index = this.likeDramas.findIndex(d => d.id === dramaId)
      if (index !== -1) {
        this.likeDramas.splice(index, 1)
      }
      this.likeDramas.unshift(dramaInfo)
    }
  }

  unsetLike(dramaId: string): void {
    if (this.dramaRepo.has(dramaId)) {
      let dramaInfo: Drama = this.dramaRepo.get(dramaId);
      dramaInfo.isLike = false;
      dramaInfo.likeCount--;
      const index = this.likeDramas.findIndex(d => d.id === dramaId);
      if (index !== -1) {
        this.likeDramas.splice(index, 1);
      }
    }
  }

  getLike(): Array<Drama> {
    return Array.from(this.likeDramas.values())
  }
}

let dramaFactor: MockDramaFactory = new MockDramaFactory()

export const getOneDrama = (vip: boolean = false): Drama => {
  return dramaFactor.getOneDrama(vip)
}

export const getDramas = (): Array<string> => {
  return dramaFactor.getDramas()
}

export const getDramaByName = (name: string): Drama => {
  return dramaFactor.getDramaByName(name)
}

// 获取主页剧集流剧集列表
export const getFeedDramaList = (): Array<Drama> => {
  let dramas: Array<Drama> = []
  for (let i = 0; i < 5; i++) {
    dramas.push(dramaFactor.getOneDrama())
  }
  return dramas;
}

// 获取剧集信息
export const getDramaInfo = (dramaId: string): Drama => {
  return dramaFactor.getDramaInfo(dramaId)
}

// 获取收藏剧集信息
export const getFavorite = (): Array<Drama> => {
  return dramaFactor.getFavorite()
}

// 收藏剧集
export const setFavorite = (dramaId: string): void => {
  dramaFactor.setFavorite(dramaId)
}

// 取消收藏剧集
export const unsetFavorite = (dramaId: string): void => {
  dramaFactor.unsetFavorite(dramaId)
}

// 获取观看记录信息
export const getMyWatchRecord = (): Array<Drama> => {
  return dramaFactor.getMyWatchRecord()
}

// 设置为观看记录
export const setMyWatchRecord = (drama: Drama): void => {
  dramaFactor.setMyWatchRecord(drama)
}

export const unsetMyWatchRecord = (dramaId: string): void => {
  dramaFactor.unsetMyWatchRecord(dramaId)
}

// 获取点赞剧集列表
export const getLike = (): Array<Drama> => {
  return dramaFactor.getLike()
}

// 点赞剧集
export const setLike = (dramaId: string): void => {
  dramaFactor.setLike(dramaId)
}

// 取消点赞剧集
export const unsetLike = (dramaId: string): void => {
  dramaFactor.unsetLike(dramaId)
}

