import { Constant } from 'common';
import { GetTicketDetailsResp } from '../../types/responseTypes/GetTicketDetailResp';
import { MockResourceEnum } from '../MockResourceEnum';

export const ticketDetailListMock: GetTicketDetailsResp =
  [{
    ticketId: 0,
    ticketName: '松山湖景区门票',
    basicTicketTypeId: 0,
    banner: Constant.CLOUD_STORAGE_URL + MockResourceEnum.SWIPER,
    labels: ['自然风光', '当前可订'],
    toKnow: '【活动期限】：2025年1月1日至2025年2月28日。\n' +
      '【适用人群】：成人限制为身份证、年龄60周岁（含）以下（按生日计算年龄）。\n' +
      '【限购说明】：同一证件在使用期限内同一产品最多预定一张。\n' +
      '【入园方式】：人脸识别、身份证、二维码（无支付宝人像库且未携带身份证请提前打开二维码）。\n' +
      '闸机通行。',
    phone: '12345678911',
    description: '',
    ticketType: [{
      ticketTypeId: 0,
      ticketTypeName: '松山湖景区成人票',
      originalPrice: 24,
      discountPrice: 24,
      instruction: '【活动期限】：2025年1月1日至2025年2月28日。\n' +
        '【适用人群】：成人限制为身份证、年龄60周岁（含）以下（按生日计算年龄）。\n' +
        '【限购说明】：同一证件在使用期限内同一产品最多预定一张。\n' +
        '【入园方式】：人脸识别、身份证、二维码（无支付宝人像库且未携带身份证请提前打开二维码）。\n' +
        '闸机通行。',
    },
      {
        ticketTypeId: 1,
        ticketTypeName: '松山湖景区观光车票',
        originalPrice: 15,
        discountPrice: 15,
        instruction: '【活动期限】：2025年1月1日至2025年2月28日。\n' +
          '【适用人群】：成人限制为身份证、年龄60周岁（含）以下（按生日计算年龄）。\n' +
          '【限购说明】：同一证件在使用期限内同一产品最多预定一张。\n' +
          '【入园方式】：人脸识别、身份证、二维码（无支付宝人像库且未携带身份证请提前打开二维码）。\n' +
          '闸机通行。',
      },
      {
        ticketTypeId: 2,
        ticketTypeName: '松山湖景区成人票',
        originalPrice: 15,
        discountPrice: 15,
        instruction: '【活动期限】：2025年1月1日至2025年2月28日。\n' +
          '【适用人群】：成人限制为身份证、年龄60周岁（含）以下（按生日计算年龄）。\n' +
          '【限购说明】：同一证件在使用期限内同一产品最多预定一张。\n' +
          '【入园方式】：人脸识别、身份证、二维码（无支付宝人像库且未携带身份证请提前打开二维码）。\n' +
          '闸机通行。',
      },
      {
        ticketTypeId: 3,
        ticketTypeName: '松山湖景区儿童票',
        originalPrice: 15,
        discountPrice: 15,
        instruction: '【活动期限】：2025年1月1日至2025年2月28日。\n' +
          '【适用人群】：成人限制为身份证、年龄60周岁（含）以下（按生日计算年龄）。\n' +
          '【限购说明】：同一证件在使用期限内同一产品最多预定一张。\n' +
          '【入园方式】：人脸识别、身份证、二维码（无支付宝人像库且未携带身份证请提前打开二维码）。\n' +
          '闸机通行。',
      }],
  },
    {
      ticketId: 1,
      ticketName: '海德尔堡景区门票',
      basicTicketTypeId: 0,
      banner: Constant.CLOUD_STORAGE_URL + MockResourceEnum.HEIDELBERG,
      labels: ['异域风情', '现可预约'],
      toKnow: '【活动期限】：2025年1月1日至2025年2月28日。\n' +
        '【适用人群】：成人限制为身份证、年龄60周岁（含）以下（按生日计算年龄）。\n' +
        '【限购说明】：同一证件在使用期限内同一产品最多预定一张。\n' +
        '【入园方式】：人脸识别、身份证、二维码（无支付宝人像库且未携带身份证请提前打开二维码）。\n' +
        '闸机通行。',
      phone: '12345678911',
      description: '',
      ticketType: [{
        ticketTypeId: 0,
        ticketTypeName: '海德尔堡景区成人票',
        originalPrice: 10,
        discountPrice: 10,
        instruction: '【活动期限】：2025年1月1日至2025年2月28日。\n' +
          '【适用人群】：成人限制为身份证、年龄60周岁（含）以下（按生日计算年龄）。\n' +
          '【限购说明】：同一证件在使用期限内同一产品最多预定一张。\n' +
          '【入园方式】：人脸识别、身份证、二维码（无支付宝人像库且未携带身份证请提前打开二维码）。\n' +
          '闸机通行。',
      },
        {
          ticketTypeId: 1,
          ticketTypeName: '海德尔堡景区学生票',
          originalPrice: 5,
          discountPrice: 5,
          instruction: '【活动期限】：2025年1月1日至2025年2月28日。\n' +
            '【适用人群】：成人限制为身份证、年龄60周岁（含）以下（按生日计算年龄）。\n' +
            '【限购说明】：同一证件在使用期限内同一产品最多预定一张。\n' +
            '【入园方式】：人脸识别、身份证、二维码（无支付宝人像库且未携带身份证请提前打开二维码）。\n' +
            '闸机通行。',
        }],
    },
  ];