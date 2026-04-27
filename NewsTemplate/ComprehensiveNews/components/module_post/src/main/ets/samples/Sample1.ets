import { PublishPostComp } from '../components/PublishPostComp';
import { PostImgVideoItem } from '../constants/Constants';
import { TextSpanInfo, Topic, User } from '../types/Types';
import { PostController } from '../controller/PostController';

@Entry
@ComponentV2
struct Sample1 {
  @Local body: string = '[]';
  @Local mediaList: PostImgVideoItem[] = [];
  @Local cityLocation: string = '';
  // 示例话题列表
  private topicList: Topic[] = [
    { id: '1', title: '#HarmonyOS开发#' },
    { id: '2', title: '#ArkTS编程#' },
    { id: '3', title: '#前端技术#' },
  ];
  // 示例联系人列表
  private userList: User[] = [
    {
      authorId: '001',
      authorNickName: '张三',
      authorIcon: '',
    },
    {
      authorId: '002',
      authorNickName: '李四',
      authorIcon: '',
    },
    {
      authorId: '003',
      authorNickName: '王五',
      authorIcon: '',
    },
  ];
  // 初始化携带的话题
  private attachedTopic: Topic = { id: '1', title: '#HarmonyOS开发#' };
  // 发帖控制器
  private postController: PostController = new PostController();

  build() {
    NavDestination() {
      this.titleBuilder()

      Column() {
        PublishPostComp({
          fontRatio: 1,
          postController: this.postController,
          attachedTopic: this.attachedTopic,
          topicList: this.topicList,
          userList: this.userList,
          onChange: (body: string, mediaList: PostImgVideoItem[], cityLocation?: string) => {
            this.body = body;
            this.mediaList = mediaList;
            this.cityLocation = cityLocation || '';
          },
          jumpTopicPage: (topic: Topic) => {
            // 跳转到话题详情页
            this.getUIContext().getPromptAction().showToast({
              message: `跳转到话题：${topic.title}`,
            })
          },
        })
      }
      .layoutWeight(1)
    }
    .hideTitleBar(true)
  }

  @Builder
  titleBuilder() {
    Row() {
      Text('发帖页面')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
      Blank()
      Button('发布')
        .width(72)
        .height(40)
        .fontSize($r('sys.float.Body_L'))
        .fontColor(this.enablePublish ? $r('sys.color.font_on_primary') : $r('sys.color.font_tertiary'))
        .backgroundColor(this.enablePublish ? '#5C79D9' :
          $r('sys.color.comp_background_secondary'))
        .enabled(this.enablePublish)
        .onClick(() => {
          this.getUIContext().getPromptAction().showToast({
            message: '点击了发布按钮',
          })
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
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
}