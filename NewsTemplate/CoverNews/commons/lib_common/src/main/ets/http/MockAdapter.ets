import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import request from './BaseRequest';
import { HttpServiceMock } from './HttpServiceMock';

// 创建mock拦截器
const mockAdapter = new AxiosMockAdapter(request, {
  delayResponse: 300,
});

// todo 全局配置，是否启用mock，当前默认启用
const enableMock: boolean = true;

if (enableMock) {
  const mockApis = [
    new HttpServiceMock(),
  ];
  mockApis.forEach((api) => {
    api.start(mockAdapter);
  });
}