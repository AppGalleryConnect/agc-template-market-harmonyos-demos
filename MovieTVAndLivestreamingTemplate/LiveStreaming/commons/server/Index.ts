import { container } from '@agctemplate/utils';

import { RequestAPI } from './src/main/ets/api/RequestAPI';

export { RequestAPI } from './src/main/ets/api/RequestAPI';

export { AudienceRes, AudienceArrRes } from './src/main/ets/api/mock/mockAudienceFactory';

container.register(RequestAPI, {
  value: new RequestAPI()
});
