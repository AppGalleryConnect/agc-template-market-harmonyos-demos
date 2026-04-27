// 定义性别枚举
export enum Gender {
  Female = 0,
  Male = 1
}

@ObservedV2
export class Audience {
  @Trace id: string
  @Trace avatar: ResourceStr
  @Trace nickName: string
  @Trace bio: string
  @Trace followingList: string[]
  @Trace followersList: string[]
  @Trace likesCount: number
  @Trace gender: Gender
  @Trace isFocused: boolean

  constructor(
    id: string = '',
    avatar: ResourceStr = '',
    nickName: string = '',
    bio: string = '',
    followingList: string[] = [],
    followersList: string[] = [],
    likesCount: number = 0,
    gender: Gender = 0,
    isFocused: boolean = false) {
    this.id = id
    this.avatar = avatar
    this.nickName = nickName
    this.bio = bio
    this.followingList = followingList
    this.followersList = followersList
    this.likesCount = likesCount
    this.gender = gender
    this.isFocused = isFocused
  }
}