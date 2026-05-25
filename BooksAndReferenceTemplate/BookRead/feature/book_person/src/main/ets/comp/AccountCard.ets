import { BreakpointStorage, BreakpointSystem, BreakpointTypeEnum, Constants,
  FontModel, TCRouter } from 'common';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { UserInfo, fp2pxUtil } from 'base_common';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct AccountCard {
  @Local bookCoins: number = 0;
  @Local isLogin: boolean = false;
  @Local userInfoFromStorage: UserInfo = AppStorage.get('userInfo') as UserInfo;
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint;
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  aboutToAppear(): void {
    this.loadUserInfo();
    // 监听登录状态变化
    try {
      emitter.on(Constants.LOGIN_CHANGE, () => {
        this.loadUserInfo();
      });
    } catch (error) {
      console.error('Failed to emitter on login change. Cause: ' + JSON.stringify(error));
    }

    try {
      emitter.on(Constants.COINS_CHANGE, () => {
        this.loadUserInfo();
      });
    } catch (error) {
      console.error('Failed to emitter on coins change. Cause: ' + JSON.stringify(error));
    }

    try {
      emitter.on(Constants.COINS_AD, () => {
        this.loadUserInfo();
      });
    } catch (error) {
      console.error('Failed to emitter on coins ad. Cause: ' + JSON.stringify(error));
    }
  }

  loadUserInfo() {
    const userInfoFromStorage: UserInfo = AppStorage.get('userInfo') as UserInfo;
    if (userInfoFromStorage) {
      this.bookCoins = typeof userInfoFromStorage.bookCoins === 'number' ? userInfoFromStorage.bookCoins : 100;
      this.isLogin = true;
    } else {
      this.bookCoins = 0;
      this.isLogin = false;
    }
  }

  // 更新书币余额
  updateBookCoins(amount: number) {
    const userInfoFromStorage: UserInfo = AppStorage.get('userInfo') as UserInfo;
    if (userInfoFromStorage) {
      const currentCoins = typeof userInfoFromStorage.bookCoins === 'number' ? userInfoFromStorage.bookCoins : 100;
      userInfoFromStorage.bookCoins = currentCoins + amount;
      AppStorage.setOrCreate('userInfo', userInfoFromStorage);
      AppStorage.setOrCreate('bookCoins', userInfoFromStorage.bookCoins);
      this.loadUserInfo();
    }
  }

  showLoginPrompt() {
    this.getUIContext()
      .getPromptAction()
      .showDialog({
        title: '提示',
        message: '需要先登录才能使用此功能',
        buttons: [
          {
            text: '取消',
            color: '#999999'
          },
          {
            text: '去登录',
            color: '#E3922F'
          }
        ]
      })
      .then((result) => {
        if (result.index === 1) {
          TCRouter.push(Constants.LOGIN_ROUTE);
        }
        // 点击"取消"，不做任何操作
      })
      .catch((error: BusinessError) => {
        console.error('AccountCard showLoginPrompt dialog error:', JSON.stringify(error));
      });
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('我的账户')
          .fontSize(this.fontModel.getFg(18))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.Start)

      Divider()
        .padding({ top: 8, bottom: 8 })

      Row() {
        Column({ space: 4 }) {
          Text(this.bookCoins.toString())
            .fontSize(this.fontModel.getFg(24))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
          Text('书币')
            .fontSize(this.fontModel.getFg(14))
            .fontColor($r('sys.color.font_secondary'))
        }
        .width(72)
        .alignItems(HorizontalAlign.Center)

        Row({ space: 8 }) {
          Button('赚书币')
            .width(72)
            .height(28)
            .fontSize(fp2pxUtil(14))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor($r('sys.color.multi_color_08'))
            .padding({
              top: 4,
              bottom: 4,
              left: 8,
              right: 8
            })
            .onClick(() => {
              TCRouter.pushByLogin(Constants.WELFARE_CENTER);
            })

          Button('充值')
            .width(72)
            .height(28)
            .fontSize(fp2pxUtil(14))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor($r('sys.color.multi_color_08'))
            .onClick(() => {
              TCRouter.pushByLogin(Constants.RECHARGE_ROUTE);
            })
        }
        .height(44)
        .alignItems(VerticalAlign.Bottom)
      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
    }
    .height(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 'auto' : 150)
    .padding({
      left: 12,
      right: 12,
      top: 12,
      bottom: 12
    })
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .justifyContent(FlexAlign.SpaceEvenly)
    .borderRadius(16)
  }
} 