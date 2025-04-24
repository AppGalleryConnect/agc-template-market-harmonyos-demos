import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import fs from '@ohos.file.fs';
import { Constant, getFormatDate, Logger } from 'common';
import { genderData, GenderType } from '../model/PersonalInfo';
import { MineVM } from '../viewmodel/MineVM';
import { util } from '@kit.ArkTS';
import { NickNameDialog, TitleBar } from 'components';

@Builder
export function EditPersonalInfoBuilder() {
  EditPersonalInfo();
}

@ComponentV2
export struct EditPersonalInfo {
  vm: MineVM = MineVM.instance;
  @Local index: number = 0;
  @Local isShowGender: boolean = false;
  @Local isShowBirthday: boolean = false;
  @Local cloneUserName: string = '';
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: NickNameDialog({
      change: (value: string) => {
        this.cloneUserName = value;
      },
      confirm: () => {
        this.vm.userInfo.nickname = this.cloneUserName;
      },
      nickName: this.cloneUserName,
    }),
    customStyle: true,
    autoCancel: true,
  });

  @Computed
  get genderVal() {
    let genderMap: Map<number, string> = new Map();
    genderData.forEach((item) => {
      genderMap.set(item, item === GenderType.MALE ? '男' : '女');
    });

    return genderMap.get(this.vm.userInfo.gender) ?? '';
  }

  @Builder
  GenderSelectBuilder() {
    List() {
      ForEach(genderData, (item: GenderType) => {
        ListItem() {
          Column() {
            Text(`${item === GenderType.MALE ? '男' : '女'}`)
              .fontWeight(500)
              .height(48)
              .width(Constant.FULL_PERCENT)
              .textAlign(TextAlign.Center);
            Divider().opacity(0.05);
          };
        }.onClick(() => {
          this.vm.userInfo.gender = item;
          this.isShowGender = false;
        });
      }, (item: GenderType) => item.toString());

      ListItem() {
        Text('取消')
          .width(Constant.FULL_PERCENT)
          .textAlign(TextAlign.Center)
          .height(40)
          .opacity(0.4)
          .onClick(() => this.isShowGender = false);
      };
    }.padding(12);
  }

  @Builder
  BirthdaySelectBuilder() {
    Column() {
      DatePicker({
        start: new Date('1970-1-1'),
        end: new Date('2100-1-1'),
        selected: new Date(this.vm.userInfo.birthday),
      })
        .disappearTextStyle({ color: Color.Gray, font: { size: '14', weight: FontWeight.Bold } })
        .textStyle({ color: '#ff182431', font: { size: '14', weight: FontWeight.Normal } })
        .selectedTextStyle({
          color: '#64BB5C',
          font: { size: '20', weight: 500 },
        })
        .onDateChange((value: Date) => {
          this.vm.userInfo.birthday = getFormatDate(value);
        });
    }.height(Constant.FULL_PERCENT).justifyContent(FlexAlign.Center);
  }

  @Builder
  ProfileBuilder() {
    Row() {
      Text('头像').fontWeight(500).opacity(0.9);
      Row() {
        FunctionalButton({
          params: {
            openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
            label: '',
            styleOption: {
              styleConfig: new functionalButtonComponentManager.ButtonConfig()
                .type(ButtonType.Circle)
                .backgroundImage(this.vm.userInfo.avatar ? this.vm.userInfo.avatar : $r('app.media.default_avatar'))
                .backgroundImageSize(ImageSize.Cover)
                .width(28)
                .height(28)
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
              this.vm.userInfo.avatar = 'file://' + newPath;
            } catch (err) {
              Logger.error('choose avatar fail' + JSON.stringify(err));
            } finally {
              fs.close(avatarFile);
            }
          }),
        });
        Image($r('app.media.chevron_right')).size({ width: 14, height: 24 });
      };
    }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

    Divider().margin({ top: 12, bottom: 12 }).opacity(0.05);
  }

  @Builder
  NickNameBuilder() {
    Row() {
      Text('昵称').fontWeight(500).opacity(0.9);
      Row({ space: 4 }) {
        Text(this.vm.userInfo.nickname ? this.vm.userInfo.nickname : '华为用户');
        Image($r('app.media.chevron_right')).size({ width: 14, height: 24 });
      };
    }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween).onClick(() => {
      this.cloneUserName = this.vm.userInfo.nickname;
      if (this.dialogController != null) {
        this.dialogController.open();
      }
    });

    Divider().margin({ top: 12, bottom: 12 }).opacity(0.05);
  }

  @Builder
  GenderBuilder() {
    Row() {
      Text('性别').fontWeight(500).opacity(0.9);
      Row() {
        Text(this.genderVal);
        Image($r('app.media.chevron_right')).size({ width: 14, height: 24 });
      };
    }
    .width(Constant.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => {
      this.isShowGender = true;
    }).bindSheet($$this.isShowGender, this.GenderSelectBuilder(),
      { showClose: false, height: 180 });

    Divider().margin({ top: 12, bottom: 12 }).opacity(0.05);
  }

  @Builder
  BirthdayBuilder() {
    Row() {
      Text('生日').fontWeight(500).opacity(0.9);
      Row() {
        Text(this.vm.userInfo.birthday);
        Image($r('app.media.chevron_right')).size({ width: 14, height: 24 });
      };
    }
    .width(Constant.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => {
      this.isShowBirthday = true;
    }).bindSheet($$this.isShowBirthday, this.BirthdaySelectBuilder(),
      { height: '40%' });
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '用户信息', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Column(){
          this.ProfileBuilder();
          this.NickNameBuilder();
          this.GenderBuilder();
          this.BirthdayBuilder();
        }.padding(12)
      }.height(Constant.FULL_PERCENT);
    }.hideTitleBar(true);
  }
}
