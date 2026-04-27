import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { axiosInstance } from '../apis/HttpRequest';
import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import {
  changeFollowers,
  deleteRecipe,
  getBloggerInfo,
  getRecipeBriefInfoList,
  getRecipeCategory,
  getRecipeDetailById,
  getRecipeHotKeys,
  uploadRecipe,
} from './MockData/RecipeList';
import {
  addCollection,
  addHistory,
  addMyRecipe,
  getBloggerFollowers,
  getCollectionList,
  getHistoryList,
  getMemberPackages,
  getMyRecipeList,
  isCollected,
  removeCollection,
  removeMyRecipe,
} from './MockData/Mine';
import { DeleteMyRecipeBody, UploadRecipeBody } from '../types/Recipe';
import {
  addCustomFood,
  addDietPlans,
  clearDietPlans,
  getFoodCategory,
  queryDietPlan,
  queryDietPlans,
  searchFoodByName,
} from './MockData/Calories';
import { ChangeFollowersBody, CustomFoodBody, DietPlanBody } from '../types/Calories';
import { getNoticeList } from './MockData/Notice';

const mock: AxiosMockAdapter = new AxiosMockAdapter(axiosInstance, {
  delayResponse: 0,
});

mock.onGet('/recipe/list').reply(async (config: AxiosRequestConfig) => {
  let list = getRecipeBriefInfoList();
  const category: string = config.params?.category;
  const name: string = config.params?.name;
  if (category) {
    list = list.filter((item => item.category.includes(category)));
  }
  if (name) {
    list = list.filter((item => item.title.includes(name) || item.category.includes(name)));
  }

  return {
    status: HttpStatusCode.Ok,
    data: list,
  };
});

mock.onGet('/recipe/category').reply(async () => {
  let list = getRecipeCategory();
  return {
    status: HttpStatusCode.Ok,
    data: list,
  };
});

mock.onGet('/recipe/detail').reply(async (config: AxiosRequestConfig) => {
  const id = Number(config.params.id);
  addHistory(id);
  const detailItem = getRecipeDetailById(id);
  if (detailItem) {
    detailItem.isCollected = isCollected(id);
  }
  return {
    status: HttpStatusCode.Ok,
    data: getRecipeDetailById(id),
  };
});

mock.onGet('/recipe/mine/list').reply(async () => {
  return {
    status: HttpStatusCode.Ok,
    data: getMyRecipeList(),
  };
});

mock.onGet('/recipe/history/list').reply(async () => {
  return {
    status: HttpStatusCode.Ok,
    data: getHistoryList(),
  };
});

mock.onGet('/recipe/collection/list').reply(async () => {
  return {
    status: HttpStatusCode.Ok,
    data: getCollectionList(),
  };
});

mock.onPost('/recipe/collection').reply(async (config: AxiosRequestConfig) => {
  const id = Number(JSON.parse(config.data).id);
  addCollection(id);
  return [HttpStatusCode.Ok];
});

mock.onDelete('/recipe/collection').reply(async (config: AxiosRequestConfig) => {
  const id = Number(JSON.parse(config.data).id);
  removeCollection(id);
  return [HttpStatusCode.Ok];
});

mock.onGet('/recipe/hot-keys').reply(async () => {
  return {
    status: HttpStatusCode.Ok,
    data: getRecipeHotKeys(),
  };
});

mock.onPost('/recipe/upload').reply(async (config: AxiosRequestConfig) => {
  const data = JSON.parse(config.data) as UploadRecipeBody;
  const id = uploadRecipe(data);
  addMyRecipe(id);
  return [HttpStatusCode.Ok];
});


mock.onDelete('/recipe/remove').reply(async (config: AxiosRequestConfig) => {
  const data = JSON.parse(config.data) as DeleteMyRecipeBody;
  const ids = data.ids;
  deleteRecipe(ids);
  removeMyRecipe(ids);
  return [HttpStatusCode.Ok];
});

mock.onGet('/calories/food-category').reply(async (config: AxiosRequestConfig) => {
  let list = getFoodCategory();
  return {
    status: HttpStatusCode.Ok,
    data: list,
  };
});
mock.onPost('/calories/add-diet-plans').reply(async (config: AxiosRequestConfig) => {
  const data = JSON.parse(config.data) as DietPlanBody;
  addDietPlans(data);
  return [HttpStatusCode.Ok];
});
mock.onPost('/calories/clear-diet-plans').reply(async (config: AxiosRequestConfig) => {
  clearDietPlans();
  return [HttpStatusCode.Ok];
});
mock.onGet('/calories/diet-plans').reply(async (config: AxiosRequestConfig) => {
  return {
    status: HttpStatusCode.Ok,
    data: queryDietPlans(),
  };
});
mock.onGet('/calories/diet-plan').reply(async (config: AxiosRequestConfig) => {
  const menuId = Number(config.params.menuId);
  return {
    status: HttpStatusCode.Ok,
    data: queryDietPlan(menuId),
  };
});
mock.onGet('/blogger/blogger-info').reply(async (config: AxiosRequestConfig) => {
  const id = Number(config.params.id);
  return {
    status: HttpStatusCode.Ok,
    data: getBloggerInfo(id),
  };
});
mock.onGet('/blogger/blogger-followers').reply(async (config: AxiosRequestConfig) => {
  const id = Number(config.params.id);
  return {
    status: HttpStatusCode.Ok,
    data: getBloggerFollowers(id),
  };
});
mock.onGet('/blogger/change-followers').reply(async (config: AxiosRequestConfig) => {
  const data = JSON.parse(config.data) as ChangeFollowersBody;
  changeFollowers(data);
  return [HttpStatusCode.Ok];
});
mock.onGet('/notice/list').reply(async (config: AxiosRequestConfig) => {
  return {
    status: HttpStatusCode.Ok,
    data: getNoticeList(),
  };
});
mock.onGet('/calories/search').reply(async (config: AxiosRequestConfig) => {
  const name: string = config.params.name;
  return {
    status: HttpStatusCode.Ok,
    data: searchFoodByName(name),
  };
});
mock.onPost('/calories/food').reply(async (config: AxiosRequestConfig) => {
  const data = JSON.parse(config.data) as CustomFoodBody;
  addCustomFood(data);
  return [HttpStatusCode.Ok];
});
mock.onGet('/member/packages').reply(async (config: AxiosRequestConfig) => {
  return {
    status: HttpStatusCode.Ok,
    data: getMemberPackages(),
  };
});