import { NewsEnum } from '../../constants/Constants';
import { BaseNews } from '../../database/NewsType';

export class MockArticle {
  static list: BaseNews[] = [
    {
      id: 'article_1',
      type: NewsEnum.Article,
      title: '中方决定同意与美方进行接触',
      tags: ['中方', '美方', '建筑', '地产'],
      authorId: '001',
      markCount: 0,
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_3.jpg',
          surfaceUrl: '',
        },
      ],
      recommends: [{
        newsId: 'article_6',
        newsType: 1,
      }, {
        newsId: 'article_7',
        newsType: 1,
      }],
      richContent: `
                   <div class="content">
                      <p style="line-height:35px;">中方决定同意与美方进行接触
                      <p style="line-height:35px;">30个开拍地块中，有8个因触及“竞地价+竞公共租赁住房面积”或“竞地价+竞政府持有商品住宅产权份额”等上限后转入“竞高标准商品住宅建设方案”环节，最终，通过评选组评分确定了8宗商品住宅用地竞得人。</p>
                    <p style="line-height:35px;">根据挂牌文件中的《高标准商品住宅建设方案评审内容和评分标准》（以下简称《评分标准》），高标准商品住宅的评分内容包括两个篇章：建筑品质和建筑规划设计，每篇章占比50%，每个篇章下又设置细分指标及对应得分项，累计后就是各个投报方案的最终得分。。
                    </p>
                    <p style="line-height:35px;">建筑品质篇主要指向四项建筑技术，包括绿色建筑、装配式建筑、健康建筑和超低能耗技术。</p>
                    </div>
                  `,
      createTime: 1751089800000,
      commentCount: 25,
      likeCount: 6000,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
      },
    },
    {
      id: 'article_2',
      type: NewsEnum.Article,
      title: '一揽子金融政策打出“组合拳”',
      tags: ['金融', '政治', '国家', '货币'],
      authorId: 'author_2',
      markCount: 0,
      recommends: [{
        newsId: 'article_8',
        newsType: 0,
      }, {
        newsId: 'article_9',
        newsType: 0,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg',
          surfaceUrl: '',
        },
      ],
      createTime: 1751089800000,
      richContent: `
            <div class="content">
              <p style="line-height: 35px">一揽子金融政策打出“组合拳”</p>
              <p style="line-height: 35px">
                在货币政策方面，自 5 月 15 日起，央行下调金融机构法定存款准备金率 0.5
                个百分点，为市场释放出长期流动性，预估金额达万亿元规模。同时，自 5 月 8
                日起，政策利率下调 0.1 个百分点，带动贷款市场报价利率（LPR）同步走低，1
                年期 LPR 降至 3.0%，5 年期以上 LPR 降至 3.5% 。不仅如此，央行还新增 3000
                亿元科技创新和技术改造再贷款额度，下调结构性货币政策工具利率 0.25
                个百分点，进一步优化金融资源配置，助力科技创新与产业升级。
              </p>
              <p style="line-height: 35px">
                针对房地产市场，相关部门加快构建适配房地产发展新模式的融资制度，优化住房公积金贷款政策，自
                5 月 8 日起，个人住房公积金贷款利率下调 0.25
                个百分点，切实减轻购房者负担，促进房地产市场平稳健康发展。。
              </p>
              <div>
                <p style="line-height: 35px">
                  资本市场层面，全力支持中央汇金公司发挥类 “平准基金”
                  作用，稳定市场信心。同时，优化资本市场工具，大力推动险资、公募基金等中长期资金入市，完善资本市场生态，提升市场韧性与活力。
                </p>
                <p style="line-height: 35px">
                  在助力小微企业与民营企业发展上，监管部门积极行动，推出支持小微企业、民营企业融资的一揽子政策，并增设支农支小再贷款额度
                  3000
                  亿元，切实缓解中小企业融资难题。此外，针对受外部冲击较大的外贸企业，银行业保险业也出台系列护航政策，帮扶企业稳定经营，开拓市场。
                </p>
                <p style="line-height: 35px">
                  中国人民银行副行长邹澜在国新办发布会上强调，后续将持续实施适度宽松的货币政策，密切关注政策传导效果与结构优化，引导金融资源精准流向经济增长的关键领域与薄弱环节。众多业内专家普遍认为，此次一揽子金融政策覆盖全面、力度空前，各政策协同联动，将为实体经济注入强劲动力，有效稳定市场预期，推动经济持续回升向好。随着政策逐步落地见效，企业融资环境有望持续改善，消费与投资活力将进一步释放，为我国经济高质量发展筑牢根基
                </p>
              </div>
                  `,
      commentCount: 25,
      isLiked: false,
      likeCount: 6000,
      shareCount: 12000,
      isMarked: false,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
      },
    },
    {
      id: 'article_3',
      type: NewsEnum.Article,
      title: '中俄两国走出一条合作共赢的崭新道路',
      tags: ['国际形势', '合作共赢', '新道路', '政治'],
      authorId: 'author_3',
      markCount: 0,
      recommends: [{
        newsId: 'article_9',
        newsType: 0,
      }, {
        newsId: 'article_11',
        newsType: 0,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_1.jpg',
          surfaceUrl: '',
        },
      ],
      createTime: 1751089800000,
      richContent: `
                    <div class="content">
                      <p style="line-height:35px;">中俄两国走出一条合作共赢的崭新道路</p>
                      <p style="line-height:35px;">近年来，中俄两国在多方面的紧密协作下，成功走出了一条合作共赢的崭新道路，为世界各国间的友好交往与合作树立了典范。</p>
                    <p style="line-height:35px;">在政治领域，中俄双方始终保持着高度的互信与频繁的高层互动。两国领导人多次会晤，就双边关系和重大国际问题深入交换意见，为两国合作指明方向。双方秉持不结盟、不对抗、不针对第三方的原则，坚定支持彼此维护本国核心利益和发展道路。在国际事务中，中俄在联合国、上海合作组织、金砖国家等多边机制内密切配合，共同推动多边主义发展，维护国际公平正义。
                    </p>
                    <p style="line-height:35px;">经贸合作是中俄关系的重要基石。多年来，两国贸易额持续增长，结构不断优化。传统领域合作稳固，能源合作尤为突出，中俄东线天然气管道等项目顺利推进，为两国能源安全提供了坚实保障。同时，新兴领域合作蓬勃发展，科技创新、跨境电商、数字经济等成为新的合作增长点。今年上半年，中俄双边贸易额突破 [X] 亿美元，同比增长 [X]%，展现出强大的合作韧性与活力。</p>
                    <p style="line-height:35px;">人文交流方面，中俄两国开展了丰富多彩的活动，增进了两国人民的相互了解与友谊。“中俄文化年”“中俄青年友好交流年” 等活动精彩纷呈，吸引了两国众多民众参与。教育领域，双方互派留学生数量逐年增加，学术交流日益频繁。旅游合作也持续升温，越来越多的中国游客前往俄罗斯领略异域风情，俄罗斯游客也钟情于中国的大好河山。</p>
                    </div>
                  `,
      commentCount: 25,
      likeCount: 6000,
      shareCount: 12000,
      isMarked: false,
      isLiked: false,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
      },
    },
    {
      id: 'article_4',
      type: NewsEnum.Article,
      title: '90万名员工了，刘强东在想什么？他的CEO在忙什么？',
      tags: ['企业', '京东', '财报', '电商'],
      authorId: 'author_4',
      markCount: 0,
      recommends: [{
        newsId: 'article_11',
        newsType: 0,
      }, {
        newsId: 'article_10',
        newsType: 0,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_2.jpg',
          surfaceUrl: '',
        },
      ],
      createTime: 1751089800000,
      richContent: `
                    <div class="content">
                      <p style="line-height:35px;">90万名员工了，刘强东在想什么？他的CEO在忙什么？</p>
                      <p style="line-height:35px;">随着京东业务版图的持续拓展，截至今年二季度末，其员工数量已飙升至 90 万人。这一庞大的数字背后，蕴含着诸多战略深意，也引发外界对刘强东所思所想，以及京东 CEO 当下工作重心的强烈好奇。</p>
                    <p style="line-height:35px;">刘强东近日在与媒体交流时袒露心声，直言京东早已超脱个人范畴，承载着 90 万个家庭的生计与尊严。从创业伊始，“供应链” 便是京东的灵魂所在，贯穿零售、物流、医药、工业等核心业务。刘强东坚定表示，自己乃至整个京东集团，未来都将紧紧围绕供应链深耕细作。他进一步透露，京东入局外卖领域，实则是为生鲜供应链服务，且预计再过一个月，京东外卖将推出一种与美团截然不同的商业模式，有望彻底革新食品安全问题。
                    </p>
                    <p style="line-height:35px;">刘强东回顾过往，感慨京东每隔三年便会孕育出新的商业模式。他称，从 2013 年首次尝试 “退休”，让职业经理人掌舵，到如今因现任 CEO 许冉的恳请而回归，目的是为了手把手指导她开展工作。待许冉熟悉业务后，刘强东计划全身心投入国际业务。他强调，京东的成功源于 “体验、成本、效率” 六字战略，未来也将坚定不移地贯彻这一理念，借助人工智能和机器人技术，在保障员工权益的基础上，持续降低成本，目标将库存周转天数压缩至 20 至 25 天。</p>
                    </div>
                  `,
      likeCount: 6000,
      isMarked: false,
      shareCount: 12000,
      commentCount: 25,
      isLiked: false,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
      },
    },
    {
      id: 'article_5',
      type: NewsEnum.Article,
      title: '2025年社会物流总额将超360万亿元',
      tags: ['物流', '金融', '采购', '消费市场'],
      authorId: 'author_5',
      markCount: 0,
      recommends: [{
        newsId: 'article_7',
        newsType: 0,
      }, {
        newsId: 'article_8',
        newsType: 0,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_4.jpg',
          surfaceUrl: '',
        },
      ],
      createTime: 1751089800000,
      richContent: `
                    <div class="content">
                      <p style="line-height:35px;">2025年社会物流总额将超360万亿元</p>
                      <p  style="line-height:35px;">中国物流与采购联合会发布的最新数据显示，2025 年我国社会物流总额有望突破 360 万亿元大关，展现出物流行业的强劲增长态势。这一数据不仅反映了国内经济的稳定复苏和市场活力的不断释放，也彰显了物流行业在推动经济高质量发展中的重要作用。</p>
                    <p style="line-height:35px;">中国物流与采购联合会发布的最新数据显示，2025 年我国社会物流总额有望突破 360 万亿元大关，展现出物流行业的强劲增长态势。这一数据不仅反映了国内经济的稳定复苏和市场活力的不断释放，也彰显了物流行业在推动经济高质量发展中的重要作用。2025 年前五个月，全国社会物流总额已达 138.7 万亿元，同比增长 5.3%，增速较去年同期有所加快。这一增长势头得益于国内一系列促进消费和投资的政策举措，有效拉动了物流需求。特别是在单位与居民物品物流领域，前五月增长 6.4%，单月同比增速在 5 月更是攀升至 8.3%，较上月提高 2.1 个百分点，显示出消费市场的旺盛活力。
                    </p>
                    <p style="line-height:35px;">消费市场的繁荣是推动物流总额增长的重要动力。节日经济与各类促销活动相互叠加，直播电商、即时零售等新兴消费模式蓬勃发展，有力推动了消费品物流的高效运转。据统计，今年上半年实物商品网上零售额同比增长 6.3%，促使消费品物流效率显著提升。同时，产业升级进程的加快，使得高端制造业、新能源等领域对物流服务的需求呈现出多样化、精细化趋势，进一步拉动了社会物流总额的增长。</p>
                    </div>
                  `,
      shareCount: 12000,
      commentCount: 25,
      isLiked: false,
      likeCount: 6000,
      isMarked: false,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
      },
    },
    {
      id: 'article_6',
      type: NewsEnum.Article,
      title: '住建部称住宅层高标准将提至不低于3米，层高低的房子不值钱了？',
      tags: ['住房', '高层', '房屋设计', '交通'],
      authorId: 'author_1',
      markCount: 0,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_9',
        newsType: 1,
      }],
      createTime: 1751089800000,
      commentCount: 25,
      likeCount: 6000,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_1.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_2.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_3.jpg',
          surfaceUrl: '',
        },
      ],
      richContent: `
                    <div class="content">
                         <p style="line-height:35px;">住建部称住宅层高标准将提至不低于3米，层高低的房子不值钱了？</p>
                         <p style="line-height:35px;">在十四届全国人大三次会议民生主题记者会上，住房城乡建设部部长倪虹表示，要加快建设 “好房子”，并将住宅层高标准提高到不低于 3
                             米。这一政策不仅顺应了百姓对居住品质日益提高的需求，更标志着我国住宅建设从 “住有所居” 迈向 “宜居优居” 的新阶段。</p>
                         <div style="display: flex; justify-content: center;">
                             <image class="image-preview"
                                 src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_1.jpg" />
                         </div>
                         <p style="line-height:35px;">
                             提高住宅的层高，可以显著提升居住空间的舒适度，增加净空高度，缓解大户型的空间压抑感，同时也为建筑立面增大开窗采光面积提供了可能性，有利于自然通风，让室内阳光更加充足，让居住环境更加健康舒适。
                         </p>
                         <p style="line-height:35px;">随着人们对居住品质追求的不断提升，地暖、新风系统、中央空调等设备逐渐成为改善型住宅的 “标配”。“3
                             米层高”，能为这些设备提供充足的安装空间，确保设备高效运行，进一步提升室内环境的舒适度。</p>
                         <div style="display: flex; justify-content: center;">
                             <image class="image-preview"
                                 src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_2.jpg" />
                         </div>
                         <p style="line-height:35px;">可以说，“将住宅层高标准提高到不低于 3 米”，是通过政策引领推动技术创新的重要举措，将鼓励开发企业、设计师探索更人性化的居住空间解决方案，进而推动住宅品质的提升。
                         </p>
                         <div style="display: flex; justify-content: center;">
                             <image class="image-preview"
                                 src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_3.jpg" />
                         </div>
                         <p style="line-height:35px;">
                             事实上，层高对于房子价值的影响，不能一概而论。房子的价值，受到地段、配套、交通、环境等多种因素的综合影响。即使层高较低，但如果房子位于城市核心地段，周边配套设施完善，交通便利，环境优美，那么其价值依然可能较高。
                         </p>
                    </div>
                  `,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomImageCard","name":"上文下图"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
    },
    {
      id: 'article_7',
      type: NewsEnum.Article,
      title: '中国物流与采购联合会：2024年社会物流总额将超360万亿元',
      tags: ['物流', '金融', '采购', '消费市场'],
      authorId: 'author_2',
      markCount: 0,
      createTime: 1751089800000,
      recommends: [{
        newsId: 'article_7',
        newsType: 1,
      }, {
        newsId: 'article_10',
        newsType: 1,
      }],
      commentCount: 25,
      likeCount: 6000,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      questionAndAnswer: {
        question: '2025年社会物流总额及增长趋势怎么样？',
        answer: '2025年前五个月，全国社会物流总额已达138.7万亿元，同比增长5.3%，增速较去年同期有所加快，全年社会物流总额有望突破360万亿元大关，展现出物流行业的强劲增长态势。',
      },
      keywordPairs: [{
        keyword: '全国社会物流总额',
        explain: '全国社会物流总额是反映全社会物流需求总规模的核心宏观经济指标，指报告期内（通常为年度）第一次进入国内需求领域，产生从供应地向接受地实体流动的物品的价值总额，由中国物流与采购联合会联合国家统计局发布，是衡量经济运行活跃度与物流行业发展水平的重要依据。',
      }],
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new_4.jpg',
          surfaceUrl: '',
        },
      ],
      richContent: `
                    <div class="content">
                      <p style="line-height:35px;">中国物流与采购联合会：2024年社会物流总额将超360万亿元</p>
                      <p style="line-height:35px;">2月11日，中国物流与采购联合会公布 2024 年全年物流运行数据。物流市场规模优势进一步巩固，与产业链协同体系逐步构建，物流需求规模持续扩张，全年<span class="content-keyword">全国社会物流总额</span>超 360 万亿元。</p>
                    <div style="display: flex; justify-content: center;">
                      <image class="image-preview"
                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new_4.jpg" />
                    </div>
                    <p style="line-height:35px;">2024年全国社会物流总额，即经济运行中的物流实物量价值总额，为360.6万亿元，同比增长5.8%，比2023年加快0.6个百分点，全年物流运行总体延续稳中有进的发展态势。</p>
                    <p style="line-height:35px;">从物流费用来看，衡量物流运行效率的重要指标——社会物流总费用与 GDP 的比率，降至近年内的最低点，有效降低全社会物流成本行动取得初步成效。2024年，社会物流总费用与GDP的比率为14.1%，比上年下降0.3个百分点。</p>
                    </div>
                  `,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
      },
    },
    {
      id: 'article_8',
      type: NewsEnum.Article,
      title: '两个尾号8个“7”的手机号均以200多万拍卖，买家为同一人',
      tags: ['拍卖', '手机号', '运营商', '收藏'],
      authorId: 'author_3',
      markCount: 0,
      createTime: 1751089800000,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_6',
        newsType: 1,
      }],
      commentCount: 25,
      isMarked: false,
      shareCount: 12000,
      isLiked: false,
      likeCount: 6000,
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg',
          surfaceUrl: '',
        },
      ],
      richContent: `
                    <div class="content">
                      <p style="line-height:35px;">两个尾号8个“7”的手机号均以200多万拍卖，买家为同一人</p>
                      <p style="line-height:35px;">近日，两场备受关注的手机号码拍卖落下帷幕，两个尾号均为 8 个 “7” 的特殊手机号最终成交价均突破 200 万元，更引人注目的是，这两个 “天价手机号” 的买家为同一人。</p>
                    <div style="display: flex; justify-content: center;">
                      <image class="image-preview"
                        src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg"/>
                    </div>
                    <p style="line-height:35px;">据拍卖平台信息显示，这两个手机号分别归属不同运营商，但其号码规律高度相似，均在末尾连续排列 8 个 “7”，属于数字重复且寓意吉祥的 “靓号”。其中，首个手机号的拍卖从起拍价 50 万元开始，经过近 300 次竞价，最终以 218 万元成交；另一个手机号的竞争同样激烈，历经 260 余次出价后，以 209 万元落槌。
                    </p>
                    <p style="line-height:35px;">拍卖记录显示，两位买家的注册信息高度吻合，经平台核实确为同一人。对于此次高价购入两个相似靓号的行为，业内人士分析，这类具有独特数字组合的手机号因其稀缺性，长期以来被部分收藏者和商务人士视为身份象征或投资标的。尤其像 8 个 “7” 这样的连号，在全国范围内存量极少，市场流通性低，从而推高了其交易价值。</p>
                    <p style="line-height:35px;">不过，也有观点认为，手机号的实际使用价值有限，高价拍卖更多反映的是特定群体对数字符号的偏好，投资需谨慎。目前，这两个手机号的过户手续正在办理中，后续是否会再次进入流通市场引发关注</p>
                    </div>
                  `,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
    },
    {
      id: 'article_9',
      type: NewsEnum.Video,
      title: '第11波！伊朗猛砸高超弹，400秒击中以色列，撕裂世界第一防空网',
      tags: ['伊朗', '战争', '军事', '导弹'],
      authorId: 'author_4',
      markCount: 0,
      createTime: 1751089800000,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_10',
        newsType: 1,
      }],
      commentCount: 25,
      likeCount: 6000,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-o7oax/template_source%2Fvideo_1.mp4?token=6504c93e-6dc3-423b-aff1-1e594711ba30',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
        },
      ],
      videoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-o7oax/template_source%2Fvideo_1.mp4?token=6504c93e-6dc3-423b-aff1-1e594711ba30',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
      videoDuration: 48234,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
      },
    },
    {
      id: 'article_10',
      type: NewsEnum.Article,
      title: '特朗普将封禁DeepSeek？外交部给出回应',
      tags: ['特朗普', 'DeepSeek', 'AI', '外交部'],
      createTime: 1751089800000,
      authorId: 'author_11',
      markCount: 0,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_9',
        newsType: 1,
      }],
      commentCount: 25,
      likeCount: 6000,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_7.jpg',
          surfaceUrl: '',
        },
      ],
      richContent: `
                    <div class="content">
                      <p style="line-height:35px;">特朗普将封禁DeepSeek？外交部给出回应</p>
                      <p style="line-height:35px;">3 月 10 日，在外交部例行记者会上，有记者提问，据《华尔街日报》报道，美国总统特朗普正在权衡限制 DeepSeek 的措施，中方对此有何回应？</p>
                    <div style="display: flex; justify-content: center;">
                      <image class="image-preview"
                        src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_7.jpg"/>
                    </div>
                    <p style="line-height:35px;">对此，外交部发言人毛宁表示：“我们一贯反对泛化国家安全概念，将经贸和科技问题政治化，我们也将坚定维护中国企业的合法权益。”
                    </p>
                    <p style="line-height:35px;">此前，自今年年初 DeepSeek 惊艳亮相、震撼世界以来，美国就一直在想方设法打压 DeepSeek，以遏制中国在人工智能技术上的发展。当地时间 1 月 28 日，美国多名官员表示 DeepSeek 是 “偷窃”，正对其影响开展国家安全调查。1 月 30 日，美国国会众议院首席行政事务官向国会办公室发出通知，警告国会办公室不要使用 DeepSeek 的服务，特朗普还称 DeepSeek 的出现 “给美国相关产业敲响了警钟” 。如今关于特朗普政府将封禁 DeepSeek 的消息传出，引发国际社会广泛关注，后续进展本报将持续跟踪报道。</p>
                    </div>
                  `,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
      },
    },
    {
      id: 'article_11',
      type: NewsEnum.Video,
      title: 'DeepSeek的所谓综合排名以“开创性+跨学科影响+方法论',
      tags: ['DeepSeek', 'AI排名', 'AI方法论', 'AI跨学科'],
      authorId: 'author_6',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_6',
        newsType: 1,
      }, {
        newsId: 'article_7',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-o7oax/template_source%2Fvideo_1.mp4?token=6504c93e-6dc3-423b-aff1-1e594711ba30',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
        },
      ],
      playCount: '1700',
      videoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-o7oax/template_source%2Fvideo_1.mp4?token=6504c93e-6dc3-423b-aff1-1e594711ba30',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
      videoType: 1,
      videoDuration: 98005,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
      },
    },
    {
      id: 'article_20',
      type: NewsEnum.Article,
      title: '中国物流与采购联合会：2024年社会物流总额将超360万亿元',
      tags: ['物流', '金融', '采购', '消费市场'],
      createTime: 1751089800000,
      authorId: 'author_8',
      markCount: 0,
      recommends: [{
        newsId: 'article_6',
        newsType: 1,
      }, {
        newsId: 'article_8',
        newsType: 1,
      }],
      commentCount: 25,
      isMarked: false,
      shareCount: 12000,
      isLiked: false,
      likeCount: 6000,
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg',
          surfaceUrl: '',
        },
      ],
      richContent: `
                    <div class="content">
                      <p style="line-height:35px;">中国物流与采购联合会：2024年社会物流总额将超360万亿元</p>
                      <p style="line-height:35px;">2 月 11 日，中国物流与采购联合会公布 2024 年全年物流运行数据。物流市场规模优势进一步巩固，与产业链协同体系逐步构建，物流需求规模持续扩张，全年全国社会物流总额超 360 万亿元。</p>
                    <div style="display: flex; justify-content: center;">
                      <image class="image-preview"
                      src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg"/>
                    </div>
                    <p style="line-height:35px;">2024 年全国社会物流总额，即经济运行中的物流实物量价值总额，为 360.6 万亿元，同比增长 5.8%，比 2023 年加快 0.6 个百分点，全年物流运行总体延续稳中有进的发展态势。”
                    </p>
                    <p style="line-height:35px;">从结构看，各领域物流总额占比基本稳定。其中，工业品物流总额超过 318 万亿元，占比 88%。中国物流信息中心主任刘宇航表示，围绕着新质生产力这个板块下的智能制造和高技术制造产品，光电子器件、智能机器人等产品的产量，均在两位数以上的增长，成为工业品物流高质量发展的重要亮点。</p>
                    <p style="line-height:35px;">从物流费用来看，衡量物流运行效率的重要指标 —— 社会物流总费用与 GDP 的比率，降至近年内的最低点，有效降低全社会物流成本行动取得初步成效。2024 年，社会物流总费用与 GDP 的比率为 14.1%，比上年下降 0.3 个百分点。</p>
                    </div>
                  `,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
      },
    },
    {
      id: 'article_21',
      type: NewsEnum.Article,
      title: '中国物流与采购联合会：2024年社会物流总额将超360万亿元',
      tags: ['物流', '金融', '采购', '消费市场'],
      createTime: 1751089800000,
      authorId: 'author_9',
      markCount: 0,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_9',
        newsType: 1,
      }],
      commentCount: 25,
      likeCount: 6000,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg',
          surfaceUrl: '',
        },
      ],
      richContent: `
                    <div class="content">
                      <p style="line-height:35px;">中国物流与采购联合会：2024年社会物流总额将超360万亿元</p>
                      <p style="line-height:35px;">2 月 11 日，中国物流与采购联合会公布 2024 年全年物流运行数据。物流市场规模优势进一步巩固，与产业链协同体系逐步构建，物流需求规模持续扩张，全年全国社会物流总额超 360 万亿元。</p>
                    <div style="display: flex; justify-content: center;">
                      <image class="image-preview"
                        src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_5.jpg" />
                    </div>
                    <p style="line-height:35px;">2024 年全国社会物流总额，即经济运行中的物流实物量价值总额，为 360.6 万亿元，同比增长 5.8%，比 2023 年加快 0.6 个百分点，全年物流运行总体延续稳中有进的发展态势。”
                    </p>
                    <p style="line-height:35px;">从结构看，各领域物流总额占比基本稳定。其中，工业品物流总额超过 318 万亿元，占比 88%。中国物流信息中心主任刘宇航表示，围绕着新质生产力这个板块下的智能制造和高技术制造产品，光电子器件、智能机器人等产品的产量，均在两位数以上的增长，成为工业品物流高质量发展的重要亮点。</p>
                    <p style="line-height:35px;">从物流费用来看，衡量物流运行效率的重要指标 —— 社会物流总费用与 GDP 的比率，降至近年内的最低点，有效降低全社会物流成本行动取得初步成效。2024 年，社会物流总费用与 GDP 的比率为 14.1%，比上年下降 0.3 个百分点。</p>
                    </div>
                  `,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
      },
    },
    {
      id: 'article_13',
      type: NewsEnum.Article,
      title: '二胎家庭” 如何平衡关爱？心理专家支招避免 “隐形偏爱',
      tags: ['二胎', '平衡', '心理学', '家庭'],
      createTime: 1751089800000,
      authorId: 'author_9',
      markCount: 0,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_9',
        newsType: 1,
      }],
      commentCount: 25,
      likeCount: 6000,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F14_2596457237_huge.jpg',
          surfaceUrl: '',
        },
      ],
      richContent: `
                    <div class="content">
                      <p style="line-height:35px;">二胎家庭” 如何平衡关爱？心理专家支招避免 “隐形偏爱</p>
                      <p style="line-height:35px;">随着生育政策的调整，越来越多的家庭迎来了第二个孩子。在为家庭带来双倍欢乐的同时，如何平衡对两个孩子的关爱，也成为许多父母面临的挑战。近日，记者就这一问题采访了心理咨询师 [专家姓名]，专家指出，在二胎家庭中，父母应特别注意避免 “隐形偏爱”，让每个孩子都能感受到充分的爱与关注。</p>
                    <div style="display: flex; justify-content: center;">
                      <image class="image-preview"
                        src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F14_2596457237_huge.jpg" />
                    </div>
                    <p style="line-height:35px;">[专家姓名] 介绍，所谓 “隐形偏爱”，是指父母在不经意间表现出对某个孩子的偏向，这种偏向并非故意为之，却可能对孩子的心理产生深远影响。“比如，在处理孩子之间的矛盾时，有的父母可能会下意识地认为大孩子应该让着小孩子，或者更倾向于相信某个孩子的说法，这些行为都可能被孩子解读为偏爱。”
                    </p>
                    <p style="line-height:35px;">在 [专家姓名] 看来，孩子对父母的爱极为敏感，即便是细微的差别对待，都可能使他们产生被忽视或不被爱的感觉。长期处于这种环境下，孩子可能会出现自卑、焦虑、叛逆等心理问题，还可能导致兄弟姐妹之间的关系紧张。</p>
                    </div>
                  `,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
      },
    },
    {
      id: 'article_14',
      type: NewsEnum.Article,
      title: '多地推行 “弹性休假” 政策，助力职场父母兼顾工作与家庭陪伴',
      tags: ['弹性休假', '工作平衡', '职场', '全职家庭'],
      createTime: 1751089800000,
      authorId: 'author_6',
      markCount: 0,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_9',
        newsType: 1,
      }],
      commentCount: 25,
      likeCount: 6000,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F18_2543265291_huge%E5%B0%8F.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F18_2549393977_huge%E5%B0%8F.jpg',
          surfaceUrl: '',
        },
      ],
      richContent: `
                <div class="content">
                      <p style="line-height: 35px">
                        多地推行 “弹性休假” 政策，助力职场父母兼顾工作与家庭陪伴
                      </p>
                      <p style="line-height: 35px">
                        在当今快节奏的社会中，职场父母常常面临着工作与家庭难以平衡的困境，尤其是二胎家庭的父母，压力更为显著。为缓解这一矛盾，多地政府积极行动，推行
                        “弹性休假” 政策，旨在帮助职场父母更好地兼顾工作与家庭陪伴
                      </p>
                      <div style="display: flex; justify-content: center">
                        <image
                          class="image-preview"
                          src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F18_2549393977_huge%E5%B0%8F.jpg"
                        />
                      </div>
                      <div>
                        <p style="line-height: 35px">
                          对于职场父母而言，弹性休假政策意义非凡。在二胎家庭中，父母往往要在两个孩子的生活照料、学业辅导、兴趣培养等方面分配精力，同时还需应对工作中的各项任务，常常感到力不从心。弹性休假能够让他们有更充裕的时间陪伴孩子成长，参与孩子的重要时刻，减少因忙碌工作对家庭陪伴的缺失。例如，家长可以利用多出来的休假时间，陪孩子参加亲子活动、户外运动，增进亲子关系，也能更好地平衡对两个孩子的关爱，避免因忙碌而产生
                          “隐形偏爱””
                        </p>
                        <p style="line-height: 35px">
                          从企业角度看，虽然弹性休假在一定程度上对管理提出了挑战，但也存在积极意义。实行弹性工作制，有利于提升员工的工作满意度和忠诚度，减少员工因工作与家庭冲突产生的离职意愿，从而降低企业的人才流失率。携程集团联合创始人、董事局主席梁建章就曾表示，未来可探索
                          4 天工作制或缩短工作时间来提高工作效率，携程也在积极实践 。
                        </p>
                      </div>
                    </div>
                  `,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomImageCard","name":"上文下图"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
    },
    {
      id: 'article_15',
      type: NewsEnum.Article,
      title: '传统家庭仪式遇新解读：年轻人用 “线上家宴” 连接异地亲人，空巢家庭” 不再孤单，社区 “银龄互助” 让老人结伴生活',
      tags: ['仪式', '老人', '互助', '空巢家庭'],
      createTime: 1751089800000,
      authorId: 'author_5',
      markCount: 0,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_9',
        newsType: 1,
      }],
      commentCount: 25,
      likeCount: 6000,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F2387811837_huge%E5%B0%8F.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F29_2590322759_huge.jpg',
          surfaceUrl: '',
        },
      ],
      richContent: `
                    <div class="content">
                      <p style="line-height:35px;">多地推行 “弹性休假” 政策，助力职场父母兼顾工作与家庭陪伴</p>
                      <p style="line-height:35px;">在当今快节奏的社会中，职场父母常常面临着工作与家庭难以平衡的困境，尤其是二胎家庭的父母，压力更为显著。为缓解这一矛盾，多地政府积极行动，推行 “弹性休假” 政策，旨在帮助职场父母更好地兼顾工作与家庭陪伴</p>
                    <div style="display: flex; justify-content: center;">
                      <image class="image-preview" src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F29_2590322759_huge.jpg" />
                    </div>
                    <div>
                      <p style="line-height:35px;">对于职场父母而言，弹性休假政策意义非凡。在二胎家庭中，父母往往要在两个孩子的生活照料、学业辅导、兴趣培养等方面分配精力，同时还需应对工作中的各项任务，常常感到力不从心。弹性休假能够让他们有更充裕的时间陪伴孩子成长，参与孩子的重要时刻，减少因忙碌工作对家庭陪伴的缺失。例如，家长可以利用多出来的休假时间，陪孩子参加亲子活动、户外运动，增进亲子关系，也能更好地平衡对两个孩子的关爱，避免因忙碌而产生 “隐形偏爱””</p>
                      <p style="line-height:35px;">从企业角度看，虽然弹性休假在一定程度上对管理提出了挑战，但也存在积极意义。实行弹性工作制，有利于提升员工的工作满意度和忠诚度，减少员工因工作与家庭冲突产生的离职意愿，从而降低企业的人才流失率。携程集团联合创始人、董事局主席梁建章就曾表示，未来可探索 4 天工作制或缩短工作时间来提高工作效率，携程也在积极实践 。</p>
                    </div>
                  `,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomImageCard","name":"上文下图"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
    },
    {
      id: 'article_16',
      type: NewsEnum.Article,
      title: '传统家庭仪式遇新解读：年轻人用 “线上家宴” 连接异地亲人，空巢家庭” 不再孤单，社区 “银龄互助” 让老人结伴生活',
      tags: ['仪式', '老人', '互助', '空巢家庭'],
      createTime: 1751089800000,
      authorId: 'author_5',
      markCount: 0,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_9',
        newsType: 1,
      }],
      commentCount: 25,
      likeCount: 6000,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F2_2302601201_huge.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F62_1545058316_huge%E5%B0%8F.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2Fhellorf_hi2239368115%E5%B0%8F.jpg',
          surfaceUrl: '',
        },
      ],
      richContent: `
                    <div class="content">
                      <p style="line-height:35px;">多地推行 “弹性休假” 政策，助力职场父母兼顾工作与家庭陪伴</p>
                      <p style="line-height:35px;">在当今快节奏的社会中，职场父母常常面临着工作与家庭难以平衡的困境，尤其是二胎家庭的父母，压力更为显著。为缓解这一矛盾，多地政府积极行动，推行 “弹性休假” 政策，旨在帮助职场父母更好地兼顾工作与家庭陪伴</p>
                    <div style="display: flex; justify-content: center;">
                      <image class="image-preview" src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2Fhellorf_hi2239368115%E5%B0%8F.jpg" />
                    </div>
                      <p style="line-height:35px;">对于职场父母而言，弹性休假政策意义非凡。在二胎家庭中，父母往往要在两个孩子的生活照料、学业辅导、兴趣培养等方面分配精力，同时还需应对工作中的各项任务，常常感到力不从心。弹性休假能够让他们有更充裕的时间陪伴孩子成长，参与孩子的重要时刻，减少因忙碌工作对家庭陪伴的缺失。例如，家长可以利用多出来的休假时间，陪孩子参加亲子活动、户外运动，增进亲子关系，也能更好地平衡对两个孩子的关爱，避免因忙碌而产生 “隐形偏爱””</p>
                      <p style="line-height:35px;">从企业角度看，虽然弹性休假在一定程度上对管理提出了挑战，但也存在积极意义。实行弹性工作制，有利于提升员工的工作满意度和忠诚度，减少员工因工作与家庭冲突产生的离职意愿，从而降低企业的人才流失率。携程集团联合创始人、董事局主席梁建章就曾表示，未来可探索 4 天工作制或缩短工作时间来提高工作效率，携程也在积极实践 。</p>
                    </div>
                  `,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomImageCard","name":"上文下图"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
    },
    {
      id: 'article_17',
      type: NewsEnum.Article,
      title: '七旬夫妇坚持手写家书 20 年，笔墨间藏着对子女的牵挂',
      tags: ['家书', '家庭', '牵挂', '职场'],
      createTime: 1751089800000,
      authorId: 'author_5',
      markCount: 0,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_9',
        newsType: 1,
      }],
      commentCount: 25,
      likeCount: 6000,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F2_2037710663_huge.jpg',
          surfaceUrl: '',
        },
      ],
      richContent: `
                    <div class="content">
                      <p style="line-height:35px;">多地推行 “弹性休假” 政策，助力职场父母兼顾工作与家庭陪伴</p>
                      <p style="line-height:35px;">在当今快节奏的社会中，职场父母常常面临着工作与家庭难以平衡的困境，尤其是二胎家庭的父母，压力更为显著。为缓解这一矛盾，多地政府积极行动，推行 “弹性休假” 政策，旨在帮助职场父母更好地兼顾工作与家庭陪伴</p>
                    <div style="display: flex; justify-content: center;">
                      <image class="image-preview" src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F2_2037710663_huge.jpg" />
                    </div>
                      <p style="line-height:35px;">对于职场父母而言，弹性休假政策意义非凡。在二胎家庭中，父母往往要在两个孩子的生活照料、学业辅导、兴趣培养等方面分配精力，同时还需应对工作中的各项任务，常常感到力不从心。弹性休假能够让他们有更充裕的时间陪伴孩子成长，参与孩子的重要时刻，减少因忙碌工作对家庭陪伴的缺失。例如，家长可以利用多出来的休假时间，陪孩子参加亲子活动、户外运动，增进亲子关系，也能更好地平衡对两个孩子的关爱，避免因忙碌而产生 “隐形偏爱””
                      </p>
                    <p style="line-height:35px;">从企业角度看，虽然弹性休假在一定程度上对管理提出了挑战，但也存在积极意义。实行弹性工作制，有利于提升员工的工作满意度和忠诚度，减少员工因工作与家庭冲突产生的离职意愿，从而降低企业的人才流失率。携程集团联合创始人、董事局主席梁建章就曾表示，未来可探索 4 天工作制或缩短工作时间来提高工作效率，携程也在积极实践 。</p>
                    </div>
                  `,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"LeftTextRightImageCard","name":"左文右图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
      },
    },
    {
      id: 'article_digital_1',
      type: NewsEnum.Article,
      title: '人工智能助力教育公平：偏远地区学生迎来优质教育资源',
      tags: ['人工智能', '偏远学区', '教育资源', '在线平台'],
      authorId: 'author_1',
      markCount: 0,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_9',
        newsType: 1,
      }],
      createTime: 1751089800000,
      commentCount: 25,
      likeCount: 6000,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      postImgList: [],
      richContent: `
                    <div class="content">
                         <p style="line-height:35px;">
                         近年来，随着人工智能技术的飞速发展，教育领域迎来了前所未有的变革。特别是在教育资源分配不均的问题上，人工智能技术的应用为偏远地区的学生带来了希望。2025年12月15日，一场以“科技赋能教育，智慧点亮未来”为主题的教育科技高峰论坛在京召开，多位教育专家、科技企业代表齐聚一堂，探讨人工智能如何推动教育公平。
                         </p>
                         <p style="line-height:35px;">
                         人工智能技术正在逐步改变传统教育模式。通过在线课堂、智能评测系统和教育资源共享平台，偏远地区的学生能够突破地域限制，享受到优质的教育资源。例如，在线教育平台通过AI算法，能够根据学生的学习情况个性化推荐课程内容，帮助学生更高效地掌握知识。同时，智能评测系统可以实时分析学生的答题情况，为教师提供精准的教学反馈，从而优化教学策略。
                         </p>
                         <p style="line-height:35px;">
                         在偏远地区，教育资源匮乏一直是制约教育发展的重要因素。许多乡村学校缺乏优秀的教师资源，学生难以接触到先进的教学理念和方法。然而，随着人工智能技术的应用，这一问题正在逐步得到解决。例如，某教育科技公司开发的“智慧课堂”系统，通过互联网将优质教育资源输送到偏远地区学校。教师可以通过系统与城市名校的教师进行实时交流，学习先进的教学方法；学生则可以通过系统观看名校课程，拓展视野。
                         </p>
                         <p style="line-height:35px;">
                         此外，人工智能技术还能够帮助解决教育资源分配不均的问题。通过大数据分析，教育部门可以更精准地了解各地区的教育资源需求，并据此制定相应的政策。例如，某省教育部门通过AI技术对全省教育资源进行了全面摸底，发现部分偏远地区学校缺乏英语教师。为此，该省教育厅迅速启动了“AI英语教师计划”，通过智能语音技术为学生提供标准的英语发音和听力训练，有效缓解了教育资源不足的问题。
                         </p>
                         <p style="line-height:35px;">
                         在教育科技高峰论坛上，多位专家表示，人工智能技术的应用不仅能够提升教育质量，还能够推动教育公平。北京师范大学教育学院院长李明教授指出：“人工智能技术的应用，为教育资源的均衡分配提供了新的可能性。通过科技手段，我们可以让更多的学生享受到优质的教育资源，从而缩小城乡教育差距。”总的来说，人工智能技术正在为教育公平注入新的活力。通过科技手段，偏远地区的学生能够享受到优质的教育资源，教育公平的愿景正在逐步成为现实。正如某教育科技公司负责人所言：“教育是每个人的权利，而科技则是实现这一权利的桥梁。我们相信，通过人工智能技术的应用，教育公平的美好未来即将到来。”
                         </p>
                    </div>
                  `,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomImageCard","name":"上文下图"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
    },
    {
      id: 'article_digital_2',
      type: NewsEnum.Article,
      title: '全球经济复苏新动力：人工智能推动增长，绿色经济成未来焦点',
      tags: ['全球经济', '人工智能', '绿色经济', '经济复苏'],
      authorId: 'author_1',
      markCount: 0,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_9',
        newsType: 1,
      }],
      createTime: 1751089800000,
      commentCount: 25,
      likeCount: 6000,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/template-thwjd/ComprehensiveNews%2Finsert_2.png',
          surfaceUrl: '',
        },
      ],
      richContent: `
                    <div class="content">
                         <p style="line-height:35px;">
                         近年来，随着人工智能技术的飞速发展，教育领域迎来了前所未有的变革。特别是在教育资源分配不均的问题上，人工智能技术的应用为偏远地区的学生带来了希望。2025年12月15日，一场以“科技赋能教育，智慧点亮未来”为主题的教育科技高峰论坛在京召开，多位教育专家、科技企业代表齐聚一堂，探讨人工智能如何推动教育公平。
                         </p>
                         <p style="line-height:35px;">
                         人工智能技术正在逐步改变传统教育模式。通过在线课堂、智能评测系统和教育资源共享平台，偏远地区的学生能够突破地域限制，享受到优质的教育资源。例如，在线教育平台通过AI算法，能够根据学生的学习情况个性化推荐课程内容，帮助学生更高效地掌握知识。同时，智能评测系统可以实时分析学生的答题情况，为教师提供精准的教学反馈，从而优化教学策略。
                         </p>
                         <div style="display: flex; justify-content: center;">
                             <image class="image-preview"
                                 src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/template-thwjd/ComprehensiveNews%2Finsert_2.png" />
                         </div>
                         <p style="line-height:35px;">
                         此外，人工智能技术还能够帮助解决教育资源分配不均的问题。通过大数据分析，教育部门可以更精准地了解各地区的教育资源需求，并据此制定相应的政策。例如，某省教育部门通过AI技术对全省教育资源进行了全面摸底，发现部分偏远地区学校缺乏英语教师。为此，该省教育厅迅速启动了“AI英语教师计划”，通过智能语音技术为学生提供标准的英语发音和听力训练，有效缓解了教育资源不足的问题。
                         </p>
                         <p style="line-height:35px;">
                         在教育科技高峰论坛上，多位专家表示，人工智能技术的应用不仅能够提升教育质量，还能够推动教育公平。通过科技手段，我们可以让更多的学生享受到优质的教育资源，从而缩小城乡教育差距。”总的来说，人工智能技术正在为教育公平注入新的活力。通过科技手段，偏远地区的学生能够享受到优质的教育资源，教育公平的愿景正在逐步成为现实。正如某教育科技公司负责人所言：“教育是每个人的权利，而科技则是实现这一权利的桥梁。我们相信，通过人工智能技术的应用，教育公平的美好未来即将到来。”
                         </p>
                    </div>
                  `,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomImageCard","name":"上文下图"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
    },
    {
      id: 'article_digital_3',
      type: NewsEnum.Article,
      title: '人工智能推动增长，绿色经济成未来焦点',
      tags: ['全球经济', '人工智能', '绿色经济', '经济复苏'],
      authorId: 'author_1',
      markCount: 0,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_9',
        newsType: 1,
      }],
      createTime: 1751089800000,
      commentCount: 25,
      likeCount: 6000,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/template-thwjd/ComprehensiveNews%2Finsert_1.png',
          surfaceUrl: '',
        },
      ],
      richContent: `
                    <div class="content">
                         <p style="line-height:35px;">
                         自2023年以来，全球经济逐步从新冠疫情的冲击中恢复，但复苏过程并不平坦。根据国际货币基金组织（IMF）的最新预测，2025年全球经济增长率预计将达到3.8%，略高于去年的3.5%。然而，这一增长面临多重挑战，包括地缘政治紧张、通货膨胀压力以及气候变化带来的不确定性。尽管如此，人工智能技术的广泛应用为全球经济注入了新的活力。AI不仅在制造业、服务业等领域提升了生产效率，还催生了许多新兴行业。例如，自动驾驶技术的突破正在改变交通运输业，而AI驱动的医疗诊断系统则大幅提高了医疗服务的质量。
                         </p>
                         <div style="display: flex; justify-content: center;">
                             <image class="image-preview"
                                 src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/template-thwjd/ComprehensiveNews%2Finsert_1.png" />
                         </div>
                         <p style="line-height:35px;">
                         人工智能被认为是推动全球经济复苏的重要引擎。根据麦肯锡全球研究院的报告，到2030年，AI有望为全球经济贡献超过13万亿美元的增量价值。这一技术不仅提高了企业的生产效率，还创造了大量新的就业机会。
                         </p>
                         <p style="line-height:35px;">
                         随着全球气候变化问题的加剧，绿色经济成为各国推动可持续发展的重要方向。2025年，全球多个国家和地区已经明确提出碳中和目标，这为绿色经济的发展提供了巨大的市场空间。
                         </p>
                         <p style="line-height:35px;">
                         在绿色能源领域，太阳能、风能等可再生能源的投资持续增长。根据彭博新能源财经的数据显示，2025年全球可再生能源的投资规模预计将达到1.3万亿美元，较2020年增长超过50%。与此同时，电动汽车、绿色建筑等领域的市场规模也在迅速扩大。
                         </p>
                         <p style="line-height:35px;">
                         绿色经济的发展不仅有助于缓解气候变化问题，还能创造大量就业机会。根据国际劳工组织的报告，到2030年，全球绿色经济领域预计将新增超过2400万个就业岗位，涵盖技术研发、设备制造、服务等多个领域。
                         </p>
                         <p style="line-height:35px;">
                         在全球经济复苏的过程中，政策支持和国际合作起到了至关重要的作用。各国政府纷纷出台了一系列刺激经济增长的政策措施，包括减税、补贴、投资激励等。例如，欧盟推出的“数字新政”计划，旨在通过加大对AI和绿色技术的投资，推动经济的数字化转型。
                         </p>
                         <p style="line-height:35px;">
                         与此同时，国际合作也成为应对全球经济挑战的重要途径。2025年，二十国集团（G20）峰会达成了一系列共识，包括加强全球经济治理、推动贸易自由化、应对气候变化等。这些举措为全球经济的稳定增长提供了有力保障。
                         </p>
                    </div>
                  `,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomImageCard","name":"上文下图"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
    },
    {
      id: 'article_digital_4',
      type: NewsEnum.Article,
      title: '人工智能：经济增长的新引擎',
      tags: ['全球经济', '人工智能', '绿色经济', '经济复苏'],
      authorId: 'author_1',
      markCount: 0,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_9',
        newsType: 1,
      }],
      createTime: 1751089800000,
      commentCount: 25,
      likeCount: 6000,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      postImgList: [],
      richContent: `
                    <div class="content">
                         <p style="line-height:35px;">
                         近年来，全球经济复苏的步伐逐渐加快，但与此同时，新的挑战和机遇也在不断涌现。在人工智能（AI）技术迅速发展的背景下，全球经济增长模式正在发生深刻变革，绿色经济成为各国关注的焦点。本文将为您详细解读当前国际经济形势下的新趋势与新格局。
                         </p>
                         <p style="line-height:35px;">
                         自2023年以来，全球经济逐步从新冠疫情的冲击中恢复，但复苏过程并不平坦。根据国际货币基金组织（IMF）的最新预测，2025年全球经济增长率预计将达到3.8%，略高于去年的3.5%。然而，这一增长面临多重挑战，包括地缘政治紧张、通货膨胀压力以及气候变化带来的不确定性。
                         </p>
                         <p style="line-height:35px;">
                         尽管如此，人工智能技术的广泛应用为全球经济注入了新的活力。AI不仅在制造业、服务业等领域提升了生产效率，还催生了许多新兴行业。例如，自动驾驶技术的突破正在改变交通运输业，而AI驱动的医疗诊断系统则大幅提高了医疗服务的质量。
                         </p>
                         <p style="line-height:35px;">
                         人工智能被认为是推动全球经济复苏的重要引擎。根据麦肯锡全球研究院的报告，到2030反对和国际社会的唾弃。
                         </p>
                         <p style="line-height:35px;">
                         在全球经济复苏的过程中，政策支持和国际合作起到了至关重要的作用。各国政府纷纷出台了一系列刺激经济增长的政策措施，包括减税、补贴、投资激励等。例如，欧盟推出的“数字新政”计划，旨在通过加大对AI和绿色技术的投资，推动经济的数字化转型。
                         </p>
                         <p style="line-height:35px;">
                         与此同时，国际合作也成为应对全球经济挑战的重要途径。2025年，二十国集团（G20）峰会达成了一系列共识，包括加强全球经济治理、推动贸易自由化、应对气候变化等。这些举措为全球经济的稳定增长提供了有力保障。
                         </p>
                         <p style="line-height:35px;">
                         总的来说，全球经济正处于一个重要的转型期。人工智能和绿色经济不仅为经济增长提供了新的动力，也为人类社会的可持续发展开辟了新的道路。
                         </p>
                    </div>
                  `,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomImageCard","name":"上文下图"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
    },
    {
      id: 'article_digital_5',
      type: NewsEnum.Article,
      title: '绿色经济：未来的增长方向',
      tags: ['全球经济', '人工智能', '绿色经济', '经济复苏'],
      authorId: 'author_1',
      markCount: 0,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_9',
        newsType: 1,
      }],
      createTime: 1751089800000,
      commentCount: 25,
      likeCount: 6000,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      postImgList: [],
      richContent: `
                    <div class="content">
                         <p style="line-height:35px;">
                         绿色经济的发展不仅有助于缓解气候变化问题，还能创造大量就业机会。根据国际劳工组织的报告，到2030年，全球绿色经济领域预计将新增超过2400万个就业岗位，涵盖技术研发、设备制造、服务等多个领域。
                         </p>
                         <p style="line-height:35px;">
                         在全球经济复苏的过程中，政策支持和国际合作起到了至关重要的作用。各国政府纷纷出台了一系列刺激经济增长的政策措施，包括减税、补贴、投资激励等。例如，欧盟推出的“数字新政”计划，旨在通过加大对AI和绿色技术的投资，推动经济的数字化转型。
                         </p>
                         <p style="line-height:35px;">
                         与此同时，国际合作也成为应对全球经济挑战的重要途径。2025年，二十国集团（G20）峰会达成了一系列共识，包括加强全球经济治理、推动贸易自由化、应对气候变化等。这些举措为全球经济的稳定增长提供了有力保障。
                         </p>
                    </div>
                  `,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomImageCard","name":"上文下图"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
    },
  ];
  static default: BaseNews = {
    id: '',
    type: NewsEnum.Post,
    title: '',
    tags: ['生活', '军事', '科技', '自然'],
    authorId: '',
    markCount: 0,
    postImgList: [
      {
        picVideoUrl: '',
        surfaceUrl: '',
      },
    ],
    recommends: [],
    richContent: '',
    createTime: new Date().getTime(),
    commentCount: 0,
    likeCount: 0,
    shareCount: 0,
    isLiked: false,
    isMarked: false,
    navInfo: {
      setting: '',
    },
  };
}