import { IUserInfo } from 'lib_foundation';
import { IVip } from '../types';

export const userInfoData: IUserInfo = {
  isLogin: false,
  id: 0,
  name: '',
  nickname: '',
  sex: '',
  cellphone: '',
  birthday: '',
  avatar: '',
  isVip: false,
  points: 0,
  couponList: [],
  realNameAuthFlag: 0
}

export const privacy: string = '欢迎您使用我们的快递物流模板，您的信任对我们很重要，我们将严格遵守法律法规要求的安全保护措施，保护您的个人信息安全可控。'

export const vipList: IVip[] = [
  {
    id: 1,
    name: '连续包月',
    originalPrice: 12,
    discountPrice: 1,
    instructions: '次月起12元/月，到期自动续费可随时取消'
  },
  {
    id: 2,
    name: '连续包年',
    originalPrice: 225,
    discountPrice: 180,
    instructions: '次年起225元/年，到期自动续费可随时取消'
  }
]