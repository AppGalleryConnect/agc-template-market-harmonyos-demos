// 依赖：npm i jsonwebtoken
export function getJWT() {
  const jwt = require("jsonwebtoken");
  const fs = require("fs");
  /*
  :todo
  */
  // 加载RSA私钥
  const PRIVATE_KEY =
    "-----BEGIN PRIVATE KEY-----\nxxxx\n-----END PRIVATE KEY-----\n";
  // 实际开发时请从服务账号密钥文件中读取sub_account
  const ISS = "xxxx";
  // 实际开发时请从服务账号密钥文件中读取key_id
  const KID = "xxxx";
  // 实际开发时请将公网地址存储在配置文件或数据库
  const AUD = "https://oauth-login.cloud.huawei.com/oauth2/v3/token";
  // 自定义Header
  const header = {
    alg: "PS256", // 建议使用PS256算法
    kid: KID,
    typ: "JWT", // 类型为JWT
  };
  // 创建JWT载荷
  const payload = {
    iss: ISS, // 实际开发时请从服务账号密钥文件中读取sub_account
    aud: AUD, // 实际开发时请将公网地址存储在配置文件或数据库
    iat: Math.floor(Date.now() / 1000),
    exp: Math.floor(Date.now() / 1000) + 3600,
  };
  // 签署JWT
  const token = jwt.sign(payload, PRIVATE_KEY, {
    algorithm: "PS256",
    header: header,
  });
  return token
}