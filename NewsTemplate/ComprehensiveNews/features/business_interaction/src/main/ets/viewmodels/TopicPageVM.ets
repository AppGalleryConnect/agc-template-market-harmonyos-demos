import { BaseViewModel, RouterMap, RouterUtils } from 'lib_common';
import { PostController, Topic } from 'module_post';

const TAG = '[TopicPageVM]';

@ObservedV2
export class TopicPageVM extends BaseViewModel {
  @Trace currentTopic: Topic = { id: '', title: '' }
  @Trace showInfoTop: boolean = false;
  public postController: PostController = new PostController();

  initParams(params: Object) {
    if (params) {
      const param = params as Record<string, Object | Topic | PostController>;
      this.currentTopic = param.topic as Topic;
      this.postController = param.postController as PostController;
    }
  }

  postPublish() {
    // 存在id，表示是从发帖页面跳转过来的，直接返回继续编辑
    if (this.currentTopic.id) {
      this.postController.joinDiscuss(this.currentTopic);
      RouterUtils.pop();
    } else {
      const params: Record<string, Topic> = {
        'topic': this.currentTopic,
      };
      RouterUtils.pushPathByName(RouterMap.PUBLISH_POST_PAGE, params);
    }
  }
}