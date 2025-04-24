import { cloud, CloudDBCollection, CloudDBZoneQuery } from '@hw-agconnect/cloud-server';
import { govn_userInfo as govnUserInfo } from './govn_userInfo';
import { getAccessToken } from './AxiosApi'
import { ResponseUserInfo, UserInfo } from './AxiosApi'

// 这里的zone name必须与DataEntry中的CloudDBZoneName一致
const ZONE_NAME = "govnUserInfo";


export class CloudDbZoneWrapper {
  collection: CloudDBCollection<govnUserInfo>;

  constructor() {
    this.collection = cloud.database({ zoneName: ZONE_NAME }).collection(govnUserInfo);
  }


  async queryUserInfo(authorizationCode: string, logger) {
    // 拿到authorizationCode获取access_token
    const userInfo: ResponseUserInfo = await getAccessToken(authorizationCode, logger)
    logger.info('userInfo', JSON.stringify(userInfo))
    let query = this.collection.query().equalTo('phoneNumber', userInfo.mobileNumber);
    let queryRes = await query.get()
    if (queryRes.length) {
      return queryRes
    } else {
      await this.upsertTickets(
        [{
          idToken: "",
          authCode: "",
          userName: "",
          avatar: "https://agc-storage-drcn.platform.dbankcloud.cn/v0/dami-2vnai/%E5%A4%B4%E5%83%8F%20%E7%94%B7%E5%AD%A9%20(2).png?token=2ac0ac64-b53f-4e0a-af47-e54cbd4d2335",
          phoneNumber: userInfo.mobileNumber
        }]
      )
      let query = this.collection.query().equalTo('phoneNumber', userInfo.mobileNumber);
      return await query.get()
    }
  }

  async upsertTickets(records: UserInfo[]) {
    return await this.collection.upsert(records);
  }
}
