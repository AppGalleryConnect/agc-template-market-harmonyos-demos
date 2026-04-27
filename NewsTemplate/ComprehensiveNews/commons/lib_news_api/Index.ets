import('./src/main/ets/utils/MockUtils');

// 常量
export { NewsEnum, VideoEnum, ChatEnum } from './src/main/ets/constants/Constants';

// 新闻公共能力接口
export { BaseNewsServiceApi } from './src/main/ets/https/BaseNewsService';

// 首页接口
export { HomeServiceApi } from './src/main/ets/https/HomeService';

// 视频接口
export { VideoServiceApi } from './src/main/ets/https/VideoService';

// 动态接口
export { PostServiceApi } from './src/main/ets/https/PostService';

// 评论接口
export { CommentServiceApi } from './src/main/ets/https/CommentService';

// 创作者接口
export { AuthorServiceApi } from './src/main/ets/https/AuthorService';

// 我的接口
export { MineServiceApi } from './src/main/ets/https/MineService';

// 文章接口
export { ArticleServiceApi } from './src/main/ets/https/ArticleService';

// 消息接口
export { MessageServiceApi } from './src/main/ets/https/MessageService';

// 基础类型
export { NavInfo, PostImgList } from './src/main/ets/params/base/BaseModel';

// 请求参数
export {
  PostQueryRequest,
  PostRequest,
  ModifyPersonalInfoRequest,
  SendMessageRequest,
  PublishCommentRequest,
} from './src/main/ets/params/request/CommonRequest';

// 作者响应模型
export { AuthorResponse } from './src/main/ets/params/response/AuthorResponse';

// 新闻响应模型
export { NewsResponse } from './src/main/ets/params/response/NewsResponse';

// 广播响应模型
export { AvResponse, VideoProgramResponse } from './src/main/ets/params/response/AvResponse';

// 评论响应模型
export { CommentResponse } from './src/main/ets/params/response/CommentResponse';

// 动态布局响应模型
export {
  RequestListData,
  LayoutStyle,
  AbstractRequestListData,
} from './src/main/ets/params/response/LayoutResponse';

// 编排新闻评论
export { AggregateNewsComment, CommentDetailResponse } from './src/main/ets/params/response/AggregateResponse';

// 消息模型
export {
  BriefMsgInfo,
  BriefIMResponse,
  ChatInfoDetailResponse,
  SystemDetailInfo,
} from './src/main/ets/params/response/MessageResponse';

// 话题模型
export { TopicResponse } from './src/main/ets/params/response/TopicResponse';

// 状态模型
export { NewsModel } from './src/main/ets/observedmodels/NewsModel';

export { AuthorModel } from './src/main/ets/observedmodels/AuthorModel';

export { CommentModel } from './src/main/ets/observedmodels/CommentModel';

export { AvModel, AvSection } from './src/main/ets/observedmodels/AvModel';