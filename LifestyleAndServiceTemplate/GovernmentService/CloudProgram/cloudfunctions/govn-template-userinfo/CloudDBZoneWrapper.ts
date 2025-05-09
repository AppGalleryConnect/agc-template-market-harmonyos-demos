import { cloud, CloudDBCollection, CloudDBZoneQuery } from '@hw-agconnect/cloud-server';
import { govn_template_userInfo as govnUserInfo } from './govn_template_userInfo';
import { getAccessToken } from './AxiosApi'
import { ResponseUserInfo, UserInfo } from './AxiosApi'

// 这里的zone name必须与DataEntry中的CloudDBZoneName一致
const ZONE_NAME = "govnTemplateUserInfo";


export class CloudDbZoneWrapper {
  collection: CloudDBCollection<govnUserInfo>;

  constructor() {
    this.collection = cloud.database({ zoneName: ZONE_NAME }).collection(govnUserInfo);
  }


  async queryUserInfo(authorizationCode: string, logger) {
    // 拿到authorizationCode获取access_token
    const userInfo: ResponseUserInfo = await getAccessToken(authorizationCode, logger)
    logger.info('userInfo', JSON.stringify(userInfo))
    let query = this.collection.query().equalTo('phoneNumber', userInfo.loginMobileNumber);
    let queryRes = await query.get()
    if (queryRes.length) {
      return queryRes
    } else {
      await this.upsertTickets(
        [{
          idToken: "",
          authCode: "",
          userName: "华为用户",
          avatar: "",
          phoneNumber: userInfo.loginMobileNumber
        }]
      )
      let query = this.collection.query().equalTo('phoneNumber', userInfo.loginMobileNumber);
      return await query.get()
    }
  }

  async upsertTickets(records: UserInfo[]) {
    return await this.collection.upsert(records);
  }
}
