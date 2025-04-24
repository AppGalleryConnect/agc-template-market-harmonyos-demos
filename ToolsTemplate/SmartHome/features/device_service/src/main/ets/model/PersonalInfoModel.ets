import { ObserverMngModel } from 'utils';


@ObservedV2
class PersonalProfileInfo {
  @Trace image: ResourceStr;
  @Trace name: string;

  constructor(image: ResourceStr, name: string) {
    this.image = image;
    this.name = name;
  }
}

interface PersonalInfo {
  avatar: ResourceStr;
  nickName: string;
  phone: string;
}

export class PersonalInfoObserverIntf {
  OnNickNameChange(nickName: string): void {
  }

  OnAvatarChange(avatar: ResourceStr): void {
  }
}

export class PersonalInfoModel extends ObserverMngModel<PersonalInfoObserverIntf> {
  private static instance: PersonalInfoModel;
  avatar: ResourceStr;
  nickName: string;
  phone: string;

  constructor() {
    super();
    this.avatar = $r('app.media.login');
    this.nickName = '';
    this.phone = '178******98';
  }

  static getInstance(): PersonalInfoModel {
    if (!PersonalInfoModel.instance) {
      PersonalInfoModel.instance = new PersonalInfoModel();
    }
    return PersonalInfoModel.instance;
  }

  getPersonalInfo(): PersonalInfo {
    let info: PersonalInfo = {
      avatar: this.avatar,
      nickName: this.nickName,
      phone: this.phone,
    };
    return info;
  }

  setNickName(nickName: string) {
    this.nickName = nickName;
    this.observers.forEach((item) => {
      item.OnNickNameChange(nickName);
    });
  }

  setAvatar(avatar: ResourceStr) {
    this.avatar = avatar;
    this.observers.forEach((item) => {
      item.OnAvatarChange(avatar);
    });
  }
}