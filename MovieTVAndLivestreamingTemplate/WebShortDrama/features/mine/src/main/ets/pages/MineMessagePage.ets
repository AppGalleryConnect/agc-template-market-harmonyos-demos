import { Header } from '../component/Header';
import { getMedia, getString } from '@agctemplate/resources';
import { CommentReply } from '../component/CommentReply';
import { CommentLike } from '../component/CommentLike';
import { NavDestinationModifier } from '@agctemplate/widgets';
import { AlertDialog } from '@kit.ArkUI';
import { container } from '@agctemplate/utils';
import { request } from '@kit.BasicServicesKit';
import { RequestAPI } from '@agctemplate/server';

@Preview
@Component
struct MineMessagePage {
  tabsContent: string[] = ['app.string.CommentReply', 'app.string.Like'];
  controller: TabsController = new TabsController();
  @State currentIndex: number = 0;
  navDestinationModifier: NavDestinationModifier = new NavDestinationModifier();
  @State message: string = 'Hello World';
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
        //实际删除后的动作和UI需要应用定制，此处预留为空
        action: () => {
          if (this.currentIndex === 0) {
            container.resolve(RequestAPI).deleteRelyList(
              []
            )
          } else {
            container.resolve(RequestAPI).deleteLikeList(
              []
            )
          }
        },
      },
    }),
  })

  build() {
    NavDestination() {
      Column() {
        Header({
          title: getString('app.string.my_message'),
          rightImageRes: $r('sys.symbol.clean'),
          rightOnClick: () => {
            //右键删除事件，选择确认,本地mock数据无法删除
            this.deleteDialogController.open()
          }
        })
      }

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
              if (index === 0) {
                CommentReply()
              } else {
                //点赞页面
                CommentLike()
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
      .margin({ top: 8 })
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.comp_background_gray'))
    .attributeModifier(this.navDestinationModifier)
    .height('100%')
  }

  @Builder
  Tab(tabName: string, tabIndex: number) {
    Button(getString(tabName))
      .height(28)
      .constraintSize({ minWidth: 72 })
      .fontSize($r('sys.float.Body_M'))
      .fontWeight(500)
      .fontColor(tabIndex === this.currentIndex ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
      .backgroundColor(tabIndex === this.currentIndex ? '#EC6E45' : 'rgba(0, 0, 0, 0.05)')
      .onClick(() => {
        this.controller.changeIndex(tabIndex)
        this.currentIndex = tabIndex
      })
  }
}

@Builder
export function MineMessagePageBuilder() {
  MineMessagePage()
}