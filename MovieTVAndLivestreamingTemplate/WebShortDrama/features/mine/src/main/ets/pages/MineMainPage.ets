import { getMedia, getString, NAV_PAGE_NAME } from '@agctemplate/resources'
import {
  AppStorageKeys,
  ListItemModel,
  Mine,
  MinePageVM,
  MinorsMode,
  MinorsProtectionUtils,
  StatusBarHeight,
  UserInfoModel,
  CommentData
} from '@agctemplate/widgets'
import { appRouter, container, PreferConstant, PreferenceUtil } from '@agctemplate/utils';
import { AppStorageV2 } from '@kit.ArkUI';
import { CommentInfo, CommentListRes, RequestAPI } from '@agctemplate/server';
import { DialPanel } from 'dial_panel';
import { BusinessError } from '@kit.BasicServicesKit';

@ComponentV2
export struct MineMainPage {
  @Local statusBarHeight: StatusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight())!;
  @Local userAvatar: ListItemModel = new ListItemModel(getString('app.string.avatar'))
  @Local userName: ListItemModel = new ListItemModel(getString('app.string.nick_name'))
  @Local userPhone: ListItemModel = new ListItemModel(getString('app.string.phone_number'))
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, 'userInfo', () => new UserInfoModel())!
  @Local vm: MinePageVM = MinePageVM.instance;
  @Local customDialogId: number = 0
  @Local myMessageList: Array<CommentData> = []
  @Local messageCount: string = ''
  @Local isOpen: boolean = false
  @Consumer('curTabIndex') currentIndex: number = 0;
  @Local minorsMode: MinorsMode =
    AppStorageV2.connect(MinorsMode, 'isMinorsMode', () => new MinorsMode(MinorsProtectionUtils.getMinorsMode()))!
  @Local commonServicesContents: Array<ListItemModel> = this.initCommonServicesContents()
  @Local commonServicesContents_2: Array<ListItemModel> = this.initCommonServicesContents_2()
  private uiContext: UIContext = this.getUIContext();
  private dialPanel: DialPanel = new DialPanel(this.uiContext)
    .onMakeCall((e: BusinessError<void>): void => {
      if (e.code) {
        this.uiContext.getPromptAction()
          .showToast({ message: `拨号页面跳转失败 -> code: ${e.code}, msg: ${e.message}` });
      }
    })

  @Monitor('minorsMode.isMinorsMode')
  onModeChange() {
    this.commonServicesContents = this.initCommonServicesContents()
    this.commonServicesContents_2 = this.initCommonServicesContents_2()
  }

  @Monitor('vm.userInfo.isPhoneAssociated', 'myMessageList')
  onMyMessageListChange() {
    if(!this.minorsMode.isMinorsMode){
      if (this.vm.userInfo.isPhoneAssociated) {
        const tempMessageCount = this.myMessageList.reduce((count, item) => {
          return count + (item.replyList ? item.replyList.length : 0);
        }, 0)
        this.commonServicesContents[1].redDot = tempMessageCount === 0 ? '' : tempMessageCount.toString()
      } else {
        this.commonServicesContents[1].redDot = ''
      }
    }
  }

  @Monitor('vm.userInfo.isPhoneAssociated')
  onUserLoginChange() {
    container.resolve(RequestAPI).getCommentList({
      pageSize: 1,
      pageNum: 20
    }).then((res) => {
      let commentListRes: CommentListRes = new CommentListRes(res.getBody())
      commentListRes.commentList?.map((commentInfo: CommentInfo) => {
        if (commentInfo.name === this.userInfo.nickname) {
          const tempMessageList: Array<CommentData> = []
          tempMessageList.push(commentInfo as CommentData)
          this.myMessageList = PreferenceUtil.getInstance(this.getUIContext().getHostContext())
            .get(PreferConstant.MY_MESSAGE_LIST_SETTINGS, tempMessageList) as Array<CommentData>
          PreferenceUtil.getInstance(this.getUIContext().getHostContext())
            .put(PreferConstant.MY_MESSAGE_LIST_SETTINGS, this.myMessageList)
        }
      })
    })
  }

  build() {
    Mine({
      userInfoHandler: () => {
        appRouter.push({
          builderName: NAV_PAGE_NAME.PersonalInfoPage.name, params: {
            userAvatar: [
              this.userAvatar.setContentImage(this.vm.localInfo.avatar ? this.vm.localInfo.avatar :
                this.vm.userInfo.avatar)
                .setHandle(() => {
                  appRouter.push({
                    builderName: NAV_PAGE_NAME.ChangePage.name
                  })
                })],
            userDetail: [this.userName.setContentText(this.vm.localInfo.nickname ? this.vm.localInfo.nickname :
              this.vm.userInfo.nickname)
              .setHandle(() => {
                appRouter.push({
                  builderName: NAV_PAGE_NAME.ChangePage.name
                })
              }),
              this.userPhone.setContentText(this.vm.userInfo.cellphone).setHandle(() => {
                this.getUIContext()
                  .getPromptAction()
                  .showToast({ message: getString('app.string.phone_tip'), alignment: Alignment.Center });
              })]
          }
        })
      },
      commonServicesContents: this.commonServicesContents,
      commonServicesContents_2: this.commonServicesContents_2
    })
      .padding({ top: `${this.getUIContext().px2vp(this.statusBarHeight.value)}vp` })
      .onVisibleAreaChange([0], () => {
        this.onUserLoginChange()
      })
  }

  @Builder
  buildTitle() {
    Text('联系客服')
      .fontSize($r('sys.float.Title_S'))
      .fontWeight(FontWeight.Medium)
  }

  goToPage(url: string) {
    if (this.vm.userInfo.isPhoneAssociated) {
      appRouter.push({ builderName: url })
    } else {
      appRouter.push({ builderName: NAV_PAGE_NAME.LoginPage.name })
    }
  }

  initCommonServicesContents():Array<ListItemModel>{
    return this.minorsMode.isMinorsMode ? [
      new ListItemModel(getString('app.string.my_record'), getMedia('app.media.icon_watched')).setHandle(() => {
        this.goToPage(NAV_PAGE_NAME.WatchRecordsPage.name)
      })] : [
      new ListItemModel(getString('app.string.my_record'), getMedia('app.media.icon_watched')).setHandle(() => {
        this.goToPage(NAV_PAGE_NAME.WatchRecordsPage.name)
      }),
      new ListItemModel(getString('app.string.my_message'), getMedia('app.media.icon_message'))
        .setHandle(() => {
          this.goToPage(NAV_PAGE_NAME.MyMessagePage.name)
        }),
      new ListItemModel(getString('app.string.my_like'), getMedia('app.media.icon_like')).setHandle(() => {
        this.goToPage(NAV_PAGE_NAME.LikesPage.name)
      }),
      new ListItemModel(getString('app.string.my_award'), getMedia('app.media.icon_award')).setHandle(() => {
        this.currentIndex = 2
      })
    ]
  }

  initCommonServicesContents_2(): Array<ListItemModel>{
    return this.minorsMode.isMinorsMode ? [
      new ListItemModel(getString('app.string.my_feedback'), getMedia('app.media.icon_feedback')).setHandle(() => {
        this.goToPage(NAV_PAGE_NAME.FeedbackSubmitPage.name)
      }),
      new ListItemModel(getString('app.string.my_setting'), getMedia('app.media.icon_setting')).setHandle(() => {
        this.goToPage(NAV_PAGE_NAME.SetUpPage.name)
      }),
    ] : [
      new ListItemModel(getString('app.string.my_feedback'), getMedia('app.media.icon_feedback')).setHandle(() => {
        this.goToPage(NAV_PAGE_NAME.FeedbackSubmitPage.name)
      }),
      new ListItemModel(getString('app.string.my_customer_service'),
        getMedia('app.media.icon_customer_service')).setHandle(() => {
        this.dialPanel
          .setTitle('联系客服')
          .setPhoneNumber('12345678901')
          .setAutoClosePanel(false) // 成功跳转后不自动关闭模态窗
          .open();
      }),
      new ListItemModel(getString('app.string.my_setting'), getMedia('app.media.icon_setting')).setHandle(() => {
        this.goToPage(NAV_PAGE_NAME.SetUpPage.name)
      }),
    ]
  }
}

@Builder
export function MineMainPageBuilder(index: number) {
  MineMainPage()
}