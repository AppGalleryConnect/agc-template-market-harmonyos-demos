export interface Exchange {
  base: string,
  date: string,
  updateTime: number,
  rates: Currency[]
}

export interface Currency {
  name: string,
  rate: number,
  country: string,
}

export const EXCHANGE_INFO: Exchange = {
  base: 'CNY',
  date: '2025-08-25',
  updateTime: 1756093170803,
  rates: [
    {
      rate: 100,
      name: '人民币',
      country: 'CNY',
    },
    {
      rate: 960.2300,
      name: '英镑',
      country: 'GBP',
    },
    {
      rate: 720.6900,
      name: '美元',
      country: 'USD',
    },
    {
      rate: 823.1800,
      name: '欧元',
      country: 'EUR',
    },
    {
      rate: 92.8300,
      name: '港币',
      country: 'HKD',
    },
    {
      rate: 21.8000,
      name: '泰国铢',
      country: 'THB',
    },
    {
      rate: 5.0938,
      name: '日元',
      country: 'JPY',
    },
    {
      rate: 463.0100,
      name: '澳大利亚元',
      country: 'AUD',
    },
    {
      rate: 523.5500,
      name: '加拿大元',
      country: 'CAD',
    },
    {
      rate: 551.8800,
      name: '新加坡元',
      country: 'SGD',
    },
    {
      rate: 883.3000,
      name: '瑞士法郎',
      country: 'CHF',
    },
    {
      rate: 110.1400,
      name: '丹麦克朗',
      country: 'DKK',
    },
    {
      rate: 90.0600,
      name: '澳门元',
      country: 'MOP',
    },
    {
      rate: 164.1300,
      name: '林吉特',
      country: 'MYR',
    },
    {
      rate: 69.1900,
      name: '挪威克朗',
      country: 'NOK',
    },
    {
      rate: 433.4800,
      name: '新西兰元',
      country: 'NZD',
    },
    {
      rate: 12.8700,
      name: '菲律宾比索',
      country: 'PHP',
    },
    {
      rate: 8.8800,
      name: '卢布',
      country: 'RUB',
    },
    {
      rate: 75.3100,
      name: '瑞典克朗',
      country: 'SEK',
    },
    {
      rate: 22.4600,
      name: '新台币',
      country: 'TWD',
    },
    {
      rate: 0.5120,
      name: '韩国元',
      country: 'KRW',
    },
    {
      rate: 38.4400,
      name: '南非兰特',
      country: 'ZAR',
    },
  ],
};