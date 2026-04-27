export class MockAudienceFactory {
  // 全局变量，用于存储观众数据
  audienceData: Array<AudienceRes> = []

  myFollowing: Array<string> = []
  myFollower: Array<string> = []
  myId: string = '0000000'

  constructor() {
    // 全局变量，用于存储观众数据
    this.audienceData = this.initAudience()

    this.myFollowing = this.getRandomAudienceIds()
    this.myFollower = this.getRandomAudienceIds()
  }

  addMyFollowing(id: string): void {
    this.myFollowing.push(id)
    const follow = this.getAudienceById(id)
    follow!.isFocused = true
    follow?.followersList.push(this.myId)
  }

  getAudience(id: string): AudienceRes[] {
    const audience = this.getAudienceById(id)
    return this.audienceData.filter(item => audience?.followingList.includes(item.id))
  }

  deleteMyFollowing(id: string): void {
    const index = this.myFollowing.indexOf(id); // 找到元素的索引
    if (index !== -1) {
      this.myFollowing.splice(index, 1); // 删除索引为 index 的元素
    }
    const follow = this.getAudienceById(id)
    follow!.isFocused = false
    const myIdIndex = follow?.followersList.indexOf(this.myId)
    follow?.followersList.splice(myIdIndex)
  }

  generateUniqueIds(length: number, digits: number): string[] {
    const ids: string[] = [];
    for (let i = 1; i <= length; i++) {
      ids.push(i.toString().padStart(digits, '0'));
    }
    return ids;
  }

  generateRandomBio(): string {
    const bios = [
      '热爱生活，喜欢分享发生在自己身上的有趣故事。',
      '新闻控，专注于播报国际国内新闻。',
      '音乐爱好者，分享好听的歌曲和音乐故事。',
      '美食家，探索世界各地的美食。',
      '旅行达人，记录旅行中的点点滴滴。',
      '电影评论家，分享电影观看体验和评论。'
    ]
    return bios[Math.floor(Math.random() * bios.length)]
  }

  initAudience(): Array<AudienceRes> {
    let avatarArr: Array<string> = [
      ('app.media.image_bai'), ('app.media.image_hui'), ('app.media.image_yu'),
      ('app.media.image_chi'), ('app.media.image_ti'), ('app.media.image_labubu'),
    ]
    let nickNameArr: Array<string> = [
      '白姐聊新闻', '会说国语的老外', '娱记大杂烩', '吃货小睡鼠', '体育前线', 'Labubu集中营'
    ]
    let audienceArray: Array<AudienceRes> = []
    // 生成50个唯一的7位数字ID
    let uniqueIds = this.generateUniqueIds(50, 7)

    for (let i = 0; i < 50; i++) {
      let index: number = Math.floor(Math.random() * 6)
      let bio = this.generateRandomBio()
      // 从uniqueIds中随机选择10-30个唯一的关注ID
      let followingList = this.getRandomUniqueIds(uniqueIds, Math.floor(Math.random() * 21) + 10)
      // 从uniqueIds中随机选择20-40个唯一的粉丝ID
      let followersList = this.getRandomUniqueIds(uniqueIds, Math.floor(Math.random() * 21) + 20)
      let likesCount = Math.floor(Math.random() * 10000) + (Math.random() > 0.5 ? 10000 : 0)
      let gender = Math.random() > 0.5 ? Gender.Male : Gender.Female

      audienceArray.push(new AudienceRes(uniqueIds[i], avatarArr[index], nickNameArr[index], bio, followingList,
        followersList, likesCount, gender, false))
    }
    return audienceArray
  }

  getRandomAudienceIds(count: number = 10): string[] {
    const audienceArray = this.audienceData
    const shuffledAudience = [...audienceArray].sort(() => 0.5 - Math.random());
    const selectedAudience = shuffledAudience.slice(0, count);
    return selectedAudience.map(audience => audience.id);
  }

  // 从uniqueIds中随机选择指定数量的唯一ID
  getRandomUniqueIds(uniqueIds: string[], count: number): string[] {
    const shuffledIds = [...uniqueIds].sort(() => 0.5 - Math.random());
    return shuffledIds.slice(0, count);
  }

  // 获取所有观众数据
  getAllAudience(): Array<AudienceRes> {
    return this.audienceData;
  }

  // 获取3-20个观众
  getRandomAudienceArr(): Array<AudienceRes> {
    let ids = this.getRandomAudienceIds(Math.floor(Math.random() * 47) + 3)
    let randomAudienceArr: Array<AudienceRes> = []
    this.audienceData.map((value: AudienceRes) => {
      if (ids.includes(value.id)) {
        randomAudienceArr.push(value)
      }
    })
    return randomAudienceArr
  }

  // 根据ID获取观众数据
  getAudienceById(id: string): AudienceRes | null {
    const audience = this.audienceData.find(a => a.id === id);
    return audience || null;
  }

  // 添加一个我的关注
  addFollowing(id: string): boolean {
    if (this.myFollowing.some(a => a === id)) {
      return false; // ID已存在，添加失败
    }
    this.myFollowing.push(id);
    return true; // 添加成功
  }

  // 删除一个我的关注
  deleteFollowing(id: string): boolean {
    const index = this.myFollowing.findIndex(a => a === id);
    if (index !== -1) {
      this.myFollowing.splice(index, 1);
      return true; // 删除成功
    }
    return false; // 删除失败，未找到ID
  }
}

export enum Gender {
  Female = 0,
  Male = 1
}

export class AudienceRes {
  id: string
  avatar: string
  nickName: string
  bio: string
  followingList: string[]
  followersList: string[]
  likesCount: number
  gender: Gender
  isFocused: boolean
  isModerator: boolean//设置房管
  isMute:boolean //是否禁言

  constructor(
    id: string = '',
    avatar: string = '',
    nickName: string = '',
    bio: string = '',
    followingList: string[] = [],
    followersList: string[] = [],
    likesCount: number = 0,
    gender: Gender = 0,
    isFocused: boolean = false,
    isModerator:boolean = false,
    isMute:boolean = false) {
    this.id = id
    this.avatar = avatar
    this.nickName = nickName
    this.bio = bio
    this.followingList = followingList
    this.followersList = followersList
    this.likesCount = likesCount
    this.gender = gender
    this.isFocused = isFocused
    this.isModerator = isModerator
    this.isMute = isMute
  }
}

export class AudienceArrRes {
  audienceArr: AudienceRes[]
}

export class AudienceIdArrRes {
  audienceIdArr: string[]
}