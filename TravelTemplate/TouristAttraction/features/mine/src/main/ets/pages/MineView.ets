import { AppStorageV2 } from '@kit.ArkUI';
import { Constant } from 'common';
import { TitleBar } from 'uicomponents';
import { UserInfo } from 'types';
import { ApiController, AtomicserviceLogin } from 'atomicservice_login';
import { LoginConfirmDialogComponent } from 'module_base';
import { getManagementModuleInfo, ManagementInfo } from '../model/ManagementInfo';
import { getOrderTypeInfo, OrderTypeInfo } from '../model/OrderTypeInfo';

@Builder
export function MineBuilder() {
  MineView();
}

@ComponentV2
export struct MineView {
  @Local userInfo: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local controller: ApiController = new ApiController()
  @Local currentClickFunc: Function = () => {
  }
  unBindPhone = async (): Promise<void> => {
    this.userInfo.mockUnLink()
  }
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: LoginConfirmDialogComponent({
      confirm: () => {
        this.userInfo.mockLink()
        this.getUIContext().getPromptAction().showToast({ message: '成功关联账号' })
        this.currentClickFunc()
      },
    }),
    customStyle: false,
    autoCancel: true,
  });

  @Builder
  FunctionBuilder() {
    List({ space: 12 }) {
      ForEach(getManagementModuleInfo(this.mainPathStack), (item: ManagementInfo, index: number) => {
        ListItem() {
          Column() {
            Row() {
              Row({ space: 8 }) {
                Image(item.icon).size({ width: 14, height: 14 });
                Text(item.title).fontSize(12).opacity(0.9);
              };

              Image($r('app.media.chevron_right')).size({ width: 14, height: 14 });
            }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

            if (index !== 2) {
              Divider().margin({ top: 12 });
            }
          }.onClick(() => {
            if (this.userInfo.isLink) {
              item.click()
            } else {
              this.currentClickFunc = item.click
              this.dialogController?.open()
            }
          });
        };
      }, (item: ManagementInfo, index: number) => index + '__' + JSON.stringify(item));
    }.padding(12).backgroundColor($r('sys.color.font_on_primary')).borderRadius(8);
  }

  @Builder
  OrderBuilder() {
    Column({ space: 16 }) {
      Text('我的订单').fontSize(14).fontWeight(500);

      Row({ space: 28 }) {
        ForEach(getOrderTypeInfo(this.mainPathStack), (item: OrderTypeInfo) => {
          Column({ space: 4 }) {
            Image(item.icon).size({ width: 18, height: 18 });
            Text(item.name).fontSize(12).margin({ top: 8 });
          }.onClick(() => {
            if (this.userInfo.isLink) {
              item.click()
            } else {
              this.currentClickFunc = item.click
              this.dialogController?.open()
            }
          });
        }, (item: OrderTypeInfo) => item.type.toString());
      };
    }
    .padding(16)
    .backgroundColor($r('sys.color.font_on_primary'))
    .borderRadius(8)
    .width(Constant.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
    .margin({ top: 22, bottom: 12 });
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: false, title: '个人中心', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Column() {
          Row() {
            AtomicserviceLogin({
              userInfo: this.userInfo,
              isLink: this.userInfo.isLink,
              controller: this.controller,
              bindPhone: (code: string | undefined) => {
                // todo 替换为开发者需要的资源
                this.userInfo.mockLink()
                this.getUIContext().getPromptAction().showToast({ message: '请通过临时登录凭证获取真实手机号' })
              },
              onGetPhoneError: (err) => {
                if (err) {
                  // todo 替换为开发者需要的资源
                  this.userInfo.mockLink()
                  this.getUIContext()
                    .getPromptAction()
                    .showToast({ message: '元服务未获取phone权限或用户授权，此为模拟关联。' })
                }
              },
              linkToEdit: () => {
                this.mainPathStack.pushPathByName('EditPersonalInfo', null);
              },
              unBindPhone: this.unBindPhone,
            })
          }
          .backgroundColor($r('sys.color.background_primary'))
          .borderRadius(16)

          this.OrderBuilder();
          this.FunctionBuilder();
        }.padding(12);

      }.backgroundColor('#F1F3F5').height(Constant.FULL_PERCENT).linearGradient({
        direction: GradientDirection.Bottom, // 渐变方向
        repeating: false, // 渐变颜色是否重复
        colors: [['rgba(100, 187, 92, 0.9)', 0.0], ['rgba(100, 187, 92, 0)', 0.5],
          ['rgba(100, 187, 92, 0)', 1]], // 数组末尾元素占比小于1时满足重复着色效果
      })
    }
  }
}