import { promptAction } from '@kit.ArkUI';
import fs from '@ohos.file.fs';
import { Constants } from 'constant';
import { AccountUtil } from 'account';
import { getFormatDate } from 'calendar';
import { GetInfoRequest, https } from 'network';
import { PersonalInfoVM } from '../viewmodel/PersonalInfoVM';
import { Logger } from 'util/Index';
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { util } from '@kit.ArkTS';
import { TitleBar } from 'component';
import { PersonalPopInfo } from '../model/Index';

@Builder
export function PersonalInfoBuilder() {
  PersonalInfo();
}

@Component
struct PersonalInfo {
  vm: PersonalInfoVM = PersonalInfoVM.instance;
  @State nickName: string = '';
  @State gender: number = 0;
  @State phoneNo: string = '';
  @State isShow: boolean = false;
  @State currentDate: string = '';
  @State genderSelected: number = 0;
  @State isSelected: boolean = false;
  @State localImgUri: ResourceStr = '';
  @State openId: string | undefined = AccountUtil.getOpenId();
  controller: TextInputController = new TextInputController();
  @Consume('mainPathStack') mainPathStack: NavPathStack;

  async aboutToAppear(): Promise<void> {
    const data: GetInfoRequest = {
      appId: '',
      openId: this.openId,
    };

    const res = await https.queryUserInfo(data);
    if (res.code === 200) {
      this.vm.userInfo.id = res.data.id;
      this.vm.userInfo.birthday = res.data.birthday;
      this.vm.userInfo.avatar = res.data.avatar;
      this.nickName = res.data.nickName;
      this.gender = res.data.gender;
      this.currentDate = res.data.birthday;
      this.phoneNo = res.data.phone;
      this.localImgUri = res.data.avatar;
    }
  }

  @Builder
  DatePickerBuilder() {
    Column() {
      DatePicker({
        start: new Date('1970-1-1'),
        end: new Date('2100-1-1'),
        selected: new Date(this.currentDate),
      })
        .disappearTextStyle({ color: Color.Gray, font: { size: '14', weight: FontWeight.Bold } })
        .textStyle({ color: '#ff182431', font: { size: '14', weight: FontWeight.Normal } })
        .selectedTextStyle({
          color: $r('app.color.keyword_type_font_color'),
          font: { size: '14', weight: FontWeight.Regular },
        })
        .onDateChange((value: Date) => {
          this.currentDate = getFormatDate(value);
        });
    }.justifyContent(FlexAlign.Center).height(Constants.FULL_SCREEN);
  }

  build() {
    NavDestination() {
      TitleBar({
        isShowBack: true, title: '个人信息', clickEvent: () => {
          this.mainPathStack.pop();
        },
      });
      Column() {
        Column() {
          Stack({ alignContent: Alignment.Bottom }) {
            FunctionalButton({
              params: {
                openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
                label: '',
                styleOption: {
                  styleConfig: new functionalButtonComponentManager.ButtonConfig()
                    .type(ButtonType.Circle)
                    .backgroundImage(this.localImgUri ? this.localImgUri : $r('app.media.avatar'))
                    .backgroundImageSize(ImageSize.Contain)
                    .width(106)
                    .height(106)
                    .backgroundColor('#FFE5E5E5'),
                },
              },
              controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar((error,
                data) => {
                if (error) {
                  return;
                }
                let avatarFile: fs.File = fs.openSync(data.avatarUri!, fs.OpenMode.READ_ONLY);
                try {
                  let newPath: string = getContext().cacheDir + `/${util.generateRandomUUID(false)}.png`;
                  fs.copyFileSync(avatarFile.fd, newPath);
                  this.localImgUri = 'file://' + newPath;
                } catch (err) {
                  Logger.error('choose avatar fail' + JSON.stringify(err));
                } finally {
                  fs.close(avatarFile);
                }
              }),
            });
            Text('更换头像').fontSize(10).padding({ bottom: 8 }).fontColor(Color.White);
          }.margin({ top: 32, bottom: 32 });

          Row() {
            Text('昵称').fontSize(14).width(72);
            TextInput({ text: this.nickName, placeholder: '请输入昵称' })
              .fontSize(14)
              .backgroundColor(Color.White)
              .placeholderFont({ size: $r('sys.float.Body_M') })
              .onChange((value: string) => {
                this.nickName = value;
              });
          }.padding({ left: 16, right: 16 });

          Divider().vertical(false);

          Row() {
            Text('性别').fontSize(14).width(72);
            Row() {
              Checkbox({ name: 'checkbox1', group: 'checkboxGroup' })
                .select(this.gender === 1)
                .selectedColor(Color.Black)
                .shape(CheckBoxShape.CIRCLE)
                .onChange((value: boolean) => {
                  value ? this.gender = 1 : this.gender = 0;
                });

              Text('男').fontSize(14);

              Checkbox({ name: 'checkbox1', group: 'checkboxGroup' })
                .select(this.gender === 0)
                .selectedColor(Color.Black)
                .margin({ left: 36 })
                .shape(CheckBoxShape.CIRCLE)
                .onChange((value: boolean) => {
                  value ? this.gender = 0 : this.gender = 1;
                });

              Text('女').fontSize(14);
            }.padding({ left: 10 });
          }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.Start).padding(16);

          Divider().vertical(false);

          Row() {
            Row() {
              Text('生日').fontSize(14).width(72);
              Text(`${this.currentDate}`).padding({ left: 14 }).fontSize(14);
            };

            Image($r('app.media.icon_direction_right')).size({ width: 12, height: 12 });
          }
          .width(Constants.FULL_SCREEN)
          .justifyContent(FlexAlign.SpaceBetween)
          .padding(16)
          .onClick(() => {
            this.isShow = true;
          })
          .bindSheet($$this.isShow, this.DatePickerBuilder(), {
            height: '50%',
            backgroundColor: Color.White,
          });

          Divider().vertical(false);

          Row() {
            Text('手机号').fontSize(14).width(72);
            TextInput({ text: this.phoneNo, placeholder: '请输入手机号' })
              .backgroundColor(Color.White)
              .fontSize(14)
              .placeholderFont({ size: $r('sys.float.Body_M') })
              .onChange((value: string) => {
                this.phoneNo = value;
              });
          }.padding({ left: 16, right: 16 });

          Divider().vertical(false);

          Button('保存', { type: ButtonType.Normal })
            .backgroundColor('#007DFF')
            .borderRadius($r('sys.float.corner_radius_level4'))
            .width('90%')
            .margin({ top: 16 })
            .onClick(() => {
              this.save();
            });

          Button('退出登录', { type: ButtonType.Normal })
            .fontColor($r('sys.color.black'))
            .backgroundColor('#FFFFFF')
            .border({ width: 1, radius: $r('sys.float.corner_radius_level4') })
            .width('90%')
            .margin({ top: 16 })
            .onClick(() => {
              this.logout();
            });
        };
      }.height('90%').justifyContent(FlexAlign.SpaceBetween);
    }.hideTitleBar(true);
  }

  async logout() {
    // 用户信息清空
    this.vm.userInfo.nickName = '';
    this.vm.userInfo.gender = 1;
    this.vm.userInfo.birthday = getFormatDate(new Date());
    this.vm.userInfo.phone = '';
    this.vm.userInfo.avatar = $r('app.media.default_avatar');
    AppStorage.setOrCreate('currentUser', '');
    AppStorage.setOrCreate('openID', '');
    const res = await this.vm.updatePersonInfo();
    if (res.code === 200) {
      promptAction.showToast({ message: '退出登录成功', duration: 1000 });
      this.mainPathStack.pop({
        type: 1,
        avatar: $r('app.media.default_avatar'),
        nickname: '立即登录',
      } as PersonalPopInfo);
    }
  }

  async save() {
    // 点击保存时方可修改
    this.vm.userInfo.nickName = this.nickName;
    this.vm.userInfo.gender = this.gender;
    this.vm.userInfo.birthday = this.currentDate;
    this.vm.userInfo.phone = this.phoneNo;
    this.vm.userInfo.avatar = this.localImgUri;
    const res = await this.vm.saveUserInfo();
    if (res?.code === 200) {
      promptAction.showToast({ message: '保存成功', duration: 1000 });
      this.mainPathStack.pop({
        type: 0,
        avatar: this.vm.userInfo.avatar,
        nickname: this.vm.userInfo.nickName,
      } as PersonalPopInfo);
    }
  }
}