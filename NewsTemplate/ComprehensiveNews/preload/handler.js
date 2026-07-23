let myHandler = async function (event, context, callback, logger) {
  logger.info(`Input event: ${JSON.stringify(event)}`);

  let hmSystem = {
    status: 1,
    msg: "success",
  };
  logger.info(`hmSystem: ${hmSystem}`);
  let recommendList = [
    {
      navInfo: {
        setting:
          '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"HotNewsServiceCard","name":"热点新闻"}],"style":{"backgroundColor":"comp_background_tertiary","border-radius":16,"padding-top":"12","padding-bottom":"12","padding-left":"12","padding-right":"12","space":12}}]}]}',
      },
      articles: [
        {
          id: "article_1",
          type: 0,
          title: "中方决定同意与美方进行接触",
          authorId: "001",
          markCount: 0,
          postImgList: [
            {
              picVideoUrl:
                "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_3.jpg",
              surfaceUrl: "",
            },
          ],
          recommends: [
            {
              id: "article_6",
              type: 0,
              title:
                "住建部称住宅层高标准将提至不低于3米，层高低的房子不值钱了？",
              authorId: "author_1",
              markCount: 0,
              recommends: [
                { newsId: "article_8", newsType: 1 },
                { newsId: "article_9", newsType: 1 },
              ],
              createTime: 1751089800000,
              commentCount: 0,
              likeCount: 6000,
              shareCount: 12000,
              isLiked: false,
              isMarked: false,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_1.jpg",
                  surfaceUrl: "",
                },
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_2.jpg",
                  surfaceUrl: "",
                },
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_3.jpg",
                  surfaceUrl: "",
                },
              ],
              richContent:
                '\n                    <div class="content">\n                      <p style="line-height:70px;">住建部称住宅层高标准将提至不低于3米，层高低的房子不值钱了？</p>\n                      <p style="line-height:70px;">在十四届全国人大三次会议民生主题记者会上，住房城乡建设部部长倪虹表示，要加快建设 “好房子”，并将住宅层高标准提高到不低于 3 米。这一政策不仅顺应了百姓对居住品质日益提高的需求，更标志着我国住宅建设从 “住有所居” 迈向 “宜居优居” 的新阶段。</p>\n                    </p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_1.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">提高住宅的层高，可以显著提升居住空间的舒适度，增加净空高度，缓解大户型的空间压抑感，同时也为建筑立面增大开窗采光面积提供了可能性，有利于自然通风，让室内阳光更加充足，让居住环境更加健康舒适。\n                    </p>\n                    <p style="line-height:70px;">随着人们对居住品质追求的不断提升，地暖、新风系统、中央空调等设备逐渐成为改善型住宅的 “标配”。“3 米层高”，能为这些设备提供充足的安装空间，确保设备高效运行，进一步提升室内环境的舒适度。</p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_2.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">可以说，“将住宅层高标准提高到不低于 3 米”，是通过政策引领推动技术创新的重要举措，将鼓励开发企业、设计师探索更人性化的居住空间解决方案，进而推动住宅品质的提升。</p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_3.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">事实上，层高对于房子价值的影响，不能一概而论。房子的价值，受到地段、配套、交通、环境等多种因素的综合影响。即使层高较低，但如果房子位于城市核心地段，周边配套设施完善，交通便利，环境优美，那么其价值依然可能较高。</p>\n                    </div>\n                  ',
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomImageCard","name":"上文下图"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
              },
              author: {
                authorId: "author_1",
                authorNickName: "1号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_1.jpg",
                authorDesc: "",
                authorIp: "北京",
                watchers: ["001", "author_2"],
                followers: ["001", "author_6", "author_7"],
                likeNum: 12,
                watchersCount: 2,
                followersCount: 3,
              },
              comments: [],
            },
            {
              id: "article_7",
              type: 0,
              title: "中国物流与采购联合会：2024年社会物流总额将超360万亿元",
              authorId: "author_2",
              markCount: 0,
              createTime: 1751089800000,
              recommends: [
                { newsId: "article_7", newsType: 1 },
                { newsId: "article_10", newsType: 1 },
              ],
              commentCount: 0,
              likeCount: 6000,
              shareCount: 12000,
              isLiked: false,
              isMarked: false,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new_4.jpg",
                  surfaceUrl: "",
                },
              ],
              richContent:
                '\n                    <div class="content">\n                      <p style="line-height:70px;">中国物流与采购联合会：2024年社会物流总额将超360万亿元</p>\n                      <p style="line-height:70px;">2 月 11 日，中国物流与采购联合会公布 2024 年全年物流运行数据。物流市场规模优势进一步巩固，与产业链协同体系逐步构建，物流需求规模持续扩张，全年全国社会物流总额超 360 万亿元。</p>\n                    </p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new_4.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">2024 年全国社会物流总额，即经济运行中的物流实物量价值总额，为 360.6 万亿元，同比增长 5.8%，比 2023 年加快 0.6 个百分点，全年物流运行总体延续稳中有进的发展态势。\n                    </p>\n                    <p style="line-height:70px;">从物流费用来看，衡量物流运行效率的重要指标 —— 社会物流总费用与 GDP 的比率，降至近年内的最低点，有效降低全社会物流成本行动取得初步成效。2024 年，社会物流总费用与 GDP 的比率为 14.1%，比上年下降 0.3 个百分点。</p>\n                    </div>\n                  ',
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_2",
                authorNickName: "2号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_2.jpg",
                authorDesc: "",
                authorIp: "南京",
                watchers: ["001"],
                followers: ["001", "author_1"],
                likeNum: 24,
                watchersCount: 1,
                followersCount: 2,
              },
              comments: [],
            },
          ],
          richContent:
            '\n                   <div class="content">\n                      <p style="line-height:70px;">中方决定同意与美方进行接触\n                      <p style="line-height:70px;">30个开拍地块中，有8个因触及“竞地价+竞公共租赁住房面积”或“竞地价+竞政府持有商品住宅产权份额”等上限后转入“竞高标准商品住宅建设方案”环节，最终，通过评选组评分确定了8宗商品住宅用地竞得人。</p>\n                    </p>\n                    <p style="line-height:70px;">根据挂牌文件中的《高标准商品住宅建设方案评审内容和评分标准》（以下简称《评分标准》），高标准商品住宅的评分内容包括两个篇章：建筑品质和建筑规划设计，每篇章占比50%，每个篇章下又设置细分指标及对应得分项，累计后就是各个投报方案的最终得分。。\n                    </p>\n                    <p style="line-height:70px;">建筑品质篇主要指向四项建筑技术，包括绿色建筑、装配式建筑、健康建筑和超低能耗技术。</p>\n                    </div>\n                  ',
          createTime: 1751089800000,
          commentCount: 10,
          likeCount: 6000,
          shareCount: 12000,
          isLiked: false,
          isMarked: false,
          navInfo: {
            setting:
              '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
          },
          author: {
            authorId: "001",
            authorNickName: "华为用户",
            authorIcon:
              "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_12.jpg",
            authorDesc:
              "在自己的小世界里，做一个快乐的普通人，把节奏放慢，享受生活！十六岁的青春张扬 十八岁的未来可期，携零零碎碎的美好奔赴未知的将来！",
            authorPhone: "177******96",
            authorIp: "南京",
            watchers: ["author_1", "author_2", "author_6", "author_7"],
            followers: [
              "author_1",
              "author_2",
              "author_3",
              "author_4",
              "author_5",
            ],
            likeNum: 12,
            myLikes: ["author_1", "author_3", "video1", "post_1"],
            myMarks: ["author_2", "author_4", "video2", "post_1"],
            myComments: [],
            myHistory: ["author_1", "video1", "post_1"],
            watchersCount: 4,
            followersCount: 5,
          },
          comments: [],
        },
        {
          id: "article_2",
          type: 0,
          title: "一揽子金融政策打出“组合拳”",
          authorId: "author_2",
          markCount: 0,
          recommends: [
            {
              id: "article_8",
              type: 0,
              title: "两个尾号8个“7”的手机号均以200多万拍卖，买家为同一人",
              authorId: "author_3",
              markCount: 0,
              createTime: 1751089800000,
              recommends: [
                { newsId: "article_8", newsType: 1 },
                { newsId: "article_6", newsType: 1 },
              ],
              commentCount: 0,
              isMarked: false,
              shareCount: 12000,
              isLiked: false,
              likeCount: 6000,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg",
                  surfaceUrl: "",
                },
              ],
              richContent:
                '\n                    <div class="content">\n                      <p style="line-height:70px;">两个尾号8个“7”的手机号均以200多万拍卖，买家为同一人</p>\n                      <p style="line-height:70px;">近日，两场备受关注的手机号码拍卖落下帷幕，两个尾号均为 8 个 “7” 的特殊手机号最终成交价均突破 200 万元，更引人注目的是，这两个 “天价手机号” 的买家为同一人。</p>\n                    </p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">据拍卖平台信息显示，这两个手机号分别归属不同运营商，但其号码规律高度相似，均在末尾连续排列 8 个 “7”，属于数字重复且寓意吉祥的 “靓号”。其中，首个手机号的拍卖从起拍价 50 万元开始，经过近 300 次竞价，最终以 218 万元成交；另一个手机号的竞争同样激烈，历经 260 余次出价后，以 209 万元落槌。\n                    </p>\n                    <p style="line-height:70px;">拍卖记录显示，两位买家的注册信息高度吻合，经平台核实确为同一人。对于此次高价购入两个相似靓号的行为，业内人士分析，这类具有独特数字组合的手机号因其稀缺性，长期以来被部分收藏者和商务人士视为身份象征或投资标的。尤其像 8 个 “7” 这样的连号，在全国范围内存量极少，市场流通性低，从而推高了其交易价值。</p>\n                    <p style="line-height:70px;">不过，也有观点认为，手机号的实际使用价值有限，高价拍卖更多反映的是特定群体对数字符号的偏好，投资需谨慎。目前，这两个手机号的过户手续正在办理中，后续是否会再次进入流通市场引发关注</p>\n                    </div>\n                  ',
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_3",
                authorNickName: "3号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_3.jpg",
                authorDesc: "",
                authorIp: "成都",
                watchers: ["001", "author_4"],
                followers: [],
                likeNum: 36,
                watchersCount: 2,
                followersCount: 0,
              },
              comments: [],
            },
            {
              id: "article_9",
              type: 1,
              title:
                "第12波！伊朗猛砸高超弹，400秒击中以色列，撕裂世界第一防空网",
              authorId: "author_4",
              markCount: 0,
              createTime: 1751089800000,
              recommends: [
                { newsId: "article_8", newsType: 1 },
                { newsId: "article_10", newsType: 1 },
              ],
              commentCount: 0,
              likeCount: 6000,
              shareCount: 12000,
              isLiked: false,
              isMarked: false,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/%E7%9F%A9%E5%BD%A2%203416%403x-2.png",
                  surfaceUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/%E7%9F%A9%E5%BD%A2%203416%403x-2.png",
                },
              ],
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_4",
                authorNickName: "4号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_4.jpg",
                authorDesc: "",
                authorIp: "福建",
                watchers: ["001"],
                followers: ["author_3"],
                likeNum: 36,
                watchersCount: 1,
                followersCount: 1,
              },
              comments: [],
            },
          ],
          postImgList: [
            {
              picVideoUrl:
                "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg",
              surfaceUrl: "",
            },
          ],
          createTime: 1751089800000,
          richContent:
            '\n                    <div class="content">\n                      <p style="line-height:70px;">一揽子金融政策打出“组合拳”</p>\n                      <p style="line-height:70px;">在货币政策方面，自 5 月 15 日起，央行下调金融机构法定存款准备金率 0.5 个百分点，为市场释放出长期流动性，预估金额达万亿元规模。同时，自 5 月 8 日起，政策利率下调 0.1 个百分点，带动贷款市场报价利率（LPR）同步走低，1 年期 LPR 降至 3.0%，5 年期以上 LPR 降至 3.5% 。不仅如此，央行还新增 3000 亿元科技创新和技术改造再贷款额度，下调结构性货币政策工具利率 0.25 个百分点，进一步优化金融资源配置，助力科技创新与产业升级。</p>\n                    </p>\n                    <p style="line-height:70px;">针对房地产市场，相关部门加快构建适配房地产发展新模式的融资制度，优化住房公积金贷款政策，自 5 月 8 日起，个人住房公积金贷款利率下调 0.25 个百分点，切实减轻购房者负担，促进房地产市场平稳健康发展。。\n                    </p>\n                    <p style="line-height:70px;">资本市场层面，全力支持中央汇金公司发挥类 “平准基金” 作用，稳定市场信心。同时，优化资本市场工具，大力推动险资、公募基金等中长期资金入市，完善资本市场生态，提升市场韧性与活力。</p>\n                    <p style="line-height:70px;">在助力小微企业与民营企业发展上，监管部门积极行动，推出支持小微企业、民营企业融资的一揽子政策，并增设支农支小再贷款额度 3000 亿元，切实缓解中小企业融资难题。此外，针对受外部冲击较大的外贸企业，银行业保险业也出台系列护航政策，帮扶企业稳定经营，开拓市场。</p>\n                    <p style="line-height:70px;">中国人民银行副行长邹澜在国新办发布会上强调，后续将持续实施适度宽松的货币政策，密切关注政策传导效果与结构优化，引导金融资源精准流向经济增长的关键领域与薄弱环节。众多业内专家普遍认为，此次一揽子金融政策覆盖全面、力度空前，各政策协同联动，将为实体经济注入强劲动力，有效稳定市场预期，推动经济持续回升向好。随着政策逐步落地见效，企业融资环境有望持续改善，消费与投资活力将进一步释放，为我国经济高质量发展筑牢根基</p>\n                    </div>\n                  ',
          commentCount: 2,
          isLiked: false,
          likeCount: 6000,
          shareCount: 12000,
          isMarked: false,
          navInfo: {
            setting:
              '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
          },
          author: {
            authorId: "author_2",
            authorNickName: "2号选手",
            authorIcon:
              "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_2.jpg",
            authorDesc: "",
            authorIp: "南京",
            watchers: ["001"],
            followers: ["001", "author_1"],
            likeNum: 24,
            watchersCount: 1,
            followersCount: 2,
          },
          comments: [],
        },
        {
          id: "article_3",
          type: 0,
          title: "中俄两国走出一条合作共赢的崭新道路",
          authorId: "author_3",
          markCount: 0,
          recommends: [
            {
              id: "article_9",
              type: 1,
              title:
                "第12波！伊朗猛砸高超弹，400秒击中以色列，撕裂世界第一防空网",
              authorId: "author_4",
              markCount: 0,
              createTime: 1751089800000,
              recommends: [
                { newsId: "article_8", newsType: 1 },
                { newsId: "article_10", newsType: 1 },
              ],
              commentCount: 0,
              likeCount: 6000,
              shareCount: 12000,
              isLiked: false,
              isMarked: false,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/%E7%9F%A9%E5%BD%A2%203416%403x-2.png",
                  surfaceUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/%E7%9F%A9%E5%BD%A2%203416%403x-2.png",
                },
              ],
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_4",
                authorNickName: "4号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_4.jpg",
                authorDesc: "",
                authorIp: "福建",
                watchers: ["001"],
                followers: ["author_3"],
                likeNum: 36,
                watchersCount: 1,
                followersCount: 1,
              },
              comments: [],
            },
            {
              id: "article_11",
              type: 1,
              title: "DeepSeek的所谓综合排名以“开创性+跨学科影响+方法论",
              createTime: 1751089800000,
              authorId: "author_10",
              markCount: 0,
              recommends: [
                { newsId: "article_12", newsType: 1 },
                { newsId: "article_13", newsType: 1 },
              ],
              commentCount: 1,
              likeCount: 6000,
              shareCount: 12000,
              isLiked: false,
              isMarked: false,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/1.png",
                  surfaceUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/1.png",
                },
              ],
              richContent: "",
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_10",
                authorNickName: "10号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_10.jpg",
                authorDesc: "",
                authorIp: "济南",
                watchers: ["author_1"],
                followers: ["001"],
                likeNum: 36,
                watchersCount: 1,
                followersCount: 1,
              },
              comments: [],
            },
          ],
          postImgList: [
            {
              picVideoUrl:
                "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_1.jpg",
              surfaceUrl: "",
            },
          ],
          createTime: 1751089800000,
          richContent:
            '\n                    <div class="content">\n                      <p style="line-height:70px;">中俄两国走出一条合作共赢的崭新道路</p>\n                      <p style="line-height:70px;">近年来，中俄两国在多方面的紧密协作下，成功走出了一条合作共赢的崭新道路，为世界各国间的友好交往与合作树立了典范。</p>\n                    </p>\n                    <p style="line-height:70px;">在政治领域，中俄双方始终保持着高度的互信与频繁的高层互动。两国领导人多次会晤，就双边关系和重大国际问题深入交换意见，为两国合作指明方向。双方秉持不结盟、不对抗、不针对第三方的原则，坚定支持彼此维护本国核心利益和发展道路。在国际事务中，中俄在联合国、上海合作组织、金砖国家等多边机制内密切配合，共同推动多边主义发展，维护国际公平正义。\n                    </p>\n                    <p style="line-height:70px;">经贸合作是中俄关系的重要基石。多年来，两国贸易额持续增长，结构不断优化。传统领域合作稳固，能源合作尤为突出，中俄东线天然气管道等项目顺利推进，为两国能源安全提供了坚实保障。同时，新兴领域合作蓬勃发展，科技创新、跨境电商、数字经济等成为新的合作增长点。今年上半年，中俄双边贸易额突破 [X] 亿美元，同比增长 [X]%，展现出强大的合作韧性与活力。</p>\n                    <p style="line-height:70px;">人文交流方面，中俄两国开展了丰富多彩的活动，增进了两国人民的相互了解与友谊。“中俄文化年”“中俄青年友好交流年” 等活动精彩纷呈，吸引了两国众多民众参与。教育领域，双方互派留学生数量逐年增加，学术交流日益频繁。旅游合作也持续升温，越来越多的中国游客前往俄罗斯领略异域风情，俄罗斯游客也钟情于中国的大好河山。</p>\n                    </div>\n                  ',
          commentCount: 1,
          likeCount: 6000,
          shareCount: 12000,
          isMarked: false,
          isLiked: false,
          navInfo: {
            setting:
              '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
          },
          author: {
            authorId: "author_3",
            authorNickName: "3号选手",
            authorIcon:
              "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_3.jpg",
            authorDesc: "",
            authorIp: "成都",
            watchers: ["001", "author_4"],
            followers: [],
            likeNum: 36,
            watchersCount: 2,
            followersCount: 0,
          },
          comments: [],
        },
        {
          id: "article_4",
          type: 0,
          title: "90万名员工了，刘强东在想什么？他的CEO在忙什么？",
          authorId: "author_4",
          markCount: 0,
          recommends: [
            {
              id: "article_11",
              type: 1,
              title: "DeepSeek的所谓综合排名以“开创性+跨学科影响+方法论",
              createTime: 1751089800000,
              authorId: "author_10",
              markCount: 0,
              recommends: [
                { newsId: "article_12", newsType: 1 },
                { newsId: "article_13", newsType: 1 },
              ],
              commentCount: 1,
              likeCount: 6000,
              shareCount: 12000,
              isLiked: false,
              isMarked: false,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/1.png",
                  surfaceUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/1.png",
                },
              ],
              richContent: "",
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_10",
                authorNickName: "10号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_10.jpg",
                authorDesc: "",
                authorIp: "济南",
                watchers: ["author_1"],
                followers: ["001"],
                likeNum: 36,
                watchersCount: 1,
                followersCount: 1,
              },
              comments: [],
            },
            {
              id: "article_10",
              type: 0,
              title: "特朗普将封禁DeepSeek？外交部给出回应",
              createTime: 1751089800000,
              authorId: "author_11",
              markCount: 0,
              recommends: [
                { newsId: "article_8", newsType: 1 },
                { newsId: "article_9", newsType: 1 },
              ],
              commentCount: 0,
              likeCount: 6000,
              shareCount: 12000,
              isLiked: false,
              isMarked: false,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_7.jpg",
                  surfaceUrl: "",
                },
              ],
              richContent:
                '\n                    <div class="content">\n                      <p style="line-height:70px;">特朗普将封禁DeepSeek？外交部给出回应</p>\n                      <p style="line-height:70px;">3 月 10 日，在外交部例行记者会上，有记者提问，据《华尔街日报》报道，美国总统特朗普正在权衡限制 DeepSeek 的措施，中方对此有何回应？</p>\n                    </p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_7.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">对此，外交部发言人毛宁表示：“我们一贯反对泛化国家安全概念，将经贸和科技问题政治化，我们也将坚定维护中国企业的合法权益。”\n                    </p>\n                    <p style="line-height:70px;">此前，自今年年初 DeepSeek 惊艳亮相、震撼世界以来，美国就一直在想方设法打压 DeepSeek，以遏制中国在人工智能技术上的发展。当地时间 1 月 28 日，美国多名官员表示 DeepSeek 是 “偷窃”，正对其影响开展国家安全调查。1 月 30 日，美国国会众议院首席行政事务官向国会办公室发出通知，警告国会办公室不要使用 DeepSeek 的服务，特朗普还称 DeepSeek 的出现 “给美国相关产业敲响了警钟” 。如今关于特朗普政府将封禁 DeepSeek 的消息传出，引发国际社会广泛关注，后续进展本报将持续跟踪报道。</p>\n                    </div>\n                  ',
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_11",
                authorNickName: "11号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_11.jpg",
                authorDesc: "",
                authorIp: "济南",
                watchers: ["author_1"],
                followers: ["001"],
                likeNum: 36,
                watchersCount: 1,
                followersCount: 1,
              },
              comments: [],
            },
          ],
          postImgList: [
            {
              picVideoUrl:
                "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_2.jpg",
              surfaceUrl: "",
            },
          ],
          createTime: 1751089800000,
          richContent:
            '\n                    <div class="content">\n                      <p style="line-height:70px;">90万名员工了，刘强东在想什么？他的CEO在忙什么？</p>\n                      <p style="line-height:70px;">随着京东业务版图的持续拓展，截至今年二季度末，其员工数量已飙升至 90 万人。这一庞大的数字背后，蕴含着诸多战略深意，也引发外界对刘强东所思所想，以及京东 CEO 当下工作重心的强烈好奇。</p>\n                    </p>\n                    <p style="line-height:70px;">刘强东近日在与媒体交流时袒露心声，直言京东早已超脱个人范畴，承载着 90 万个家庭的生计与尊严。从创业伊始，“供应链” 便是京东的灵魂所在，贯穿零售、物流、医药、工业等核心业务。刘强东坚定表示，自己乃至整个京东集团，未来都将紧紧围绕供应链深耕细作。他进一步透露，京东入局外卖领域，实则是为生鲜供应链服务，且预计再过一个月，京东外卖将推出一种与美团截然不同的商业模式，有望彻底革新食品安全问题。\n                    </p>\n                    <p style="line-height:70px;">刘强东回顾过往，感慨京东每隔三年便会孕育出新的商业模式。他称，从 2013 年首次尝试 “退休”，让职业经理人掌舵，到如今因现任 CEO 许冉的恳请而回归，目的是为了手把手指导她开展工作。待许冉熟悉业务后，刘强东计划全身心投入国际业务。他强调，京东的成功源于 “体验、成本、效率” 六字战略，未来也将坚定不移地贯彻这一理念，借助人工智能和机器人技术，在保障员工权益的基础上，持续降低成本，目标将库存周转天数压缩至 20 至 25 天。</p>\n                    </div>\n                  ',
          likeCount: 6000,
          isMarked: false,
          shareCount: 12000,
          commentCount: 1,
          isLiked: false,
          navInfo: {
            setting:
              '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
          },
          author: {
            authorId: "author_4",
            authorNickName: "4号选手",
            authorIcon:
              "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_4.jpg",
            authorDesc: "",
            authorIp: "福建",
            watchers: ["001"],
            followers: ["author_3"],
            likeNum: 36,
            watchersCount: 1,
            followersCount: 1,
          },
          comments: [],
        },
        {
          id: "article_5",
          type: 0,
          title: "2025年社会物流总额将超360万亿元",
          authorId: "author_5",
          markCount: 0,
          recommends: [
            {
              id: "article_7",
              type: 0,
              title: "中国物流与采购联合会：2024年社会物流总额将超360万亿元",
              authorId: "author_2",
              markCount: 0,
              createTime: 1751089800000,
              recommends: [
                { newsId: "article_7", newsType: 1 },
                { newsId: "article_10", newsType: 1 },
              ],
              commentCount: 0,
              likeCount: 6000,
              shareCount: 12000,
              isLiked: false,
              isMarked: false,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new_4.jpg",
                  surfaceUrl: "",
                },
              ],
              richContent:
                '\n                    <div class="content">\n                      <p style="line-height:70px;">中国物流与采购联合会：2024年社会物流总额将超360万亿元</p>\n                      <p style="line-height:70px;">2 月 11 日，中国物流与采购联合会公布 2024 年全年物流运行数据。物流市场规模优势进一步巩固，与产业链协同体系逐步构建，物流需求规模持续扩张，全年全国社会物流总额超 360 万亿元。</p>\n                    </p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new_4.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">2024 年全国社会物流总额，即经济运行中的物流实物量价值总额，为 360.6 万亿元，同比增长 5.8%，比 2023 年加快 0.6 个百分点，全年物流运行总体延续稳中有进的发展态势。\n                    </p>\n                    <p style="line-height:70px;">从物流费用来看，衡量物流运行效率的重要指标 —— 社会物流总费用与 GDP 的比率，降至近年内的最低点，有效降低全社会物流成本行动取得初步成效。2024 年，社会物流总费用与 GDP 的比率为 14.1%，比上年下降 0.3 个百分点。</p>\n                    </div>\n                  ',
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_2",
                authorNickName: "2号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_2.jpg",
                authorDesc: "",
                authorIp: "南京",
                watchers: ["001"],
                followers: ["001", "author_1"],
                likeNum: 24,
                watchersCount: 1,
                followersCount: 2,
              },
              comments: [],
            },
            {
              id: "article_8",
              type: 0,
              title: "两个尾号8个“7”的手机号均以200多万拍卖，买家为同一人",
              authorId: "author_3",
              markCount: 0,
              createTime: 1751089800000,
              recommends: [
                { newsId: "article_8", newsType: 1 },
                { newsId: "article_6", newsType: 1 },
              ],
              commentCount: 0,
              isMarked: false,
              shareCount: 12000,
              isLiked: false,
              likeCount: 6000,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg",
                  surfaceUrl: "",
                },
              ],
              richContent:
                '\n                    <div class="content">\n                      <p style="line-height:70px;">两个尾号8个“7”的手机号均以200多万拍卖，买家为同一人</p>\n                      <p style="line-height:70px;">近日，两场备受关注的手机号码拍卖落下帷幕，两个尾号均为 8 个 “7” 的特殊手机号最终成交价均突破 200 万元，更引人注目的是，这两个 “天价手机号” 的买家为同一人。</p>\n                    </p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">据拍卖平台信息显示，这两个手机号分别归属不同运营商，但其号码规律高度相似，均在末尾连续排列 8 个 “7”，属于数字重复且寓意吉祥的 “靓号”。其中，首个手机号的拍卖从起拍价 50 万元开始，经过近 300 次竞价，最终以 218 万元成交；另一个手机号的竞争同样激烈，历经 260 余次出价后，以 209 万元落槌。\n                    </p>\n                    <p style="line-height:70px;">拍卖记录显示，两位买家的注册信息高度吻合，经平台核实确为同一人。对于此次高价购入两个相似靓号的行为，业内人士分析，这类具有独特数字组合的手机号因其稀缺性，长期以来被部分收藏者和商务人士视为身份象征或投资标的。尤其像 8 个 “7” 这样的连号，在全国范围内存量极少，市场流通性低，从而推高了其交易价值。</p>\n                    <p style="line-height:70px;">不过，也有观点认为，手机号的实际使用价值有限，高价拍卖更多反映的是特定群体对数字符号的偏好，投资需谨慎。目前，这两个手机号的过户手续正在办理中，后续是否会再次进入流通市场引发关注</p>\n                    </div>\n                  ',
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_3",
                authorNickName: "3号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_3.jpg",
                authorDesc: "",
                authorIp: "成都",
                watchers: ["001", "author_4"],
                followers: [],
                likeNum: 36,
                watchersCount: 2,
                followersCount: 0,
              },
              comments: [],
            },
          ],
          postImgList: [
            {
              picVideoUrl:
                "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_4.jpg",
              surfaceUrl: "",
            },
          ],
          createTime: 1751089800000,
          richContent:
            '\n                    <div class="content">\n                      <p style="line-height:70px;">2025年社会物流总额将超360万亿元</p>\n                      <p  style="line-height:70px;">中国物流与采购联合会发布的最新数据显示，2025 年我国社会物流总额有望突破 360 万亿元大关，展现出物流行业的强劲增长态势。这一数据不仅反映了国内经济的稳定复苏和市场活力的不断释放，也彰显了物流行业在推动经济高质量发展中的重要作用。</p>\n                    </p>\n                    <p style="line-height:70px;">中国物流与采购联合会发布的最新数据显示，2025 年我国社会物流总额有望突破 360 万亿元大关，展现出物流行业的强劲增长态势。这一数据不仅反映了国内经济的稳定复苏和市场活力的不断释放，也彰显了物流行业在推动经济高质量发展中的重要作用。2025 年前五个月，全国社会物流总额已达 138.7 万亿元，同比增长 5.3%，增速较去年同期有所加快。这一增长势头得益于国内一系列促进消费和投资的政策举措，有效拉动了物流需求。特别是在单位与居民物品物流领域，前五月增长 6.4%，单月同比增速在 5 月更是攀升至 8.3%，较上月提高 2.1 个百分点，显示出消费市场的旺盛活力。\n                    </p>\n                    <p style="line-height:70px;">消费市场的繁荣是推动物流总额增长的重要动力。节日经济与各类促销活动相互叠加，直播电商、即时零售等新兴消费模式蓬勃发展，有力推动了消费品物流的高效运转。据统计，今年上半年实物商品网上零售额同比增长 6.3%，促使消费品物流效率显著提升。同时，产业升级进程的加快，使得高端制造业、新能源等领域对物流服务的需求呈现出多样化、精细化趋势，进一步拉动了社会物流总额的增长。</p>\n                    </div>\n                  ',
          shareCount: 12000,
          commentCount: 0,
          isLiked: false,
          likeCount: 6000,
          isMarked: false,
          navInfo: {
            setting:
              '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
          },
          author: {
            authorId: "author_5",
            authorNickName: "5号选手",
            authorIcon:
              "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_5.jpg",
            authorDesc: "",
            authorIp: "深圳",
            watchers: ["001", "author_6"],
            followers: [],
            likeNum: 36,
            watchersCount: 2,
            followersCount: 0,
          },
          comments: [],
        },
      ],
      extraInfo: {},
    },
    {
      navInfo: {
        setting:
          '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomImageCard","name":"上文下图"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
      articles: [
        {
          id: "article_6",
          type: 0,
          title: "住建部称住宅层高标准将提至不低于3米，层高低的房子不值钱了？",
          authorId: "author_1",
          markCount: 0,
          recommends: [
            {
              id: "article_8",
              type: 0,
              title: "两个尾号8个“7”的手机号均以200多万拍卖，买家为同一人",
              authorId: "author_3",
              markCount: 0,
              createTime: 1751089800000,
              recommends: [
                { newsId: "article_8", newsType: 1 },
                { newsId: "article_6", newsType: 1 },
              ],
              commentCount: 0,
              isMarked: false,
              shareCount: 12000,
              isLiked: false,
              likeCount: 6000,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg",
                  surfaceUrl: "",
                },
              ],
              richContent:
                '\n                    <div class="content">\n                      <p style="line-height:70px;">两个尾号8个“7”的手机号均以200多万拍卖，买家为同一人</p>\n                      <p style="line-height:70px;">近日，两场备受关注的手机号码拍卖落下帷幕，两个尾号均为 8 个 “7” 的特殊手机号最终成交价均突破 200 万元，更引人注目的是，这两个 “天价手机号” 的买家为同一人。</p>\n                    </p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">据拍卖平台信息显示，这两个手机号分别归属不同运营商，但其号码规律高度相似，均在末尾连续排列 8 个 “7”，属于数字重复且寓意吉祥的 “靓号”。其中，首个手机号的拍卖从起拍价 50 万元开始，经过近 300 次竞价，最终以 218 万元成交；另一个手机号的竞争同样激烈，历经 260 余次出价后，以 209 万元落槌。\n                    </p>\n                    <p style="line-height:70px;">拍卖记录显示，两位买家的注册信息高度吻合，经平台核实确为同一人。对于此次高价购入两个相似靓号的行为，业内人士分析，这类具有独特数字组合的手机号因其稀缺性，长期以来被部分收藏者和商务人士视为身份象征或投资标的。尤其像 8 个 “7” 这样的连号，在全国范围内存量极少，市场流通性低，从而推高了其交易价值。</p>\n                    <p style="line-height:70px;">不过，也有观点认为，手机号的实际使用价值有限，高价拍卖更多反映的是特定群体对数字符号的偏好，投资需谨慎。目前，这两个手机号的过户手续正在办理中，后续是否会再次进入流通市场引发关注</p>\n                    </div>\n                  ',
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_3",
                authorNickName: "3号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_3.jpg",
                authorDesc: "",
                authorIp: "成都",
                watchers: ["001", "author_4"],
                followers: [],
                likeNum: 36,
                watchersCount: 2,
                followersCount: 0,
              },
              comments: [],
            },
            {
              id: "article_9",
              type: 1,
              title:
                "第12波！伊朗猛砸高超弹，400秒击中以色列，撕裂世界第一防空网",
              authorId: "author_4",
              markCount: 0,
              createTime: 1751089800000,
              recommends: [
                { newsId: "article_8", newsType: 1 },
                { newsId: "article_10", newsType: 1 },
              ],
              commentCount: 0,
              likeCount: 6000,
              shareCount: 12000,
              isLiked: false,
              isMarked: false,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/%E7%9F%A9%E5%BD%A2%203416%403x-2.png",
                  surfaceUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/%E7%9F%A9%E5%BD%A2%203416%403x-2.png",
                },
              ],
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_4",
                authorNickName: "4号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_4.jpg",
                authorDesc: "",
                authorIp: "福建",
                watchers: ["001"],
                followers: ["author_3"],
                likeNum: 36,
                watchersCount: 1,
                followersCount: 1,
              },
              comments: [],
            },
          ],
          createTime: 1751089800000,
          commentCount: 0,
          likeCount: 6000,
          shareCount: 12000,
          isLiked: false,
          isMarked: false,
          postImgList: [
            {
              picVideoUrl:
                "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_1.jpg",
              surfaceUrl: "",
            },
            {
              picVideoUrl:
                "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_2.jpg",
              surfaceUrl: "",
            },
            {
              picVideoUrl:
                "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_3.jpg",
              surfaceUrl: "",
            },
          ],
          richContent:
            '\n                    <div class="content">\n                      <p style="line-height:70px;">住建部称住宅层高标准将提至不低于3米，层高低的房子不值钱了？</p>\n                      <p style="line-height:70px;">在十四届全国人大三次会议民生主题记者会上，住房城乡建设部部长倪虹表示，要加快建设 “好房子”，并将住宅层高标准提高到不低于 3 米。这一政策不仅顺应了百姓对居住品质日益提高的需求，更标志着我国住宅建设从 “住有所居” 迈向 “宜居优居” 的新阶段。</p>\n                    </p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_1.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">提高住宅的层高，可以显著提升居住空间的舒适度，增加净空高度，缓解大户型的空间压抑感，同时也为建筑立面增大开窗采光面积提供了可能性，有利于自然通风，让室内阳光更加充足，让居住环境更加健康舒适。\n                    </p>\n                    <p style="line-height:70px;">随着人们对居住品质追求的不断提升，地暖、新风系统、中央空调等设备逐渐成为改善型住宅的 “标配”。“3 米层高”，能为这些设备提供充足的安装空间，确保设备高效运行，进一步提升室内环境的舒适度。</p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_2.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">可以说，“将住宅层高标准提高到不低于 3 米”，是通过政策引领推动技术创新的重要举措，将鼓励开发企业、设计师探索更人性化的居住空间解决方案，进而推动住宅品质的提升。</p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_3.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">事实上，层高对于房子价值的影响，不能一概而论。房子的价值，受到地段、配套、交通、环境等多种因素的综合影响。即使层高较低，但如果房子位于城市核心地段，周边配套设施完善，交通便利，环境优美，那么其价值依然可能较高。</p>\n                    </div>\n                  ',
          navInfo: {
            setting:
              '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomImageCard","name":"上文下图"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
          },
          author: {
            authorId: "author_1",
            authorNickName: "1号选手",
            authorIcon:
              "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_1.jpg",
            authorDesc: "",
            authorIp: "北京",
            watchers: ["001", "author_2"],
            followers: ["001", "author_6", "author_7"],
            likeNum: 12,
            watchersCount: 2,
            followersCount: 3,
          },
          comments: [],
        },
      ],
      extraInfo: {},
    },
    {
      navInfo: {
        setting:
          '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图","style":{"padding-top":"12","padding-bottom":"12"}}],"style":{"backgroundColor":"#FFFFFF"}}]}]}',
      },
      articles: [
        {
          id: "article_7",
          type: 0,
          title: "中国物流与采购联合会：2024年社会物流总额将超360万亿元",
          authorId: "author_2",
          markCount: 0,
          createTime: 1751089800000,
          recommends: [
            {
              id: "article_7",
              type: 0,
              title: "中国物流与采购联合会：2024年社会物流总额将超360万亿元",
              authorId: "author_2",
              markCount: 0,
              createTime: 1751089800000,
              recommends: [
                { newsId: "article_7", newsType: 1 },
                { newsId: "article_10", newsType: 1 },
              ],
              commentCount: 0,
              likeCount: 6000,
              shareCount: 12000,
              isLiked: false,
              isMarked: false,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new_4.jpg",
                  surfaceUrl: "",
                },
              ],
              richContent:
                '\n                    <div class="content">\n                      <p style="line-height:70px;">中国物流与采购联合会：2024年社会物流总额将超360万亿元</p>\n                      <p style="line-height:70px;">2 月 11 日，中国物流与采购联合会公布 2024 年全年物流运行数据。物流市场规模优势进一步巩固，与产业链协同体系逐步构建，物流需求规模持续扩张，全年全国社会物流总额超 360 万亿元。</p>\n                    </p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new_4.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">2024 年全国社会物流总额，即经济运行中的物流实物量价值总额，为 360.6 万亿元，同比增长 5.8%，比 2023 年加快 0.6 个百分点，全年物流运行总体延续稳中有进的发展态势。\n                    </p>\n                    <p style="line-height:70px;">从物流费用来看，衡量物流运行效率的重要指标 —— 社会物流总费用与 GDP 的比率，降至近年内的最低点，有效降低全社会物流成本行动取得初步成效。2024 年，社会物流总费用与 GDP 的比率为 14.1%，比上年下降 0.3 个百分点。</p>\n                    </div>\n                  ',
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_2",
                authorNickName: "2号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_2.jpg",
                authorDesc: "",
                authorIp: "南京",
                watchers: ["001"],
                followers: ["001", "author_1"],
                likeNum: 24,
                watchersCount: 1,
                followersCount: 2,
              },
              comments: [],
            },
            {
              id: "article_10",
              type: 0,
              title: "特朗普将封禁DeepSeek？外交部给出回应",
              createTime: 1751089800000,
              authorId: "author_11",
              markCount: 0,
              recommends: [
                { newsId: "article_8", newsType: 1 },
                { newsId: "article_9", newsType: 1 },
              ],
              commentCount: 0,
              likeCount: 6000,
              shareCount: 12000,
              isLiked: false,
              isMarked: false,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_7.jpg",
                  surfaceUrl: "",
                },
              ],
              richContent:
                '\n                    <div class="content">\n                      <p style="line-height:70px;">特朗普将封禁DeepSeek？外交部给出回应</p>\n                      <p style="line-height:70px;">3 月 10 日，在外交部例行记者会上，有记者提问，据《华尔街日报》报道，美国总统特朗普正在权衡限制 DeepSeek 的措施，中方对此有何回应？</p>\n                    </p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_7.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">对此，外交部发言人毛宁表示：“我们一贯反对泛化国家安全概念，将经贸和科技问题政治化，我们也将坚定维护中国企业的合法权益。”\n                    </p>\n                    <p style="line-height:70px;">此前，自今年年初 DeepSeek 惊艳亮相、震撼世界以来，美国就一直在想方设法打压 DeepSeek，以遏制中国在人工智能技术上的发展。当地时间 1 月 28 日，美国多名官员表示 DeepSeek 是 “偷窃”，正对其影响开展国家安全调查。1 月 30 日，美国国会众议院首席行政事务官向国会办公室发出通知，警告国会办公室不要使用 DeepSeek 的服务，特朗普还称 DeepSeek 的出现 “给美国相关产业敲响了警钟” 。如今关于特朗普政府将封禁 DeepSeek 的消息传出，引发国际社会广泛关注，后续进展本报将持续跟踪报道。</p>\n                    </div>\n                  ',
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_11",
                authorNickName: "11号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_11.jpg",
                authorDesc: "",
                authorIp: "济南",
                watchers: ["author_1"],
                followers: ["001"],
                likeNum: 36,
                watchersCount: 1,
                followersCount: 1,
              },
              comments: [],
            },
          ],
          commentCount: 0,
          likeCount: 6000,
          shareCount: 12000,
          isLiked: false,
          isMarked: false,
          postImgList: [
            {
              picVideoUrl:
                "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new_4.jpg",
              surfaceUrl: "",
            },
          ],
          richContent:
            '\n                    <div class="content">\n                      <p style="line-height:70px;">中国物流与采购联合会：2024年社会物流总额将超360万亿元</p>\n                      <p style="line-height:70px;">2 月 11 日，中国物流与采购联合会公布 2024 年全年物流运行数据。物流市场规模优势进一步巩固，与产业链协同体系逐步构建，物流需求规模持续扩张，全年全国社会物流总额超 360 万亿元。</p>\n                    </p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new_4.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">2024 年全国社会物流总额，即经济运行中的物流实物量价值总额，为 360.6 万亿元，同比增长 5.8%，比 2023 年加快 0.6 个百分点，全年物流运行总体延续稳中有进的发展态势。\n                    </p>\n                    <p style="line-height:70px;">从物流费用来看，衡量物流运行效率的重要指标 —— 社会物流总费用与 GDP 的比率，降至近年内的最低点，有效降低全社会物流成本行动取得初步成效。2024 年，社会物流总费用与 GDP 的比率为 14.1%，比上年下降 0.3 个百分点。</p>\n                    </div>\n                  ',
          navInfo: {
            setting:
              '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
          },
          author: {
            authorId: "author_2",
            authorNickName: "2号选手",
            authorIcon:
              "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_2.jpg",
            authorDesc: "",
            authorIp: "南京",
            watchers: ["001"],
            followers: ["001", "author_1"],
            likeNum: 24,
            watchersCount: 1,
            followersCount: 2,
          },
          comments: [],
        },
        {
          id: "article_8",
          type: 0,
          title: "两个尾号8个“7”的手机号均以200多万拍卖，买家为同一人",
          authorId: "author_3",
          markCount: 0,
          createTime: 1751089800000,
          recommends: [
            {
              id: "article_8",
              type: 0,
              title: "两个尾号8个“7”的手机号均以200多万拍卖，买家为同一人",
              authorId: "author_3",
              markCount: 0,
              createTime: 1751089800000,
              recommends: [
                { newsId: "article_8", newsType: 1 },
                { newsId: "article_6", newsType: 1 },
              ],
              commentCount: 0,
              isMarked: false,
              shareCount: 12000,
              isLiked: false,
              likeCount: 6000,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg",
                  surfaceUrl: "",
                },
              ],
              richContent:
                '\n                    <div class="content">\n                      <p style="line-height:70px;">两个尾号8个“7”的手机号均以200多万拍卖，买家为同一人</p>\n                      <p style="line-height:70px;">近日，两场备受关注的手机号码拍卖落下帷幕，两个尾号均为 8 个 “7” 的特殊手机号最终成交价均突破 200 万元，更引人注目的是，这两个 “天价手机号” 的买家为同一人。</p>\n                    </p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">据拍卖平台信息显示，这两个手机号分别归属不同运营商，但其号码规律高度相似，均在末尾连续排列 8 个 “7”，属于数字重复且寓意吉祥的 “靓号”。其中，首个手机号的拍卖从起拍价 50 万元开始，经过近 300 次竞价，最终以 218 万元成交；另一个手机号的竞争同样激烈，历经 260 余次出价后，以 209 万元落槌。\n                    </p>\n                    <p style="line-height:70px;">拍卖记录显示，两位买家的注册信息高度吻合，经平台核实确为同一人。对于此次高价购入两个相似靓号的行为，业内人士分析，这类具有独特数字组合的手机号因其稀缺性，长期以来被部分收藏者和商务人士视为身份象征或投资标的。尤其像 8 个 “7” 这样的连号，在全国范围内存量极少，市场流通性低，从而推高了其交易价值。</p>\n                    <p style="line-height:70px;">不过，也有观点认为，手机号的实际使用价值有限，高价拍卖更多反映的是特定群体对数字符号的偏好，投资需谨慎。目前，这两个手机号的过户手续正在办理中，后续是否会再次进入流通市场引发关注</p>\n                    </div>\n                  ',
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_3",
                authorNickName: "3号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_3.jpg",
                authorDesc: "",
                authorIp: "成都",
                watchers: ["001", "author_4"],
                followers: [],
                likeNum: 36,
                watchersCount: 2,
                followersCount: 0,
              },
              comments: [],
            },
            {
              id: "article_6",
              type: 0,
              title:
                "住建部称住宅层高标准将提至不低于3米，层高低的房子不值钱了？",
              authorId: "author_1",
              markCount: 0,
              recommends: [
                { newsId: "article_8", newsType: 1 },
                { newsId: "article_9", newsType: 1 },
              ],
              createTime: 1751089800000,
              commentCount: 0,
              likeCount: 6000,
              shareCount: 12000,
              isLiked: false,
              isMarked: false,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_1.jpg",
                  surfaceUrl: "",
                },
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_2.jpg",
                  surfaceUrl: "",
                },
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_3.jpg",
                  surfaceUrl: "",
                },
              ],
              richContent:
                '\n                    <div class="content">\n                      <p style="line-height:70px;">住建部称住宅层高标准将提至不低于3米，层高低的房子不值钱了？</p>\n                      <p style="line-height:70px;">在十四届全国人大三次会议民生主题记者会上，住房城乡建设部部长倪虹表示，要加快建设 “好房子”，并将住宅层高标准提高到不低于 3 米。这一政策不仅顺应了百姓对居住品质日益提高的需求，更标志着我国住宅建设从 “住有所居” 迈向 “宜居优居” 的新阶段。</p>\n                    </p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_1.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">提高住宅的层高，可以显著提升居住空间的舒适度，增加净空高度，缓解大户型的空间压抑感，同时也为建筑立面增大开窗采光面积提供了可能性，有利于自然通风，让室内阳光更加充足，让居住环境更加健康舒适。\n                    </p>\n                    <p style="line-height:70px;">随着人们对居住品质追求的不断提升，地暖、新风系统、中央空调等设备逐渐成为改善型住宅的 “标配”。“3 米层高”，能为这些设备提供充足的安装空间，确保设备高效运行，进一步提升室内环境的舒适度。</p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_2.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">可以说，“将住宅层高标准提高到不低于 3 米”，是通过政策引领推动技术创新的重要举措，将鼓励开发企业、设计师探索更人性化的居住空间解决方案，进而推动住宅品质的提升。</p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_3.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">事实上，层高对于房子价值的影响，不能一概而论。房子的价值，受到地段、配套、交通、环境等多种因素的综合影响。即使层高较低，但如果房子位于城市核心地段，周边配套设施完善，交通便利，环境优美，那么其价值依然可能较高。</p>\n                    </div>\n                  ',
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomImageCard","name":"上文下图"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
              },
              author: {
                authorId: "author_1",
                authorNickName: "1号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_1.jpg",
                authorDesc: "",
                authorIp: "北京",
                watchers: ["001", "author_2"],
                followers: ["001", "author_6", "author_7"],
                likeNum: 12,
                watchersCount: 2,
                followersCount: 3,
              },
              comments: [],
            },
          ],
          commentCount: 0,
          isMarked: false,
          shareCount: 12000,
          isLiked: false,
          likeCount: 6000,
          postImgList: [
            {
              picVideoUrl:
                "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg",
              surfaceUrl: "",
            },
          ],
          richContent:
            '\n                    <div class="content">\n                      <p style="line-height:70px;">两个尾号8个“7”的手机号均以200多万拍卖，买家为同一人</p>\n                      <p style="line-height:70px;">近日，两场备受关注的手机号码拍卖落下帷幕，两个尾号均为 8 个 “7” 的特殊手机号最终成交价均突破 200 万元，更引人注目的是，这两个 “天价手机号” 的买家为同一人。</p>\n                    </p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">据拍卖平台信息显示，这两个手机号分别归属不同运营商，但其号码规律高度相似，均在末尾连续排列 8 个 “7”，属于数字重复且寓意吉祥的 “靓号”。其中，首个手机号的拍卖从起拍价 50 万元开始，经过近 300 次竞价，最终以 218 万元成交；另一个手机号的竞争同样激烈，历经 260 余次出价后，以 209 万元落槌。\n                    </p>\n                    <p style="line-height:70px;">拍卖记录显示，两位买家的注册信息高度吻合，经平台核实确为同一人。对于此次高价购入两个相似靓号的行为，业内人士分析，这类具有独特数字组合的手机号因其稀缺性，长期以来被部分收藏者和商务人士视为身份象征或投资标的。尤其像 8 个 “7” 这样的连号，在全国范围内存量极少，市场流通性低，从而推高了其交易价值。</p>\n                    <p style="line-height:70px;">不过，也有观点认为，手机号的实际使用价值有限，高价拍卖更多反映的是特定群体对数字符号的偏好，投资需谨慎。目前，这两个手机号的过户手续正在办理中，后续是否会再次进入流通市场引发关注</p>\n                    </div>\n                  ',
          navInfo: {
            setting:
              '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
          },
          author: {
            authorId: "author_3",
            authorNickName: "3号选手",
            authorIcon:
              "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_3.jpg",
            authorDesc: "",
            authorIp: "成都",
            watchers: ["001", "author_4"],
            followers: [],
            likeNum: 36,
            watchersCount: 2,
            followersCount: 0,
          },
          comments: [],
        },
      ],
      extraInfo: {},
    },
    {
      navInfo: {
        setting:
          '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
      },
      articles: [
        {
          id: "video8",
          type: 1,
          title: "第12波！伊朗猛砸高超弹，400秒击中以色列，撕裂世界第一防空网",
          authorId: "author_4",
          markCount: 0,
          createTime: 1751089800000,
          recommends: [
            {
              id: "article_8",
              type: 0,
              title: "两个尾号8个“7”的手机号均以200多万拍卖，买家为同一人",
              authorId: "author_3",
              markCount: 0,
              createTime: 1751089800000,
              recommends: [
                { newsId: "article_8", newsType: 1 },
                { newsId: "article_6", newsType: 1 },
              ],
              commentCount: 0,
              isMarked: false,
              shareCount: 12000,
              isLiked: false,
              likeCount: 6000,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg",
                  surfaceUrl: "",
                },
              ],
              richContent:
                '\n                    <div class="content">\n                      <p style="line-height:70px;">两个尾号8个“7”的手机号均以200多万拍卖，买家为同一人</p>\n                      <p style="line-height:70px;">近日，两场备受关注的手机号码拍卖落下帷幕，两个尾号均为 8 个 “7” 的特殊手机号最终成交价均突破 200 万元，更引人注目的是，这两个 “天价手机号” 的买家为同一人。</p>\n                    </p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">据拍卖平台信息显示，这两个手机号分别归属不同运营商，但其号码规律高度相似，均在末尾连续排列 8 个 “7”，属于数字重复且寓意吉祥的 “靓号”。其中，首个手机号的拍卖从起拍价 50 万元开始，经过近 300 次竞价，最终以 218 万元成交；另一个手机号的竞争同样激烈，历经 260 余次出价后，以 209 万元落槌。\n                    </p>\n                    <p style="line-height:70px;">拍卖记录显示，两位买家的注册信息高度吻合，经平台核实确为同一人。对于此次高价购入两个相似靓号的行为，业内人士分析，这类具有独特数字组合的手机号因其稀缺性，长期以来被部分收藏者和商务人士视为身份象征或投资标的。尤其像 8 个 “7” 这样的连号，在全国范围内存量极少，市场流通性低，从而推高了其交易价值。</p>\n                    <p style="line-height:70px;">不过，也有观点认为，手机号的实际使用价值有限，高价拍卖更多反映的是特定群体对数字符号的偏好，投资需谨慎。目前，这两个手机号的过户手续正在办理中，后续是否会再次进入流通市场引发关注</p>\n                    </div>\n                  ',
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_3",
                authorNickName: "3号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_3.jpg",
                authorDesc: "",
                authorIp: "成都",
                watchers: ["001", "author_4"],
                followers: [],
                likeNum: 36,
                watchersCount: 2,
                followersCount: 0,
              },
              comments: [],
            },
            {
              id: "article_10",
              type: 0,
              title: "特朗普将封禁DeepSeek？外交部给出回应",
              createTime: 1751089800000,
              authorId: "author_11",
              markCount: 0,
              recommends: [
                { newsId: "article_8", newsType: 1 },
                { newsId: "article_9", newsType: 1 },
              ],
              commentCount: 0,
              likeCount: 6000,
              shareCount: 12000,
              isLiked: false,
              isMarked: false,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_7.jpg",
                  surfaceUrl: "",
                },
              ],
              richContent:
                '\n                    <div class="content">\n                      <p style="line-height:70px;">特朗普将封禁DeepSeek？外交部给出回应</p>\n                      <p style="line-height:70px;">3 月 10 日，在外交部例行记者会上，有记者提问，据《华尔街日报》报道，美国总统特朗普正在权衡限制 DeepSeek 的措施，中方对此有何回应？</p>\n                    </p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_7.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">对此，外交部发言人毛宁表示：“我们一贯反对泛化国家安全概念，将经贸和科技问题政治化，我们也将坚定维护中国企业的合法权益。”\n                    </p>\n                    <p style="line-height:70px;">此前，自今年年初 DeepSeek 惊艳亮相、震撼世界以来，美国就一直在想方设法打压 DeepSeek，以遏制中国在人工智能技术上的发展。当地时间 1 月 28 日，美国多名官员表示 DeepSeek 是 “偷窃”，正对其影响开展国家安全调查。1 月 30 日，美国国会众议院首席行政事务官向国会办公室发出通知，警告国会办公室不要使用 DeepSeek 的服务，特朗普还称 DeepSeek 的出现 “给美国相关产业敲响了警钟” 。如今关于特朗普政府将封禁 DeepSeek 的消息传出，引发国际社会广泛关注，后续进展本报将持续跟踪报道。</p>\n                    </div>\n                  ',
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_11",
                authorNickName: "11号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_11.jpg",
                authorDesc: "",
                authorIp: "济南",
                watchers: ["author_1"],
                followers: ["001"],
                likeNum: 36,
                watchersCount: 1,
                followersCount: 1,
              },
              comments: [],
            },
          ],
          commentCount: 0,
          likeCount: 6000,
          shareCount: 12000,
          isLiked: false,
          isMarked: false,
          postImgList: [
            {
              picVideoUrl:
                "https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-o7oax/template_source%2Fvideo_1.mp4?token=6504c93e-6dc3-423b-aff1-1e594711ba30",
              surfaceUrl:
                "https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg",
            },
          ],
          videoUrl:
            "https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-o7oax/template_source%2Fvideo_1.mp4?token=6504c93e-6dc3-423b-aff1-1e594711ba30",
          coverUrl:
            "https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg",
          videoDuration: 48234,
          navInfo: {
            setting:
              '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
          },
          author: {
            authorId: "author_4",
            authorNickName: "4号选手",
            authorIcon:
              "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_4.jpg",
            authorDesc: "",
            authorIp: "福建",
            watchers: ["001"],
            followers: ["author_3"],
            likeNum: 36,
            watchersCount: 1,
            followersCount: 1,
          },
          comments: [],
        },
      ],
      extraInfo: {},
    },
    {
      navInfo: {
        setting:
          '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","margin-top":"12","margin-bottom":"24","space":"8"}}]}]}',
      },
      articles: [
        {
          id: "article_10",
          type: 0,
          title: "特朗普将封禁DeepSeek？外交部给出回应",
          createTime: 1751089800000,
          authorId: "author_11",
          markCount: 0,
          recommends: [
            {
              id: "article_8",
              type: 0,
              title: "两个尾号8个“7”的手机号均以200多万拍卖，买家为同一人",
              authorId: "author_3",
              markCount: 0,
              createTime: 1751089800000,
              recommends: [
                { newsId: "article_8", newsType: 1 },
                { newsId: "article_6", newsType: 1 },
              ],
              commentCount: 0,
              isMarked: false,
              shareCount: 12000,
              isLiked: false,
              likeCount: 6000,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg",
                  surfaceUrl: "",
                },
              ],
              richContent:
                '\n                    <div class="content">\n                      <p style="line-height:70px;">两个尾号8个“7”的手机号均以200多万拍卖，买家为同一人</p>\n                      <p style="line-height:70px;">近日，两场备受关注的手机号码拍卖落下帷幕，两个尾号均为 8 个 “7” 的特殊手机号最终成交价均突破 200 万元，更引人注目的是，这两个 “天价手机号” 的买家为同一人。</p>\n                    </p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">据拍卖平台信息显示，这两个手机号分别归属不同运营商，但其号码规律高度相似，均在末尾连续排列 8 个 “7”，属于数字重复且寓意吉祥的 “靓号”。其中，首个手机号的拍卖从起拍价 50 万元开始，经过近 300 次竞价，最终以 218 万元成交；另一个手机号的竞争同样激烈，历经 260 余次出价后，以 209 万元落槌。\n                    </p>\n                    <p style="line-height:70px;">拍卖记录显示，两位买家的注册信息高度吻合，经平台核实确为同一人。对于此次高价购入两个相似靓号的行为，业内人士分析，这类具有独特数字组合的手机号因其稀缺性，长期以来被部分收藏者和商务人士视为身份象征或投资标的。尤其像 8 个 “7” 这样的连号，在全国范围内存量极少，市场流通性低，从而推高了其交易价值。</p>\n                    <p style="line-height:70px;">不过，也有观点认为，手机号的实际使用价值有限，高价拍卖更多反映的是特定群体对数字符号的偏好，投资需谨慎。目前，这两个手机号的过户手续正在办理中，后续是否会再次进入流通市场引发关注</p>\n                    </div>\n                  ',
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_3",
                authorNickName: "3号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_3.jpg",
                authorDesc: "",
                authorIp: "成都",
                watchers: ["001", "author_4"],
                followers: [],
                likeNum: 36,
                watchersCount: 2,
                followersCount: 0,
              },
              comments: [],
            },
            {
              id: "article_9",
              type: 1,
              title:
                "第12波！伊朗猛砸高超弹，400秒击中以色列，撕裂世界第一防空网",
              authorId: "author_4",
              markCount: 0,
              createTime: 1751089800000,
              recommends: [
                { newsId: "article_8", newsType: 1 },
                { newsId: "article_10", newsType: 1 },
              ],
              commentCount: 0,
              likeCount: 6000,
              shareCount: 12000,
              isLiked: false,
              isMarked: false,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/%E7%9F%A9%E5%BD%A2%203416%403x-2.png",
                  surfaceUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/%E7%9F%A9%E5%BD%A2%203416%403x-2.png",
                },
              ],
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_4",
                authorNickName: "4号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_4.jpg",
                authorDesc: "",
                authorIp: "福建",
                watchers: ["001"],
                followers: ["author_3"],
                likeNum: 36,
                watchersCount: 1,
                followersCount: 1,
              },
              comments: [],
            },
          ],
          commentCount: 0,
          likeCount: 6000,
          shareCount: 12000,
          isLiked: false,
          isMarked: false,
          postImgList: [
            {
              picVideoUrl:
                "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_7.jpg",
              surfaceUrl: "",
            },
          ],
          richContent:
            '\n                    <div class="content">\n                      <p style="line-height:70px;">特朗普将封禁DeepSeek？外交部给出回应</p>\n                      <p style="line-height:70px;">3 月 10 日，在外交部例行记者会上，有记者提问，据《华尔街日报》报道，美国总统特朗普正在权衡限制 DeepSeek 的措施，中方对此有何回应？</p>\n                    </p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_7.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">对此，外交部发言人毛宁表示：“我们一贯反对泛化国家安全概念，将经贸和科技问题政治化，我们也将坚定维护中国企业的合法权益。”\n                    </p>\n                    <p style="line-height:70px;">此前，自今年年初 DeepSeek 惊艳亮相、震撼世界以来，美国就一直在想方设法打压 DeepSeek，以遏制中国在人工智能技术上的发展。当地时间 1 月 28 日，美国多名官员表示 DeepSeek 是 “偷窃”，正对其影响开展国家安全调查。1 月 30 日，美国国会众议院首席行政事务官向国会办公室发出通知，警告国会办公室不要使用 DeepSeek 的服务，特朗普还称 DeepSeek 的出现 “给美国相关产业敲响了警钟” 。如今关于特朗普政府将封禁 DeepSeek 的消息传出，引发国际社会广泛关注，后续进展本报将持续跟踪报道。</p>\n                    </div>\n                  ',
          navInfo: {
            setting:
              '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
          },
          author: {
            authorId: "author_11",
            authorNickName: "11号选手",
            authorIcon:
              "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_11.jpg",
            authorDesc: "",
            authorIp: "济南",
            watchers: ["author_1"],
            followers: ["001"],
            likeNum: 36,
            watchersCount: 1,
            followersCount: 1,
          },
          comments: [],
        },
      ],
      extraInfo: {},
    },
    {
      navInfo: {
        setting:
          '{"type":"view","style":{"background-color":"#FFFFFF"},"children":[{"type":"view","style":{"background-color":"#F0F4F6"},"children":[{"type":"Scroll","style":{"background-color":null,"space":8},"children":[{"type":"native","showType":"VerticalBigImageCard","name":"竖图大图","style":{"border-radius":"8","width":"192","height":"256"}}]}]}]}',
      },
      articles: [
        {
          id: "video6",
          type: 1,
          title: "DeepSeek的所谓综合排名以“开创性+跨学科影响+方法论",
          authorId: "author_6",
          createTime: 1754366346094,
          commentCount: 0,
          markCount: 0,
          likeCount: 0,
          shareCount: 0,
          isLiked: false,
          isMarked: false,
          recommends: [
            {
              id: "article_6",
              type: 0,
              title:
                "住建部称住宅层高标准将提至不低于3米，层高低的房子不值钱了？",
              authorId: "author_1",
              markCount: 0,
              recommends: [
                { newsId: "article_8", newsType: 1 },
                { newsId: "article_9", newsType: 1 },
              ],
              createTime: 1751089800000,
              commentCount: 0,
              likeCount: 6000,
              shareCount: 12000,
              isLiked: false,
              isMarked: false,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_1.jpg",
                  surfaceUrl: "",
                },
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_2.jpg",
                  surfaceUrl: "",
                },
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_3.jpg",
                  surfaceUrl: "",
                },
              ],
              richContent:
                '\n                    <div class="content">\n                      <p style="line-height:70px;">住建部称住宅层高标准将提至不低于3米，层高低的房子不值钱了？</p>\n                      <p style="line-height:70px;">在十四届全国人大三次会议民生主题记者会上，住房城乡建设部部长倪虹表示，要加快建设 “好房子”，并将住宅层高标准提高到不低于 3 米。这一政策不仅顺应了百姓对居住品质日益提高的需求，更标志着我国住宅建设从 “住有所居” 迈向 “宜居优居” 的新阶段。</p>\n                    </p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_1.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">提高住宅的层高，可以显著提升居住空间的舒适度，增加净空高度，缓解大户型的空间压抑感，同时也为建筑立面增大开窗采光面积提供了可能性，有利于自然通风，让室内阳光更加充足，让居住环境更加健康舒适。\n                    </p>\n                    <p style="line-height:70px;">随着人们对居住品质追求的不断提升，地暖、新风系统、中央空调等设备逐渐成为改善型住宅的 “标配”。“3 米层高”，能为这些设备提供充足的安装空间，确保设备高效运行，进一步提升室内环境的舒适度。</p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_2.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">可以说，“将住宅层高标准提高到不低于 3 米”，是通过政策引领推动技术创新的重要举措，将鼓励开发企业、设计师探索更人性化的居住空间解决方案，进而推动住宅品质的提升。</p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_3.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">事实上，层高对于房子价值的影响，不能一概而论。房子的价值，受到地段、配套、交通、环境等多种因素的综合影响。即使层高较低，但如果房子位于城市核心地段，周边配套设施完善，交通便利，环境优美，那么其价值依然可能较高。</p>\n                    </div>\n                  ',
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomImageCard","name":"上文下图"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
              },
              author: {
                authorId: "author_1",
                authorNickName: "1号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_1.jpg",
                authorDesc: "",
                authorIp: "北京",
                watchers: ["001", "author_2"],
                followers: ["001", "author_6", "author_7"],
                likeNum: 12,
                watchersCount: 2,
                followersCount: 3,
              },
              comments: [],
            },
            {
              id: "article_7",
              type: 0,
              title: "中国物流与采购联合会：2024年社会物流总额将超360万亿元",
              authorId: "author_2",
              markCount: 0,
              createTime: 1751089800000,
              recommends: [
                { newsId: "article_7", newsType: 1 },
                { newsId: "article_10", newsType: 1 },
              ],
              commentCount: 0,
              likeCount: 6000,
              shareCount: 12000,
              isLiked: false,
              isMarked: false,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new_4.jpg",
                  surfaceUrl: "",
                },
              ],
              richContent:
                '\n                    <div class="content">\n                      <p style="line-height:70px;">中国物流与采购联合会：2024年社会物流总额将超360万亿元</p>\n                      <p style="line-height:70px;">2 月 11 日，中国物流与采购联合会公布 2024 年全年物流运行数据。物流市场规模优势进一步巩固，与产业链协同体系逐步构建，物流需求规模持续扩张，全年全国社会物流总额超 360 万亿元。</p>\n                    </p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new_4.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">2024 年全国社会物流总额，即经济运行中的物流实物量价值总额，为 360.6 万亿元，同比增长 5.8%，比 2023 年加快 0.6 个百分点，全年物流运行总体延续稳中有进的发展态势。\n                    </p>\n                    <p style="line-height:70px;">从物流费用来看，衡量物流运行效率的重要指标 —— 社会物流总费用与 GDP 的比率，降至近年内的最低点，有效降低全社会物流成本行动取得初步成效。2024 年，社会物流总费用与 GDP 的比率为 14.1%，比上年下降 0.3 个百分点。</p>\n                    </div>\n                  ',
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_2",
                authorNickName: "2号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_2.jpg",
                authorDesc: "",
                authorIp: "南京",
                watchers: ["001"],
                followers: ["001", "author_1"],
                likeNum: 24,
                watchersCount: 1,
                followersCount: 2,
              },
              comments: [],
            },
          ],
          postImgList: [
            {
              picVideoUrl:
                "https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-o7oax/template_source%2Fvideo_1.mp4?token=6504c93e-6dc3-423b-aff1-1e594711ba30",
              surfaceUrl:
                "https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg",
            },
          ],
          playCount: "1700",
          videoUrl:
            "https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-o7oax/template_source%2Fvideo_1.mp4?token=6504c93e-6dc3-423b-aff1-1e594711ba30",
          coverUrl:
            "https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg",
          videoType: 1,
          videoDuration: 98005,
          navInfo: {
            setting:
              '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
          },
          author: {
            authorId: "author_6",
            authorNickName: "6号选手",
            authorIcon:
              "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_6.jpg",
            authorDesc: "",
            authorIp: "连云港",
            watchers: ["1"],
            followers: ["001", "author_5"],
            likeNum: 36,
            watchersCount: 1,
            followersCount: 2,
          },
          comments: [],
        },
        {
          id: "video7",
          type: 1,
          title: "综合排名以“开创性+跨学科影响+方法论",
          authorId: "author_7",
          createTime: 1754366346094,
          commentCount: 0,
          markCount: 0,
          likeCount: 0,
          shareCount: 0,
          isLiked: false,
          isMarked: false,
          recommends: [
            {
              id: "article_2",
              type: 0,
              title: "一揽子金融政策打出“组合拳”",
              authorId: "author_2",
              markCount: 0,
              recommends: [
                { newsId: "article_8", newsType: 0 },
                { newsId: "article_9", newsType: 0 },
              ],
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg",
                  surfaceUrl: "",
                },
              ],
              createTime: 1751089800000,
              richContent:
                '\n                    <div class="content">\n                      <p style="line-height:70px;">一揽子金融政策打出“组合拳”</p>\n                      <p style="line-height:70px;">在货币政策方面，自 5 月 15 日起，央行下调金融机构法定存款准备金率 0.5 个百分点，为市场释放出长期流动性，预估金额达万亿元规模。同时，自 5 月 8 日起，政策利率下调 0.1 个百分点，带动贷款市场报价利率（LPR）同步走低，1 年期 LPR 降至 3.0%，5 年期以上 LPR 降至 3.5% 。不仅如此，央行还新增 3000 亿元科技创新和技术改造再贷款额度，下调结构性货币政策工具利率 0.25 个百分点，进一步优化金融资源配置，助力科技创新与产业升级。</p>\n                    </p>\n                    <p style="line-height:70px;">针对房地产市场，相关部门加快构建适配房地产发展新模式的融资制度，优化住房公积金贷款政策，自 5 月 8 日起，个人住房公积金贷款利率下调 0.25 个百分点，切实减轻购房者负担，促进房地产市场平稳健康发展。。\n                    </p>\n                    <p style="line-height:70px;">资本市场层面，全力支持中央汇金公司发挥类 “平准基金” 作用，稳定市场信心。同时，优化资本市场工具，大力推动险资、公募基金等中长期资金入市，完善资本市场生态，提升市场韧性与活力。</p>\n                    <p style="line-height:70px;">在助力小微企业与民营企业发展上，监管部门积极行动，推出支持小微企业、民营企业融资的一揽子政策，并增设支农支小再贷款额度 3000 亿元，切实缓解中小企业融资难题。此外，针对受外部冲击较大的外贸企业，银行业保险业也出台系列护航政策，帮扶企业稳定经营，开拓市场。</p>\n                    <p style="line-height:70px;">中国人民银行副行长邹澜在国新办发布会上强调，后续将持续实施适度宽松的货币政策，密切关注政策传导效果与结构优化，引导金融资源精准流向经济增长的关键领域与薄弱环节。众多业内专家普遍认为，此次一揽子金融政策覆盖全面、力度空前，各政策协同联动，将为实体经济注入强劲动力，有效稳定市场预期，推动经济持续回升向好。随着政策逐步落地见效，企业融资环境有望持续改善，消费与投资活力将进一步释放，为我国经济高质量发展筑牢根基</p>\n                    </div>\n                  ',
              commentCount: 2,
              isLiked: false,
              likeCount: 6000,
              shareCount: 12000,
              isMarked: false,
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_2",
                authorNickName: "2号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_2.jpg",
                authorDesc: "",
                authorIp: "南京",
                watchers: ["001"],
                followers: ["001", "author_1"],
                likeNum: 24,
                watchersCount: 1,
                followersCount: 2,
              },
              comments: [],
            },
            {
              id: "article_5",
              type: 0,
              title: "2025年社会物流总额将超360万亿元",
              authorId: "author_5",
              markCount: 0,
              recommends: [
                { newsId: "article_7", newsType: 0 },
                { newsId: "article_8", newsType: 0 },
              ],
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_4.jpg",
                  surfaceUrl: "",
                },
              ],
              createTime: 1751089800000,
              richContent:
                '\n                    <div class="content">\n                      <p style="line-height:70px;">2025年社会物流总额将超360万亿元</p>\n                      <p  style="line-height:70px;">中国物流与采购联合会发布的最新数据显示，2025 年我国社会物流总额有望突破 360 万亿元大关，展现出物流行业的强劲增长态势。这一数据不仅反映了国内经济的稳定复苏和市场活力的不断释放，也彰显了物流行业在推动经济高质量发展中的重要作用。</p>\n                    </p>\n                    <p style="line-height:70px;">中国物流与采购联合会发布的最新数据显示，2025 年我国社会物流总额有望突破 360 万亿元大关，展现出物流行业的强劲增长态势。这一数据不仅反映了国内经济的稳定复苏和市场活力的不断释放，也彰显了物流行业在推动经济高质量发展中的重要作用。2025 年前五个月，全国社会物流总额已达 138.7 万亿元，同比增长 5.3%，增速较去年同期有所加快。这一增长势头得益于国内一系列促进消费和投资的政策举措，有效拉动了物流需求。特别是在单位与居民物品物流领域，前五月增长 6.4%，单月同比增速在 5 月更是攀升至 8.3%，较上月提高 2.1 个百分点，显示出消费市场的旺盛活力。\n                    </p>\n                    <p style="line-height:70px;">消费市场的繁荣是推动物流总额增长的重要动力。节日经济与各类促销活动相互叠加，直播电商、即时零售等新兴消费模式蓬勃发展，有力推动了消费品物流的高效运转。据统计，今年上半年实物商品网上零售额同比增长 6.3%，促使消费品物流效率显著提升。同时，产业升级进程的加快，使得高端制造业、新能源等领域对物流服务的需求呈现出多样化、精细化趋势，进一步拉动了社会物流总额的增长。</p>\n                    </div>\n                  ',
              shareCount: 12000,
              commentCount: 0,
              isLiked: false,
              likeCount: 6000,
              isMarked: false,
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_5",
                authorNickName: "5号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_5.jpg",
                authorDesc: "",
                authorIp: "深圳",
                watchers: ["001", "author_6"],
                followers: [],
                likeNum: 36,
                watchersCount: 2,
                followersCount: 0,
              },
              comments: [],
            },
          ],
          postImgList: [
            {
              picVideoUrl:
                "https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-o7oax/template_source%2Fvideo_1.mp4?token=6504c93e-6dc3-423b-aff1-1e594711ba30",
              surfaceUrl:
                "https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg",
            },
          ],
          playCount: "45000",
          videoUrl:
            "https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-o7oax/template_source%2Fvideo_1.mp4?token=6504c93e-6dc3-423b-aff1-1e594711ba30",
          coverUrl:
            "https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg",
          videoType: 1,
          videoDuration: 48234,
          navInfo: {
            setting:
              '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
          },
          author: {
            authorId: "author_7",
            authorNickName: "7号选手",
            authorIcon:
              "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_7.jpg",
            authorDesc: "",
            authorIp: "济南",
            watchers: ["author_1"],
            followers: ["001"],
            likeNum: 36,
            watchersCount: 1,
            followersCount: 1,
          },
          comments: [],
        },
      ],
      extraInfo: {},
    },
    {
      navInfo: {
        setting:
          '{"type":"view","children":[{"type":"native","showType":"AdvertisementCard","name":"横幅广告"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}',
      },
      articles: [],
      extraInfo: {},
    },
    {
      navInfo: {
        setting:
          '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
      articles: [
        {
          id: "post_1",
          type: 2,
          likeCount: 36,
          commentCount: 1,
          shareCount: 12000,
          isLiked: false,
          isMarked: false,
          markCount: 4500,
          recommends: [
            {
              id: "article_11",
              type: 1,
              title: "DeepSeek的所谓综合排名以“开创性+跨学科影响+方法论",
              createTime: 1751089800000,
              authorId: "author_10",
              markCount: 0,
              recommends: [
                { newsId: "article_12", newsType: 1 },
                { newsId: "article_13", newsType: 1 },
              ],
              commentCount: 1,
              likeCount: 6000,
              shareCount: 12000,
              isLiked: false,
              isMarked: false,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/1.png",
                  surfaceUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/1.png",
                },
              ],
              richContent: "",
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_10",
                authorNickName: "10号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_10.jpg",
                authorDesc: "",
                authorIp: "济南",
                watchers: ["author_1"],
                followers: ["001"],
                likeNum: 36,
                watchersCount: 1,
                followersCount: 1,
              },
              comments: [],
            },
          ],
          title:
            "假期的旅行碎片已加载完毕～。旅行哪里是逃离呀，分明是让你在人山人海里，重新找到自己的位置，原来旅行的意义，真的藏在那些不期而遇里，走在陌生的街道，看当地人慢悠悠地喝茶，突然懂了 “慢下来” 不是浪费时，原来自己比想象中更有韧性呀。",
          richContent: "",
          authorId: "author_6",
          createTime: 1751089800000,
          postImgList: [
            {
              picVideoUrl:
                "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_2.jpg",
              surfaceUrl: "",
            },
            {
              picVideoUrl:
                "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_8.jpg",
              surfaceUrl: "",
            },
            {
              picVideoUrl:
                "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_3.jpg",
              surfaceUrl: "",
            },
            {
              picVideoUrl:
                "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_5.jpg",
              surfaceUrl: "",
            },
            {
              picVideoUrl:
                "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_4.jpg",
              surfaceUrl: "",
            },
            {
              picVideoUrl:
                "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_6.jpg",
              surfaceUrl: "",
            },
            {
              picVideoUrl:
                "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_10.jpg",
              surfaceUrl: "",
            },
            {
              picVideoUrl:
                "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_7.jpg",
              surfaceUrl: "",
            },
            {
              picVideoUrl:
                "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_9.jpg",
              surfaceUrl: "",
            },
          ],
          navInfo: {
            setting:
              '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","padding-top":"12"}}]}]}',
          },
          author: {
            authorId: "author_6",
            authorNickName: "6号选手",
            authorIcon:
              "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_6.jpg",
            authorDesc: "",
            authorIp: "连云港",
            watchers: ["1"],
            followers: ["001", "author_5"],
            likeNum: 36,
            watchersCount: 1,
            followersCount: 2,
          },
          comments: [],
        },
      ],
      extraInfo: {},
    },
    {
      navInfo: {
        setting:
          '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
      articles: [
        {
          id: "post_2",
          type: 2,
          likeCount: 36,
          commentCount: 0,
          shareCount: 12000,
          isLiked: false,
          isMarked: false,
          markCount: 4500,
          recommends: [
            {
              id: "article_8",
              type: 0,
              title: "两个尾号8个“7”的手机号均以200多万拍卖，买家为同一人",
              authorId: "author_3",
              markCount: 0,
              createTime: 1751089800000,
              recommends: [
                { newsId: "article_8", newsType: 1 },
                { newsId: "article_6", newsType: 1 },
              ],
              commentCount: 0,
              isMarked: false,
              shareCount: 12000,
              isLiked: false,
              likeCount: 6000,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg",
                  surfaceUrl: "",
                },
              ],
              richContent:
                '\n                    <div class="content">\n                      <p style="line-height:70px;">两个尾号8个“7”的手机号均以200多万拍卖，买家为同一人</p>\n                      <p style="line-height:70px;">近日，两场备受关注的手机号码拍卖落下帷幕，两个尾号均为 8 个 “7” 的特殊手机号最终成交价均突破 200 万元，更引人注目的是，这两个 “天价手机号” 的买家为同一人。</p>\n                    </p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">据拍卖平台信息显示，这两个手机号分别归属不同运营商，但其号码规律高度相似，均在末尾连续排列 8 个 “7”，属于数字重复且寓意吉祥的 “靓号”。其中，首个手机号的拍卖从起拍价 50 万元开始，经过近 300 次竞价，最终以 218 万元成交；另一个手机号的竞争同样激烈，历经 260 余次出价后，以 209 万元落槌。\n                    </p>\n                    <p style="line-height:70px;">拍卖记录显示，两位买家的注册信息高度吻合，经平台核实确为同一人。对于此次高价购入两个相似靓号的行为，业内人士分析，这类具有独特数字组合的手机号因其稀缺性，长期以来被部分收藏者和商务人士视为身份象征或投资标的。尤其像 8 个 “7” 这样的连号，在全国范围内存量极少，市场流通性低，从而推高了其交易价值。</p>\n                    <p style="line-height:70px;">不过，也有观点认为，手机号的实际使用价值有限，高价拍卖更多反映的是特定群体对数字符号的偏好，投资需谨慎。目前，这两个手机号的过户手续正在办理中，后续是否会再次进入流通市场引发关注</p>\n                    </div>\n                  ',
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_3",
                authorNickName: "3号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_3.jpg",
                authorDesc: "",
                authorIp: "成都",
                watchers: ["001", "author_4"],
                followers: [],
                likeNum: 36,
                watchersCount: 2,
                followersCount: 0,
              },
              comments: [],
            },
          ],
          title: "#旅行的意义 #在路上",
          richContent: "",
          authorId: "author_6",
          createTime: 1751089800000,
          postImgList: [
            {
              picVideoUrl:
                "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_11.jpg",
              surfaceUrl: "",
            },
          ],
          navInfo: {
            setting:
              '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","padding-top":"12"}}]}]}',
          },
          author: {
            authorId: "author_6",
            authorNickName: "6号选手",
            authorIcon:
              "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_6.jpg",
            authorDesc: "",
            authorIp: "连云港",
            watchers: ["1"],
            followers: ["001", "author_5"],
            likeNum: 36,
            watchersCount: 1,
            followersCount: 2,
          },
          comments: [],
        },
      ],
      extraInfo: {},
    },
    {
      navInfo: {
        setting:
          '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
      articles: [
        {
          id: "video1",
          type: 1,
          title: "新通话，让每一次连接超越想象",
          authorId: "author_1",
          createTime: 1754366346094,
          commentCount: 4,
          markCount: 0,
          likeCount: 0,
          shareCount: 0,
          isLiked: false,
          isMarked: false,
          recommends: [
            {
              id: "article_10",
              type: 0,
              title: "特朗普将封禁DeepSeek？外交部给出回应",
              createTime: 1751089800000,
              authorId: "author_11",
              markCount: 0,
              recommends: [
                { newsId: "article_8", newsType: 1 },
                { newsId: "article_9", newsType: 1 },
              ],
              commentCount: 0,
              likeCount: 6000,
              shareCount: 12000,
              isLiked: false,
              isMarked: false,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_7.jpg",
                  surfaceUrl: "",
                },
              ],
              richContent:
                '\n                    <div class="content">\n                      <p style="line-height:70px;">特朗普将封禁DeepSeek？外交部给出回应</p>\n                      <p style="line-height:70px;">3 月 10 日，在外交部例行记者会上，有记者提问，据《华尔街日报》报道，美国总统特朗普正在权衡限制 DeepSeek 的措施，中方对此有何回应？</p>\n                    </p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_7.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">对此，外交部发言人毛宁表示：“我们一贯反对泛化国家安全概念，将经贸和科技问题政治化，我们也将坚定维护中国企业的合法权益。”\n                    </p>\n                    <p style="line-height:70px;">此前，自今年年初 DeepSeek 惊艳亮相、震撼世界以来，美国就一直在想方设法打压 DeepSeek，以遏制中国在人工智能技术上的发展。当地时间 1 月 28 日，美国多名官员表示 DeepSeek 是 “偷窃”，正对其影响开展国家安全调查。1 月 30 日，美国国会众议院首席行政事务官向国会办公室发出通知，警告国会办公室不要使用 DeepSeek 的服务，特朗普还称 DeepSeek 的出现 “给美国相关产业敲响了警钟” 。如今关于特朗普政府将封禁 DeepSeek 的消息传出，引发国际社会广泛关注，后续进展本报将持续跟踪报道。</p>\n                    </div>\n                  ',
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_11",
                authorNickName: "11号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_11.jpg",
                authorDesc: "",
                authorIp: "济南",
                watchers: ["author_1"],
                followers: ["001"],
                likeNum: 36,
                watchersCount: 1,
                followersCount: 1,
              },
              comments: [],
            },
            {
              id: "article_11",
              type: 1,
              title: "DeepSeek的所谓综合排名以“开创性+跨学科影响+方法论",
              createTime: 1751089800000,
              authorId: "author_10",
              markCount: 0,
              recommends: [
                { newsId: "article_12", newsType: 1 },
                { newsId: "article_13", newsType: 1 },
              ],
              commentCount: 1,
              likeCount: 6000,
              shareCount: 12000,
              isLiked: false,
              isMarked: false,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/1.png",
                  surfaceUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/1.png",
                },
              ],
              richContent: "",
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_10",
                authorNickName: "10号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_10.jpg",
                authorDesc: "",
                authorIp: "济南",
                watchers: ["author_1"],
                followers: ["001"],
                likeNum: 36,
                watchersCount: 1,
                followersCount: 1,
              },
              comments: [],
            },
          ],
          postImgList: [
            {
              picVideoUrl:
                "https://www-file.huawei.com/admin/asset/v1/pro/view/a20e0965e56a4dc498fc33ee23750c0d.mp4",
              surfaceUrl:
                "https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg",
            },
          ],
          videoUrl:
            "https://www-file.huawei.com/admin/asset/v1/pro/view/a20e0965e56a4dc498fc33ee23750c0d.mp4",
          coverUrl:
            "https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg",
          videoType: 1,
          videoDuration: 134506,
          navInfo: {
            setting:
              '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
          },
          author: {
            authorId: "author_1",
            authorNickName: "1号选手",
            authorIcon:
              "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_1.jpg",
            authorDesc: "",
            authorIp: "北京",
            watchers: ["001", "author_2"],
            followers: ["001", "author_6", "author_7"],
            likeNum: 12,
            watchersCount: 2,
            followersCount: 3,
          },
          comments: [],
        },
      ],
      extraInfo: {},
    },
    {
      navInfo: {
        setting:
          '{"type":"view","children":[{"type":"native","showType":"AdvertisementCard","name":"横幅广告"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}',
      },
      articles: [],
      extraInfo: {},
    },
    {
      navInfo: {
        setting:
          '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
      articles: [
        {
          id: "video2",
          type: 1,
          title: "以行践言，让科技与自然共生",
          authorId: "author_2",
          createTime: 1754366346094,
          commentCount: 0,
          markCount: 0,
          likeCount: 0,
          shareCount: 0,
          isLiked: false,
          isMarked: false,
          recommends: [
            {
              id: "article_10",
              type: 0,
              title: "特朗普将封禁DeepSeek？外交部给出回应",
              createTime: 1751089800000,
              authorId: "author_11",
              markCount: 0,
              recommends: [
                { newsId: "article_8", newsType: 1 },
                { newsId: "article_9", newsType: 1 },
              ],
              commentCount: 0,
              likeCount: 6000,
              shareCount: 12000,
              isLiked: false,
              isMarked: false,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_7.jpg",
                  surfaceUrl: "",
                },
              ],
              richContent:
                '\n                    <div class="content">\n                      <p style="line-height:70px;">特朗普将封禁DeepSeek？外交部给出回应</p>\n                      <p style="line-height:70px;">3 月 10 日，在外交部例行记者会上，有记者提问，据《华尔街日报》报道，美国总统特朗普正在权衡限制 DeepSeek 的措施，中方对此有何回应？</p>\n                    </p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_7.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">对此，外交部发言人毛宁表示：“我们一贯反对泛化国家安全概念，将经贸和科技问题政治化，我们也将坚定维护中国企业的合法权益。”\n                    </p>\n                    <p style="line-height:70px;">此前，自今年年初 DeepSeek 惊艳亮相、震撼世界以来，美国就一直在想方设法打压 DeepSeek，以遏制中国在人工智能技术上的发展。当地时间 1 月 28 日，美国多名官员表示 DeepSeek 是 “偷窃”，正对其影响开展国家安全调查。1 月 30 日，美国国会众议院首席行政事务官向国会办公室发出通知，警告国会办公室不要使用 DeepSeek 的服务，特朗普还称 DeepSeek 的出现 “给美国相关产业敲响了警钟” 。如今关于特朗普政府将封禁 DeepSeek 的消息传出，引发国际社会广泛关注，后续进展本报将持续跟踪报道。</p>\n                    </div>\n                  ',
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_11",
                authorNickName: "11号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_11.jpg",
                authorDesc: "",
                authorIp: "济南",
                watchers: ["author_1"],
                followers: ["001"],
                likeNum: 36,
                watchersCount: 1,
                followersCount: 1,
              },
              comments: [],
            },
            {
              id: "article_11",
              type: 1,
              title: "DeepSeek的所谓综合排名以“开创性+跨学科影响+方法论",
              createTime: 1751089800000,
              authorId: "author_10",
              markCount: 0,
              recommends: [
                { newsId: "article_12", newsType: 1 },
                { newsId: "article_13", newsType: 1 },
              ],
              commentCount: 1,
              likeCount: 6000,
              shareCount: 12000,
              isLiked: false,
              isMarked: false,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/1.png",
                  surfaceUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/1.png",
                },
              ],
              richContent: "",
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_10",
                authorNickName: "10号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_10.jpg",
                authorDesc: "",
                authorIp: "济南",
                watchers: ["author_1"],
                followers: ["001"],
                likeNum: 36,
                watchersCount: 1,
                followersCount: 1,
              },
              comments: [],
            },
          ],
          postImgList: [
            {
              picVideoUrl:
                "https://www-file.huawei.com/admin/asset/v1/pro/view/daa381bc66604878bd403ef77c1c458d.mp4",
              surfaceUrl:
                "https://www-file.huawei.com/admin/asset/v1/pro/view/935d7a0c9e4a41db95de250a004ce6a7.jpg",
            },
          ],
          videoUrl:
            "https://www-file.huawei.com/admin/asset/v1/pro/view/daa381bc66604878bd403ef77c1c458d.mp4",
          coverUrl:
            "https://www-file.huawei.com/admin/asset/v1/pro/view/935d7a0c9e4a41db95de250a004ce6a7.jpg",
          videoType: 1,
          videoDuration: 204800,
          navInfo: {
            setting:
              '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
          },
          author: {
            authorId: "author_2",
            authorNickName: "2号选手",
            authorIcon:
              "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_2.jpg",
            authorDesc: "",
            authorIp: "南京",
            watchers: ["001"],
            followers: ["001", "author_1"],
            likeNum: 24,
            watchersCount: 1,
            followersCount: 2,
          },
          comments: [],
        },
      ],
      extraInfo: {},
    },
    {
      navInfo: {
        setting:
          '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
      articles: [
        {
          id: "video3",
          type: 1,
          title: "用科技为黄河三角洲鸟类生态保护开创更多可能",
          authorId: "author_3",
          createTime: 1754366346094,
          commentCount: 0,
          markCount: 0,
          likeCount: 0,
          shareCount: 0,
          isLiked: false,
          isMarked: false,
          recommends: [
            {
              id: "article_8",
              type: 0,
              title: "两个尾号8个“7”的手机号均以200多万拍卖，买家为同一人",
              authorId: "author_3",
              markCount: 0,
              createTime: 1751089800000,
              recommends: [
                { newsId: "article_8", newsType: 1 },
                { newsId: "article_6", newsType: 1 },
              ],
              commentCount: 0,
              isMarked: false,
              shareCount: 12000,
              isLiked: false,
              likeCount: 6000,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg",
                  surfaceUrl: "",
                },
              ],
              richContent:
                '\n                    <div class="content">\n                      <p style="line-height:70px;">两个尾号8个“7”的手机号均以200多万拍卖，买家为同一人</p>\n                      <p style="line-height:70px;">近日，两场备受关注的手机号码拍卖落下帷幕，两个尾号均为 8 个 “7” 的特殊手机号最终成交价均突破 200 万元，更引人注目的是，这两个 “天价手机号” 的买家为同一人。</p>\n                    </p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">据拍卖平台信息显示，这两个手机号分别归属不同运营商，但其号码规律高度相似，均在末尾连续排列 8 个 “7”，属于数字重复且寓意吉祥的 “靓号”。其中，首个手机号的拍卖从起拍价 50 万元开始，经过近 300 次竞价，最终以 218 万元成交；另一个手机号的竞争同样激烈，历经 260 余次出价后，以 209 万元落槌。\n                    </p>\n                    <p style="line-height:70px;">拍卖记录显示，两位买家的注册信息高度吻合，经平台核实确为同一人。对于此次高价购入两个相似靓号的行为，业内人士分析，这类具有独特数字组合的手机号因其稀缺性，长期以来被部分收藏者和商务人士视为身份象征或投资标的。尤其像 8 个 “7” 这样的连号，在全国范围内存量极少，市场流通性低，从而推高了其交易价值。</p>\n                    <p style="line-height:70px;">不过，也有观点认为，手机号的实际使用价值有限，高价拍卖更多反映的是特定群体对数字符号的偏好，投资需谨慎。目前，这两个手机号的过户手续正在办理中，后续是否会再次进入流通市场引发关注</p>\n                    </div>\n                  ',
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_3",
                authorNickName: "3号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_3.jpg",
                authorDesc: "",
                authorIp: "成都",
                watchers: ["001", "author_4"],
                followers: [],
                likeNum: 36,
                watchersCount: 2,
                followersCount: 0,
              },
              comments: [],
            },
            {
              id: "article_10",
              type: 0,
              title: "特朗普将封禁DeepSeek？外交部给出回应",
              createTime: 1751089800000,
              authorId: "author_11",
              markCount: 0,
              recommends: [
                { newsId: "article_8", newsType: 1 },
                { newsId: "article_9", newsType: 1 },
              ],
              commentCount: 0,
              likeCount: 6000,
              shareCount: 12000,
              isLiked: false,
              isMarked: false,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_7.jpg",
                  surfaceUrl: "",
                },
              ],
              richContent:
                '\n                    <div class="content">\n                      <p style="line-height:70px;">特朗普将封禁DeepSeek？外交部给出回应</p>\n                      <p style="line-height:70px;">3 月 10 日，在外交部例行记者会上，有记者提问，据《华尔街日报》报道，美国总统特朗普正在权衡限制 DeepSeek 的措施，中方对此有何回应？</p>\n                    </p>\n                    <image class="image-preview"\n                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_7.jpg"\n                      style="width: 100%;" />\n                    <p style="line-height:70px;">对此，外交部发言人毛宁表示：“我们一贯反对泛化国家安全概念，将经贸和科技问题政治化，我们也将坚定维护中国企业的合法权益。”\n                    </p>\n                    <p style="line-height:70px;">此前，自今年年初 DeepSeek 惊艳亮相、震撼世界以来，美国就一直在想方设法打压 DeepSeek，以遏制中国在人工智能技术上的发展。当地时间 1 月 28 日，美国多名官员表示 DeepSeek 是 “偷窃”，正对其影响开展国家安全调查。1 月 30 日，美国国会众议院首席行政事务官向国会办公室发出通知，警告国会办公室不要使用 DeepSeek 的服务，特朗普还称 DeepSeek 的出现 “给美国相关产业敲响了警钟” 。如今关于特朗普政府将封禁 DeepSeek 的消息传出，引发国际社会广泛关注，后续进展本报将持续跟踪报道。</p>\n                    </div>\n                  ',
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_11",
                authorNickName: "11号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_11.jpg",
                authorDesc: "",
                authorIp: "济南",
                watchers: ["author_1"],
                followers: ["001"],
                likeNum: 36,
                watchersCount: 1,
                followersCount: 1,
              },
              comments: [],
            },
          ],
          postImgList: [
            {
              picVideoUrl:
                "https://www-file.huawei.com/admin/asset/v1/pro/view/95c55588cbdb4b999eeae0c069dbc5d9.mp4",
              surfaceUrl:
                "https://www-file.huawei.com/admin/asset/v1/pro/view/eb8efe3c1000428e8619a47c1e110922.jpg",
            },
          ],
          videoUrl:
            "https://www-file.huawei.com/admin/asset/v1/pro/view/95c55588cbdb4b999eeae0c069dbc5d9.mp4",
          coverUrl:
            "https://www-file.huawei.com/admin/asset/v1/pro/view/eb8efe3c1000428e8619a47c1e110922.jpg",
          videoType: 1,
          navInfo: {
            setting:
              '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
          },
          videoDuration: 371605,
          author: {
            authorId: "author_3",
            authorNickName: "3号选手",
            authorIcon:
              "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_3.jpg",
            authorDesc: "",
            authorIp: "成都",
            watchers: ["001", "author_4"],
            followers: [],
            likeNum: 36,
            watchersCount: 2,
            followersCount: 0,
          },
          comments: [],
        },
      ],
      extraInfo: {},
    },
    {
      navInfo: {
        setting:
          '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
      articles: [
        {
          id: "video4",
          type: 1,
          title:
            "《华为逆行者》科摩罗篇：驻守火山岛，他们是联接科摩罗群岛的信使",
          authorId: "author_4",
          createTime: 1754366346094,
          commentCount: 0,
          markCount: 0,
          likeCount: 0,
          shareCount: 0,
          isLiked: false,
          isMarked: false,
          recommends: [
            {
              id: "article_9",
              type: 1,
              title:
                "第12波！伊朗猛砸高超弹，400秒击中以色列，撕裂世界第一防空网",
              authorId: "author_4",
              markCount: 0,
              createTime: 1751089800000,
              recommends: [
                { newsId: "article_8", newsType: 1 },
                { newsId: "article_10", newsType: 1 },
              ],
              commentCount: 0,
              likeCount: 6000,
              shareCount: 12000,
              isLiked: false,
              isMarked: false,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/%E7%9F%A9%E5%BD%A2%203416%403x-2.png",
                  surfaceUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/%E7%9F%A9%E5%BD%A2%203416%403x-2.png",
                },
              ],
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_4",
                authorNickName: "4号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_4.jpg",
                authorDesc: "",
                authorIp: "福建",
                watchers: ["001"],
                followers: ["author_3"],
                likeNum: 36,
                watchersCount: 1,
                followersCount: 1,
              },
              comments: [],
            },
            {
              id: "article_11",
              type: 1,
              title: "DeepSeek的所谓综合排名以“开创性+跨学科影响+方法论",
              createTime: 1751089800000,
              authorId: "author_10",
              markCount: 0,
              recommends: [
                { newsId: "article_12", newsType: 1 },
                { newsId: "article_13", newsType: 1 },
              ],
              commentCount: 1,
              likeCount: 6000,
              shareCount: 12000,
              isLiked: false,
              isMarked: false,
              postImgList: [
                {
                  picVideoUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/1.png",
                  surfaceUrl:
                    "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/1.png",
                },
              ],
              richContent: "",
              navInfo: {
                setting:
                  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
              },
              author: {
                authorId: "author_10",
                authorNickName: "10号选手",
                authorIcon:
                  "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_10.jpg",
                authorDesc: "",
                authorIp: "济南",
                watchers: ["author_1"],
                followers: ["001"],
                likeNum: 36,
                watchersCount: 1,
                followersCount: 1,
              },
              comments: [],
            },
          ],
          postImgList: [
            {
              picVideoUrl:
                "https://www-file.huawei.com/admin/asset/v1/pro/view/73253951779340a39a7763e29f40ccb8.mp4",
              surfaceUrl:
                "https://www-file.huawei.com/admin/asset/v1/pro/view/ca03b4509af94cadbdde656fd9cd23ef.jpg",
            },
          ],
          videoUrl:
            "https://www-file.huawei.com/admin/asset/v1/pro/view/73253951779340a39a7763e29f40ccb8.mp4",
          coverUrl:
            "https://www-file.huawei.com/admin/asset/v1/pro/view/ca03b4509af94cadbdde656fd9cd23ef.jpg",
          videoType: 1,
          videoDuration: 405504,
          navInfo: {
            setting:
              '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
          },
          author: {
            authorId: "author_4",
            authorNickName: "4号选手",
            authorIcon:
              "https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_4.jpg",
            authorDesc: "",
            authorIp: "福建",
            watchers: ["001"],
            followers: ["author_3"],
            likeNum: 36,
            watchersCount: 1,
            followersCount: 1,
          },
          comments: [],
        },
      ],
      extraInfo: {},
    },
  ];
  logger.info(`tableTitleArr: ${recommendList}`);
  let result = { hmSystem, recommendList };
  let res = new context.HTTPResponse(
    result,
    {
      "faas-content-type": "json",
    },
    "application/json",
    "200"
  );

  callback(res);
};

module.exports.myHandler = myHandler;
