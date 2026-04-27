export interface UserInfo {
  id: number;
  avatar: string | Resource;
  name: string;
  nickname: string;
  sex: string;
  cellphone: string;
  birthday: string;
  code: string;
  isLogin: boolean;
  bio: string
  followingList: string[]
  followersList: string[]
  likesCount: number
  realNameAuthFlag: boolean
}