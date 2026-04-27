import { AppStorageV2, UIContext, window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { AtomicServiceEnhancedWebController } from '@atomicservice/ascfapi';
import { UtilLog } from '@hw-agconnect/util-log';
import { CustomShareParams, GridRowColSetting, queryNewsArticle, RouterModule } from 'lib_foundation';
import { RouterMap } from '../common/Constant';
import { NewsArticle } from '../model/NewsDetail';

const TAG = '[NewsDetailViewModel]';

@ObservedV2
export class NewsDetailViewModel {
  @Trace newsArticle: NewsArticle = new NewsArticle();
  @Trace isLoading: boolean = false;
  @Trace breakpoint: string = '';
  @Trace richTextHeight: number = 300;
  @Trace positionX: number = 0;
  @Trace positionY: number = 0;
  @Trace startX: number = 0;
  @Trace startY: number = 0;
  @Trace startLeft: number = 0;
  @Trace startTop: number = 0;
  @Trace statusHeight: number = 0;
  @Trace bottomAvoidAreaHeight: number = 0;
  @Trace winWidth: number = 0;
  @Trace winHeight: number = 0;
  @Trace instance: CustomShareParams =
    AppStorageV2.connect(CustomShareParams, 'shareInstance', () => new CustomShareParams())!;
  public atomicWebController: AtomicServiceEnhancedWebController = new AtomicServiceEnhancedWebController();

  @Computed
  get formatDate() {
    const date = new Date(this.newsArticle.createTime)
    return `${date.getFullYear()}/${(date.getMonth() + 1).toString().padStart(2, '0')}/${date.getDate()
      .toString().padStart(2, '0')}`
  }

  init(uiContext: UIContext) {
    const paramList: string[] = RouterModule.getNavParam({ url: RouterMap.NEWS_DETAIL });
    if (paramList.length && paramList[paramList.length - 1] !== undefined) {
      const newsId = paramList[paramList.length - 1];
      queryNewsArticle(newsId).then((resp) => {
        this.newsArticle = resp as NewsArticle;
        this.isLoading = true;
        this.instance.pageName = 'NewsDetail';
        this.instance.newsId = this.newsArticle.id;
        this.instance.newsTitle = this.newsArticle.title;
      })
    }
    this.getWindowInfo(uiContext);
    this.listenSizeChange(uiContext);
  }

  reset() {
    // 设置分享参数
    this.instance.pageName = '';
    this.instance.newsId = '';
    this.instance.newsTitle = '';
  }

  readBody() {
    return this.newsArticle?.richContent ? this.extractText(this.newsArticle.richContent) :
      this.newsArticle.title
  }

  listenSizeChange(uiContext: UIContext) {
    try {
      let windowClass = (uiContext.getHostContext() as common.UIAbilityContext).windowStage.getMainWindowSync();
      windowClass.on('windowSizeChange', () => {
        this.getWindowInfo(uiContext);
      })
    } catch (err) {
      UtilLog.error(`listenSizeChange fail, error code: ${err.code}, error mesage: ${err.message}`);
    }
  }

  getWindowInfo(uiContext: UIContext) {
    let context = uiContext.getHostContext() as common.UIAbilityContext;
    try {
      let windowClass = (context as common.UIAbilityContext).windowStage.getMainWindowSync();
      this.statusHeight =
        uiContext.px2vp(windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height);
      this.bottomAvoidAreaHeight =
        uiContext.px2vp(windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
          .bottomRect
          .height);
      let windowProperties = windowClass.getWindowProperties();
      this.winWidth = uiContext.px2vp(windowProperties.windowRect.width);
      this.winHeight = uiContext.px2vp(windowProperties.windowRect.height);
      this.positionX = GridRowColSetting.getPageMargin(this.breakpoint);
      this.positionY = this.winHeight * 0.6;
    } catch (error) {
      UtilLog.error(TAG, 'getWindowInfo fail, error: ' + JSON.stringify(error));
    }
  }

  public extractText(html: string | undefined): string {
    let htmlContent = html ?? ''
    let text = htmlContent.replace(/<[^>]*>/g, '');
    // 再移除所有空格和换行符
    return text.replace(/[\s\n\r]/g, '');
  }

  public generateHtml(): string {
    const html = `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
        </head>
        <style>
            @media (0px<=width<320px) {
               .image-preview {
                   width: 100%;
                   border-radius: 16px;
                   max-height: 240px;
                   object-fit: cover;
               }
           }
           @media (320px<=width<600px) {
               .image-preview {
                   width: 100%;
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
           .post-image {
             display: block;
             margin-left: auto;
             margin-right: auto;
             height: auto;
           }
           .news-body {
              margin: 16px;
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
        <body id="body" class="news-body">
          <div class="title">${this.newsArticle.title ?? ''}</div>
          <div class="subtitle">${this.formatDate}  ${this.newsArticle.createDate ?? ''}</div>
          ${this.newsArticle.richContent}

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
}