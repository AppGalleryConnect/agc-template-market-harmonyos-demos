/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import {
  DigitalNewsResponse,
  DigitalNewsSource,
  IUserInfo,
  LoginWithHuaweiIDResp,
  NewsArticle
} from '../model/IResponse';

/**
 * 数字报Mock数据类
 */
export class MockDigitalNews {
  static list: DigitalNewsResponse[] = [
    {
      id: 1,
      newsImg: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/template-thwjd/ComprehensiveNews%2Fdigital_1.png',
      newsName: '第01版：头版',
      position: '10,56,510,56,510,379,10,379,,https://www.example.com,,article_digital_1,,人工智能助力教育公平：偏远地区学生迎来优质教育资源||521,56,691,56,691,269,521,269,,https://www.example.com,,article_digital_2,,全球经济复苏新动力：人工智能推动增长，绿色经济成未来焦点||10,391,510,391,510,875,10,875,,https://www.example.com,,article_digital_3,,人工智能推动增长，绿色经济成未来焦点||521,281,691,281,691,1026,521,1026,,https://www.example.com,,article_digital_4,,人工智能：经济增长的新引擎||10,895,510,895,510,1026,10,1026,,https://www.example.com,,article_digital_1,,人工智能助力教育公平：偏远地区学生迎来优质教育资源',
      width: '700',
      height: '1036',
      paperId: 1,
      paperTime: '2025-06-28',
    },
    {
      id: 2,
      newsImg: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/template-thwjd/ComprehensiveNews%2Fdigital_2.png',
      newsName: '第02版：要闻',
      position: '10,56,690,56,690,252,10,252,,https://www.example.com,,article_digital_1,,人工智能助力教育公平：偏远地区学生迎来优质教育资源||10,265,464,265,464,729,10,729,,https://www.example.com,,article_digital_2,,全球经济复苏新动力：人工智能推动增长，绿色经济成未来焦点||476,264,690,264,690,729,476,729,,https://www.example.com,,article_digital_4,,人工智能：经济增长的新引擎||10,752,380,752,380,861,10,861,,https://www.example.com,,article_digital_3,,人工智能推动增长，绿色经济成未来焦点||392,752,692,752,692,1024,392,1024,,https://www.example.com,,article_digital_1,,人工智能助力教育公平：偏远地区学生迎来优质教育资源||10,869,380,869,380,1024,10,1024,,https://www.example.com,,article_digital_5,,绿色经济：未来的增长方向',
      width: '700',
      height: '1036',
      paperId: 1,
      paperTime: '2025-06-28',
    },
    {
      id: 3,
      newsImg: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/template-thwjd/ComprehensiveNews%2Fdigital_3.png',
      newsName: '第03版：国内',
      position: '10,56,510,56,510,379,10,379,,https://www.example.com,,article_digital_1,,人工智能助力教育公平：偏远地区学生迎来优质教育资源||521,56,691,56,691,269,521,269,,https://www.example.com,,article_digital_2,,全球经济复苏新动力：人工智能推动增长，绿色经济成未来焦点||10,391,510,391,510,875,10,875,,https://www.example.com,,article_digital_3,,人工智能推动增长，绿色经济成未来焦点||521,281,691,281,691,1026,521,1026,,https://www.example.com,,article_digital_4,,人工智能：经济增长的新引擎||10,895,510,895,510,1026,10,1026,,https://www.example.com,,article_digital_1,,人工智能助力教育公平：偏远地区学生迎来优质教育资源',
      width: '700',
      height: '1036',
      paperId: 1,
      paperTime: '2025-06-28',
    },
    {
      id: 4,
      newsImg: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/template-thwjd/ComprehensiveNews%2Fdigital_4.png',
      newsName: '第04版：天下',
      position: '10,56,690,56,690,252,10,252,,https://www.example.com,,article_digital_1,,人工智能助力教育公平：偏远地区学生迎来优质教育资源||10,265,464,265,464,729,10,729,,https://www.example.com,,article_digital_2,,全球经济复苏新动力：人工智能推动增长，绿色经济成未来焦点||476,264,690,264,690,729,476,729,,https://www.example.com,,article_digital_4,,人工智能：经济增长的新引擎||10,752,380,752,380,861,10,861,,https://www.example.com,,article_digital_3,,人工智能推动增长，绿色经济成未来焦点||392,752,692,752,692,1024,392,1024,,https://www.example.com,,article_digital_1,,人工智能助力教育公平：偏远地区学生迎来优质教育资源||10,869,380,869,380,1024,10,1024,,https://www.example.com,,article_digital_5,,绿色经济：未来的增长方向',
      width: '700',
      height: '1036',
      paperId: 1,
      paperTime: '2025-06-28',
    },
    {
      id: 5,
      newsImg: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/template-thwjd/ComprehensiveNews%2Fdigital_5.png',
      newsName: '第05版：视线',
      position: '10,56,510,56,510,379,10,379,,https://www.example.com,,article_digital_1,,人工智能助力教育公平：偏远地区学生迎来优质教育资源||521,56,691,56,691,269,521,269,,https://www.example.com,,article_digital_2,,全球经济复苏新动力：人工智能推动增长，绿色经济成未来焦点||10,391,510,391,510,875,10,875,,https://www.example.com,,article_digital_3,,人工智能推动增长，绿色经济成未来焦点||521,281,691,281,691,1026,521,1026,,https://www.example.com,,article_digital_4,,人工智能：经济增长的新引擎||10,895,510,895,510,1026,10,1026,,https://www.example.com,,article_digital_1,,人工智能助力教育公平：偏远地区学生迎来优质教育资源',
      width: '700',
      height: '1036',
      paperId: 1,
      paperTime: '2025-06-28',
    },
    {
      id: 6,
      newsImg: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/template-thwjd/ComprehensiveNews%2Fdigital_6.png',
      newsName: '第06版：资讯',
      position: '10,56,690,56,690,252,10,252,,https://www.example.com,,article_digital_1,,人工智能助力教育公平：偏远地区学生迎来优质教育资源||10,265,464,265,464,729,10,729,,https://www.example.com,,article_digital_2,,全球经济复苏新动力：人工智能推动增长，绿色经济成未来焦点||476,264,690,264,690,729,476,729,,https://www.example.com,,article_digital_4,,人工智能：经济增长的新引擎||10,752,380,752,380,861,10,861,,https://www.example.com,,article_digital_3,,人工智能推动增长，绿色经济成未来焦点||392,752,692,752,692,1024,392,1024,,https://www.example.com,,article_digital_1,,人工智能助力教育公平：偏远地区学生迎来优质教育资源||10,869,380,869,380,1024,10,1024,,https://www.example.com,,article_digital_5,,绿色经济：未来的增长方向',
      width: '700',
      height: '1036',
      paperId: 1,
      paperTime: '2025-06-28',
    },
  ];
  static sources: DigitalNewsSource[] = [
    {
      id: '1',
      name: '人民日报',
    },
    {
      id: '2',
      name: '光明日报',
    },
    {
      id: '3',
      name: '经济日报',
    },
    {
      id: '4',
      name: '南方日报',
    },
    {
      id: '5',
      name: '广州日报',
    },
    {
      id: '6',
      name: '新华社',
    },
    {
      id: '7',
      name: '扬子晚报',
    },
    {
      id: '8',
      name: '法治日报',
    },
    {
      id: '9',
      name: '钱江晚报',
    },
    {
      id: '10',
      name: '南方都市报',
    },
    {
      id: '11',
      name: '解放日报',
    },
    {
      id: '12',
      name: '文汇报',
    },
    {
      id: '13',
      name: '大众日报',
    },
    {
      id: '14',
      name: '湖北日报',
    },
    {
      id: '15',
      name: '新华日报',
    },
  ];
}

/**
 * 新闻详情Mock数据类
 */
export class MockNewsArticle {
  static list: NewsArticle[] = [
    {
      id: 'article_digital_1',
      title: '人工智能助力教育公平：偏远地区学生迎来优质教育资源',
      authorId: 'author_1',
      markCount: 0,
      createTime: 1751089800000,
      createDate: '星期二',
      commentCount: 25,
      likeCount: 6000,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
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
    },
    {
      id: 'article_digital_2',
      title: '全球经济复苏新动力：人工智能推动增长，绿色经济成未来焦点',
      authorId: 'author_1',
      markCount: 0,
      createTime: 1751089800000,
      createDate: '星期二',
      commentCount: 25,
      likeCount: 6000,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
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
    },
    {
      id: 'article_digital_3',
      title: '人工智能推动增长，绿色经济成未来焦点',
      authorId: 'author_1',
      markCount: 0,
      createTime: 1751089800000,
      createDate: '星期二',
      commentCount: 25,
      likeCount: 6000,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
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
    },
    {
      id: 'article_digital_4',
      title: '人工智能：经济增长的新引擎',
      authorId: 'author_1',
      markCount: 0,
      createTime: 1751089800000,
      createDate: '星期二',
      commentCount: 25,
      likeCount: 6000,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
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
    },
    {
      id: 'article_digital_5',
      title: '绿色经济：未来的增长方向',
      authorId: 'author_1',
      markCount: 0,
      createTime: 1751089800000,
      createDate: '星期二',
      commentCount: 25,
      likeCount: 6000,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
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
    },
  ]
}

/**
 * 用户Mock数据类
 */
export class MockUserData {
  static USER_ID: number = 1;
  static LOGIN_RESP: LoginWithHuaweiIDResp = {
    token: '',
    userId: MockUserData.USER_ID.toString(),
  };
  static USER_INFO: IUserInfo = {
    userId: MockUserData.USER_ID,
    nickName: '华为用户',
    mobile: '130****0000',
    avatar: 'resourceImage://ic_user_default',
  };
}
