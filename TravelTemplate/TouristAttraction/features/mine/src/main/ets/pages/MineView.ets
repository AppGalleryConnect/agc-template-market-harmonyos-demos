import { AppStorageV2 } from '@kit.ArkUI';
import { ApiController, AtomicserviceLogin } from 'atomicservice_login';
import { BreakpointModel, BreakpointNameEnum, Constant } from 'common';
import { LoginConfirmDialogComponent } from 'module_base';
import { UserInfo } from 'types';
import { TitleBar } from 'uicomponents';
import { getManagementModuleInfo, ManagementInfo } from '../model/ManagementInfo';
import { getOrderTypeInfo, OrderTypeInfo } from '../model/OrderTypeInfo';

@Builder
export function MineBuilder() {
  MineView();
}

@ComponentV2
export struct MineView {
  @Local userInfo: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;
  unBindPhone = async (): Promise<void> => {
    this.userInfo.mockUnLink();
  };
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local controller: ApiController = new ApiController();
  @Local currentClickFunc: Function = () => {
  };
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: LoginConfirmDialogComponent({
      confirm: () => {
        this.userInfo.mockLink();
        this.getUIContext().getPromptAction().showToast({ message: '成功关联账号' });
        this.currentClickFunc();
      },
    }), customStyle: false, autoCancel: true,
  });

  getFunctionLane() {
    return [BreakpointNameEnum.MD, BreakpointNameEnum.SM].includes(this.breakPointModel.currentBreakpoint) ? 1 : 2
  }

  @Builder
  FunctionBuilder() {
    List() {
      ForEach(getManagementModuleInfo(this.mainPathStack), (item: ManagementInfo, index: number) => {
        ListItem() {
          Row({ space: 4 }) {
            Row({ space: 16 }) {
              SymbolGlyph(item.icon).width(24).height(24).fontSize(24).fontColor([$r('sys.color.icon_primary')]);
              Text(item.title)
                .fontSize($r('sys.float.Subtitle_M'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium);
            };

            SymbolGlyph($r('sys.symbol.chevron_right'))
              .width(12)
              .height(24)
              .fontSize(24)
              .fontColor([$r('sys.color.icon_fourth')]);
          }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween).padding({
            top: 16,
            bottom: 16,
            left: 12,
            right: 12,
          }).onClick(() => {
            if (this.userInfo.isLink) {
              item.click();
            } else {
              this.currentClickFunc = item.click;
              this.dialogController?.open();
            }
          });
        };
      }, (item: ManagementInfo, index: number) => index + '__' + JSON.stringify(item));
    }
    .margin({ top: 12 })
    .padding({ top: 4, bottom: 4 })
    .backgroundColor($r('sys.color.font_on_primary'))
    .borderRadius(16)
    .lanes(this.getFunctionLane())
    .divider({ strokeWidth: 1, startMargin: 52, endMargin: 12 });
  }

  @Builder
  OrderBuilder() {
    Column() {
      Text('我的订单')
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .padding({ top: 24, bottom: 8 });

      Row({ space: 30 }) {
        ForEach(getOrderTypeInfo(this.mainPathStack), (item: OrderTypeInfo) => {
          Column({ space: 4 }) {
            Image(item.icon).size({ width: 24, height: 24 });
            Text(item.name).fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary'));
          }.layoutWeight(1).onClick(() => {
            if (this.userInfo.isLink) {
              item.click();
            } else {
              this.currentClickFunc = item.click;
              this.dialogController?.open();
            }
          });
        }, (item: OrderTypeInfo) => item.type.toString());
      }.padding(12).backgroundColor($r('sys.color.background_primary')).borderRadius(16);
    }.width(Constant.FULL_PERCENT).alignItems(HorizontalAlign.Start);
  }

  build() {
    Column() {
      TitleBar({
        isShowBack: false, title: '我的', clickEvent: () => {
        },
      });

      Column() {
        Row() {
          AtomicserviceLogin({
            userInfo: this.userInfo,
            isLink: this.userInfo.isLink,
            controller: this.controller,
            bindPhone: (code: string | undefined) => { // todo 替换为开发者需要的资源
              this.userInfo.mockLink();
              this.getUIContext().getPromptAction().showToast({ message: '请通过临时登录凭证获取真实手机号' });
            },
            onGetPhoneError: (err) => {
              if (err) { // todo 替换为开发者需要的资源
                this.userInfo.mockLink();
                this.getUIContext()
                  .getPromptAction()
                  .showToast({ message: '元服务未获取phone权限或用户授权，此为模拟关联。' });
              }
            },
            linkToEdit: () => {
              this.mainPathStack.pushPathByName('EditPersonalInfo', null);
            },
            unBindPhone: this.unBindPhone,
          });
        }.backgroundColor($r('sys.color.background_primary')).borderRadius(16);

        this.OrderBuilder();
        this.FunctionBuilder();
      }.padding({
        top: 8,
        bottom: 8,
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding,
      });

    }.backgroundColor($r('sys.color.background_secondary')).height(Constant.FULL_PERCENT);
  };
}