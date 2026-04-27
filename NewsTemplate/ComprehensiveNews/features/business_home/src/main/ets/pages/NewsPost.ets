import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import {
  BreakpointModel,
  CommonConfirmDialog,
  CommonConstants,
  CommonLoadingDialog,
  GlobalContextUtils,
  RouterMap,
  RouterUtils,
  SettingModel,
  UserInfoModel,
  EventEnum,
} from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { AuthorResponse, MineServiceApi, PostImgList, PostRequest, PostServiceApi, TopicResponse } from 'lib_news_api';
import { ArticlePost } from 'module_articlepost';
import { PostImgVideoItem, PublishPostComp, FileUtils, PostController, Topic, TextSpanInfo } from 'module_post';
import { KindsList, newsKindsList, NewsSelectType } from '../constants/NewsConstants';
import { VideoPost } from '../components/VideoPost';

@Builder
export function NewsPostBuilder() {
  NewsPost()
}

@ComponentV2
export struct NewsPost {
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  @Local newsKindsList: KindsList[] = newsKindsList
  @Local content: string = ''
  @Local title: string = ''
  @Local videoCanBack: boolean = false
  @Local targetIndex: number = 0
  @Local selectedId: string = NewsSelectType.ARTICLE
  @Local postBody: string = ''
  @Local mediaList: PostImgVideoItem[] = []
  @Local cityLocation: string = ''
  @Local isTabHide: boolean = false
  @Local controller: RichEditorController = new RichEditorController();
  @Local enableClick: boolean = true;
  @Local postController: PostController = new PostController();
  @Local userList: AuthorResponse[] = [];
  @Local topicList: TopicResponse[] = [];

  aboutToAppear(): void {
    this.queryListInfo();
  }

  async queryListInfo() {
    this.topicList = await PostServiceApi.queryTopicList();
    this.userList = await MineServiceApi.queryWatchUsers(this.userInfoModel.authorId);
  }

  @Computed
  get plainText() {
    try {
      const list = JSON.parse(this.postBody) as TextSpanInfo[];
      return list.map(v => v.text).join('');
    } catch (e) {
      return '';
    }
  }

  @Computed
  get canNext() {
    if (this.selectedId === NewsSelectType.ARTICLE) {
      return (this.title.trim().length > 1 && this.content.trim().length > 0)
    }
    return this.enablePublish
  }

  @Computed
  get enablePublish() {
    if (this.plainText) {
      return true;
    }
    if (this.mediaList.length) {
      return true;
    }
    return false;
  }

  @Computed
  get isOnEdit() {
    return this.title.trim().length > 0 || this.content.trim().length > 0
  }

  @Computed
  get isPost() {
    return this.selectedId === NewsSelectType.POST
  }

  publishPost() {
    if (!this.enableClick) {
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
          const files = await FileUtils.saveMovingPhotoToSandbox(GlobalContextUtils.globalContext, item.movingPhoto);
          picVideoUrl = files[0] ?? '';
          movingVideoUrl = files[1] ?? '';
        } else {
          picVideoUrl = await FileUtils.handleUri(GlobalContextUtils.globalUIContext, item.picVideoUrl);
        }
        list.push({
          picVideoUrl: picVideoUrl,
          movingVideoUrl: movingVideoUrl,
          surfaceUrl: item.surfaceUrl,
        });
      }
      const params: PostRequest = {
        postBody: this.postBody,
        postImgList: list,
        city: this.cityLocation,
      };
      PostServiceApi.publishPost(params)
        .then(() => {
          GlobalContextUtils.showToast({ message: '发布成功' });
          // 事件分发，通知互动推荐刷新
          emitter.emit(EventEnum.INTERACTION_RECOMMEND_REFRESH);
          RouterUtils.pop();
        })
        .catch(() => {
          GlobalContextUtils.showToast({ message: '发布失败' });
        })
        .finally(() => {
          CommonLoadingDialog.close();
          this.enableClick = true;
        });
    }, 50);
  }

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '',
        rightPartBuilder: () => {
          this.barRight()
        },
      })
      Column() {
        Tabs({ index: this.targetIndex }) {
          TabContent() {
            ArticlePost({
              fontSizeRatio: this.settingInfo.fontSizeRatio,
              darkMode: this.settingInfo.darkSwitch,
              customPadding: {
                left: this.breakPointModel.pagePadding,
                right: this.breakPointModel.pagePadding,
              },
              onTitleChange: (value: string) => {
                this.title = value
              },
              onContentChange: (value: string) => {
                this.content = value
              },
            })
          }

          TabContent() {
            VideoPost({
              fontSizeRatio: this.settingInfo.fontSizeRatio,
              onValidate: (isCanBack: boolean) => {
                this.videoCanBack = isCanBack
              },
            })
          }

          TabContent() {
            PublishPostComp({
              fontRatio: this.settingInfo.fontSizeRatio,
              richEditorController: this.controller,
              postController: this.postController,
              themeColor: $r('app.color.app_theme'),
              userList: this.userList,
              topicList: this.topicList,
              onChange: (body: string, mediaList: PostImgVideoItem[], cityLocation?: string) => {
                this.postBody = body
                this.mediaList = mediaList
                this.cityLocation = cityLocation ?? ''
              },
              isFocus: (isTabHide: boolean) => {
                this.isTabHide = isTabHide
              },
              jumpTopicPage: (topic) => {
                const params: Record<string, Object | Topic | PostController> = {
                  'topic': topic,
                  'postController': this.postController,
                }
                RouterUtils.pushPathByName(RouterMap.TOPIC_RESULT_PAGE, params);
              },
            })
              .margin({
                top: CommonConstants.PADDING_M,
              })
          }
        }
        .barHeight(0)
        .layoutWeight(1)
        .onAnimationStart((_index: number, targetIndex: number) => {
          this.selectedId = this.newsKindsList[targetIndex].id
        })
        .onChange((index: number) => {
          this.targetIndex = index
        })
      }
      .layoutWeight(1)

      Column() {
        this.newsPublishKindsList()
      }
      .visibility(this.isTabHide ? Visibility.None : Visibility.Visible)
    }
    .onBackPressed(() => {
      if (this.isOnEdit || this.videoCanBack) {
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
    })
    .hideTitleBar(true)
  }

  @Builder
  newsPublishKindsList() {
    Flex({ justifyContent: FlexAlign.SpaceAround }) {
      ForEach(this.newsKindsList, (item: KindsList, index: number) => {
        Row() {
          Text(item.name)
            .fontSize(16 * this.settingInfo.fontSizeRatio)
            .fontColor(this.selectedId === item.id ? $r('sys.color.icon_primary') : $r('sys.color.icon_secondary'))
            .fontWeight(FontWeight.Medium)
        }
        .justifyContent(FlexAlign.Center)
        .flexGrow(1)
        .onClick(() => {
          this.selectedId = item.id
          this.targetIndex = index
        })
      }, (item: KindsList) => item.id)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ top: CommonConstants.PADDING_L, bottom: 36 })
  }

  @Builder
  barRight() {
    Row() {
      Button(this.isPost ? '发表' : '下一步')
        .width(82)
        .opacity(this.canNext ? 1 : 0.4)
        .height(40)
        .fontSize(16 * this.settingInfo.fontSizeRatio)
        .fontColor(true ? $r('sys.color.font_on_primary') : $r('sys.color.font_tertiary'))
        .backgroundColor(true ? $r('app.color.app_theme') :
          $r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          if (this.canNext) {
            if (this.isPost) {
              this.publishPost()
              return
            }
            let params: Record<string, string> = {
              'title': this.title,
              'content': this.content,
            }
            RouterUtils.pushPathByName(RouterMap.NEWS_PUBLISH_SELECT, params)
          }
        })
    }
    .visibility(this.selectedId !== NewsSelectType.VIDEO ? Visibility.Visible : Visibility.None)
    .layoutWeight(1)
    .justifyContent(FlexAlign.End)
  }
}
