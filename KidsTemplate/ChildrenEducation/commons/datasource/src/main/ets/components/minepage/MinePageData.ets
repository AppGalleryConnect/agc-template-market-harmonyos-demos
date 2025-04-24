export interface CommonServiceModel {
  symbol : string
  serviceName: string,
  pageName: string,
}

/**
 * 精选列表首页
 */
export const mineCommonService: Array<CommonServiceModel> = [
  {
    symbol:'sys.symbol.doc_text',
    serviceName: 'app.string.view_history',
    pageName: 'ViewHistory',
  },
  {
    symbol:'sys.symbol.message_on_message',
    serviceName: 'app.string.contact_us',
    pageName: 'ContactUs',
  },
  {
    symbol:'sys.symbol.gearshape',
    serviceName: 'app.string.setting',
    pageName: 'SettingsPage',
  },
];