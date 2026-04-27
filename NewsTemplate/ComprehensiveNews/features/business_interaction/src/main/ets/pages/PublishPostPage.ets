import { common } from '@kit.AbilityKit'
import { CommonConstants, RouterMap, RouterUtils } from 'lib_common'
import { NavHeaderBar } from 'lib_widget'
import { PostController, PostImgVideoItem, PublishPostComp, Topic } from 'module_post'
import { PublishPostViewModel } from '../viewmodels/PublishPostVM'

@Builder
export function PublishPostPageBuilder() {
  PublishPostPage()
}

@ComponentV2
export struct PublishPostPage {
  vm: PublishPostViewModel = new PublishPostViewModel();

  aboutToAppear(): void {
    this.vm.init();
    this.vm.onKeyBoard(this.getUIContext().getHostContext() as common.UIAbilityContext);
  }

  aboutToDisappear(): void {
    this.vm.offKeyBoard(this.getUIContext().getHostContext() as common.UIAbilityContext);
  }

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '',
        rightPartBuilder: () => {
          this.barRight()
        },
        onBack: () => {
          const customBack = this.vm.onBackPressed();
          if (!customBack) {
            RouterUtils.pop();
          }
        },
      })
      Column() {
        PublishPostComp({
          fontRatio: this.vm.settingInfo.fontSizeRatio,
          richEditorController: this.vm.controller,
          postController: this.vm.postController,
          themeColor: $r('app.color.app_theme'),
          userList: this.vm.userList,
          topicList: this.vm.topicList,
          attachedTopic: this.vm.attachedTopic,
          onChange: (body: string, mediaList: PostImgVideoItem[], cityLocation?: string) => {
            this.vm.body = body;
            this.vm.mediaList = mediaList;
            this.vm.cityLocation = cityLocation ?? '';
          },
          jumpTopicPage: (topic) => {
            const params: Record<string, Object | Topic | PostController> = {
              'topic': topic,
              'postController': this.vm.postController,
            }
            RouterUtils.pushPathByName(RouterMap.TOPIC_RESULT_PAGE, params);
          },
        })
      }
      .layoutWeight(1)
      .padding({
        top: CommonConstants.PADDING_M,
        bottom: this.vm.paddingBottom,
      })
    }
    .hideTitleBar(true)
    .onReady((context) => {
      this.vm.initRouterParams(context);
    })
    .onBackPressed(() => {
      return this.vm.onBackPressed();
    })
  }

  @Builder
  barRight() {
    Row() {
      Button('发表')
        .width(72)
        .height(40)
        .opacity(this.vm.enablePublish() ? 1 : 0.4)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor($r('app.color.app_theme'))
        .onClick(() => {
          this.vm.publishPost();
        })
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.End)
  }
}