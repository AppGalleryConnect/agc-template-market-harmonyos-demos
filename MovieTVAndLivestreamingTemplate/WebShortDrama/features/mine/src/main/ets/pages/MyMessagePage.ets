import { getMedia, getString } from '@agctemplate/resources'
import { CommentInfo, CommentListRes, LikeInfo, RequestAPI } from '@agctemplate/server';
import { appRouter, container, PreferConstant, PreferenceUtil } from '@agctemplate/utils'
import { FontModel, MinePageVM, NavDestinationModifier, UserInfoModel, CommentData,
  fp2pxUtil } from '@agctemplate/widgets'
import { CommentReplyContent } from '../component/CommentReplyContent';
import { Header } from '../component/Header';
import { LikeContent } from '../component/LikeContent';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { MyMessageStorage } from '@agctemplate/detail';
import { AlertDialog } from '@kit.ArkUI'

@ObservedV2
export class FlagStorage {
  static singleton: FlagStorage;

  static instance() {
    if (!FlagStorage.singleton) {
      FlagStorage.singleton = new FlagStorage();
    }
    ;
    return FlagStorage.singleton;
  }

  @Trace firstFlag: boolean = true
}

@ComponentV2
export struct MyMessagePage {
  navDestinationModifier: NavDestinationModifier = new NavDestinationModifier();
  @Local currentIndex: number = 0
  @Local commentDataList: Array<CommentData> = []
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, 'userInfo', () => new UserInfoModel())!
  @Local myMessageList: Array<CommentData> = PreferenceUtil.getInstance(this.getUIContext().getHostContext())
    .get(PreferConstant.MY_MESSAGE_LIST_SETTINGS, []) as Array<CommentData>
  @Local flagStorage: FlagStorage = FlagStorage.instance()
  @Local myMessageStorage: MyMessageStorage = MyMessageStorage.instance()
  private controller: TabsController = new TabsController()
  tabsContent: string[] = ['评论回复', '点赞']
  @Local isReplyListShow: boolean = true
  @Local isLikeListShow: boolean = true
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  deleteDialogController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: '是否清空' + (this.currentIndex === 0 ? '评论' : '点赞') + '数据',
      primaryButton: {
        value: '取消',
        action: () => {
          this.deleteDialogController.close()
        }
      },
      secondaryButton: {
        value: '确定',
        fontColor: $r('sys.color.ohos_id_color_warning'),
        action: () => {
          if (this.currentIndex === 0) {
            this.myMessageList.map(item => item.replyList = [])
            this.isReplyListShow = false
            PreferenceUtil.getInstance(this.getUIContext().getHostContext())
              .put(PreferConstant.MY_MESSAGE_LIST_SETTINGS, this.myMessageList)
            this.myMessageList = [...this.myMessageList]
            this.getUIContext().getPromptAction().showToast({ message: '操作成功' })
          } else {
            this.myMessageList.map(item => item.likeList = [])
            this.isLikeListShow = false
            PreferenceUtil.getInstance(this.getUIContext().getHostContext())
              .put(PreferConstant.MY_MESSAGE_LIST_SETTINGS, this.myMessageList)
            this.myMessageList = [...this.myMessageList]
            this.getUIContext().getPromptAction().showToast({ message: '操作成功' })
          }
        },
      },
    }),
  })

  @Builder
  Tab(tabName: string, tabIndex: number) {
    Button(tabName)
      .height(28)
      .constraintSize({ minWidth: 72 })
      .fontSize(fp2pxUtil(14))
      .fontWeight(500)
      .fontColor(tabIndex === this.currentIndex ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
      .backgroundColor(tabIndex === this.currentIndex ? '#EC6E45' : $r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        this.controller.changeIndex(tabIndex)
        this.currentIndex = tabIndex
      })
  }

  aboutToAppear(): void {
    container.resolve(RequestAPI).getCommentList({
      pageSize: 1,
      pageNum: 20
    }).then((res) => {
      this.myMessageStorage.moreList = []
      let commentListRes: CommentListRes = new CommentListRes(res.getBody())
      commentListRes.commentList?.map((commentInfo: CommentInfo) => {
        this.commentDataList.push(commentInfo as CommentData)
        this.myMessageStorage.moreList.push(0)
      })
    })
  }

  build() {
    NavDestination() {
      Column() {
        Header({
          title: getString('app.string.my_message'),
          rightImageRes: $r('sys.symbol.clean'),
          rightOnClick: () => {
            if (this.myMessageList.length > 0) {
              this.deleteDialogController.open()
            } else {
              this.getUIContext().getPromptAction().showToast({ message: '暂无未读消息' })
            }
          }
        })
        Column() {
          Column() {
            Scroll() {
              Row({ space: 16 }) {
                ForEach(this.tabsContent, (item: string, index: number) => {
                  this.Tab(item, index)
                }, (item: string) => item)
              }
              .justifyContent(FlexAlign.Start)
            }
            .align(Alignment.Start)
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')
            .margin({ bottom: 24 })

            Tabs({ barPosition: BarPosition.Start, controller: this.controller }) {
              ForEach(this.tabsContent, (item: string, index: number) => {
                TabContent() {
                  if (index === 0 && this.isReplyListShow) {
                    CommentReplyContent({
                      commentDataList: this.commentDataList,
                      myMessageList: this.myMessageList
                    })
                  } else if (index === 1 && this.isLikeListShow) {
                    LikeContent({
                      commentDataList: this.commentDataList,
                      myMessageList: this.myMessageList
                    })
                  }
                }
              }, (item: string) => item)
            }
            .barHeight(0)
            .animationDuration(100)
            .onContentWillChange((currentIndex, comingIndex) => {
              this.currentIndex = comingIndex
              return true
            })
          }
          .alignItems(HorizontalAlign.Start)

        }
        .margin({ top: 8 })
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
      }

      .height('100%')
    }
    .onBackPressed(() => {
      appRouter.back(true)
      return true
    })
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.comp_background_gray'))
    .attributeModifier(this.navDestinationModifier)
    .height('100%')
  }
}

@Builder
export function MyMessagePageBuilder() {
  MyMessagePage()
}