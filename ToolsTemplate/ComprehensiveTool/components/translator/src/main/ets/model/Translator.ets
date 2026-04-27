export interface XFConfig {
  hostUrl: string,
  host: string,
  appid: string,
  apiSecret: string,
  apiKey: string,
  uri: string,
}

export interface TransVar {
  text: string,
  from: string,
  to: string,
}

export interface Common {
  app_id: string
}

export interface Business {
  from: string,
  to: string,
}

export interface Data {
  text: string
}

export interface DigestObj {
  common: Common,
  business: Business,
  data: Data
}

export interface XFOptions {
  url: string,
  headers: Header,
  json: boolean,
  body: DigestObj,
}


