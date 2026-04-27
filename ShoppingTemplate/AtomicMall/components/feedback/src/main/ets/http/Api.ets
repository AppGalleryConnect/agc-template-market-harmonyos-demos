
import { fileUri } from '@kit.CoreFileKit';
import axios, {
  AxiosInstance, AxiosRequestConfig, AxiosResponse, FormData,
} from '@ohos/axios';

import { ApiPath } from './ApiPath';
import { MockServer } from './MockServer';
import { Config } from '../common/Config';
import { FeedbackRecordDTO } from '../models/FeedbackRecordDTO';
import { FeedbackSubmitDTO } from '../models/FeedbackSubmitDTO';
import { FileUtils } from '../utils/FileUtils';

const axiosInstance: AxiosInstance = axios.create({
  baseURL: Config.API_BASE_URL,
  timeout: Config.REQUEST_TIMEOUT,
});

if (Config.IS_MOCK_ADAPTER_ENABLE) {
  const server: MockServer = new MockServer(axiosInstance);
  server.start();
}

/**
 * API 访问层
 *
 * 该类封装了问题反馈相关接口调用逻辑，代码保持最小实现
 *
 * todo: 可结合自身业务需要进行扩展与改造，如鉴权处理、错误处理、重试机制等。
 */
export class Api {
  /**
   * 上传单张图片到服务器
   *
   * @param uri - 媒体文件 URI
   * @returns 图片在服务器上的访问 URL，失败时返回空字符串
   *
   * @see https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/user-file-uri-intro#媒体文件uri介绍
   */
  public static async uploadSingleImage(uri: string): Promise<string> {
    try {
      const cacheImageUriObj =
        await FileUtils.saveFileToCache(uri);
      if (!cacheImageUriObj) {
        return '';
      }
      const config: AxiosRequestConfig<FormData> = {
        headers: { 'Content-Type': 'multipart/form-data' },
      };
      const formData: FormData = new FormData();
      // 使用 Axios 上传文件时，仅支持使用 Cache 沙箱路径或 internal://cache/ 协议类型的 URI
      formData.append('file', cacheImageUriObj.path);
      const resp: AxiosResponse<string> = await axiosInstance.post(
        ApiPath.UPLOAD_IMAGE,
        formData,
        config,
      );
      return resp.data;
    } catch {
      return '';
    }
  }

  /**
   * 提交问题反馈
   *
   * @param dto - 提交 API 数据传输对象
   * @returns 提交结果
   */
  public static async submitFeedback(dto: FeedbackSubmitDTO): Promise<boolean> {
    try {
      const urls: string[] = await Promise.all(
        dto.images.map((item: string) => {
          if (item.startsWith('file://')) {
            return Api.uploadSingleImage(item);
          } else {
            return Promise.resolve(item);
          }
        }),
      );
      if (urls.some((url: string) => !url)) {
        throw new Error('One or more images failed to upload');
      }
      dto.images = urls;
      const config: AxiosRequestConfig<FeedbackSubmitDTO> = {
        headers: { 'Content-Type': 'application/json' },
      };
      const resp: AxiosResponse<boolean> = await axiosInstance.post(
        ApiPath.SUBMIT_FEEDBACK,
        dto,
        config,
      );
      return typeof resp.data === 'boolean' && resp.data;
    } catch {
      return false;
    }
  }

  /**
   * 获取历史问题反馈列表
   *
   * @returns 问题反馈列表
   */
  public static async listFeedbacks(): Promise<FeedbackRecordDTO[]> {
    try {
      const resp: AxiosResponse<FeedbackRecordDTO[]> = await axiosInstance.get(
        ApiPath.LIST_FEEDBACKS,
      );
      return resp.data;
    } catch {
      return [];
    }
  }
}
