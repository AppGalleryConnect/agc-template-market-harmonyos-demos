import mockAdapter from '../common/MockAdapter';
import { AuthorServiceMock } from '../httpsmock/AuthorServiceMock';
import { HomeServiceMock } from '../httpsmock/HomeServiceMock';
import { MineServiceMock } from '../httpsmock/MineServiceMock';

// todo: 全局配置，是否启用mock，默认启用
const enableMock: boolean = true;

if (enableMock) {
  const mockApis = [
    new AuthorServiceMock(),
    new HomeServiceMock(),
    new MineServiceMock(),
  ];
  mockApis.forEach((api) => {
    api.start(mockAdapter);
  });
}