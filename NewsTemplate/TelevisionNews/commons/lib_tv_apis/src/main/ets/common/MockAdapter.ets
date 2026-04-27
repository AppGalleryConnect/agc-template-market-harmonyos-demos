import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import instance from './BaseRequest';

// 创建mock拦截器
const mockAdapter = new AxiosMockAdapter(instance, {
  delayResponse: 300,
});

export default mockAdapter;
