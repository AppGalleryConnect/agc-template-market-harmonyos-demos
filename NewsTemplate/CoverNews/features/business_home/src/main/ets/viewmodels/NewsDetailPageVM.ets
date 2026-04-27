import { AppStorageV2 } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { AtomicServiceEnhancedWebController } from '@atomicservice/ascfapi';
import { BaseViewModel, HttpServiceApi, NewsDetailRouter, NewsItem, TimeUtils } from 'lib_common';

@ObservedV2
export class NewsDetailPageVM extends BaseViewModel {
  @Trace newsInfo: NewsItem = new NewsItem();
  @Trace newsDetailRouter: NewsDetailRouter = AppStorageV2.connect(NewsDetailRouter, () => new NewsDetailRouter())!;
  public webController: webview.WebviewController = new webview.WebviewController();
  public atomicWebController: AtomicServiceEnhancedWebController = new AtomicServiceEnhancedWebController();
  @Trace initComplete: boolean = false;

  public async loadNewsDetail(newsId: string): Promise<void> {
    const news = await HttpServiceApi.queryNewsDetail(newsId);
    this.newsInfo = NewsItem.create(news);
    this.initComplete = true;
  }

  public setShareParams() {
    this.newsDetailRouter.newsId = this.newsInfo.id;
    this.newsDetailRouter.newsTitle = this.newsInfo.title;
    this.newsDetailRouter.newsSource = this.newsInfo.source;
  }

  public generateHtml(): string {
    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
           @media (0px<=width<600px) {
               .image-preview {
                   width: 100%;
                   border-radius: 16px;
                   max-height: 240px;
                   object-fit: cover;
               }
           }
           @media (600px<=width<840px) {
               .image-preview {
                   width: 80%;
                   border-radius: 16px;
                   max-height: 400px;
                   object-fit: cover;
               }
           }
           @media (840px<=width) {
               .image-preview {
                   width: 50%;
                   border-radius: 16px;
                   max-height: 450px;
                   object-fit: cover;
               }
           }
           p {
             line-height:35px;
           }
           .news-body {
               margin: 0 16px;
           }
           .image-box {
              display: flex;
              justify-content: center;
           }
           .title {
            font-style: Bold;
            font-size: 20px;
            font-weight: 700;
            line-height: 27px;
            letter-spacing: 0px;
            text-align: left;
           }
           .subtitle {
              color: rgba(0, 0, 0, 0.6);
              font-style: Regular;
              font-size: 14px;
              font-weight: 400;
              line-height: 19px;
              letter-spacing: 0px;
              text-align: left;
              margin: 8px 0 16px 0;
           }
        </style>
      </head>
      <body id="body" class="news-body">
        <div class="title">${this.newsInfo.title}</div>
        <div class="subtitle">${this.newsInfo.source}  ${TimeUtils.formatDate(this.newsInfo.time)}</div>
        ${this.newsInfo.content}

        <script>
          // 这里放的aseweb-sdk.umd.js
          (function(t,n){typeof exports=="object"&&typeof module<"u"?module.exports=n():typeof define=="function"&&define.amd?define(n):(t=typeof globalThis<"u"?globalThis:t||self,t.has=n())})(this,function(){"use strict";function t(e,j){if(!window||!window.atomicServiceProxy||!window.atomicServiceProxy.invokeJsApi){console.error("window.atomicServiceProxy is undefined");return}window.atomicServiceProxy.invokeJsApi(e,j)}function n(e={}){t("getPhoneNumber",e)}function i(e={}){t("getAvatarInfo",e)}function o(e={}){t("getInvoiceTitle",e)}function c(e={}){t("getDeliveryAddress",e)}function a(e={}){t("getServiceSubscription",e)}function r(e={}){t("router.pushUrl",e)}function u(e={}){t("router.replaceUrl",e)}function s(e={}){t("router.back",e)}function f(e={}){t("router.clear",e)}function p(e={}){t("navPathStack.pushPath",e)}function l(e={}){t("navPathStack.replacePath",e)}function d(e={}){t("navPathStack.pop",e)}function h(e={}){t("navPathStack.clear",e)}function v(e={}){t("asWeb.postMessage",e)}function P(e={}){t("asWeb.getEnv",e)}function g(e={}){t("asWeb.checkJsApi",e)}function k(e={}){t("cameraPicker.pick",e)}function w(e={}){t("photoViewPicker.select",e)}function S(e={}){t("filePreview.openPreview",e)}function b(e={}){t("request.uploadFile",e)}function I(e={}){t("request.downloadFile",e)}function m(e={}){t("getLocalImgData",e)}function y(e={}){t("connection.getNetworkType",e)}function q(e={}){t("location.getLocation",e)}function A(e={}){t("login",e)}function x(e){t("requestPayment",e)}function N(e){t("cashierPicker",e)}function M(e){t("requestContract",e)}function F(e){t("requestSubscribeMessage",e)}function T(e){t("createIap",e)}function V(e){t("finishIap",e)}function D(e){t("queryIap",e)}function E(e){t("queryIapProducts",e)}function J(e){t("queryIapEnvStatus",e)}function L(e){t("isIapSandboxActivated",e)}function R(e){t("showIapManagedSubscriptions",e)}function U(e){t("startRealNameVerification",e)}function W(e){t("startRealNameAuth",e)}function C(e){t("startFaceVerification",e)}return{router:{pushUrl:r,replaceUrl:u,back:s,clear:f},navPathStack:{pushPath:p,replacePath:l,pop:d,clear:h},asWeb:{postMessage:v,getEnv:P,checkJsApi:g},cameraPicker:{pick:k},photoViewPicker:{select:w},filePreview:{openPreview:S},request:{uploadFile:b,downloadFile:I},connection:{getNetworkType:y},location:{getLocation:q},login:A,requestPayment:x,cashierPicker:N,requestContract:M,requestSubscribeMessage:F,getLocalImgData:m,createIap:T,finishIap:V,queryIap:D,queryIapProducts:E,queryIapEnvStatus:J,isIapSandboxActivated:L,showIapManagedSubscriptions:R,startRealNameVerification:U,startRealNameAuth:W,startFaceVerification:C,getPhoneNumber:n,getAvatarInfo:i,getInvoiceTitle:o,getDeliveryAddress:c,getServiceSubscription:a}});
        </script>

        <script>
          has.asWeb.getEnv({
            callback: (err, res) => {
              console.log('success: ', res);
            }
          });
          function callNativePreview(srcList, index) {
            has.navPathStack.pushPath({
              name: 'ImagePreviewPage',
              param: { srcList, index },
              animated: true,
            });
          }
          let imageList = document.querySelectorAll(".image-preview")
          imageList.forEach((element,index) => {
              element.addEventListener('click', function () {
                  let srcList = [...imageList].map(value => {
                      return value.src
                  })
                  callNativePreview(srcList, index)
              })
          });
        </script>
      </body>
      </html>
    `;
    return encodeURIComponent(html);
  }

  public handleLikeClick(): void {
    if (this.newsInfo.isLiked) {
      HttpServiceApi.cancelLike(this.newsInfo.id);
    } else {
      HttpServiceApi.addLike(this.newsInfo.id);
    }
    this.newsInfo.isLiked = !this.newsInfo.isLiked;
  }
}