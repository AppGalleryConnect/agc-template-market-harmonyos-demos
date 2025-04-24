import { ActivityModel } from '@ohos_agcit/postpartum_care_center_utils';
import { ActivityTypeItem } from '../model/ActivityTypeItem';
import { CityItem } from '../model/CityItem';
import { StoreModel } from '../model/StoreModel';

export const STORE_LIST = [
  new StoreModel(1, '南京涵江楼', '南京市高新技术产业园区软件大道101号酒店16F', '11100000001',
    $r('app.media.store_pic1'), '南京', 31.98, 118.76),
  new StoreModel(2, '南京卓美悦', '南京市高新技术产业园区软件大道101号酒店16F', '11100000002',
    $r('app.media.store_pic2'), '南京', 31.99, 118.71),
  new StoreModel(3, '南京华轩府', '南京市高新技术产业园区软件大道101号酒店16F', '11100000003',
    $r('app.media.store_pic2'), '南京', 32.03, 118.80),
  new StoreModel(4, '无锡雅辉阁', '无锡市高新技术产业园区软件大道101号酒店16F', '11100000004',
    $r('app.media.store_pic1'), '无锡', 31.58, 120.30),
  new StoreModel(5, '苏州华轩苑', '苏州市高新技术产业园区软件大道101号酒店16F', '11100000005',
    $r('app.media.store_pic1'), '苏州', 31.29, 120.64),
  new StoreModel(6, '杭州科技城', '杭州市高新技术产业园区软件大道101号酒店16F', '11100000006',
    $r('app.media.store_pic2'), '杭州', 30.22, 120.12),
  new StoreModel(7, '北京卓美悦', '北京市高新技术产业园区软件大道101号酒店16F', '11100000007',
    $r('app.media.store_pic1'), '北京', 39.91, 116.47),
  new StoreModel(8, '深圳海月楼', '深圳市高新技术产业园区软件大道101号酒店16F', '11100000008',
    $r('app.media.store_pic2'), '深圳', 22.54, 114.06),
  new StoreModel(9, '东莞华轩苑', '东莞市高新技术产业园区软件大道101号酒店16F', '11100000009',
    $r('app.media.store_pic1'), '东莞', 23.02, 113.75),
  new StoreModel(10, '广州银月楼', '广州市高新技术产业园区软件大道101号酒店16F', '11100000010',
    $r('app.media.store_pic2'), '广州', 23.13, 113.26),
  new StoreModel(11, '汕头卓美悦', '汕头市高新技术产业园区软件大道101号酒店16F', '11100000011',
    $r('app.media.store_pic1'), '汕头', 23.35, 116.68),
  new StoreModel(12, '常州银月楼', '常州市高新技术产业园区软件大道101号酒店16F', '11100000012',
    $r('app.media.store_pic2'), '常州', 31.81, 119.94),
  new StoreModel(13, '上海银月楼', '上海市高新技术产业园区软件大道101号酒店16F', '11100000013',
    $r('app.media.store_pic1'), '上海', 31.23, 121.47),
  new StoreModel(14, '上海云顶轩', '上海市高新技术产业园区软件大道101号酒店16F', '11100000014',
    $r('app.media.store_pic2'), '上海', 31.20, 121.36),
  new StoreModel(15, '北京云顶轩', '北京市高新技术产业园区软件大道101号酒店16F', '11100000015',
    $r('app.media.store_pic1'), '北京', 39.90, 116.41),
  new StoreModel(16, '常州星辉阁', '常州市高新技术产业园区软件大道101号酒店16F', '11100000016',
    $r('app.media.store_pic2'), '常州', 31.78, 119.89),
  new StoreModel(17, '深圳华轩苑', '深圳市高新技术产业园区软件大道101号酒店16F', '11100000017',
    $r('app.media.store_pic1'), '深圳', 22.57, 113.94),
  new StoreModel(18, '广州卓美拉', '广州市高新技术产业园区软件大道101号酒店16F', '11100000018',
    $r('app.media.store_pic2'), '广州', 23.17, 113.39),
  new StoreModel(19, '上海雅阁楼', '上海市高新技术产业园区软件大道101号酒店16F', '11100000019',
    $r('app.media.store_pic1'), '上海', 31.18, 121.38),
  new StoreModel(20, '上海华轩府', '上海市高新技术产业园区软件大道101号酒店16F', '11100000020',
    $r('app.media.store_pic2'), '上海', 31.22, 121.35),
  new StoreModel(21, '杭州涵江楼', '杭州市高新技术产业园区软件大道101号酒店16F', '11100000021',
    $r('app.media.store_pic1'), '杭州', 30.25, 120.16),
  new StoreModel(22, '杭州卓美悦', '杭州市高新技术产业园区软件大道101号酒店16F', '11100000022',
    $r('app.media.store_pic2'), '杭州', 30.20, 119.99),
  new StoreModel(23, '无锡卓美悦', '无锡市高新技术产业园区软件大道101号酒店16F', '11100000023',
    $r('app.media.store_pic1'), '无锡', 31.52, 120.45),
];

export const CITY_LIST: CityItem[] = [
  { id: 0, name: '附近' },
  { id: 1, name: '南京' },
  { id: 2, name: '无锡' },
  { id: 3, name: '杭州' },
  { id: 4, name: '东莞' },
  { id: 5, name: '广州' },
  { id: 6, name: '汕头' },
  { id: 7, name: '北京' },
  { id: 8, name: '常州' },
  { id: 9, name: '苏州' },
  { id: 10, name: '深圳' },
  { id: 11, name: '上海' },
];

export const CITY_LIST_ACTIVITY: CityItem[] = [
  { id: 0, name: '全部' },
  { id: 1, name: '南京' },
  { id: 2, name: '无锡' },
  { id: 3, name: '杭州' },
  { id: 4, name: '东莞' },
  { id: 5, name: '广州' },
  { id: 6, name: '汕头' },
  { id: 7, name: '北京' },
  { id: 8, name: '常州' },
  { id: 9, name: '苏州' },
  { id: 10, name: '深圳' },
  { id: 11, name: '上海' }
];

export const ACTIVITY_TYPE_LIST: ActivityTypeItem[] = [
  { id: 0, name: '全部' },
  { id: 1, name: '品牌沙龙' },
  { id: 2, name: '专家讲座' },
  { id: 3, name: '宝贝时光' },
  { id: 4, name: '心灵驿站' },
  { id: 5, name: '巧手工坊' },
  { id: 6, name: '其他活动' },
];

export const ACTIVITY_LIST: ActivityModel[] = [
  new ActivityModel(1, '妈妈最爱品牌展', new Date, new Date, new Date,
    new Date, '品牌沙龙', '南京', '南京涵江楼', '请您添加活动介绍', $r('app.media.activity_cover_image_1'), 1),

  new ActivityModel(1, '儿科专家健康讲堂', new Date, new Date, new Date,
    new Date, '专家讲座', '南京', '南京卓美悦', '请您添加活动介绍', $r('app.media.activity_cover_image_2'), 1),

  new ActivityModel(1, '儿童语言启蒙班', new Date, new Date, new Date,
    new Date, '宝贝时光', '南京', '南京华轩府', '请您添加活动介绍', $r('app.media.activity_cover_image_3'), 1),

  new ActivityModel(1, '妈妈心灵成长营', new Date, new Date, new Date,
    new Date, '心灵驿站', '南京', '南京涵江楼', '请您添加活动介绍', $r('app.media.activity_cover_image_4'), 1),

  new ActivityModel(1, '手工编织新手班', new Date, new Date, new Date,
    new Date, '巧手工坊', '南京', '南京涵江楼', '请您添加活动介绍', $r('app.media.activity_cover_image_5'), 1),

  new ActivityModel(1, '妈妈最爱品牌展', new Date, new Date, new Date,
    new Date, '品牌沙龙', '无锡', '无锡雅辉阁', '请您添加活动介绍', $r('app.media.activity_cover_image_1'), 1),

  new ActivityModel(1, '儿科专家健康讲堂', new Date, new Date, new Date,
    new Date, '专家讲座', '无锡', '无锡卓美悦', '请您添加活动介绍', $r('app.media.activity_cover_image_2'), 1),

  new ActivityModel(1, '儿童语言启蒙班', new Date, new Date, new Date,
    new Date, '宝贝时光', '无锡', '无锡雅辉阁', '请您添加活动介绍', $r('app.media.activity_cover_image_3'), 1),

  new ActivityModel(1, '妈妈心灵成长营', new Date, new Date, new Date,
    new Date, '心灵驿站', '无锡', '无锡凯悦臻选', '请您添加活动介绍', $r('app.media.activity_cover_image_4'), 1),

  new ActivityModel(1, '手工编织新手班', new Date, new Date, new Date,
    new Date, '巧手工坊', '无锡', '无锡凯悦臻选', '请您添加活动介绍', $r('app.media.activity_cover_image_5'), 1),

  new ActivityModel(1, '妈妈最爱品牌展', new Date, new Date, new Date,
    new Date, '品牌沙龙', '杭州', '杭州涵江楼', '请您添加活动介绍', $r('app.media.activity_cover_image_1'), 1),

  new ActivityModel(1, '儿科专家健康讲堂', new Date, new Date, new Date,
    new Date, '专家讲座', '杭州', '杭州卓美悦', '请您添加活动介绍', $r('app.media.activity_cover_image_2'), 1),

  new ActivityModel(1, '儿童语言启蒙班', new Date, new Date, new Date,
    new Date, '宝贝时光', '杭州', '杭州卓美悦', '请您添加活动介绍', $r('app.media.activity_cover_image_3'), 1),

  new ActivityModel(1, '妈妈心灵成长营', new Date, new Date, new Date,
    new Date, '心灵驿站', '杭州', '杭州卓美悦', '请您添加活动介绍', $r('app.media.activity_cover_image_4'), 1),

  new ActivityModel(1, '手工编织新手班', new Date, new Date, new Date,
    new Date, '巧手工坊', '杭州', '杭州卓美悦', '请您添加活动介绍', $r('app.media.activity_cover_image_5'), 1),

  new ActivityModel(1, '妈妈最爱品牌展', new Date, new Date, new Date,
    new Date, '品牌沙龙', '东莞', '东莞华轩苑', '请您添加活动介绍', $r('app.media.activity_cover_image_1'), 1),

  new ActivityModel(1, '儿科专家健康讲堂',  new Date, new Date, new Date,
    new Date, '专家讲座', '东莞', '东莞华轩苑', '请您添加活动介绍', $r('app.media.activity_cover_image_2'), 1),

  new ActivityModel(1, '儿童语言启蒙班', new Date, new Date, new Date,
    new Date, '宝贝时光', '东莞', '东莞华轩苑', '请您添加活动介绍', $r('app.media.activity_cover_image_3'), 1),

  new ActivityModel(1, '妈妈心灵成长营', new Date, new Date, new Date,
    new Date, '心灵驿站', '东莞', '东莞华轩苑', '请您添加活动介绍', $r('app.media.activity_cover_image_4'), 1),

  new ActivityModel(1, '手工编织新手班', new Date, new Date, new Date,
    new Date, '巧手工坊', '东莞', '东莞华轩苑', '请您添加活动介绍', $r('app.media.activity_cover_image_5'), 1)
];