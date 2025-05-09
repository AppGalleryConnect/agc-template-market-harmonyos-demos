// 评论数据模型
export class Comment {
  id: number;
  userName: string;
  content: string;
  publishDate: string;
  likes: number;

  constructor(id: number, userName: string, content: string, publishDate: string, likes: number = 0) {
    this.id = id;
    this.userName = userName;
    this.content = content;
    this.publishDate = publishDate;
    this.likes = likes;
  }
}

// 新闻数据模型
export class NewsItem {
  id: number;
  title: string;
  content: string;
  author: string;
  publishDate: string;
  imageUrl: string;
  comments: Comment[];

  constructor(id: number, title: string, content: string, author: string, publishDate: string, imageUrl: string,
    comments: Comment[] = []) {
    this.id = id;
    this.title = title;
    this.content = content;
    this.author = author;
    this.publishDate = publishDate;
    this.imageUrl = imageUrl;
    this.comments = comments;
  }
}

// 模拟数据
export class NewsDataSource {
  static getNewsList(): NewsItem[] {
    return [
      new NewsItem(
        1,
        '鸿蒙OS发布最新版本，新增多项功能',
        '华为今日发布鸿蒙操作系统最新版本，增加了分布式能力和多设备协同功能，使用户体验得到极大提升。据悉，该系统将支持更多设备类型，' +
          '包括手机、平板、智能电视、智能手表等。',
        '科技日报',
        '2024-04-16',
        '',
        [
          new Comment(1, '用户A', '期待鸿蒙系统的未来发展！', '2024-04-16 09:30', 12),
          new Comment(2, '用户B', '已经在使用了，体验很好', '2024-04-16 10:15', 8)
        ]
      ),
      new NewsItem(
        2,
        '人工智能技术在医疗领域的应用取得新突破',
        '近日，某研究团队利用人工智能技术成功预测某类疾病的发展趋势，准确率达到95%以上。这一突破将有助于医生更早地发现潜在健康问题，' +
          '提供更精准的治疗方案。',
        '医疗科技周刊',
        '2024-04-15',
        '',
        [
          new Comment(3, '医学专家', '这项技术确实很有前景，可以大大提高诊断效率', '2024-04-15 14:20', 25),
          new Comment(4, '技术爱好者', '希望能尽快应用到实际临床中', '2024-04-15 16:45', 15)
        ]
      ),
      new NewsItem(
        3,
        '全球气候变化会议将在下月召开',
        '据报道，全球气候变化峰会将于下月在巴黎召开，多国领导人将就减排目标达成新的协议。此次会议被认为是应对全球气候危机的关键一步。',
        '国际新闻社',
        '2024-04-14',
        '',
        [
          new Comment(5, '环保人士', '希望这次会议能达成实质性的协议', '2024-04-14 12:10', 18),
          new Comment(6, '公民C', '个人减排也很重要，我们每个人都应该行动起来', '2024-04-14 13:35', 21)
        ]
      )
    ];
  }
}