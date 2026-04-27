import { util } from '@kit.ArkTS';
import { fileUri } from '@kit.CoreFileKit';
import {
  AxiosRequestConfig,
  HttpStatusCode,
  AxiosInstance,
  FormData,
} from '@ohos/axios';
import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';


import { ApiPath } from './ApiPath';
import { db, MockData } from './MockDB';
import { FeedbackRecordDTO } from '../models/FeedbackRecordDTO';
import { FeedbackSubmitDTO } from '../models/FeedbackSubmitDTO';

export class MockServer {
  private adapter: AxiosMockAdapter;

  public start(): void {
    /**
     * 上传图片
     *
     * 通过响应图片沙箱 URI 来模拟真实 URL
     */
    this.adapter
      .onPost(ApiPath.UPLOAD_IMAGE)
      .reply(async (config: AxiosRequestConfig) => {
        const formData: FormData = config.data;
        const cacheImagePath: string = formData.get('file').value;
        return [HttpStatusCode.Ok, fileUri.getUriFromPath(cacheImagePath)];
      });
    /**
     * 提交意见反馈
     *
     * 将提交数据持久化并响应提交成功
     */
    this.adapter
      .onPost(ApiPath.SUBMIT_FEEDBACK)
      .reply(async (config: AxiosRequestConfig) => {
        const submit: FeedbackSubmitDTO = JSON.parse(config.data);
        const record: FeedbackRecordDTO = {
          id: util.generateRandomUUID(false),
          description: submit.description,
          images: submit.images,
          createAt: Date.now(),
        };
        const mockData: MockData = await db.getData();
        mockData.feedbacks.unshift(record);
        await db.save();
        return [HttpStatusCode.Ok, true];
      });
    /**
     * 查询意见反馈记录
     *
     * 响应持久化数据中的意见反馈数据
     */
    this.adapter.onGet(ApiPath.LIST_FEEDBACKS).reply(async () => {
      const mockData: MockData = await db.getData();
      const list: FeedbackRecordDTO[] = [...mockData.feedbacks];
      return [HttpStatusCode.Ok, list];
    });
  }

  constructor(axiosInstance: AxiosInstance) {
    this.adapter = new AxiosMockAdapter(axiosInstance, { delayResponse: 700 });
  }
}
