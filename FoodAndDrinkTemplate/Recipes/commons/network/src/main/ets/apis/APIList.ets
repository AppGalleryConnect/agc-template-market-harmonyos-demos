import { AxiosResponse } from '@ohos/axios';
import { axiosInstance } from './HttpRequest';
import {
  CollectionBody,
  QueryListParams,
  RecipeBriefInfo,
  RecipeCategory,
  RecipeDetail,
  UploadRecipeBody,
} from '../types/Recipe';
import '../mocks/RequestMock';

// 查询菜谱列表
export const queryRecipeList = (params?: QueryListParams): Promise<AxiosResponse<Array<RecipeBriefInfo>, void>> => {
  const url = '/recipe/list'
  return axiosInstance.get(url, { params })
}

// 查询菜谱列表
export const queryRecipeCategory = (): Promise<AxiosResponse<Array<RecipeCategory>, void>> => {
  const url = '/recipe/category'
  return axiosInstance.get(url)
}

// 查询菜谱详情
export const queryRecipeDetail = (id: number): Promise<AxiosResponse<RecipeDetail, void>> => {
  const url = '/recipe/detail';
  return axiosInstance.get(url, { params: { id } })
}

// 查询我的菜谱
export const queryMyRecipeList = (): Promise<AxiosResponse<Array<RecipeBriefInfo>, void>> => {
  const url = '/recipe/mine/list';
  return axiosInstance.get(url)
}

// 查询我的菜谱
export const uploadMyRecipe = (data: UploadRecipeBody): Promise<AxiosResponse<void, UploadRecipeBody>> => {
  const url = '/recipe/upload';
  return axiosInstance.post(url, data)
}

// 查询浏览历史
export const queryRecipeHistoryList = (): Promise<AxiosResponse<Array<RecipeBriefInfo>, void>> => {
  const url = '/recipe/history/list';
  return axiosInstance.get(url)
}

// 查询我的收藏
export const queryCollectionList = (): Promise<AxiosResponse<Array<RecipeBriefInfo>, void>> => {
  const url = '/recipe/collection/list';
  return axiosInstance.get(url)
}

// 添加收藏
export const addCollection = (id: number): Promise<AxiosResponse<void, CollectionBody>> => {
  const url = '/recipe/collection';
  const data: CollectionBody = { id };
  return axiosInstance.post(url, data)
}

// 取消收藏
export const removeCollection = (id: number): Promise<AxiosResponse<void, CollectionBody>> => {
  const url = '/recipe/collection';
  const data: CollectionBody = { id: id };
  return axiosInstance.delete(url, { data })
}

// 热门搜索词
export const querySearchHotkeys = (): Promise<AxiosResponse<Array<string>, void>> => {
  const url = '/recipe/hot-keys';
  return axiosInstance.get(url)
}