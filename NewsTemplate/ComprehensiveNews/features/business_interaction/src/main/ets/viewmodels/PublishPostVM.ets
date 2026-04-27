import { emitter } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { BaseViewModel, CommonConfirmDialog, CommonLoadingDialog, EventEnum, Logger, RouterUtils } from 'lib_common';
import { PostRequest, PostServiceApi, PostImgList, AuthorResponse, TopicResponse, MineServiceApi } from 'lib_news_api';
import { PostImgVideoItem, FileUtils, PostController, Topic, TextSpanInfo } from 'module_post';

const TAG = '[PublishPostViewModel]';

@ObservedV2
export class PublishPostViewModel extends BaseViewModel {
  @Trace body: string = '[]';
  @Trace mediaList: PostImgVideoItem[] = [];
  @Trace cityLocation: string = '';
  @Trace paddingBottom: number = this.windowModel.windowBottomPadding;
  @Trace enableClick: boolean = true;
  @Trace userList: AuthorResponse[] = [];
  @Trace topicList: TopicResponse[] = [];
  @Trace attachedTopic: Topic = { id: '', title: '' };
  public controller: RichEditorController = new RichEditorController();
  public postController: PostController = new PostController();

  async init() {
    this.topicList = await PostServiceApi.queryTopicList();
    this.userList = await MineServiceApi.queryWatchUsers(this.userInfoModel.authorId);
  }

  initRouterParams(context: NavDestinationContext) {
    const params = context.pathInfo.param as Record<string, TopicResponse>;
    if (params?.topic) {
      this.attachedTopic = params.topic as Topic;
    }
  }

  @Computed
  get plainText() {
    try {
      const list = JSON.parse(this.body) as TextSpanInfo[];
      return list.map(v => v.text).join('');
    } catch (e) {
      return '';
    }
  }

  enablePublish() {
    if (this.plainText) {
      return true;
    }
    if (this.mediaList.length) {
      return true;
    }
    return false;
  }

  async publishPost() {
    if (!this.enableClick) {
      return;
    }

    if (!this.enablePublish()) {
      return;
    }

    // 防止暴力点击
    this.enableClick = false;
    this.controller.stopEditing();

    CommonLoadingDialog.show({
      loadColor: $r('sys.color.icon_on_primary'),
      textColor: $r('sys.color.font_on_primary'),
      maskColor: $r('sys.color.mask_secondary'),
      autoCancel: false,
      text: '发布中',
    })

    setTimeout(async () => {
      const list: PostImgList[] = [];
      for (let item of this.mediaList) {
        let picVideoUrl = '';
        let movingVideoUrl = '';
        if (item.movingPhoto) {
          const files = await FileUtils.saveMovingPhotoToSandbox(this.contextModel.globalContext, item.movingPhoto);
          picVideoUrl = files[0] ?? '';
          movingVideoUrl = files[1] ?? '';
        } else {
          picVideoUrl = await FileUtils.handleUri(this.contextModel.globalUIContext, item.picVideoUrl);
        }
        list.push({
          picVideoUrl: picVideoUrl,
          movingVideoUrl: movingVideoUrl,
          surfaceUrl: item.surfaceUrl,
        });
      }
      const params: PostRequest = {
        postBody: this.body,
        postImgList: list,
        city: this.cityLocation,
      };
      PostServiceApi.publishPost(params)
        .then(() => {
          this.contextModel.showToast({ message: '发布成功' });
          // 事件分发，通知互动推荐刷新
          emitter.emit(EventEnum.INTERACTION_RECOMMEND_REFRESH);
          RouterUtils.pop();
        })
        .catch(() => {
          this.contextModel.showToast({ message: '发布失败' });
        })
        .finally(() => {
          CommonLoadingDialog.close();
          this.enableClick = true;
        });
    }, 50)
  }

  onBackPressed(): boolean {
    if (this.enablePublish()) {
      CommonConfirmDialog.show({
        primaryTitle: '温馨提示',
        content: '当前内容未发表，返回将丢失。是否确认返回？',
        confirm: () => {
          RouterUtils.pop();
        },
      });
      return true;
    }
    return false;
  }

  onKeyBoard(context: common.UIAbilityContext) {
    try {
      let windowClass = (context as common.UIAbilityContext).windowStage.getMainWindowSync();
      windowClass.on('keyboardHeightChange', this.onKeyBoardCB);
    } catch (error) {
      Logger.error(TAG, 'onKeyBoard getMainWindowSync fail, error: ' + JSON.stringify(error));
    }
  }

  offKeyBoard(context: common.UIAbilityContext) {
    try {
      let windowClass = (context as common.UIAbilityContext).windowStage.getMainWindowSync();
      windowClass.off('keyboardHeightChange', this.onKeyBoardCB);
    } catch (error) {
      Logger.error(TAG, 'offKeyBoard getMainWindowSync fail, error: ' + JSON.stringify(error));
    }
  }

  onKeyBoardCB: (height: number) => void = (height: number) => {
    this.contextModel.globalUIContext?.animateTo({
      duration: 200,
      curve: Curve.EaseInOut,
    }, () => {
      if (height > 0) {
        this.paddingBottom = 0;
      } else {
        this.paddingBottom = this.windowModel.windowBottomPadding;
      }
    });
  };
}