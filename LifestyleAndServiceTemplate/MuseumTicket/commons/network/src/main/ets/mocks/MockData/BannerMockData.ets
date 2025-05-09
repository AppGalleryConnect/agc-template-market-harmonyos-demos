import { getFormattedResp } from '../Utils';
import { GetBannerImgRequest } from '../../types/RequestTypes';
import { CLOUD_STORAGE_URL } from '../Constants';

const url1 = CLOUD_STORAGE_URL + 'IMG_379.png?token=429c87bf-e9eb-474b-b079-e94ea238c668';

const url2 = CLOUD_STORAGE_URL + 'IMG_002.png?token=fd98d196-dca0-4bbc-b8e4-dfcb4a84593e';

const url3 = CLOUD_STORAGE_URL + 'IMG_380.png?token=7448f9bd-194d-4728-a4e2-567138dfda07';

export class BannerDatasetMock {
  public static getBannerSource(data: GetBannerImgRequest) {
    if (data.pageType === 1) {
      return getFormattedResp([url1, url2]);
    } else {
      return getFormattedResp(url3);
    }
  }
}