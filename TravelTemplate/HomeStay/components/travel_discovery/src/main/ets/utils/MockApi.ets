import { InternalAxiosRequestConfig } from '@ohos/axios';
import { ITravelogue, ITravelogueDetail, ITravelogueList } from '../model/IResponse';
import { MockData } from './MockData';

export class MockApi {
  static list: ITravelogue[] = [...MockData.LIST1, ...MockData.LIST2];

  static queryTravelogueList(config?: InternalAxiosRequestConfig) {
    const data: ESObject = JSON.parse(config?.data ?? '{}');
    const resp: ITravelogueList = {
      data: [],
    };

    const filterList = MockApi.list.filter(v => {
      return v.title.includes(data.title ?? '');
    })

    if (data.pageNum === 1) {
      resp.data = filterList.slice(0, 10);
    } else if (data.pageNum === 2) {
      resp.data = filterList.splice(10);
    } else {
      resp.data = [];
    }

    return resp;

  }

  static recordBrowse() {
    return true;
  }

  static queryTravelogueDetail(config?: InternalAxiosRequestConfig) {
    const data: ESObject = JSON.parse(config?.data ?? '{}');
    const id = data.id as number || 1;
    const item = MockApi.list.find(v => v.id === id);
    const resp: ITravelogueDetail = {
      data: item ?? null
    };
    return resp;
  }

  static likeTravelogue(config?: InternalAxiosRequestConfig) {
    const data: ESObject = JSON.parse(config?.data ?? '{}');
    const id = data.relId as number || 1;
    const item = MockApi.list.find(v => v.id === id);
    if (item) {
      item.currentUserLikeStatus = 'Y';
      item.likeNum += 1;
    }
    return true;
  }

  static cancelLikeTravelogue(config?: InternalAxiosRequestConfig) {
    const data: ESObject = JSON.parse(config?.data ?? '{}');
    const id = data.relId as number || 1;
    const item = MockApi.list.find(v => v.id === id);
    if (item) {
      item.currentUserLikeStatus = 'N';
      item.likeNum -= 1;
    }
    return true;
  }

  static favorTravelogue(config?: InternalAxiosRequestConfig) {
    const data: ESObject = JSON.parse(config?.data ?? '{}');
    const id = data.relId as number || 1;
    const item = MockApi.list.find(v => v.id === id);
    if (item) {
      item.currentUserCollectStatus = 'Y';
      item.collectNum += 1;
    }
    return true;
  }

  static cancelFavorTravelogue(config?: InternalAxiosRequestConfig) {
    const data: ESObject = JSON.parse(config?.data ?? '{}');
    const id = data.relId as number || 1;
    const item = MockApi.list.find(v => v.id === id);
    if (item) {
      item.currentUserCollectStatus = 'N';
      item.collectNum -= 1;
    }
    return true;
  }

  static commentTravelogue(config?: InternalAxiosRequestConfig) {
    const data: ESObject = JSON.parse(config?.data ?? '{}');
    const id = data.travelId as number || 1;
    const evaluateContent = data.evaluateContent as string || '';
    const item = MockApi.list.find(v => v.id === id);
    if (item) {
      item.travelogueEvaluateList?.splice(0, 0, {
        createBy: '',
        createTime: new Date().getTime(),
        evaluateContent: evaluateContent,
        userHeadImg: '',
      },);
      item.commentNum += 1;
    }
    return true;
  }
}