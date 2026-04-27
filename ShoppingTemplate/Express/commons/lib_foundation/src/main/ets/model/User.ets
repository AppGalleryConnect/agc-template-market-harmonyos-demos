import { relationalStore } from '@kit.ArkData';

export enum LoginStatus {
  LOGGED_OUT = 0,
  LOGGED_IN
}

export class User {
  // 用户id
  userId: number = 0;
  // 手机号
  phone: string = '';
  // 昵称
  nickname: string = '';
  // 性别
  gender: number = 2;
  // 生日
  birthday: string = '';
  // 头像
  avatar: string = '';
  // 登录状态 0：未登录  1：登录
  loginStatus: number = 0;
  // 最后登录时间
  lastLoginTime: string = '';
  // 实名认证状态 0：未实名  1：已实名
  isRealName: number = 0;
  // 真实姓名
  realName: string = '';
  // 脱敏身份证
  idCardMask: string = '';
  // 会员开通状态  0：未开通  1：已开通
  isVip: number = 0;
  // 会员超期时间
  vipExpireTime: number = 0;
  // 会员权益领取状态 0：未领取  1：已领取
  isClaimBenefit: number = 0
  // 积分
  points: number = 0;

  /**
   * 将数据库查询结果单行转换为 User 对象
   */
  static fromResultSet(resultSet: relationalStore.ResultSet): User {
    const user = new User();
    // 2. 根据索引获取对应类型的值
    try {
      user.userId = resultSet.getLong(resultSet.getColumnIndex('user_id'));
      user.phone = resultSet.getString(resultSet.getColumnIndex('phone'));
      user.gender = resultSet.getLong(resultSet.getColumnIndex('gender'));
      user.loginStatus = resultSet.getLong(resultSet.getColumnIndex('login_status'));
      user.isRealName = resultSet.getLong(resultSet.getColumnIndex('is_real_name'));
      user.isVip = resultSet.getLong(resultSet.getColumnIndex('is_vip'));
      user.vipExpireTime = resultSet.getLong(resultSet.getColumnIndex('vip_expire_time'));
      user.isClaimBenefit = resultSet.getLong(resultSet.getColumnIndex('is_claim_benefit'));
      user.points = resultSet.getLong(resultSet.getColumnIndex('points'));
      // 处理可能为 null 的字段
      const nicknameIndex = resultSet.getColumnIndex('nickname');
      if (!resultSet.isColumnNull(nicknameIndex)) {
        user.nickname = resultSet.getString(nicknameIndex);
      }
      const avatarIndex = resultSet.getColumnIndex('avatar');
      if (!resultSet.isColumnNull(avatarIndex)) {
        user.avatar = resultSet.getString(resultSet.getColumnIndex('avatar'));
      }
      const birthDataIndex = resultSet.getColumnIndex('birthday');
      if (!resultSet.isColumnNull(birthDataIndex)) {
        user.birthday = resultSet.getString(resultSet.getColumnIndex('birthday'));
      }
      const lastLoginTimeIndex = resultSet.getColumnIndex('last_login_time');
      if (!resultSet.isColumnNull(lastLoginTimeIndex)) {
        user.lastLoginTime = resultSet.getString(resultSet.getColumnIndex('last_login_time'));
      }
      const realNameIndex = resultSet.getColumnIndex('real_name');
      if (!resultSet.isColumnNull(realNameIndex)) {
        user.realName = resultSet.getString(resultSet.getColumnIndex('real_name'));
      }
      const idCardMaskIndex = resultSet.getColumnIndex('id_card_mask');
      if (!resultSet.isColumnNull(idCardMaskIndex)) {
        user.idCardMask = resultSet.getString(resultSet.getColumnIndex('id_card_mask'));
      }
    } catch (error) {
      // TODO: Implement error handling.
    }

    return user;
  }
}