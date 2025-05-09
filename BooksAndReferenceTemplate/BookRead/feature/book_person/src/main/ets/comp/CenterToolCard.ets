import { BookApi, Constants, GetUserInfoRsp, TCRouter, UserInfo } from 'common';

@ComponentV2
export struct CenterToolCard {
  @Local userInfo: UserInfo | undefined;

  async aboutToAppear(): Promise<void> {
    const rsp: GetUserInfoRsp = await BookApi.getUserInfo('123');
    this.userInfo = rsp.user;
  }

  @Builder
  IconCard(img: Resource, text: ResourceStr, jumpPath: string, params?: ESObject) {
    Column({ space: 20 }) {
      Stack() {
        Column()
          .height(40)
          .width(40)
          .opacity(0.1)
          .borderRadius(100)
          .backgroundColor($r('app.color.ic_color'))
        Image(img)
          .height(25)
          .width(25)
      }

      Text(text)
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.font_primary'))
    }.onClick(() => {
      TCRouter.pushByLogin(jumpPath, params);
    })

  }

  build() {
    Column({ space: 10 }) {
      Row() {
        this.IconCard($r('app.media.ic_book_list'), $r('app.string.book_list'), Constants.SHELF_ROUTER, false);
        this.IconCard($r('app.media.ic_history'), $r('app.string.history'), Constants.SHELF_ROUTER, true);
        this.IconCard($r('app.media.ic_library'), $r('app.string.library'), Constants.LIBARY_ROUTE);
        this.IconCard($r('app.media.ic_borrow_card'), $r('app.string.borrow_card'), Constants.BORROW_ROUTE);
      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .height(135)
      .borderRadius(16)
      .padding({
        left: 16,
        right: 16,
        top: 24,
        bottom: 24,
      })

      Column() {
        Row() {
          Row() {
            Image($r('app.media.ic_setting'))
              .width(16)
              .height(16)
            Text($r('app.string.settings'))
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_primary'))
              .margin({ left: 12 })
          }

          Image($r('app.media.arrow_right')).width(16).height(16)
        }
        .width(Constants.FULL_SIZE)
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
          TCRouter.pushByLogin(Constants.SETTING_ROUTE);
        })
      }
      .padding(16)
      .width(Constants.FULL_SIZE)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(16)


      Column() {
        Row() {
          Row() {
            Image($r('app.media.ic_public_about'))
              .width(16)
              .height(16)
            Text($r('app.string.about'))
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_primary'))
              .margin({ left: 12 })
          }

          Image($r('app.media.arrow_right'))
            .width(16).height(16)
        }
        .width(Constants.FULL_SIZE)
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
          TCRouter.push(Constants.ABOUT_ROUTE);
        })
      }
      .padding(16)
      .width(Constants.FULL_SIZE)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(16)
    }
  }
}