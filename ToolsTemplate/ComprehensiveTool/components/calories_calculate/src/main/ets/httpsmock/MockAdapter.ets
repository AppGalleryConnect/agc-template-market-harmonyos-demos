import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import instance from '../https/Request';
import { ExchangeServiceMock } from './mockapis/CaloriesServiceMock';

// 创建mock拦截器
const mockAdapter = new AxiosMockAdapter(instance, {
  delayResponse: 300,
});

// 全局配置，是否启用mock，当前默认启用
const enableMock: boolean = true;

if (enableMock) {
  const mockApis = [new ExchangeServiceMock()];
  mockApis.forEach((api) => {
    api.start(mockAdapter);
  });
}