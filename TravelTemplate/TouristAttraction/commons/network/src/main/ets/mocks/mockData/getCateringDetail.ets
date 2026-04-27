import { Constant } from 'common';
import { GetCateringDetailResp } from '../../types/responseTypes/GetCateringDetailResp';
import { MockResourceEnum } from '../MockResourceEnum';

export const cateringDetailMock: GetCateringDetailResp = {
  siteId: '',
  banner: [Constant.CLOUD_STORAGE_URL + MockResourceEnum.CATERING],
  startPrice: 75,
  images: [Constant.CLOUD_STORAGE_URL + MockResourceEnum.CATERING],
  detail: '餐厅坐落在风景如画的松山湖畔,拥有得天独厚的自然风光。让顾客在用餐的同时能够欣赏到周围的自然景色。餐厅建筑面积800平方米,室内独具特色的3个包间,它私密而安静,室内餐位共50个,室外休闲餐位48个。提供铜锅炖鱼、砂锅鱼头货、荷叶酿鱼胶等菜品。专业的服务团队将竭诚为您提供周到细致的服务,让您在这里享受到完美的体验。',
  openHours: '9：00-22：00',
};