import { cloud, CloudDBCollection, CloudDBZoneObjectOperator, CloudDBZoneQuery } from '@hw-agconnect/cloud-server';
import { UserInfo } from '../models/UserInfo';
import { AccountTriggerMap } from '../constants';
import { BindPhoneReq, UpdateUserInfoReq } from '../types/RequestTypes';
import { GetUserInfoResp } from '../types/ResponseTypes';
import { getPhoneNumber } from './AxiosApi';

const ZONE_NAME = 'ArtTraining';
const TAG = '[user-info-db]';

export class DatabaseHelper {
  logger;
  private userId: string;
  userList: CloudDBCollection<UserInfo>;

  constructor(logger, userId) {
    this.userId = userId;
    this.logger = logger;
    this.userList = cloud.database({ zoneName: ZONE_NAME }).collection(UserInfo);
  }

  public async bindPhone(params: BindPhoneReq) {
    const LOGGER_TAG = TAG + AccountTriggerMap.BIND_PHONE;
    const authCode = params.authCode;
    const createMock = params.createMock;
    try {
      const userResp = await this.getUserInfo();
      if (userResp && userResp.phone) {
        return userResp;
      } else {
        const newUser = await this._createUser(authCode, createMock, userResp);
        if (newUser) {
          await this.userList.upsert(newUser);
          this.logger.info(LOGGER_TAG + 'create or rebind user success');
          const userResp = this._getUserInfoResp(newUser);
          return userResp;
        }
      }
    } catch (err) {
      this.logger.error(LOGGER_TAG + ` error: ${err}`);
    }
  }

  public async unbindPhone() {
    const LOGGER_TAG = TAG + AccountTriggerMap.UNBIND_PHONE;
    try {
      const userQuery: CloudDBZoneQuery<UserInfo> = this.userList
        .query()
        .orderByAsc('userId')
        .equalTo('userId', this.userId);
      const userData: UserInfo[] = await userQuery.get();
      if (userData.length === 1) {
        const userResource = userData[0];
        if (userResource.getPhone()) {
          const operator = CloudDBZoneObjectOperator.build(userResource).update('phone', '');
          const res = await this.userList.update(operator);
          this.logger.info(LOGGER_TAG, 'clear phone number success');
          return res;
        }
      }
    } catch (err) {
      this.logger.error(LOGGER_TAG + ` error: ${err}`);
    }
  }

  public async getUserInfo() {
    const LOGGER_TAG = TAG + AccountTriggerMap.GET_INFO;
    try {
      const userQuery: CloudDBZoneQuery<UserInfo> = this.userList
        .query()
        .orderByAsc('userId')
        .equalTo('userId', this.userId);
      const userData = await userQuery.get();
      if (userData.length === 1) {
        this.logger.info(LOGGER_TAG + 'user has been created before ');
        const userResp = this._getUserInfoResp(userData[0]);
        return userResp;
      } else {
        this.logger.error(LOGGER_TAG + 'cannot find user');
      }
    } catch (err) {
      this.logger.error(LOGGER_TAG + `error: ${err}`);
    }
  }

  public async updateUserInfo(params: UpdateUserInfoReq) {
    const LOGGER_TAG = TAG + AccountTriggerMap.UPDATE_INFO;
    try {
      const userResp = await this.getUserInfo();
      if (userResp) {
        const updateData: UserInfo = new UserInfo();
        updateData.setUserId(this.userId);
        updateData.setAvatar(params.avatar ?? '');
        updateData.setNickname(params.nickname ?? '');
        updateData.setPhone(userResp.phone);
        updateData.setStudentID(userResp.studentID);
        updateData.setWechat(params.wechat ?? '');
        updateData.setBirthday(params.birthday ?? '');
        await this.userList.upsert(updateData);
        this.logger.info(LOGGER_TAG + ' update user info success');
        const newResp = this._getUserInfoResp(updateData);
        return newResp;
      } else {
        this.logger.error(LOGGER_TAG + ` cannot find exist user`);
      }
    } catch (err) {
      this.logger.error(LOGGER_TAG + ` error: ${err}`);
    }
  }

  private async _createUser(authCode: string, createMock: boolean = false, userResp: GetUserInfoResp | undefined) {
    const LOGGER_TAG = TAG + 'create-user';
    try {
      let initData;
      if (createMock) {
        initData = {
          mobileNumber: '12300005678',
          userName: '虚拟用户',
          avatar: '',
        };
      } else {
        initData = await getPhoneNumber(authCode, this.logger);
      }
      const studentID = new Date().getTime().toString();
      const user = new UserInfo();
      user.setUserId(this.userId);
      user.setAvatar(userResp?.avatar ?? initData.avatar);
      user.setNickname(userResp?.nickname ?? initData.userName);
      user.setPhone(initData.mobileNumber);
      user.setStudentID(userResp?.studentID ?? studentID);
      user.setWechat(userResp?.wechat ?? '');
      user.setBirthday(userResp?.birthday ?? '');
      return user;
    } catch (err) {
      this.logger.error(LOGGER_TAG + `error: ${err}`);
    }
  }

  private _getUserInfoResp(item: UserInfo) {
    const userResp: GetUserInfoResp = {
      avatar: item.getAvatar(),
      nickname: item.getNickname(),
      phone: item.getPhone(),
      studentID: item.getStudentID(),
      wechat: item.getWechat(),
      birthday: item.getBirthday(),
    };
    return userResp;
  }
}
