import { ReviewInfo, BookBasicInfo } from '../model/ReviewModels';
import { BookInfo } from 'common';
import { UserInfo } from 'base_common';
import { emitter } from '@kit.BasicServicesKit';

export class ReviewDataUtil {
  private static readonly STORAGE_KEY: string = 'reviewData';
  private static isInitialized: boolean = false;

  // 获取当前书籍信息的辅助方法
  public static getCurrentBookInfo(): BookInfo | undefined {
    const currentBook = AppStorage.get<BookInfo>('currentBook');
    if (currentBook && currentBook.id && currentBook.name) {
      return currentBook;
    }
    console.warn('未找到有效的当前书籍信息');
    return undefined;
  }

  // 设置当前书籍信息
  public static setCurrentBookInfo(bookInfo: BookInfo): void {
    if (bookInfo && bookInfo.id && bookInfo.name) {
      AppStorage.setOrCreate('currentBook', bookInfo);
      console.info(`设置当前书籍信息: ${bookInfo.name} (ID: ${bookInfo.id})`);
    } else {
      console.error('尝试设置无效的书籍信息');
    }
  }

  // 获取当前登录用户信息
  public static getCurrentUserInfo(): UserInfo | undefined {
    const userInfo = AppStorage.get<UserInfo>('userInfo');
    if (userInfo && userInfo.isLogin) {
      return userInfo;
    }
    console.warn('未找到有效的登录用户信息');
    return undefined;
  }

  // 初始化评论系统，确保用户信息同步
  public static initialize(): void {
    if (!ReviewDataUtil.isInitialized) {
      console.info('初始化评论系统，同步用户信息');
      ReviewDataUtil.updateCurrentUserReviews();
      ReviewDataUtil.isInitialized = true;
    }
  }

  // 更新当前用户的所有评论信息（头像和昵称）
  public static updateCurrentUserReviews(): void {
    const currentUserInfo = ReviewDataUtil.getCurrentUserInfo();
    if (!currentUserInfo) {
      console.warn('无法更新用户评论：未找到用户信息');
      return;
    }

    const reviews = ReviewDataUtil.getAllReviews();
    let hasUpdated = false;

    for (let review of reviews) {
      if (review.userId === 'current_user') {
        // 更新用户名
        if (review.username !== currentUserInfo.nickName) {
          review.username = currentUserInfo.nickName || '我';
          hasUpdated = true;
        }

        // 更新头像
        const newAvatar = currentUserInfo.avatarUrl || $r('app.media.ic_default_hd_png');
        if (review.avatar !== newAvatar) {
          review.avatar = newAvatar as ResourceStr;
          hasUpdated = true;
        }
      }
    }

    if (hasUpdated) {
      ReviewDataUtil.saveReviews(reviews);
      console.info('已更新当前用户的评论信息');
    }
  }

  // 验证当前书籍信息设置是否正确
  public static validateCurrentBookInfo(): boolean {
    const currentBook = ReviewDataUtil.getCurrentBookInfo();
    if (currentBook) {
      console.info(`当前书籍信息验证通过: ${currentBook.name} (ID: ${currentBook.id}, 分类: ${currentBook.category})`);
      return true;
    } else {
      console.warn('当前书籍信息验证失败: 未找到有效的书籍信息');
      return false;
    }
  }

  // 获取所有评论数据
  public static getAllReviews(): ReviewInfo[] {
    const reviewsStr = AppStorage.get<string>(ReviewDataUtil.STORAGE_KEY);
    if (reviewsStr) {
      try {
        const parsedData = JSON.parse(reviewsStr) as ReviewInfo[];
        return parsedData;
      } catch (error) {
        console.error('解析评论数据失败:', error);
        return ReviewDataUtil.getDefaultReviews();
      }
    }
    return ReviewDataUtil.getDefaultReviews();
  }

  // 获取当前用户的评论数据
  public static getMyReviews(): ReviewInfo[] {
    const allReviews = ReviewDataUtil.getAllReviews();
    const myReviews = allReviews.filter(review => review.userId === 'current_user');
    console.info('获取我的评论，共' + myReviews.length + '条');
    return myReviews;
  }

  // 获取精彩书评（字数超过40字的评论）
  public static getWonderfulReviews(): ReviewInfo[] {
    const allReviews = ReviewDataUtil.getAllReviews();
    const wonderfulReviews = allReviews.filter(review => review.content.toString().length > 40);
    console.info('获取精彩书评，共' + wonderfulReviews.length + '条');
    return wonderfulReviews;
  }

  // 添加新评论
  public static addReview(rating: number, content: string, bookInfo?: BookInfo): void {
    const reviews = ReviewDataUtil.getAllReviews();
    const currentDate = new Date();

    // 处理书籍信息，确保类型安全
    let reviewBookInfo: BookBasicInfo;

    if (bookInfo && bookInfo.id && bookInfo.name) {
      // 处理封面URL的类型转换
      let coverUrl: ResourceStr;

      if (typeof bookInfo.coverUrl === 'string') {
        // 如果是字符串类型，检查是否为资源路径
        if (bookInfo.coverUrl.startsWith('app.media.')) {
          coverUrl = $r(bookInfo.coverUrl);
        } else {
          coverUrl = bookInfo.coverUrl;
        }
      } else if (bookInfo.coverUrl) {
        // 如果已经是ResourceStr或其他类型，直接使用
        coverUrl = bookInfo.coverUrl as ResourceStr;
      } else {
        // 如果没有封面，使用默认封面
        coverUrl = $r('app.media.book_image_1');
      }

      reviewBookInfo = {
        id: bookInfo.id,
        name: bookInfo.name,
        coverUrl: coverUrl,
        category: bookInfo.category || '未分类'
      };

      console.info(`使用书籍信息: ${bookInfo.name} (ID: ${bookInfo.id})`);
    } else {
      // 如果没有有效的书籍信息，使用默认值
      reviewBookInfo = {
        id: 'unknown_book',
        name: '未知书籍',
        coverUrl: $r('app.media.book_image_1'),
        category: '未分类'
      };

      console.warn('未提供有效的书籍信息，使用默认值');
    }

    // 获取真实用户信息
    const currentUserInfo = ReviewDataUtil.getCurrentUserInfo();
    const username = currentUserInfo?.nickName || '我';
    const avatar = currentUserInfo?.avatarUrl || $r('app.media.ic_default_hd_png');
    const isVip = currentUserInfo?.isMembership || false;

    const newReview: ReviewInfo = {
      id: Date.now().toString(),
      userId: 'current_user',
      username: username,
      avatar: avatar as ResourceStr,
      content: content,
      rating: rating,
      createTime: currentDate.toISOString().split('T')[0],
      isVip: isVip,
      isExpanded: false,
      bookInfo: reviewBookInfo
    };

    reviews.unshift(newReview);
    ReviewDataUtil.saveReviews(reviews);
    console.info(`新增评论成功，ID: ${newReview.id}，书籍: ${reviewBookInfo.name}`);
  }

  // 保存评论数据到AppStorage
  private static saveReviews(reviews: ReviewInfo[]): void {
    try {
      const reviewsJson = JSON.stringify(reviews);
      AppStorage.setOrCreate(ReviewDataUtil.STORAGE_KEY, reviewsJson);
      console.info('评论数据保存成功，共' + reviews.length + '条');
    } catch (error) {
      console.error('保存评论数据失败:', error);
    }
  }

  // 更新评论的展开状态
  public static updateReviewExpandState(reviewId: string, isExpanded: boolean): void {
    const reviews = ReviewDataUtil.getAllReviews();
    const reviewIndex = reviews.findIndex(review => review.id === reviewId);
    if (reviewIndex !== -1) {
      reviews[reviewIndex].isExpanded = isExpanded;
      ReviewDataUtil.saveReviews(reviews);
      console.info('更新评论展开状态成功，ID:', reviewId, '展开状态:', isExpanded);
    } else {
      console.warn('未找到要更新的评论，ID:', reviewId);
    }
  }

  // 获取默认评论数据
  private static getDefaultReviews(): ReviewInfo[] {
    // 获取真实用户信息用于默认评论
    const currentUserInfo = ReviewDataUtil.getCurrentUserInfo();
    const username = currentUserInfo?.nickName || '我';
    const avatar = currentUserInfo?.avatarUrl || $r('app.media.ic_default_hd_png');
    const isVip = currentUserInfo?.isMembership || false;

    const defaultReviews: ReviewInfo[] = [
    // 添加一些当前用户的评论数据用于测试
      {
        id: 'my1',
        userId: 'current_user',
        username: username,
        avatar: $r('app.media.ic_default_hd_png'),
        content: '这本书真的很棒！故事情节引人入胜，人物刻画生动，非常值得推荐给大家。作者的文笔功底深厚，每一个细节都描写得很好。',
        rating: 5,
        createTime: '2025-01-04',
        isVip: isVip,
        isExpanded: false,
        bookInfo: {
          id: 'book1',
          name: '设计理论实践应用',
          coverUrl: $r('app.media.book_image_1'),
          category: '艺术'
        }
      },
      {
        id: 'my2',
        userId: 'current_user',
        username: username,
        avatar: $r('app.media.ic_default_hd_png'),
        content: '很有趣的一本书，适合休闲阅读。',
        rating: 4,
        createTime: '2025-01-02',
        isVip: isVip,
        isExpanded: false,
        bookInfo: {
          id: 'book2',
          name: '小羊肖恩',
          coverUrl: $r('app.media.book_image_6'),
          category: '文学'
        }
      },
      {
        id: 'my3',
        userId: 'current_user',
        username: '我',
        avatar: $r('app.media.ic_default_hd_png'),
        content: '这本书的内容很丰富，涵盖了很多有趣的知识点。作者的写作风格很独特，读起来很有意思。整体来说是一本不错的书籍，值得花时间阅读。',
        rating: 4,
        createTime: '2024-12-28',
        isVip: true,
        vipLevel: 'LV3',
        isExpanded: false,
        bookInfo: {
          id: 'book3',
          name: '十年能源变革',
          coverUrl: $r('app.media.book_image_3'),
          category: '艺术'
        }
      },
      // 其他用户的评论
      {
        id: '1',
        userId: 'user1',
        username: '读书小达人',
        avatar: $r('app.media.user_avatar'),
        content: '这本书真的非常精彩，故事情节跌宕起伏，人物刻画深入人心。作者的文笔功底深厚，每一个细节都描写得栩栩如生。特别是主角的成长历程，让我深受感动和启发。这是一本值得反复阅读的好书，强烈推荐给所有读者！整个故事从开始就紧紧抓住了我的心，每一个转折都出人意料，又在情理之中。',
        rating: 5,
        createTime: '2024-01-15',
        isVip: true,
        vipLevel: 'LV3',
        isExpanded: false,
        bookInfo: {
          id: 'book1',
          name: '设计理论实践应用',
          coverUrl: $r('app.media.book_image_1'),
          category: '艺术'
        }
      },
      {
        id: '2',
        userId: 'user2',
        username: '书虫小王子',
        avatar: $r('app.media.default_avatar'),
        content: '剧情设置很新颖，作者的想象力很丰富。虽然有些地方感觉节奏稍快，但总体来说是一本不错的作品。期待作者的下一部作品能够更加完善。文字功底扎实，故事结构完整。',
        rating: 4,
        createTime: '2024-01-14',
        isVip: true,
        vipLevel: 'LV1',
        isExpanded: false,
        bookInfo: {
          id: 'book2',
          name: '小羊肖恩',
          coverUrl: $r('app.media.book_image_6'),
          category: '文学'
        }
      },
      {
        id: '3',
        userId: 'user3',
        username: '文学爱好者',
        avatar: $r('app.media.user_avatar'),
        content: '这本书的世界观构建得非常完整，每个角色都有自己的特色和发展轨迹。故事中蕴含的哲理让人深思，是一部既有娱乐性又有思想深度的优秀作品。作者通过细腻的描写和深刻的思考，为我们呈现了一个丰富多彩的世界。',
        rating: 5,
        createTime: '2024-01-13',
        isVip: true,
        vipLevel: 'LV2',
        isExpanded: false,
        bookInfo: {
          id: 'book3',
          name: '十年能源变革',
          coverUrl: $r('app.media.book_image_3'),
          category: '艺术'
        }
      },
      {
        id: '4',
        userId: 'user4',
        username: '夜读书者',
        avatar: $r('app.media.user_avatar'),
        content: '一口气读完了整本书，实在是太精彩了！故事节奏把握得恰到好处，既有紧张刺激的情节，又有温馨感人的片段。人物性格鲜明，对话自然流畅，让人身临其境。这样的好书真是不多见，强烈推荐大家阅读！',
        rating: 5,
        createTime: '2024-01-12',
        isVip: true,
        vipLevel: 'LV1',
        isExpanded: false,
        bookInfo: {
          id: 'book4',
          name: '诛仙',
          coverUrl: $r('app.media.book_image_1'),
          category: '艺术'
        }
      },
      {
        id: '5',
        userId: 'user5',
        username: '阅读达人888',
        avatar: $r('app.media.default_avatar'),
        content: '不错的作品，故事情节比较吸引人，但是某些地方的逻辑还可以再完善一些。总体来说值得一读。',
        rating: 3,
        createTime: '2024-01-11',
        isVip: false,
        isExpanded: false,
        bookInfo: {
          id: 'book2',
          name: '小羊肖恩',
          coverUrl: $r('app.media.book_image_6'),
          category: '文学'
        }
      },
      {
        id: '6',
        userId: 'user6',
        username: '文青小姐姐',
        avatar: $r('app.media.user_avatar'),
        content: '作者的文笔很有个人特色，故事背景设定新颖，人物刻画生动。虽然是虚构的故事，但是读起来很有代入感。每个章节都有新的惊喜，让人欲罢不能。这本书让我重新燃起了对阅读的热情，真心推荐给大家！',
        rating: 4,
        createTime: '2024-01-10',
        isVip: true,
        vipLevel: 'LV4',
        isExpanded: false,
        bookInfo: {
          id: 'book1',
          name: '设计理论实践应用',
          coverUrl: $r('app.media.book_image_1'),
          category: '艺术'
        }
      },
      {
        id: '7',
        userId: 'user7',
        username: '书海无涯',
        avatar: $r('app.media.default_avatar'),
        content: '这本书给我的感觉就像是在看一部精彩的电影，画面感很强，情节紧凑。作者在细节描写上很用心，每个场景都描绘得栩栩如生。虽然故事有些复杂，但是逻辑清晰，读起来并不费力。是一本值得收藏的好书！',
        rating: 5,
        createTime: '2024-01-09',
        isVip: false,
        isExpanded: false,
        bookInfo: {
          id: 'book3',
          name: '十年能源变革',
          coverUrl: $r('app.media.book_image_3'),
          category: '艺术'
        }
      },
      {
        id: '8',
        userId: 'user8',
        username: '深夜读者',
        avatar: $r('app.media.user_avatar'),
        content: '小羊肖恩我超级喜欢，有一定的可读性，推荐大家多看看，反复品味。',
        rating: 3,
        createTime: '2024-01-08',
        isVip: true,
        vipLevel: 'LV4',
        isExpanded: false,
        bookInfo: {
          id: 'book2',
          name: '小羊肖恩',
          coverUrl: $r('app.media.book_image_6'),
          category: '文学'
        }
      },
      {
        id: '9',
        userId: 'user9',
        username: '文学青年',
        avatar: $r('app.media.default_avatar'),
        content: '这本书的主题很深刻，通过故事反映了很多现实问题。作者的思考角度独特，文字表达力强。虽然有些地方比较沉重，但是读完后会有很多思考和收获。是一本能够启发人思考的好书，值得多读几遍。',
        rating: 4,
        createTime: '2024-01-07',
        isVip: true,
        vipLevel: 'LV2',
        isExpanded: false,
        bookInfo: {
          id: 'book4',
          name: '诛仙',
          coverUrl: $r('app.media.book_image_1'),
          category: '艺术'
        }
      },
      {
        id: '10',
        userId: 'user10',
        username: '书痴一枚',
        avatar: $r('app.media.user_avatar'),
        content: '从头到尾都很精彩！作者的想象力真的很丰富，能够创造出这样一个完整的世界观。人物性格鲜明，每个角色都有自己的故事。情节设计巧妙，伏笔和呼应都很到位。这样的作品真的不多见，必须给五星好评！',
        rating: 5,
        createTime: '2024-01-06',
        isVip: true,
        vipLevel: 'LV5',
        isExpanded: false,
        bookInfo: {
          id: 'book3',
          name: '十年能源变革',
          coverUrl: $r('app.media.book_image_3'),
          category: '艺术'
        }
      }
    ];

    // 首次加载时保存默认数据
    ReviewDataUtil.saveReviews(defaultReviews);
    console.info('初始化默认评论数据，共' + defaultReviews.length + '条');
    return defaultReviews;
  }
} 