import { BaseResponse } from '../../types/BaseResponse';
import { GetProductTypeListResp, IProductType } from '../../types/responseTypes/GetProductResp';

const productType1: IProductType = {
  id: 1,
  name: '活钱管理',
  description: '历史天天正收益，取用灵活'
}
const productType2: IProductType = {
  id: 2,
  name: '稳健低波',
  description: '追求正收益，波动小'
}
const productType3: IProductType = {
  id: 3,
  name: '稳健增值',
  description: '追求到期收益，适当波动'
}
const productType4: IProductType = {
  id: 4,
  name: '稳中求进',
  description: '更高收益更高波动'
}
const productType5: IProductType = {
  id: 5,
  name: '进取投资',
  description: '长期追求高回报'
}


export const getProductTypeList: BaseResponse<GetProductTypeListResp> = {
  code: 0,
  data: [productType1, productType2, productType3, productType4, productType5]
}