/**
 * 跳转H5
 *
 * @param isLogin
 * @param title
 * @param h5Url
 */
export function goH5WithLogIn(isLogin: boolean, title: string, h5Url?: string, pageInfos?: NavPathStack): void {
  if (isLogin) {
    goH5Page(title, h5Url, pageInfos);
  } else {
    goLogInPage(pageInfos);
  }
}

/**
 * 跳转H5
 *
 * @param title 页面标题
 * @param h5Url H5页面URL
 */
function goH5Page(title: string, h5Url?: string, pageInfos?: NavPathStack): void {
  let params: Record<string, string | undefined> = {
    'url': h5Url,
    'title': title,
  }
  pageInfos?.pushPathByName('H5', params);
}

/**
 * 跳转登录页
 */
function goLogInPage(pageInfos?: NavPathStack) {
  pageInfos?.pushPathByName('Login', null)
};
