import { Decimal } from '@kit.ArkTS'

export interface UserInfo {
  id: number;
  avatar: string;
  name: string;
  nickname: string;
  sex: string;
  cellphone: string;
  birthday: string;
  code: string;
  isLogin: boolean;
  isMembership: boolean;
}

@ObservedV2
export class RecipeBriefInfo {
  @Trace id: number = 0
  @Trace title: string = ''
  @Trace description: string = ''
  @Trace category: string = ''
  @Trace cookingTime: number = 0
  @Trace difficulty: string = ''
  @Trace authorId: number = 0
  @Trace author: string = ''
  @Trace authorAvatar: string = ''
  @Trace thumbnail: string = ''
  @Trace views: number = 0;
  @Trace likes: number = 0;
  @Trace video: string = '';
}

@ObservedV2
export class BloggerInfo {
  @Trace id: number = 0
  @Trace name: string = ''
  @Trace avatar: ResourceStr = ''
  @Trace phoneNumber: string = ''
  @Trace isMembership: boolean = false
  @Trace profile: string = '未知'
  @Trace sex: string = '未知'
  @Trace createdAccount: string = ''
  @Trace ipLocation: string = ''
  @Trace bloggerType: string = ''
  @Trace followers: number = 0
  @Trace fans: number = 0
  @Trace beFavorite: number = 0
  @Trace beFollowed: number = 0
  @Trace myRecipeList: RecipeBriefInfo[] = []
  @Trace collectRecipeList: RecipeBriefInfo[] = []

  getFollowers(): string {
    return this.formatNumber(this.followers)
  }

  getFans(): string {
    return this.formatNumber(this.fans)
  }

  getBeFavorite(): string {
    return this.formatNumber(this.beFavorite)
  }

  getBeFollowed(): string {
    return this.formatNumber(this.beFollowed)
  }

  private formatNumber(num: number) {
    if (num >= 10000) {
      return `${new Decimal(num).div(10000).toFixed(1)}万`
    } else {
      return num.toString()
    }
  }

  updateData(id: number = -1, name: string = '', avatar: ResourceStr = '', profile: string = '', sex: string = '',
    createdAccount: string = '', ipLocation: string = '', bloggerType: string = '', followers: number = 0,
    fans: number = 0, beFavorite: number = 0, beFollowed: number = 0, myRecipeList: RecipeBriefInfo[] = [],
    collectRecipeList: RecipeBriefInfo[] = []) {
    this.id = id;
    this.name = name;
    this.avatar = avatar;
    this.profile = profile;
    this.sex = sex;
    this.createdAccount = createdAccount;
    this.ipLocation = ipLocation;
    this.bloggerType = bloggerType;
    this.followers = followers;
    this.fans = fans;
    this.beFavorite = beFavorite;
    this.beFollowed = beFollowed;
    this.myRecipeList = myRecipeList;
    this.collectRecipeList = collectRecipeList;
  }
}