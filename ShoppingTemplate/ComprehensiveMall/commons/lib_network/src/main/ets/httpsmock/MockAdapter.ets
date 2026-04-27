import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { HomeMockApis } from './mockapis/HomeMock';
import { OrderMockApis } from './mockapis/OrderMock';
import { ProductMockApis } from './mockapis/ProductMock';
import { SeckillMockApis } from './mockapis/SeckillMock';
import { ShoppingCartMockApis } from './mockapis/ShoppingCartMock';
import { UserMockApis } from './mockapis/UserMock';
import { CouponMockApis } from './mockapis/CouponMock';
import { PointsMockApis } from './mockapis/PointsMock';
import instance from '../https/Request';

// 创建mock拦截器
const mockAdapter = new AxiosMockAdapter(instance, {
  delayResponse: 300,
});

// 全局配置，是否启用mock，当前默认启用
const enableMock: boolean = true;

if (enableMock) {
  const mockApis = [
    new HomeMockApis(),
    new OrderMockApis(),
    new ProductMockApis(),
    new UserMockApis(),
    new SeckillMockApis(),
    new ShoppingCartMockApis(),
    new CouponMockApis(),
    new PointsMockApis(),
  ];
  mockApis.forEach((api) => {
    api.start(mockAdapter);
  });
}
