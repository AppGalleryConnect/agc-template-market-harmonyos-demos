import * as agconnect from '@agconnect/common-server';
import { AGCAuth }  from '@agconnect/auth-server';

export class AuthWrapper {
  logger;
  auth;
  constructor(credential, logger) {
    this.logger = logger;
    try {
      // 初始化AGCClient
      logger.info("begin to init agcClient");
      let agcClient;
      try {
        agcClient = agconnect.AGCClient.getInstance();
      } catch {
        agconnect.AGCClient.initialize(credential);
        agcClient = agconnect.AGCClient.getInstance();
      }
      // 初始化AGConnectCloudDB实例
      logger.info("begin to init auth");
      this.auth = AGCAuth.getInstance();
    } catch (err) {
      logger.error("init AuthWrapper error: " + err);
    }
  }

  verifyToken(accessToken) {
    if (!this.auth) {
      this.logger.error("agcAuth is null, try re-initialize it");
    }

    this.logger.info("begin to verifyToken");

    let promise;

    try {
      promise = this.auth.verifyAccessToken(accessToken, false);
    } catch (err) {
      this.logger.error("verify token failed " + err);
    }

    return promise;
  }
};
