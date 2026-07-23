import { ToastDialog } from '@hw-agconnect/ui-toast';
import { GetInfoRequest, https } from 'network';
import { CommonHeader } from 'component';
import {
  PersonalInfoView,
  DataType,
  PersonalInfo as CollectPersonalInfo,
  ApiHandler,
  SwitchInfo,
} from 'collect_personal_info';
import { PersonalInfoVM } from '../viewmodel/PersonalInfoVM';
import { PersonalPopInfo } from '../model/Index';

@Builder
export function PersonalInfoBuilder() {
  PersonalInfoPage();
}

@ComponentV2
struct PersonalInfoPage {
  vm: PersonalInfoVM = PersonalInfoVM.instance;
  @Local nickName: string = '';
  @Local gender: number = 0;
  @Local phoneNo: string = '';
  @Local avatar: ResourceStr = '';
  @Local birthday: string = '';
  @Local fullName: string = '';
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  async aboutToAppear(): Promise<void> {
    const openId: string = AppStorage.get('openID') as string || '';
    const data: GetInfoRequest = {
      appId: '',
      openId: openId,
    };

    const res = await https.queryUserInfo(data);
    if (res.code === 200) {
      this.vm.userInfo.id = res.data.id;
      this.vm.userInfo.birthday = res.data.birthday;
      this.vm.userInfo.avatar = res.data.avatar;
      this.nickName = res.data.nickName;
      this.gender = res.data.gender;
      this.phoneNo = res.data.phone;
      this.avatar = res.data.avatar ? res.data.avatar : $r('app.media.avatar');
      this.birthday = res.data.birthday;
    }
  }

  build() {
    NavDestination() {
      Column() {
        CommonHeader({ title: '个人信息', showBackButton: true, backButtonClick: () => {
          this.saveAndPop();
        }});

        PersonalInfoView({
          personalInfo: {
            avatar: this.avatar,
            nickName: this.nickName,
            gender: this.gender,
            birthDate: this.birthday ? new Date(this.birthday) : new Date(),
            fullName: this.fullName,
            phoneNumber: this.phoneNo,
          } as CollectPersonalInfo,
          apiInfo: {
            updateAvatar: async (param: Object) => {
              this.vm.userInfo.avatar = param as string;
              this.avatar = param as string;
              await this.vm.updatePersonInfo();
            },
            updateNickName: async (param: Object) => {
              this.vm.userInfo.nickName = param as string;
              this.nickName = param as string;
              await this.vm.updatePersonInfo();
            },
            updateGender: async (param: Object) => {
              this.vm.userInfo.gender = param as number;
              this.gender = param as number;
              await this.vm.updatePersonInfo();
            },
            updateBirth: async (param: Object) => {
              this.vm.userInfo.birthday = this.vm.getFormatDate(String(param));
              this.birthday = String(param);
              await this.vm.updatePersonInfo();
            },
            updateFullName: async (param: Object) => {
              this.fullName = param as string;
              await this.vm.updatePersonInfo();
            },
            updatePhoneInfo: {
              codeLength: 6,
              sendCode: (_phone: string) => {
                return new Promise((resolve) => {
                  setTimeout(() => {
                    resolve();
                  }, 1000);
                });
              },
              verifyCode: (_phone: string, _code: string) => {
                return new Promise((resolve) => {
                  setTimeout(() => {
                    resolve(true);
                  }, 1000);
                });
              },
            },
          } as ApiHandler,
          switchInfo: {
            showAvatar: true,
            showNickName: true,
            showGender: true,
            showBirthDate: true,
            showFullName: true,
            showPhoneNumber: true,
            showIntroDesc: true,
          } as SwitchInfo,
          onChange: (type: DataType, data: CollectPersonalInfo) => {
            if (type === DataType.NICK_NAME) {
              this.nickName = (data.nickName as string) ?? '';
            } else if (type === DataType.AVATAR) {
              this.avatar = data.avatar ?? '';
            } else if (type === DataType.GENDER) {
              this.gender = data.gender as number ?? 0;
            } else if (type === DataType.BIRTH_DATE) {
              this.birthday = String(data.birthDate ?? '');
            } else if (type === DataType.FULL_NAME) {
              this.fullName = (data.fullName as string) ?? '';
            } else if (type === DataType.PHONE_NUMBER) {
              this.phoneNo = data.phoneNumber ?? '';
            }
          },
        }).layoutWeight(1).padding(16);
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_secondary'));
    }.hideTitleBar(true);
  }

  async saveAndPop() {
    this.vm.userInfo.nickName = this.nickName;
    this.vm.userInfo.phone = this.phoneNo;
    this.vm.userInfo.avatar = this.avatar as string;
    this.vm.userInfo.gender = this.gender;
    this.vm.userInfo.birthday = this.birthday;
    const res = await this.vm.saveUserInfo(this.getUIContext());
    if (res?.code === 200) {
      ToastDialog.showToast({ message: '保存成功' });
      this.mainPathStack.pop({
        type: 0,
        avatar: this.vm.userInfo.avatar,
        nickname: this.vm.userInfo.nickName,
      } as PersonalPopInfo);
    }
  }
}
