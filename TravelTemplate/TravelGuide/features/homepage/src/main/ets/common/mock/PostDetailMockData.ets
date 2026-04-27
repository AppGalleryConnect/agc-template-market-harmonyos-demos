import { PostInfo, Comment, PostType, MyPostList } from 'common_travel_guide'
import { IPostDataAccess, setPostDataAccess } from 'common_travel_guide'
import { AppStorageV2 } from '@kit.ArkUI'


// 辅助函数：创建评论
function createComment(
  id: string,
  nickName: string,
  avatarUrl: ResourceStr,
  content: string,
  commentTime: string,
  commentLocation: string,
  likes: number
): Comment {
  const comment = new Comment(content, commentTime, commentLocation)
  comment.id = id
  comment.nickName = nickName
  comment.avatarUrl = avatarUrl
  comment.likes = likes
  return comment
}

// 辅助函数：创建详情PostInfo
function createPostDetail(
  id: string,
  title: string,
  content: string,
  coverImg: ResourceStr,
  imgVideoList: ResourceStr[],
  nickName: string,
  avatarUrl: ResourceStr,
  publishTime: string,
  publishLocation: string,
  likes: number,
  views: number,
  comments: Comment[],
  videoUrl: ResourceStr | undefined,
  postType: PostType,
  postTopic?: string
): PostInfo {
  const post = new PostInfo(title, content, publishTime, publishLocation)
  post.id = id
  post.coverImg = coverImg
  post.imgVideoList = imgVideoList
  post.authorNickName = nickName
  post.authorAvatarUrl = avatarUrl
  post.likes = likes
  post.views = views
  post.comments = comments
  post.commentCount = comments.length
  post.postType = postType
  if (videoUrl) {
    post.videoUrl = videoUrl
  }
  if (postTopic) {
    post.postTopic = postTopic
  }
  return post
}

// Mock评论数据
const comments1: Comment[] = [
  createComment('c1', '小蛮妮儿', $r('app.media.path2x'),
    '水阁家宴好友特色乌镇听评弹收费吗', '2024-12-03', '云南', 999),
  createComment('c2', '新月无形', $r('app.media.path2x'), '好玩的呢',
    '2024-12-03', '云南', 999),
  createComment('c3', '新月无形', $r('app.media.path2x'), '好玩的呢',
    '2024-12-03', '云南', 999),
  createComment('c9', '新月无形', $r('app.media.path2x'), '好玩的呢',
    '2024-12-03', '云南', 999),
  createComment('c10', '新月无形', $r('app.media.path2x'), '好玩的呢',
    '2024-12-03', '云南', 999),
  createComment('c11', '新月无形', $r('app.media.path2x'), '好玩的呢',
    '2024-12-03', '云南', 999),
  createComment('c12', '新月无形', $r('app.media.path2x'), '好玩的呢',
    '2024-12-03', '云南', 999),
  createComment('c13', '新月无形', $r('app.media.path2x'), '好玩的呢',
    '2024-12-03', '云南', 999),
  createComment('c14', '新月无形', $r('app.media.path2x'), '好玩的呢',
    '2024-12-03', '云南', 999),
  createComment('c15', '新月无形', $r('app.media.path2x'), '好玩的呢',
    '2024-12-03', '云南', 999),
  createComment('c16', '新月无形', $r('app.media.path2x'), '好玩的呢',
    '2024-12-03', '云南', 999),
  createComment('c17', '新月无形', $r('app.media.path2x'), '好玩的呢',
    '2024-12-03', '云南', 999),
  createComment('c18', '新月无形', $r('app.media.path2x'), '好玩的呢',
    '2024-12-03', '云南', 999),
  createComment('c19', '新月无形', $r('app.media.path2x'), '好玩的呢',
    '2024-12-03', '云南', 999),
]

const comments2: Comment[] = [
  createComment('c4', '旅行达人', $r('app.media.path2x'),
    '这个地方真的很美，值得一去！', '2024-12-04', '北京', 256),
  createComment('c5', '摄影爱好者', $r('app.media.path2x'),
    '照片拍得真不错，我也想去看看', '2024-12-04', '上海', 189)
]

const comments3: Comment[] = [
  createComment('c6', '美食探索家', $r('app.media.path2x'), '看起来很好吃的样子',
    '2024-12-05', '广州', 156),
  createComment('c7', '文化爱好者', $r('app.media.path2x'), '传统文化真的很棒',
    '2024-12-05', '深圳', 134),
  createComment('c8', '旅行小白', $r('app.media.path2x'),
    '第一次去，有什么建议吗？', '2024-12-05', '杭州', 98)
]

const comments0: Comment[] = []

// 创建所有帖子数据（统一数据源）
const allPosts: PostInfo[] = [
// 主页帖子数据（h1-h20）
  createPostDetail('h1', '最高列表高度,最高列表高度,最高列表高度',
    '登高远眺，打卡城市天际线，拍照出片率拉满。这里是最佳的观景位置，可以看到整个城市的美景。站在高处，感受城市的繁华与宁静，记录下这美好的瞬间。',
    $r('app.media.post_cover_01'),
    [$r('app.media.post_cover_01'), $r('app.media.post_cover_02'), $r('app.media.post_cover_01'), $r('app.media.post_cover_02')], '小明',
    $r('app.media.path2x'), '2024-01-15', '北京', 120, 20, comments1, undefined, PostType.HOME, '城市探索'),
  createPostDetail('h2', '帖子标题最大显示范围支持两行显示,过长使用...',
    '咖啡、戏台、手作店，一条街满足所有幻想。这里有很多有趣的小店，值得慢慢探索。每一家店都有自己的特色，让人流连忘返。',
    $r('app.media.post_cover_02'), [], '小明', $r('app.media.path2x'), '2024-01-14',
    '北京', 98, 20, comments2, $rawfile('local.mp4'), PostType.HOME),
  createPostDetail('h3', '隐秘小院，适合发呆的老房子',
    '远离人潮的庭院酒店，静静待上一整个下午。享受慢生活的美好时光，感受岁月的沉淀。在这里，时间仿佛慢了下来，让人可以静下心来思考。',
    $r('app.media.post_cover_03'), [$r('app.media.post_cover_01'), $r('app.media.post_cover_02')], '小李',
    $r('app.media.path2x'), '2024-01-13', '北京', 86, 35, comments3, undefined, PostType.HOME, '慢生活'),
  createPostDetail('h4', '夜游古城，灯火里的烟火气',
    '华灯初上，跟着本地人逛吃一整条街。感受古城的夜晚魅力，品尝地道美食，体验最地道的当地生活。', $r('app.media.post_cover_04'),
    [$r('app.media.post_cover_01'), $r('app.media.post_cover_02')], '阿青',
    $r('app.media.path2x'), '2024-01-12', '北京', 76, 42, comments0, undefined, PostType.HOME),
  createPostDetail('h5', '山间徒步，呼吸最纯净的空气',
    '远离城市喧嚣，走进自然，感受山间的宁静与美好。呼吸最纯净的空气，享受大自然的馈赠。', $r('app.media.post_cover_05'),
    [$r('app.media.post_cover_01'), $r('app.media.post_cover_02')], '小王',
    $r('app.media.path2x'), '2024-01-11', '北京', 145, 58, comments2, undefined, PostType.HOME, '户外运动'),
  createPostDetail('h6', '古镇寻味，品尝地道美食', '穿梭在古色古香的街道，寻找那些藏在巷子里的美味。',
    $r('app.media.post_cover_06'), [], '小张', $r('app.media.path2x'),
    '2024-01-10', '北京', 112, 67, comments0, undefined, PostType.HOME),
  createPostDetail('h7', '海边日出，迎接第一缕阳光', '清晨的海边，看太阳从海平面缓缓升起，感受大自然的壮美。',
    $r('app.media.post_cover_01'), [], '小刘', $r('app.media.path2x'), '2024-01-09',
    '北京', 203, 89, comments1, undefined, PostType.HOME),
  createPostDetail('h8', '博物馆之旅，了解历史文化', '走进博物馆，感受历史的厚重，了解这座城市的文化底蕴。',
    $r('app.media.post_cover_02'), [], '小陈', $r('app.media.path2x'), '2024-01-08',
    '北京', 89, 45, comments2, undefined, PostType.HOME),
  createPostDetail('h9', '温泉度假，放松身心', '在温泉中放松身心，享受慢生活的美好时光。', $r('app.media.post_cover_03'), [],
    '小赵', $r('app.media.path2x'), '2024-01-07', '北京', 167, 78, comments3, undefined, PostType.HOME),
  createPostDetail('h10', '夜市逛吃，体验当地生活', '夜晚的市集，各种小吃琳琅满目，体验最地道的当地生活。',
    $r('app.media.post_cover_04'), [], '小孙', $r('app.media.path2x'), '2024-01-06',
    '北京', 134, 92, comments0, undefined, PostType.HOME),
  createPostDetail('h11', '公园晨练，感受城市活力', '清晨的公园，人们在这里锻炼、散步，感受城市的活力。',
    $r('app.media.post_cover_05'), [], '小周', $r('app.media.path2x'), '2024-01-05',
    '北京', 78, 56, comments1, undefined, PostType.HOME),
  createPostDetail('h12', '艺术展览，欣赏创意作品', '参观艺术展览，欣赏各种创意作品，感受艺术的魅力。',
    $r('app.media.post_cover_06'), [], '小吴', $r('app.media.path2x'),
    '2024-01-04', '北京', 156, 63, comments2, undefined, PostType.HOME),
  createPostDetail('h13', '骑行探索，发现城市角落', '骑着单车，穿梭在城市的大街小巷，发现那些不为人知的美好角落。',
    $r('app.media.post_cover_01'), [], '小郑', $r('app.media.path2x'), '2024-01-03',
    '北京', 198, 105, comments3, undefined, PostType.HOME),
  createPostDetail('h14', '茶楼品茗，享受悠闲时光', '在古色古香的茶楼里，品一杯好茶，享受悠闲的下午时光。',
    $r('app.media.post_cover_02'), [], '小钱', $r('app.media.path2x'), '2024-01-02',
    '北京', 92, 48, comments0, undefined, PostType.HOME),
  createPostDetail('h15', '摄影打卡，记录美好瞬间', '寻找最佳拍摄角度，记录旅途中的每一个美好瞬间。',
    $r('app.media.post_cover_03'), [], '小冯', $r('app.media.path2x'), '2024-01-01',
    '北京', 221, 127, comments1, undefined, PostType.HOME),
  createPostDetail('h16', '民俗体验，感受传统文化', '参与当地的民俗活动，感受传统文化的魅力。', $r('app.media.post_cover_04'),
    [], '小卫', $r('app.media.path2x'), '2023-12-31', '北京', 103, 71,
    comments2, undefined, PostType.HOME),
  createPostDetail('h17', '春日赏花，感受自然之美', '春天来了，一起去赏花吧！樱花、桃花、油菜花，各种花卉竞相开放。',
    $r('app.media.post_cover_05'), [], '小新', $r('app.media.path2x'), '2024-01-20',
    '北京', 256, 156, comments3, undefined, PostType.HOME),
  createPostDetail('h18', '周末短途游，放松心情', '周末不知道去哪？这些地方值得一去，距离不远，风景很美。',
    $r('app.media.post_cover_06'), [], '小新', $r('app.media.path2x'),
    '2024-01-19', '北京', 189, 134, comments0, undefined, PostType.HOME),
  createPostDetail('h19', '美食探店，发现好味道', '最近发现了几家不错的餐厅，环境好，味道棒，推荐给大家。',
    $r('app.media.post_cover_01'), [], '小新', $r('app.media.path2x'), '2024-01-18',
    '北京', 167, 98, comments1, undefined, PostType.HOME),
  createPostDetail('h20', '夜景拍摄地，记录城市夜色', '这些地方的夜景特别美，适合拍照，晚上去逛逛很不错。',
    $r('app.media.post_cover_02'), [], '小新', $r('app.media.path2x'), '2024-01-17',
    '北京', 143, 87, comments2, undefined, PostType.HOME),
  // 景点/攻略推荐数据（1-16）
  createPostDetail('1', '最高楼看古城，全景一览无余', '登高远眺，打卡城市天际线，拍照出片率拉满。',
    $r('app.media.post_cover_01'), [], '小明', $r('app.media.path2x'), '2024-01-15',
    '北京', 120, 0, comments3, undefined, PostType.ATTRACTION_RECOMMEND, '城市探索'),
  createPostDetail('2', '老街慢步，一天逛遍百年古巷', '咖啡、戏台、手作店，一条街满足所有幻想。', $r('app.media.post_cover_02'),
    [], '小明', $r('app.media.path2x'), '2024-01-14', '北京', 98, 0, comments0, undefined,
    PostType.ATTRACTION_RECOMMEND),
  createPostDetail('3', '隐秘小院，适合发呆的老房子', '远离人潮的庭院酒店，静静待上一整个下午。', $r('app.media.post_cover_04'),
    [], '小李', $r('app.media.path2x'), '2024-01-13', '北京', 86, 0,
    comments1, undefined, PostType.ATTRACTION_RECOMMEND, '慢生活'),
  createPostDetail('4', '夜游古城，灯火里的烟火气', '华灯初上，跟着本地人逛吃一整条街。', $r('app.media.post_cover_03'), [],
    '阿青', $r('app.media.path2x'), '2024-01-12', '北京', 76, 0, comments2, undefined, PostType.ATTRACTION_RECOMMEND),
  createPostDetail('5', '山间徒步，呼吸最纯净的空气', '远离城市喧嚣，走进自然，感受山间的宁静与美好。',
    $r('app.media.post_cover_05'), [], '小王', $r('app.media.path2x'), '2024-01-11',
    '北京', 145, 0, comments3, undefined, PostType.ATTRACTION_RECOMMEND),
  createPostDetail('6', '古镇寻味，品尝地道美食', '穿梭在古色古香的街道，寻找那些藏在巷子里的美味。',
    $r('app.media.post_cover_06'), [], '小张', $r('app.media.path2x'),
    '2024-01-10', '北京', 112, 0, comments0, undefined, PostType.ATTRACTION_RECOMMEND),
  createPostDetail('7', '海边日出，迎接第一缕阳光', '清晨的海边，看太阳从海平面缓缓升起，感受大自然的壮美。',
    $r('app.media.post_cover_06'), [], '小刘', $r('app.media.path2x'),
    '2024-01-09', '北京', 203, 0, comments1, undefined, PostType.ATTRACTION_RECOMMEND),
  createPostDetail('8', '博物馆之旅，了解历史文化', '走进博物馆，感受历史的厚重，了解这座城市的文化底蕴。',
    $r('app.media.post_cover_06'), [], '小陈', $r('app.media.path2x'),
    '2024-01-08', '北京', 89, 0, comments2, undefined, PostType.ATTRACTION_RECOMMEND),
  createPostDetail('9', '温泉度假，放松身心', '在温泉中放松身心，享受慢生活的美好时光。', $r('app.media.post_cover_06'),
    [], '小赵', $r('app.media.path2x'), '2024-01-07', '北京', 167, 0, comments3, undefined,
    PostType.ATTRACTION_RECOMMEND),
  createPostDetail('10', '夜市逛吃，体验当地生活', '夜晚的市集，各种小吃琳琅满目，体验最地道的当地生活。',
    $r('app.media.post_cover_06'), [], '小孙', $r('app.media.path2x'),
    '2024-01-06', '北京', 134, 0, comments0, undefined, PostType.ATTRACTION_RECOMMEND),
  createPostDetail('11', '公园晨练，感受城市活力', '清晨的公园，人们在这里锻炼、散步，感受城市的活力。',
    $r('app.media.post_cover_06'), [], '小周', $r('app.media.path2x'),
    '2024-01-05', '北京', 78, 0, comments1, undefined, PostType.ATTRACTION_RECOMMEND),
  createPostDetail('12', '艺术展览，欣赏创意作品', '参观艺术展览，欣赏各种创意作品，感受艺术的魅力。',
    $r('app.media.post_cover_06'), [], '小吴', $r('app.media.path2x'),
    '2024-01-04', '北京', 156, 0, comments2, undefined, PostType.ATTRACTION_RECOMMEND),
  createPostDetail('13', '骑行探索，发现城市角落', '骑着单车，穿梭在城市的大街小巷，发现那些不为人知的美好角落。',
    $r('app.media.post_cover_06'), [], '小郑', $r('app.media.path2x'),
    '2024-01-03', '北京', 198, 0, comments3, undefined, PostType.ATTRACTION_RECOMMEND),
  createPostDetail('14', '茶楼品茗，享受悠闲时光', '在古色古香的茶楼里，品一杯好茶，享受悠闲的下午时光。',
    $r('app.media.post_cover_06'), [], '小钱', $r('app.media.path2x'),
    '2024-01-02', '北京', 92, 0, comments0, undefined, PostType.ATTRACTION_RECOMMEND),
  createPostDetail('15', '摄影打卡，记录美好瞬间', '寻找最佳拍摄角度，记录旅途中的每一个美好瞬间。',
    $r('app.media.post_cover_06'), [], '小冯', $r('app.media.path2x'),
    '2024-01-01', '北京', 221, 0, comments1, undefined, PostType.ATTRACTION_RECOMMEND),
  createPostDetail('16', '民俗体验，感受传统文化', '参与当地的民俗活动，感受传统文化的魅力。',
    $r('app.media.post_cover_06'), [], '小卫', $r('app.media.path2x'),
    '2023-12-31', '北京', 103, 0, comments2, undefined, PostType.ATTRACTION_RECOMMEND),
  // 景点/攻略最新数据（21-28）- 使用不同的内容和图片，与推荐区分开
  createPostDetail('21', '最新：春日赏花，感受自然之美',
    '春天来了，一起去赏花吧！樱花、桃花、油菜花，各种花卉竞相开放，美不胜收。', $r('app.media.post_cover_01'), [], '小b',
    $r('app.media.path2x'), '2024-01-20', '北京', 256, 0, comments3, undefined, PostType.ATTRACTION_LATEST, '春日赏花'),
  createPostDetail('22', '最新：周末短途游，放松心情', '周末不知道去哪？这些地方值得一去，距离不远，风景很美，适合放松。',
    $r('app.media.post_cover_02'), [], '小a', $r('app.media.path2x'), '2024-01-19',
    '北京', 189, 0, comments0, undefined, PostType.ATTRACTION_LATEST),
  createPostDetail('23', '最新：美食探店，发现好味道', '最近发现了几家不错的餐厅，环境好，味道棒，推荐给大家去试试。',
    $r('app.media.post_cover_03'), [], '小c', $r('app.media.path2x'), '2024-01-18',
    '北京', 167, 0, comments1, undefined, PostType.ATTRACTION_LATEST),
  createPostDetail('24', '最新：夜景拍摄地，记录城市夜色', '这些地方的夜景特别美，适合拍照，晚上去逛逛很不错，很有氛围。',
    $r('app.media.post_cover_04'), [], '小n', $r('app.media.path2x'), '2024-01-17',
    '北京', 143, 0, comments2, undefined, PostType.ATTRACTION_LATEST),
  createPostDetail('25', '最新：亲子游好去处，欢乐时光', '带孩子出去玩，这些地方既有趣又安全，孩子们都很喜欢，适合全家出游。',
    $r('app.media.post_cover_05'), [], '小k', $r('app.media.path2x'), '2024-01-16',
    '北京', 178, 0, comments3, undefined, PostType.ATTRACTION_LATEST),
  createPostDetail('26', '最新：文艺小资路线，慢生活', '喜欢文艺范的朋友可以看看，这些地方很有情调，适合慢慢逛，享受慢生活。',
    $r('app.media.post_cover_01'), [], '小新', $r('app.media.path2x'), '2024-01-15',
    '北京', 134, 0, comments0, undefined, PostType.ATTRACTION_LATEST),
  createPostDetail('27', '最新：户外运动，健康生活', '喜欢运动的朋友看过来，这些地方适合跑步、骑行、爬山，锻炼身体的好去处。',
    $r('app.media.post_cover_02'), [], '小小', $r('app.media.path2x'), '2024-01-14',
    '北京', 201, 0, comments1, undefined, PostType.ATTRACTION_LATEST),
  createPostDetail('28', '最新：购物天堂，买买买', '买买买！这些地方购物环境好，品牌齐全，折扣也多，购物爱好者的天堂。',
    $r('app.media.post_cover_03'), [], '小新', $r('app.media.path2x'), '2024-01-13',
    '北京', 112, 0, comments2, undefined, PostType.ATTRACTION_LATEST)
]

// 构建详情数据Map（使用let以便可以更新）
let postDetailMap: Map<string, PostInfo> = new Map()
allPosts.forEach((post) => {
  postDetailMap.set(post.id, post)
})

// 更新帖子详情的函数（用于保存新添加的评论和点赞状态）
// 只更新评论和点赞相关字段，不覆盖其他字段，避免影响主页显示
export function updatePostDetail(post: PostInfo): void {
  // 更新函数，用于同步更新帖子对象
  const updatePost = (targetPost: PostInfo) => {
    targetPost.liked = post.liked
    targetPost.likes = post.likes
    targetPost.views = post.views

    // 更新评论列表（深拷贝，避免引用问题）
    // 使用独立的nickName和avatarUrl字段，避免userInfo共享引用问题
    if (post.comments) {
      targetPost.comments = post.comments.map((comment) => {
        const clonedComment = new Comment(comment.content, comment.commentTime, comment.commentLocation)
        clonedComment.id = comment.id
        // 使用独立的nickName和avatarUrl字段
        clonedComment.nickName = comment.nickName || ''
        clonedComment.avatarUrl = comment.avatarUrl || ''
        clonedComment.likes = comment.likes
        clonedComment.liked = comment.liked
        return clonedComment
      })
    } else {
      targetPost.comments = []
    }
    targetPost.commentCount = targetPost.comments.length
  }

  // 更新postDetailMap中的帖子（allPosts中的对象是同一个引用，会自动同步）
  const existingPostInMap = postDetailMap.get(post.id)
  if (existingPostInMap) {
    updatePost(existingPostInMap)
  } else {
    // 如果不存在，则直接设置
    postDetailMap.set(post.id, post)
  }

  // 同步更新MyPostList中的帖子（用户自己发布的帖子，是不同的对象引用，需要单独更新）
  try {
    const myPostList = AppStorageV2.connect(MyPostList, () => new MyPostList())!
    const existingPostInMyList = myPostList.getDataById(post.id)
    if (existingPostInMyList) {
      updatePost(existingPostInMyList)
    }
  } catch (e) {
    // 如果获取MyPostList失败，忽略错误（可能在某些情况下不可用）
  }
}

// 导出主页帖子列表（使用postType区分）
export const homePagePostList: PostInfo[] = allPosts.filter(post => post.postType === PostType.HOME)

// 导出景点/攻略推荐列表（使用postType区分）
export const attractionRecommendList: PostInfo[] =
  allPosts.filter(post => post.postType === PostType.ATTRACTION_RECOMMEND)

// 导出景点/攻略最新列表（使用postType区分）
export const attractionLatestList: PostInfo[] = allPosts.filter(post => post.postType === PostType.ATTRACTION_LATEST)


export function getPostDetailById(id: string): PostInfo | undefined {
  return postDetailMap.get(id)
}

/**
 * 获取所有帖子数组（用于工具函数访问）
 * @returns 所有帖子数组的引用
 */
export function getAllPosts(): PostInfo[] {
  return allPosts
}

/**
 * 获取帖子详情Map（用于工具函数访问）
 * @returns 帖子详情Map的引用
 */
export function getPostDetailMap(): Map<string, PostInfo> {
  return postDetailMap
}

/**
 * 实现 IPostDataAccess 接口
 */
class PostDataAccessImpl implements IPostDataAccess {
  getAllPosts(): PostInfo[] {
    return getAllPosts()
  }

  getPostDetailMap(): Map<string, PostInfo> {
    return getPostDetailMap()
  }
}

// 初始化数据访问器
setPostDataAccess(new PostDataAccessImpl())
