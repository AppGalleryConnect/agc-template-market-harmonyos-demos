import { MessageGroup, MessageItem } from '../commons/Types';

export const MOCK_MESSAGE_GROUP: MessageGroup[] = [
  {
    type: 1,
    title: '系统消息',
    icon: $r('app.media.ic_notice_system'),
    latestContent: '双十一热门活动来啦！',
    latestTime: Date.now() - 10000,
    unreadCount: 2,
  },

  {
    type: 2,
    title: '物流消息',
    icon: $r('app.media.ic_notice_express'),
    latestContent: '您的订单已成功发货，预计3天内送达。',
    latestTime: Date.now() - 7200000,
    unreadCount: 1,
  },
  {
    type: 3,
    title: '活动推送',
    icon: $r('app.media.ic_notice_activity'),
    latestContent: '欢迎加入我们的商城，赠送您一张满100减50的新人券。',
    latestTime: Date.now() - 72000000,
    unreadCount: 3,
  },
  {
    type: 4,
    title: '客服消息',
    icon: $r('app.media.ic_notice_custom_service'),
    latestContent: '您的退货申请已受理，请耐心等待~',
    latestTime: Date.now() - 72000000,
    unreadCount: 3,
  },
];

export const MOCK_MESSAGE_LIST: MessageItem[] = [
  // 系统消息 (type: 1)
  {
    id: 'sys_001',
    type: 1,
    title: '系统通知',
    content: '双十一热门活动来啦！百万商品限时特惠，快来参与吧！',
    timestamp: Date.now() - 10000,
    isRead: false,
  },
  {
    id: 'sys_002',
    type: 1,
    title: '系统维护通知',
    content:
      '系统将于今晚凌晨2:00-4:00进行维护升级，期间可能无法正常访问，敬请谅解。',
    timestamp: Date.now() - 86400000,
    isRead: false,
  },
  {
    id: 'sys_003',
    type: 1,
    title: '版本更新',
    content: '新版本v2.1.0已发布，修复了已知问题并优化了用户体验。',
    timestamp: Date.now() - 172800000,
    isRead: true,
  },

  // 物流消息 (type: 2)
  {
    id: 'log_001',
    type: 2,
    title: '发货通知',
    content: '您的订单已成功发货，预计3天内送达。快递单号：SF1234567890',
    timestamp: Date.now() - 7200000,
    isRead: false,
  },
  {
    id: 'log_002',
    type: 2,
    title: '配送中',
    content: '您的包裹正在派送中，快递员：张三，电话：138****1234',
    timestamp: Date.now() - 3600000,
    isRead: true,
  },
  {
    id: 'log_003',
    type: 2,
    title: '签收成功',
    content: '您的包裹已签收，如有问题请联系客服。感谢您的购买！',
    timestamp: Date.now() - 1800000,
    isRead: true,
  },

  // 活动推送 (type: 3)
  {
    id: 'act_001',
    type: 3,
    title: '新人专享',
    content: '欢迎加入我们的商城，赠送您一张满100减50的新人券，有效期7天。',
    timestamp: Date.now() - 72000000,
    isRead: false,
  },
  {
    id: 'act_002',
    type: 3,
    title: '限时秒杀',
    content: '今日10:00-12:00限时秒杀，热门商品低至5折，不容错过！',
    timestamp: Date.now() - 86400000,
    isRead: false,
  },
  {
    id: 'act_003',
    type: 3,
    title: '会员专享',
    content: '会员专享福利：全场包邮+专属折扣+积分加倍，立即开通享受权益！',
    timestamp: Date.now() - 172800000,
    isRead: false,
  },
  {
    id: 'act_004',
    type: 3,
    title: '节日特惠',
    content: '国庆大促来袭，全场满199减50，多买多优惠！',
    timestamp: Date.now() - 259200000,
    isRead: true,
  },

  // 客服消息 (type: 4)
  {
    id: 'cs_001',
    type: 4,
    title: '退货处理',
    content:
      '您的退货申请已受理，请耐心等待审核结果，我们将在1-3个工作日内处理。',
    timestamp: Date.now() - 72000000,
    isRead: false,
  },
  {
    id: 'cs_002',
    type: 4,
    title: '问题咨询',
    content:
      '关于您咨询的商品尺寸问题，我们已经为您提交给商家，请等待商家回复。',
    timestamp: Date.now() - 144000000,
    isRead: false,
  },
  {
    id: 'cs_003',
    type: 4,
    title: '投诉反馈',
    content:
      '对于您反映的物流延迟问题，我们深表歉意，已为您申请10元优惠券作为补偿。',
    timestamp: Date.now() - 216000000,
    isRead: false,
  },
];
