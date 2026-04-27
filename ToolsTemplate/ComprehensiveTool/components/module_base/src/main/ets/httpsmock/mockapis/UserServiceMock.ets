import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { PRODUCT_PLAN } from '../../constant/Index';
import { GetProductExpireTimeRequest, ModifyPersonalInfoRequest, SignInRequest } from '../../model/HttpRequest';
import { MockUser } from '../MockUser';

export class UserServiceMock {
  public start(adapter: AxiosMockAdapter) {
    // 用户登录
    adapter.onPost('/sign/in').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as SignInRequest;
      if (data.loginChannel === 'wechat') {
        MockUser.user.userNickName = '微信用户';
      } else {
        MockUser.user.userNickName = '华为用户';
      }
      if (data.uid) {
        // todo: 根据uid查询手机号
        MockUser.user.userPhone = MockUser.user.userPhone;
      }
      return [HttpStatusCode.Ok, MockUser.user];
    });

    // 修改个人信息
    adapter.onPost('/modify/personal/info').reply((config: AxiosRequestConfig) => {
      const params = JSON.parse(config.data) as ModifyPersonalInfoRequest;

      if (params.userIcon) {
        MockUser.user.userIcon = params.userIcon;
      }
      if (params.userNickName) {
        MockUser.user.userNickName = params.userNickName;
      }
      if (params.userPhone) {
        MockUser.user.userPhone = params.userPhone;
      }
      return [HttpStatusCode.Ok];
    });

    // 获取短信验证码
    adapter.onPost('/send/code').reply(() => {
      return [HttpStatusCode.Ok];
    });

    // 验证短信验证码
    adapter.onPost('/verify/code').reply(() => {
      return [HttpStatusCode.Ok];
    });

    adapter.onPost('/product/time').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as GetProductExpireTimeRequest;
      let time = '';
      if (data.time) {
        // 购买时获取非续期商品的周期
        let periodTime = PRODUCT_PLAN.get(data.productId) ?? 0;
        let timeStamp = data.time + periodTime;
        let date = new Date(timeStamp);
        time = `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate()
          .toString()
          .padStart(2, '0')}`;
      }
      return [HttpStatusCode.Ok, time];
    });
  }
}