/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { JobListItem } from '../clazz/JobListItem';
import { ResumeEntity } from '../clazz/ResumeEntity';
/**
 * Style constants that can be used by all modules
 */
/**
 * Route type define.
 */
export class Route {
  title: string | Resource;
  img: Resource;
  path: string;

  constructor(title: string | Resource, img: Resource, path: string) {
    this.title = title;
    this.img = img;
    this.path = path;
  }
}

export class CommonConstants {
  /**
   * Full width.
   */
  static readonly FULL_WIDTH: string = '100%';
  /**
   * Full height.
   */
  static readonly FULL_HEIGHT: string = '100%';
  /**
   * font weight 400.
   */
  static readonly FONT_WEIGHT_400: number = 400;
  /**
   * font weight 500.
   */
  static readonly FONT_WEIGHT_500: number = 500;
  /**
   * font weight 600.
   */
  static readonly FONT_WEIGHT_600: number = 600;
  /**
   * Larger font 700.
   */
  static readonly FONT_WEIGHT_700: number = 700;
  /**
   * font weight 800.
   */
  static readonly FONT_WEIGHT_800: number = 800;
  /**
   * Height of list.
   */
  static readonly LIST_HEIGHT: string = '80%';
  /**
   * Height of list board.
   */
  static readonly LIST_BOARD_HEIGHT: string = '67%';
  /**
   * list space.
   */
  static readonly LIST_SPACE: number = 12;
  /**
   * Radius of list.
   */
  static readonly COMMON_RADIUS: number = 24;
  /**
   * animation duration.
   */
  static readonly DURATION: number = 300;
  /**
   * x-axis transition animation.
   */
  static readonly TRANSITION_ANIMATION_X: number = 1;
  /**
   * y-axis transition animation.
   */
  static readonly TRANSITION_ANIMATION_Y: number = 0;

  /**
   * Transparency full
   */
  static readonly TRANSPARENCY_FULL: number = 1;

  /**
   * Transparency half
   */
  static readonly TRANSPARENCY_HALF: number = 0.4;
  
  static readonly ROUTES: Route[] = [
    new Route($r('app.string.mine_my_favorite'), $r('app.media.star'), `pages/mine/MyFavorite`),
    new Route($r('app.string.mine_delivery_info'), $r('app.media.mine_delivery'), `pages/mine/MyDelivery`),
    new Route($r('app.string.mine_resume_management'), $r('app.media.mine_resume'), `pages/mine/ResumeManagement`
    )
  ]

  static readonly RESUMES: ResumeEntity[] =
    [
      new ResumeEntity()
    ]
  
  static readonly DELIVERY_STATUS: SearchType[] = [
    { index: 0, title: '进行中' },
    { index: 1, title: '待面试' },
    { index: 2, title: '已结束' },
  ]
  static readonly DELIVERY_STATUS_MAP: Map<number, string> = new Map(
    this.DELIVERY_STATUS.map(item => [item.index, item.title])
  );
  static readonly JOB_COLLECTION: SearchType[] =
    [
      { index: 0, title: '技术类' },
      { index: 1, title: '产品类' },
      { index: 2, title: '运营类' },
      { index: 3, title: '设计类' },
      { index: 4, title: '销售类' },
      { index: 5, title: '职能类' }
    ]
  static readonly RECRUITMENT_COLLECTION: SearchType[] =
    [
      { index: 0, title: '社会招聘' },
      { index: 1, title: '校园招聘' },
      { index: 2, title: '实习生招聘' }
    ]
  static readonly ADDRESS_COLLECTION: SearchType[] =
    [
      { index: 0, title: '北京市' },
      { index: 1, title: '上海市' },
      { index: 2, title: '广州市' },
      { index: 3, title: '深圳市' },
      { index: 4, title: '南京市' },
      { index: 5, title: '苏州市' },
      { index: 6, title: '武汉市' },
      { index: 7, title: '厦门市' },
      { index: 8, title: '杭州市' },
      { index: 9, title: '香港特别行政区' }
    ]
  static readonly ADDRESS_MAP: Map<number, string> = new Map(
    this.ADDRESS_COLLECTION.map(item => [item.index, item.title])
  );
  static readonly JOB_LIST: JobListItem[] =
    [
      new JobListItem('1', 0, 'Java技术专家-用户增长', 0, '后端开发', '2024.11.26', 0,
        '1.负责用户增长领域的架构设计与技术实现，优化用户增长策略，提升拉新、促活、留存等核心指标；\n' +
          '2.承担核心业务模块的设计和开发，保障系统的高可用性和高并发处理能力；\n' +
          '3.参与用户增长方向的 A/B 测试、数据分析和策略优化，不断提升用户体验；',
        '1.统招本科及以上学历，计算机相关专业，5年以上 Java 开发经验，有增长方向技术经验者优先；\n' +
          '2.熟练掌握 Java 生态体系，熟悉 Spring Boot、Spring Cloud、MyBatis 等技术栈；\n' +
          '3.具备高并发、大流量系统的设计与优化经验，熟悉分布式系统、微服务架构；'),
      new JobListItem('2', 0, '业务架构研发-基础技术', 0, '后端开发', '2024.11.26', 0,
        '1.负责云原生架构设计与研发，优化 Kubernetes、Service Mesh 等云原生技术方案；\n' +
          '2.设计并开发高性能、可扩展的分布式系统，提升云原生环境下的稳定性和可用性；\n' +
          '3.推动容器化、自动化运维及 DevOps 体系的完善，提高运维效率和系统弹性；\n' +
          '4.研究云原生领域的新技术、新工具，优化 CI/CD 流程，提升开发交付效率；',
        '1.统招本科及以上学历，计算机相关专业，3年及以上云原生相关开发经验；\n' +
          '2.熟练掌握 Kubernetes、Docker、Istio、Envoy 等云原生技术栈；\n' +
          '3.熟悉微服务架构，了解服务治理、API 网关、负载均衡等核心技术；\n' +
          '4.具备 Golang/Java/Python 其中一门编程语言的开发经验；'),
      new JobListItem('3', 0, '云原生高级开发工程师', 1, '后端开发', '2024.11.26', 0,
        '1.负责公司基础技术架构的设计与优化，保障业务系统的稳定性、可扩展性；\n' +
          '2.负责核心业务框架和基础组件的研发，提升业务开发效率；\n' +
          '3.参与高并发、高可用架构的设计和优化，推动业务架构的持续演进；',
        '1.统招本科及以上学历，计算机相关专业，5年以上研发经验；\n' +
          '2.熟练掌握 Java/C++/Go 其中一种语言，并有扎实的编程功底；\n' +
          '3.具备大型分布式系统的架构设计和优化经验，熟悉微服务架构、缓存、消息队列等技术；'),
      new JobListItem('4', 0, '高级SRE', 1, '运维', '2024.11.26', 0,
        '1.负责公司核心系统的高可用架构设计、部署和优化，确保系统稳定运行；\n' +
          '2.制定并实施运维自动化方案，提高运维效率，降低故障率；\n' +
          '3.监控、分析系统性能指标，优化资源使用，提升服务质量；',
        '1.统招本科及以上学历，计算机、软件工程等相关专业，5年及以上SRE或运维开发经验；\n' +
          '2.熟悉Linux系统，具备Shell/Python/Golang等编程能力，有较强的自动化运维经验；\n' +
          '3.熟悉Kubernetes、Docker、Prometheus等云原生技术，并有落地经验；'),
      new JobListItem('5', 0, 'AI大模型工程师', 2, '后端开发', '2024.11.26', 0,
        '1.负责大规模预训练模型（如Transformer、LLM）的研发、优化和部署；\n' +
          '2.研究和实现高效训练算法，提升模型训练和推理效率；\n' +
          '3.参与模型微调、知识蒸馏、量化等优化工作，提高模型性能和适用性；\n' +
          '4.关注AI大模型领域的最新研究进展，推动前沿技术落地；',
        '1.统招本科及以上学历，计算机、人工智能、机器学习相关专业，3年及以上AI相关经验；\n' +
          '2.熟练掌握PyTorch、TensorFlow等深度学习框架，具备大规模训练经验；\n' +
          '3.熟悉Transformer架构，掌握BERT、GPT等主流模型的原理和优化方法；\n' +
          '4.具备高性能计算（HPC）、分布式训练、模型加速等相关经验；'),
      new JobListItem('6', 0, '软件测试工程师', 2, '后端开发', '2024.11.26', 0,
        '1.负责公司软件产品的功能测试、性能测试、自动化测试，保障产品质量；\n' +
          '2.设计测试方案，编写测试用例，执行测试计划，并跟踪问题修复情况；\n' +
          '3.搭建自动化测试框架，提高测试效率，降低人工成本；\n' +
          '4.参与CI/CD流程优化，提高测试覆盖率，确保高效稳定的版本迭代；',
        '1.统招本科及以上学历，计算机或相关专业，3年及以上软件测试经验；\n' +
          '2.熟悉软件测试流程，具备手动测试和自动化测试能力；\n' +
          '3.熟练使用测试工具（如Selenium、JMeter、Postman等），有自动化测试经验；\n' +
          '4.熟悉Python/Java等编程语言，能编写测试脚本；\n' +
          '5.具备良好的问题分析能力，良好的团队协作和沟通能力。'),
      new JobListItem('7', 0, '高级产品经理', 0, '产品', '2024.11.26', 1,
        '1.负责产品规划与设计，推动产品从概念到落地，提升用户体验与业务增长；\n' +
          '2.进行市场调研，分析用户需求，制定产品策略，提升产品竞争力；\n' +
          '3.协同研发、设计、运营等团队，确保产品按时高质量交付；',
        '1.统招本科及以上学历，计算机、经济管理等相关专业，5年及以上产品管理经验；\n' +
          '2.熟悉互联网产品从0到1的建设过程，具备成功的产品落地经验；\n' +
          '3.具备优秀的数据分析能力，能够基于数据驱动产品优化；'),
      new JobListItem('8', 0, '用户体验运营', 0, '运营', '2024.11.26', 2,
        '1.负责用户体验相关的调研、分析，优化用户路径，提高用户满意度；\n' +
          '2.监控用户反馈，分析用户行为数据，提出改进方案，提升产品体验；\n' +
          '3.参与社区运营，促进用户活跃度，提高用户留存率；\n' +
          '4.制定并实施用户增长策略，提升用户转化和商业价值；\n' +
          '5.与产品、技术团队协作，推动用户体验优化落地。',
        '1.统招本科及以上学历，市场营销、心理学、数据分析等相关专业，3年及以上用户运营经验；\n' +
          '2.熟悉用户增长、用户体验相关方法论，有成功案例者优先；\n' +
          '3.具备数据分析能力，能利用数据驱动决策；\n' +
          '4.具备优秀的沟通和跨团队协作能力，能够推动体验优化方案落地；\n' +
          '5.热爱用户研究，对提升用户体验有深刻的理解和热情。'),
      new JobListItem('9', 0, '财务分析专家', 0, '财务', '2024.11.26', 5,
        '1.负责企业财务数据分析，提供财务报表、成本分析、预算控制等方面的专业支持；\n' +
          '2.研究市场动态，结合业务发展趋势，提出财务优化和风险控制建议；\n' +
          '3.建立并完善财务分析模型，支持经营决策，提高财务管理效率；',
        '1.统招本科及以上学历，财务管理、会计、金融相关专业，5年及以上财务分析经验；\n' +
          '2.熟练掌握财务分析方法，具备数据建模能力，能高效处理和解读财务数据；\n' +
          '3.熟悉企业财务报表及预算管理体系，具备良好的财务规划能力；\n' +
          '4.熟练使用Excel、SQL、Python等数据分析工具，能够实现财务数据的可视化展示；'),
      new JobListItem('10', 0, '应用安全专家', 0, '后端开发', '2024.11.26', 0,
        '1.负责公司核心应用的安全架构设计，确保系统安全性和合规性；\n' +
          '2.进行安全漏洞检测与分析，提出修复方案，并推动开发团队实施安全优化；\n' +
          '3.研究最新的安全威胁和攻击手段，提升公司应用安全防护能力；\n' +
          '4.建立安全开发流程（SDL），推广安全编码实践，减少安全风险；',
        '1.统招本科及以上学历，信息安全、计算机相关专业，5年及以上应用安全经验；\n' +
          '2.熟悉Web安全、移动安全、API安全等常见攻击手段及防御方法；\n' +
          '3.熟练掌握常见安全工具（如Burp Suite、Nmap、Metasploit等），具备一定的渗透测试能力；\n' +
          '4.了解安全开发生命周期（SDL），具备推动安全左移的经验；'),
      new JobListItem('11', 0, 'C++架构专家', 0, '后端开发', '2024.11.26', 0,
        '1.负责C++架构设计，优化系统性能，提高代码质量和可维护性；\n' +
          '2.参与核心模块的开发和优化，推动高性能计算、分布式系统等技术落地；\n' +
          '3.研究和应用现代C++（C++11/14/17/20）技术，提高系统稳定性和运行效率；\n' +
          '4.解决复杂的技术问题，优化底层算法和数据结构；',
        '1.统招本科及以上学历，计算机相关专业，5年及以上C++开发经验；\n' +
          '2.精通C++，熟悉STL、Boost等库，了解操作系统原理、网络编程、多线程编程等；\n' +
          '3.具备大型分布式系统、游戏引擎、实时计算等相关开发经验者优先；'),
      new JobListItem('12', 1, 'Java开发专家', 0, '后端开发', '2024.11.26', 0,
        '1.负责高性能Java后端架构设计，优化服务性能，提升系统可扩展性；\n' +
          '2.参与核心业务系统的开发和优化，推动微服务架构演进；\n' +
          '3.研究并应用分布式计算、存储、消息队列等技术，提高系统稳定性；',
        '1.统招本科及以上学历，计算机相关专业，5年及以上Java开发经验；\n' +
          '2.熟练掌握Spring Boot、Spring Cloud、MyBatis等主流框架，具备微服务开发经验；\n' +
          '3.了解数据库优化、分布式事务、缓存策略、消息队列等关键技术；\n' +
          '4.具备高并发、高可用架构设计经验，熟悉Redis、Kafka、Zookeeper等中间件；\n' +
          '5.具备良好的系统设计能力，逻辑思维清晰，能够独立解决复杂技术问题。'),
      new JobListItem('13', 2, '鸿蒙开发练习生', 9, '后端开发', '2025.01.28', 0,
        '1.参与HarmonyOS（鸿蒙）应用的开发与优化，学习鸿蒙系统架构；\n' +
          '2.协助团队进行鸿蒙App UI/UX设计及交互优化，提高用户体验；\n' +
          '3.学习并实践OpenHarmony SDK，掌握鸿蒙分布式能力和硬件适配方案；',
        '1.统招本科及以上学历，计算机、软件工程、物联网相关专业，在校生或应届毕业生；\n' +
          '2.了解Java/Kotlin或C++，有移动端开发经验者优先；\n' +
          '3.熟悉Android开发，有Flutter、React Native等跨平台开发经验者优先；')
    ]
  static readonly JOB_LIST_MAP: Map<string, JobListItem> = new Map(
    this.JOB_LIST.map(item => [item.jobId, item])
  );
}

/**
 * AddressType type define.
 */
export interface SearchType {
  title: string;
  index: number;
}