import { MinePageVM } from '../viewModels/MinePageVM';
import { buildTitleBar } from 'commonlib';
import { LengthMetrics } from '@kit.ArkUI';
import { PersonalInfo, PersonalInfoView, DataType } from 'collect_personal_info';

@Builder
export function PersonalInfoBuilder() {
  PersonalView();
}

@ComponentV2
struct PersonalView {
  vm: MinePageVM = MinePageVM.instance;

  aboutToAppear(): void {
    this.vm.personalInfo.nickName = this.vm.userInfo.nickname ? this.vm.userInfo.nickname : '华为用户';
    this.vm.personalInfo.avatar = this.vm.userInfo.avatar;
    this.vm.personalInfo.fullName = this.vm.userInfo.nickname ? this.vm.userInfo.name : '';
    this.vm.personalInfo.introDesc = this.vm.userInfo.introDesc ? this.vm.userInfo.introDesc : '';
    this.vm.personalInfo.gender = this.getGenderWithSex(this.vm.userInfo.sex);
    this.vm.personalInfo.birthDate =
      new Date(this.vm.userInfo.birthday) ? new Date(this.vm.userInfo.birthday) : new Date('1990-10-01');
    this.vm.personalInfo.phoneNumber = this.vm.userInfo.cellphone ? this.vm.userInfo.cellphone : '';
  }

  getSexWithGender(gender: number): string {
    let sex = '男';
    switch (gender) {
      case 0:
        sex = '男';
        break;
      case 1:
        sex = '女';
        break;
      case 2:
        sex = '保密';
        break;
      default:
        sex = '男';
        break;
    }
    return sex;
  }

  getGenderWithSex(sex: string): number {
    let gender = 0;
    switch (sex) {
      case '男':
        gender = 0;
        break;
      case '女':
        gender = 1;
        break;
      case '保密':
        gender = 2;
        break;
      default:
        gender = 0;
        break;
    }
    return gender;
  }

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        PersonalInfoView({
          switchInfo: this.vm.switchInfo,
          personalInfo: this.vm.personalInfo,
          apiInfo: this.vm.apiInfo,
          onChange: (type: DataType, data: PersonalInfo) => {
            this.vm.userInfo.nickname = data.nickName as string;
            this.vm.userInfo.avatar = data.avatar as string;
            this.vm.userInfo.name = data.fullName as string;
            this.vm.userInfo.sex = this.getSexWithGender(data.gender!);
            this.vm.userInfo.birthday = data.birthDate?.toString() as string;
            this.vm.userInfo.cellphone = data.phoneNumber as string;
            this.vm.userInfo.introDesc = data.introDesc as string;
          }
        })
      }
      .height('100%')
      .backgroundColor($r('sys.color.comp_background_gray'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .padding({ top: 12, left: 16, right: 16 });
    }
    .title(buildTitleBar('个人信息'), { paddingStart: LengthMetrics.vp(16) })
    .padding({ top: 40 })
  }
}