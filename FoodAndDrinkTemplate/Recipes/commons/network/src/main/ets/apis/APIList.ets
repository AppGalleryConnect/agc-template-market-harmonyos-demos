import { AxiosResponse } from '@ohos/axios';
import { axiosInstance } from './HttpRequest';
import {
  BloggerFollower,
  BloggerInfo,
  CollectionBody,
  DeleteMyRecipeBody,
  QueryListParams,
  RecipeBriefInfo,
  RecipeCategory,
  RecipeDetail,
  UploadRecipeBody,
} from '../types/Recipe';
import '../mocks/RequestMock';
import {
  ChangeFollowersBody,
  CustomFoodBody,
  DietPlanBody,
  DietPlans,
  FoodCalories,
  FoodCategory,
  FoodPlanCaloriesBody,
} from '../types/Calories';
import { Notice } from '../types/Notice';
import { MemberPackage } from '../types/Member';

// 查询菜谱列表
export const queryRecipeList = (params?: QueryListParams): Promise<AxiosResponse<Array<RecipeBriefInfo>, void>> => {
  const url = '/recipe/list';
  return axiosInstance.get(url, { params });
};

// 查询菜谱列表
export const queryRecipeCategory = (): Promise<AxiosResponse<Array<RecipeCategory>, void>> => {
  const url = '/recipe/category';
  return axiosInstance.get(url);
};

// 查询菜谱详情
export const queryRecipeDetail = (id: number): Promise<AxiosResponse<RecipeDetail, void>> => {
  const url = '/recipe/detail';
  return axiosInstance.get(url, { params: { id } });
};

// 查询我的菜谱
export const queryMyRecipeList = (): Promise<AxiosResponse<Array<RecipeBriefInfo>, void>> => {
  const url = '/recipe/mine/list';
  return axiosInstance.get(url);
};

// 上传我的菜谱
export const uploadMyRecipe = (data: UploadRecipeBody): Promise<AxiosResponse<void, UploadRecipeBody>> => {
  const url = '/recipe/upload';
  return axiosInstance.post(url, data);
};

// 查询浏览历史
export const queryRecipeHistoryList = (): Promise<AxiosResponse<Array<RecipeBriefInfo>, void>> => {
  const url = '/recipe/history/list';
  return axiosInstance.get(url);
};

// 查询我的收藏
export const queryCollectionList = (): Promise<AxiosResponse<Array<RecipeBriefInfo>, void>> => {
  const url = '/recipe/collection/list';
  return axiosInstance.get(url);
};

// 添加收藏
export const addCollection = (id: number): Promise<AxiosResponse<void, CollectionBody>> => {
  const url = '/recipe/collection';
  const data: CollectionBody = { id };
  return axiosInstance.post(url, data);
};

// 取消收藏
export const removeCollection = (id: number): Promise<AxiosResponse<void, CollectionBody>> => {
  const url = '/recipe/collection';
  const data: CollectionBody = { id: id };
  return axiosInstance.delete(url, { data });
};

// 删除我的菜谱
export const deleteMyRecipe = (ids: number[]): Promise<AxiosResponse<void, DeleteMyRecipeBody>> => {
  const url = '/recipe/remove';
  const data: DeleteMyRecipeBody = { ids };
  return axiosInstance.delete(url, { data });
};

// 热门搜索词
export const querySearchHotkeys = (): Promise<AxiosResponse<Array<RecipeBriefInfo>, void>> => {
  const url = '/recipe/hot-keys';
  return axiosInstance.get(url);
};

// 查询饮食列表
export const queryFoodCategory = (): Promise<AxiosResponse<Array<FoodCategory>, void>> => {
  const url = '/calories/food-category';
  return axiosInstance.get(url);
};

// 查询饮食计划列表
export const queryDietPlans = (): Promise<AxiosResponse<Array<DietPlans>, void>> => {
  const url = '/calories/diet-plans';
  return axiosInstance.get(url);
};

// 根据id查询饮食计划
export const queryDietPlan = (menuId: number): Promise<AxiosResponse<DietPlans, void>> => {
  const url = '/calories/diet-plan';
  return axiosInstance.get(url, { params: { menuId } });
};

// 查询饮食计划
export const addDietPlans =
  (menuId: number, name: string, foodList: FoodPlanCaloriesBody[]): Promise<AxiosResponse<number, void>> => {
    const url = '/calories/add-diet-plans';
    const data: DietPlanBody = {
      menuId,
      name,
      foodList,
    };
    return axiosInstance.post(url, data);
  };

// 删除饮食计划
export const clearDietPlans =
  (): Promise<AxiosResponse<number, void>> => {
    const url = '/calories/clear-diet-plans';
    return axiosInstance.post(url);
  };

// 查询博主信息
export const getBloggerInfo = (id: number): Promise<AxiosResponse<BloggerInfo, void>> => {
  const url = '/blogger/blogger-info';
  return axiosInstance.get(url, { params: { id } });
};

// 查询博主关注
export const getBloggerFollowers = (id: number): Promise<AxiosResponse<Array<BloggerFollower>, void>> => {
  const url = '/blogger/blogger-followers';
  return axiosInstance.get(url, { params: { id } });
};

// 关注/取关博主
export const changeFollowers = (bloggerId: number, type: number): Promise<AxiosResponse<void, ChangeFollowersBody>> => {
  const url = '/blogger/change-followers';
  const data: ChangeFollowersBody = { bloggerId, type };
  return axiosInstance.post(url, data);
};

// 查询消息列表
export const getMyNoticeList = (): Promise<AxiosResponse<Array<Notice>, void>> => {
  const url = '/notice/list';
  return axiosInstance.get(url);
};

// 搜索食物
export const searchFoodByName = (name: string): Promise<AxiosResponse<Array<FoodCalories>, void>> => {
  const url = '/calories/search';
  return axiosInstance.get(url, { params: { name } });
};

// 添加自定义食物
export const addCustomFood = (data: CustomFoodBody): Promise<AxiosResponse<void, CustomFoodBody>> => {
  const url = '/calories/food';
  return axiosInstance.post(url, data);
};

// 获取会员套餐
export const getMemberPackages = (): Promise<AxiosResponse<Array<MemberPackage>, void>> => {
  const url = '/member/packages';
  return axiosInstance.get(url);
};
