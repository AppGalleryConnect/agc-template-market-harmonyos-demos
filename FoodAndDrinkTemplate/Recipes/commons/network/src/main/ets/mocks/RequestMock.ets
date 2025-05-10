import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { axiosInstance } from '../apis/HttpRequest';
import { AxiosMock } from './AxiosMock';
import {
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
  getCollectionList,
  getHistoryList,
  getMyRecipeList,
  isCollected,
  removeCollection,
} from './MockData/Mine';
import { UploadRecipeBody } from '../types/Recipe';

const mock: AxiosMock = new AxiosMock(axiosInstance, {
  delayResponse: 300,
});

mock.onGet('/recipe/list').reply(async (config: AxiosRequestConfig) => {
  let list = getRecipeBriefInfoList();
  const category: string = config.params?.category;
  const name: string = config.params?.name;
  if (category) {
    list = list.filter((item => item.category.includes(category)))
  }
  if (name) {
    list = list.filter((item => item.title.includes(name) || item.category.includes(name)))
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
  return {
    status: HttpStatusCode.Ok,
  };
});

mock.onDelete('/recipe/collection').reply(async (config: AxiosRequestConfig) => {
  const id = Number(JSON.parse(config.data).id);
  removeCollection(id);
  return {
    status: HttpStatusCode.Ok,
  };
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
  return {
    status: HttpStatusCode.Ok,
  };
});
